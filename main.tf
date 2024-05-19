provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.5.0"

  name                 = "ecs-vpc"
  cidr                 = var.vpc_cidr
  azs                  = ["${var.region}a", "${var.region}b"]
  private_subnets      = [var.private_subnet1_cidr, var.private_subnet2_cidr]
  public_subnets       = [var.public_subnet1_cidr, var.public_subnet2_cidr]
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "ecs-vpc"
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "7.0.0"

  name               = "ecs-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  http_tcp_listeners = [
    {
      port     = 80
      protocol = "HTTP"
    }
  ]

  https_listeners = [
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "your-acm-certificate-arn"
    }
  ]

  target_groups = [
    {
      name_prefix      = "ecs-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
      health_check = {
        path                = "/"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 5
        unhealthy_threshold = 2
        matcher             = "200"
      }
    }
  ]

  tags = {
    Name = "ecs-alb"
  }
}

resource "aws_security_group" "alb_sg" {
  name_prefix = "ecs-alb-sg-"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-alb-sg"
  }
}

module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "3.0.0"

  name               = "ecs-cluster"
  cluster_name       = "ecs-cluster"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.private_subnets
  capacity_providers = ["EC2"]

  tags = {
    Name = "ecs-cluster"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ecs_task_execution_role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "your-ecr-repo-uri:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "ecs-service"
  cluster         = module.ecs_cluster.ecs_cluster_id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "EC2"
  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = false
  }
}

resource "aws_security_group" "ecs_service_sg" {
  name_prefix = "ecs-service-sg-"
  description = "Security group for ECS service"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-service-sg"
  }
}

resource "aws_waf_web_acl" "web_acl" {
  name        = "ecs-waf"
  metric_name = "ecsWaf"

  default_action {
    block {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  tags = {
    Name = "ecs-waf"
  }
}
