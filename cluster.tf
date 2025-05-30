# 1. ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "main"
}

# 2. Launch Template (recommended over Launch Configuration)
resource "aws_launch_template" "ecs" {
  name          = "ecs-launch-template-rebel-grease"
  # name_prefix   = "ecs-launch-template-"
  image_id      = "ami-0c1ac8a41498c1a9c" # Replace with your ECS-optimized AMI
  instance_type = "t3.micro"

  user_data = base64encode(<<EOF
#!/bin/bash
sudo yum update -y ecs-int
sudo systemctl restart docker && service docker restart
sudo start ecs
echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

# 3. Auto Scaling Group
resource "aws_autoscaling_group" "ecs" {
  name                = "ecs-asg"
  max_size            = 2
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = [aws_subnet.public_a.id, aws_subnet.public_b.id] # Replace with your subnet id(s)

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ecs-instance"
    propagate_at_launch = true
  }

  health_check_type         = "EC2"
  force_delete              = true
  wait_for_capacity_timeout = "0"
}

# 4. IAM Role for ECS Instances
resource "aws_iam_role" "ecs_instance" {
  name = "ecsInstanceRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_instance.name
}

# Attach IAM Instance Profile to Launch Template
resource "aws_launch_template" "ecs_profile" {
  name_prefix   = "ecs-launch-template-profile-"
  image_id      = aws_launch_template.ecs.image_id
  instance_type = aws_launch_template.ecs.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance.name
  }

  user_data = aws_launch_template.ecs.user_data

  lifecycle {
    create_before_destroy = true
  }
}
data "template_file" "user_data" {
  template = file("user_data.tpl")
}
# Note:
# - Replace "subnet-xxxxxxxx" with your actual subnet IDs (can provide multiple in a list).
# - Replace the AMI ID with the latest ECS-optimized AMI for your region.
# - Adjust the instance type, scaling parameters, and tags as needed.
# - Security Groups and further network settings are not included here for brevity.
