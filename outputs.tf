


# outputs.tf

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.web.public_dns
}

output "ec2_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.web.private_ip
}

output "ec2_security_group_id" {
  description = "Security group ID attached to the EC2 instance"
  value       = tolist(aws_instance.web.vpc_security_group_ids)
}

output "rds_endpoint" {
  description = "RDS connection endpoint"
  value       = aws_db_instance.mysql.endpoint
}
