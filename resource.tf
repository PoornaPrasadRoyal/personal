resource "aws_launch_template" "mylaunch" {
  name                   = "terraform-template"
  image_id               = "ami-004d1eaf8eaa0107d"
  instance_type          = "t3.micro"
  key_name               = "new_KP"
  vpc_security_group_ids = [aws_security_group.mysg_1.id]

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name = local.instance_name
      }
    )
  }

  tags = merge(
    local.common_tags,
    {
      Name = "terraform-template"
    }
  )
}


resource "aws_elb" "myelb" {
  name   = "terraform-lb"

  subnets         = [aws_subnet.mysubnet1.id, aws_subnet.mysubnet2.id]
  security_groups = [aws_security_group.mysg_1.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  tags = {
    Name = "terraform-lb"
    env  = "dev"
  }
}


resource "aws_autoscaling_group" "myautoscaling" {
  name                = "terraform-asg"
  desired_capacity    = 2
  min_size            = 1
  max_size            = 4
  vpc_zone_identifier = [
    aws_subnet.mysubnet1.id,
    aws_subnet.mysubnet2.id
  ]

  launch_template {
    id      = aws_launch_template.mylaunch.id
    version = "$Latest"
  }

  load_balancers = [aws_elb.myelb.name]

  dynamic "tag" {
    for_each = merge(
      local.common_tags,
      {
        Name = local.instance_name
      }
    )

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
