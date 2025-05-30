#!/bin/bash
sudo yum update -y ecs-int
sudo systemctl restart docker && service docker restart
sudo start ecs
echo ECS_CLUSTER=main >> /etc/ecs/ecs.config
