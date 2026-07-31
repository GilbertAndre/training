variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix used for all resource names"
  type        = string
  default     = "my-app"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances (Amazon Linux 2 recommended)"
  type        = string
  # Latest Amazon Linux 2 AMI in us-east-1 — update per region
  default = "ami-0c02fb55956c7d316"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access (leave empty to disable)"
  type        = string
  default     = ""
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH into instances"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances in the ASG"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of EC2 instances in the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of EC2 instances in the ASG"
  type        = number
  default     = 4
}

variable "cpu_scale_out_threshold" {
  description = "CPU % above which a scale-out event is triggered"
  type        = number
  default     = 70
}

variable "cpu_scale_in_threshold" {
  description = "CPU % below which a scale-in event is triggered"
  type        = number
  default     = 30
}
