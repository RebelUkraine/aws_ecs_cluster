resource "aws_ecs_task_definition" "node-red" {
  family = "node-red-task"
  container_definitions = jsonencode([
    {
      name      = "node-red"
      image     = "633087887197.dkr.ecr.eu-north-1.amazonaws.com/node-red:latest"
      network_mode          = "awsvpc"
      requires_compatibilities = ["FARGATE"]
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 1880
          hostPort      = 1880
        }
      ]
    }])
}

resource "aws_ecs_service" "node-red" {
  name            = "node-red"
  cluster         = aws_ecs_cluster.main.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.node-red.arn
  desired_count   = 1
  iam_role        = "ecs-task-role"
  # depends_on      = [aws_iam_role_policy.foo]

  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.node-red.arn
    container_name   = "node-red"
    container_port   = 1880
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [eu-north-1a, eu-north-1b]"
  }
}

resource "aws_lb" "node-red" {
  name               = "node-red"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.node-red.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  enable_deletion_protection = false

  #access_logs {
  #  bucket  = aws_s3_bucket.lb_logs.id
  #  prefix  = "test-lb"
  #  enabled = true
  #}

}

resource "aws_lb_target_group" "node-red" {
  name     = "node-red"
  target_type = "alb"
  port     = 1880
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_security_group" "node-red" {
  name   = "node-red"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ipv4" {
  security_group_id = aws_security_group.node-red.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = 1880
  ip_protocol       = "tcp"
  to_port           = 1880
}
