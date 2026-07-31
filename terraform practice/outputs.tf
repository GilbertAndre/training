output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.this.name
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.this.id
}

output "security_group_id" {
  description = "ID of the Security Group attached to instances"
  value       = aws_security_group.asg_sg.id
}

output "vpc_id" {
  description = "VPC used for the deployment"
  value       = data.aws_vpc.default.id
}

output "subnet_ids" {
  description = "Subnets used by the ASG"
  value       = data.aws_subnets.default.ids
}
