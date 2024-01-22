# Connect Instances

resource "aws_connect_instance" "instance" {
  identity_management_type = var.identity_management_type
  inbound_calls_enabled    = true
  instance_alias           = var.instance_alias
  outbound_calls_enabled   = true
  contact_flow_logs_enabled = true
}

output "aws_connect_instance_id" {
  value = aws_connect_instance.instance.id
}

# Hours of Operation

resource "aws_connect_hours_of_operation" "hours_of_operation" {
  instance_id = aws_connect_instance.instance.id
  name        = "${var.common_name} Office Hours"
  description = "Demo Test Office Hours"
  time_zone   = "Africa/Johannesburg"
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

resource "aws_connect_queue" "elective_queue" {
  instance_id           = aws_connect_instance.instance.id
  name                  = "Elective Call Queue"
  description           = "Queue for Elective Call Presentation"
  hours_of_operation_id = aws_connect_hours_of_operation.hours_of_operation.id
  tags = {
    "Name" = "Elective Call Queue"
  }
}

output "aws_connect_elective_queue_id" {
  value = aws_connect_queue.elective_queue.id
}

# resource "aws_connect_queue" "automatic_queue" {
#   instance_id           = aws_connect_instance.instance.id
#   name                  = "Automatic Call Queue"
#   description           = "Queue for Automatic Call Presentation"
#   hours_of_operation_id = aws_connect_hours_of_operation.hours_of_operation.id
#   tags = {
#     "Name" = "Automatic Call Queue"
#   }
# }

# output "aws_connect_automatic_queue_id" {
#   value = aws_connect_queue.automatic_queue.id
# }

# Routing profile

resource "aws_connect_routing_profile" "elective_routing_profile" {
  instance_id             = aws_connect_instance.instance.id
  name                    = "Elective Call Presentation Profile"
  description             = "Elective Call Presentation Profile"
  default_outbound_queue_id = aws_connect_queue.elective_queue.id
  media_concurrencies {
    channel = "VOICE"
    concurrency = 1
  }
}

# resource "aws_connect_routing_profile" "automatic_routing_profile" {
#   instance_id             = aws_connect_instance.instance.id
#   name                    = "Automatic Call Presentation Profile"
#   description             = "Automatic Call Presentation Profile"
#   default_outbound_queue_id = aws_connect_queue.automatic_queue.id
#   media_concurrencies {
#     channel = "VOICE"
#     concurrency = 1
#   }
# }


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

# resource "aws_connect_user" "user" {
#   instance_id        = aws_connect_instance.instance.id
#   name               = "RLain"
#   password           = "${var.password}"
#   routing_profile_id = "${var.routing_profile_id}"
#   # routing_profile_id = aws_connect_routing_profile.elective_routing_profile.routing_profile_id
#   security_profile_ids = [
#     aws_connect_security_profile.security_profile.security_profile_id
#   ]
#   identity_info {
#     first_name = "Rebecca"
#     last_name  = "Lain"
#   }
#   phone_config {
#     after_contact_work_time_limit = 0
#     phone_type                    = "SOFT_PHONE"
#   }
# }


# Contact flow 
# The content of the contact flow should be in JSON format in Amazon Contact Flow language. 
# For more information, see Amazon Connect Flow language in the Amazon Connect Administrator Guide.

# resource "aws_connect_contact_flow" "my_contact_flow" {
#   instance_id = aws_connect_instance.instance.id
#   name        = "My Contact Flow"
#   type        = "CONTACT_FLOW"
#   content     = <<EOF
#   {
#   "Version": "1.0",
#   "StartAction": "1",
#   "Actions": [
#     {
#       "Identifier": "1",
#       "Type": "PlayPrompt",
#       "Parameters": {
#         "Text": "Thank you for calling. Your call is important to us."
#       },
#       "SuccessAction": "2",
#       "FailAction": "2"
#     },
#     {
#       "Identifier": "2",
#       "Type": "Disconnect"
#     }
#   ],
#   "Metadata": {
#     "Version": "1",
#     "Status": "Published",
#     "Name": "BasicContactFlow",
#     "Description": "A basic contact flow example"
#   }
# }
# EOF 
# }
# {
#   "Version": "1.0",
#   "StartAction": "1",
#   "Actions": [
#     {
#       "Identifier": "1",
#       "Type": "CheckContactAttributes",
#       "Parameters": {
#         "AttributeName": "agent_call_presentation",
#         "AttributeValue": "elective"
#       },
#       "SuccessAction": "2",
#       "FailAction": "3"
#     },
#     {
#       "Identifier": "2",
#       "Type": "Whisper",
#       "Parameters": {
#         "Text": "You have a call. Please accept to connect the customer."
#       },
#       "SuccessAction": "4"
#     },
#     {
#       "Identifier": "3",
#       "Type": "CheckContactAttributes",
#       "Parameters": {
#         "AttributeName": "transfer_to_queue",
#         "AttributeValue": "true"
#       },
#       "SuccessAction": "5",
#       "FailAction": "6"
#     },
#     {
#       "Identifier": "4",
#       "Type": "SetDisconnectFlow",
#       "Parameters": {
#         "ContactFlowId": "${var.disconnect_flow_id}"
#       }
#     },
#     {
#       "Identifier": "5",
#       "Type": "SetQueue",
#       "Parameters": {
#         "QueueId": "${aws_connect_queue.queue.id}"
#       }
#     },
#     {
#       "Identifier": "6",
#       "Type": "CheckContactAttributes",
#       "Parameters": {
#         "AttributeName": "transfer_to_agent_group",
#         "AttributeValue": "true"
#       },
#       "SuccessAction": "7",
#       "FailAction": "8"
#     },
#     {
#       "Identifier": "7",
#       "Type": "SetRoutingProfile",
#       "Parameters": {
#         "RoutingProfileId": "${var.routing_profile_id}"
#       }
#     },
#     {
#       "Identifier": "8",
#       "Type": "Disconnect"
#     }
#   ],
#   "Metadata": {
#     "Version": "1",
#     "Status": "Draft",
#     "Description": "My Contact Flow Description"
#   }
# }
# EOF
# }



# Lambda function association

# resource "aws_connect_lambda_function_association" "lambda_assoc" {
#   function_arn = var.lambda_function_arn
#   instance_id  = aws_connect_instance.instance.id
# }