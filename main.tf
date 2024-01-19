# Connect Instances

resource "aws_connect_instance" "instance" {
  identity_management_type = var.identity_management_type
  directory_id = var.directory_id
  inbound_calls_enabled    = true
  instance_alias           = var.instance_alias
  outbound_calls_enabled   = true
  contact_flow_logs_enabled = true
}

# Lambda function association

resource "aws_connect_lambda_function_association" "lambda_assoc" {
  function_arn = var.lambda_function_arn
  instance_id  = aws_connect_instance.instance.id
}

# Hours of Operation

resource "aws_connect_hours_of_operation" "hours_of_operation" {
  instance_id = aws_connect_instance.instance.id
  name        = "${var.common_name} Office Hours"
  description = "Demo Test Office Hours"
  time_zone   = "EST"
  config {
    day = "MONDAY"
    end_time {
      hours   = 23
      minutes = 8
    }
    start_time {
      hours   = 8
      minutes = 0
    }
  }
  config {
    day = "TUESDAY"
    end_time {
      hours   = 21
      minutes = 0
    }
    start_time {
      hours   = 9
      minutes = 0
    }
  }
 tags = {
    "Name" = "${var.common_name}"
  }
}

# Create a queue

resource "aws_connect_queue" "queue" {
  instance_id           = aws_connect_instance.instance.id
  name                  = "${var.common_name} Queue1"
  description           = "Test Queue for Terraform"
  hours_of_operation_id = aws_connect_hours_of_operation.hours_of_operation.hours_of_operation_id
tags = {
    "Name" = "${var.common_name} Test Queue",
  }
}

# Routing profile

resource "aws_connect_routing_profile" "routing_profile" {
  instance_id               = aws_connect_instance.instance.id
  name                      = var.common_name
  default_outbound_queue_id = aws_connect_queue.queue.queue_id
  description               = "${var.common_name} Routing Profile"
media_concurrencies {
    channel     = "VOICE"
    concurrency = 1
  }
queue_configs {
    channel  = "VOICE"
    delay    = 0
    priority = 1
    queue_id = aws_connect_queue.queue.queue_id
  }
tags = {
    "Name" = var.common_name,
  }
}

# Security Profile

resource "aws_connect_security_profile" "security_profile" {
  instance_id = aws_connect_instance.instance.id
  name        = var.common_name
  description = "${var.common_name} security profile"
permissions = [
    "BasicAgentAccess",
    "OutboundCallAccess",
  ]
tags = {
    "Name" = "${var.common_name}"
  }
}

# User

resource "aws_connect_user" "user" {
  instance_id        = aws_connect_instance.instance.id
  name               = "bob@test.com"
  password           = "Password123"
  routing_profile_id = aws_connect_routing_profile.routing_profile.routing_profile_id
security_profile_ids = [
    aws_connect_security_profile.security_profile.security_profile_id
  ]
identity_info {
    first_name = "Bob"
    last_name  = "Test"
  }
phone_config {
    after_contact_work_time_limit = 0
    phone_type                    = "SOFT_PHONE"
  }
}

# Contact flow 
# The content of the contact flow should be in JSON format in Amazon Contact Flow language. 
# For more information, see Amazon Connect Flow language in the Amazon Connect Administrator Guide.

resource "aws_connect_contact_flow" "demo_test" {
  instance_id  = aws_connect_instance.instance.id
  name         = var.common_name
  description  = "Test Contact Flow for Terraform"
  type         = var.contact_flow_type
  content     = <<JSON
{
    "Version": "2019-10-30",
    "StartAction": "4e2b5f43-8379-4b90-852b-930de11591de",
    "Metadata": {
      "entryPointPosition": {
        "x": 20,
        "y": 20
      },
      "snapToGrid": false,
      "ActionMetadata": {
        "ac3808f0-8313-483a-ae5f-47e4acb83a53": {
          "position": {
            "x": 806,
            "y": 194
          }
        },
        "4e2b5f43-8379-4b90-852b-930de11591de": {
          "position": {
            "x": 196,
            "y": 37
          },
          "useDynamic": false
        },
        "c2b9d7f7-36d3-4180-86aa-3f1957870e1a": {
          "position": {
            "x": 463,
            "y": 38.599998474121094
          },
          "dynamicMetadata": {},
          "useDynamic": false
        }
      }
    },
    "Actions": [
      {
        "Identifier": "ac3808f0-8313-483a-ae5f-47e4acb83a53",
        "Type": "DisconnectParticipant",
        "Parameters": {},
        "Transitions": {}
      },
      {
        "Identifier": "4e2b5f43-8379-4b90-852b-930de11591de",
        "Parameters": {
          "Text": "Hello!"
        },
        "Transitions": {
          "NextAction": "c2b9d7f7-36d3-4180-86aa-3f1957870e1a",
          "Errors": [
            {
              "NextAction": "ac3808f0-8313-483a-ae5f-47e4acb83a53",
              "ErrorType": "NoMatchingError"
            }
          ],
          "Conditions": []
        },
        "Type": "MessageParticipant"
      },
      {
        "Identifier": "c2b9d7f7-36d3-4180-86aa-3f1957870e1a",
        "Parameters": {
          "LambdaFunctionARN": "${var.lambda_function_arn}",
          "InvocationTimeLimitSeconds": "3"
        },
        "Transitions": {
          "NextAction": "ac3808f0-8313-483a-ae5f-47e4acb83a53",
          "Errors": [
            {
              "NextAction": "ac3808f0-8313-483a-ae5f-47e4acb83a53",
              "ErrorType": "NoMatchingError"
            }
          ],
          "Conditions": []
        },
        "Type": "InvokeLambdaFunction"
      }
    ]
  }
JSON
  tags = {
    "Name"        = "${var.common_name} Contact Flow",
    "MaintedBy" = "Terraform",
  }
}