
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.startuptech-vpc.id
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.startuptech-alb.dns_name
}

output "bastion_public_ip" {
  description = "The Elastic IP of the Bastion Host"
  value       = aws_eip.startuptech-bastion-eip.public_ip
}

output "backend_private_ip" {
  description = "The private IP of the Backend Server"
  value       = aws_instance.startuptech-backend-server.private_ip
}

output "mongodb_private_ip" {
  description = "The private IP of the MongoDB Server"
  value       = aws_instance.startuptech-mongodb-server.private_ip
}

