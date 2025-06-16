resource "aws_ecs_task_definition" "node-red" {
  family = "node-red"
  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "service-first"
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
