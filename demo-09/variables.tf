variable "aws_profile" {
  description = "Local AWS profile to use for AWS credentials"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "AWS region to build in"
  type        = string
}

variable "owner_email" {
  description = "Email address to tag resources with"
  type        = string

  validation {
    condition     = can(regex("@", var.owner_email))
    error_message = "The owner_email must contain an at sign."
  }
}

variable "project_tag" {
  description = "Project name to tag resources with for grouping"
  type        = string
  default     = "IntroToTerraformAndAnsible"
}

variable "key_name" {
  description = "Name of an already-installed AWS keypair"
  type        = string
}

variable "private_key_file" {
  description = "Path to the private key of the already-installed AWS keypair"
  type        = string
}
