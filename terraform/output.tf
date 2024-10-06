output "ecs_service_id" {
  description = "The ECS service ID"
  value       = aws_ecs_service.my_service.id
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS task definition"
  value       = aws_ecs_task_definition.my_task.arn
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.my_lb.dns_name
}

# Output the VPC ID
output "vpc_id" {
  description = "The ID of the VPC created"
  value       = aws_vpc.main_vpc.id
}
