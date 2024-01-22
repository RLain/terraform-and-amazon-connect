variable "instance_alias" {
  type = string
  description = "Alias name of the instance"
}
variable "identity_management_type" {
  type = string
  description = "Identity management type. Accepted Values: SAML , CONNECT_MANAGED, EXISTING_DIRECTORY"
}
variable "contact_flow_type" {
  type = string
  description = "Type of contact flow"
  default = "CONTACT_FLOW"
}
variable "common_name" {
  type =string
  description = "A common name of the amazon connect resources"
}
variable "lambda_function_arn" {
  description = "ARN of the lambda function for association with connect instance"
}

variable "routing_profile_id" {
  type = string
  description = "Routing profile UUID"
}

variable "disconnect_flow_id" {
  type = string
  description = "Disconnect flor UUID"
}

variable "password" {
  type = string
  description = "User password"
}

variable "access_key" {
  type = string
  description = "AWS Access Key"
}

variable "secret_key" {
  type = string
  description = "AWS Secret Key"
}

variable "custom_transfer_queues" {
  description = "List of custom transfer queues"
  type        = list(string)
  default     = []
}

variable "custom_transfer_agent_groups" {
  description = "List of custom transfer agent groups"
  type        = list(string)
  default     = []
}