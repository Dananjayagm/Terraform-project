resource "aws_launch_configuration" "ecs_launch_configuration" {
  name          = "ecs-launch-configuration"
  image_id      = "ami-0c55b159cbfafe1f0" # Use the latest ECS-optimized AMI
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name
  security_groups      = [aws_security_group.ecs_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name} >> /etc/ecs/ecs.config
              EOF
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 1
  max_size             = 2
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.ec2_private_1.id, aws_subnet.ec2_private_2.id]
  launch_configuration = aws_launch_configuration.ecs_launch_configuration.name
  health_check_type    = "EC2"
}
