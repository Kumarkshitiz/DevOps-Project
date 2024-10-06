provider "aws" {
  region = var.region  # Use variable for flexibility
}

resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "${var.application_name}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "main_subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.subnet_1_cidr
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.application_name}-subnet-1"
    Environment = var.environment
  }
}

resource "aws_subnet" "main_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.subnet_2_cidr
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.application_name}-subnet-2"
    Environment = var.environment
  }
}

resource "aws_security_group" "allow_all" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 5000  # Change to allow only necessary traffic
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change this in production to specific IP ranges
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.application_name}-sg"
    Environment = var.environment
  }
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "${var.application_name}-ecs-cluster"

  tags = {
    Name        = "${var.application_name}-ecs-cluster"
    Environment = var.environment
  }
}

resource "aws_ecs_task_definition" "my_task" {
  family                   = "${var.application_name}-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = <<DEFINITION
[
  {
    "name": "flask-app",
    "image": "${var.container_image}",
    "portMappings": [
      {
        "containerPort": 5000,
        "hostPort": 5000
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "my_service" {
  name            = "${var.application_name}-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = var.desired_count  # Use variable for desired count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.main_subnet_1.id, aws_subnet.main_subnet_2.id]
    security_groups  = [aws_security_group.allow_all.id]
    assign_public_ip = true
  }

  tags = {
    Name        = "${var.application_name}-service"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name        = "${var.application_name}-igw"
    Environment = var.environment
  }
}

resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name        = "${var.application_name}-route-table"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "main_association" {
  subnet_id      = aws_subnet.main_subnet_1.id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_route_table_association" "main_association_2" {
  subnet_id      = aws_subnet.main_subnet_2.id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_lb" "my_lb" {
  name               = "${var.application_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_all.id]
  subnets            = [aws_subnet.main_subnet_1.id, aws_subnet.main_subnet_2.id]

  tags = {
    Name        = "${var.application_name}-lb"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_target_group" "app_tg" {
  name        = "${var.application_name}-tg"
  port        = var.container_port  # Use variable for container port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main_vpc.id
  target_type = "ip"

  tags = {
    Name        = "${var.application_name}-tg"
    Environment = var.environment
  }
}

# Output for Load Balancer Public DNS
output "lb_public_dns" {
  value       = aws_lb.my_lb.dns_name
  description = "The public DNS name of the load balancer."
}