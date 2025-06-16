resource "aws_ecs_task_definition" "node-red" {
  family = "node-red"
  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "633087887197.dkr.ecr.eu-north-1.amazonaws.com/node-red:latest"
      cpu       = 10
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
  task_definition = aws_ecs_task_definition.node-red.arn
  desired_count   = 1
  iam_role        = "ecs-task-role"
  # depends_on      = [aws_iam_role_policy.foo]

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  #load_balancer {
  #  target_group_arn = aws_lb_target_group.foo.arn
  #  container_name   = "mongo"
  #  container_port   = 8080
  #}

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [eu-north-1a, eu-north-1b]"
  }
}
