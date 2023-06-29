variable "VPC_NAME" {
  default = "platform"
}

variable "AWS_REGION" {
  default     = "af-south-1"
  description = "region to create the resources in"
}

variable "ACCOUNT" {
  default     = "default"
  description = "the account to use as in ~/.aws/credentials file - referenced in providers.tf"
}
