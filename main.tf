# Create a new VPC
resource "aws_vpc" "test" {
  cidr_block = "10.0.0.0/16"
}

# Create public subnets in two different AZs
resource "aws_subnet" "public_1" {
  vpc_id     = aws_vpc.test.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public_2" {
  vpc_id     = aws_vpc.test.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# Create a private subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.test.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
}

# Create a security group to allow traffic on port 80
resource "aws_security_group" "allow_http" {
  name_prefix = "allow_http"
  vpc_id      = aws_vpc.test.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create two EC2 instances in the private subnet
resource "aws_instance" "test" {
  count         = 2
  ami           = "ami-0889a44b331db0194"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.allow_http.id]

  tags = {
    Name = "test-${count.index}"
  }
}

resource "aws_internet_gateway" "test" {
  vpc_id = aws_vpc.test.id
}


# Create a load balancer
resource "aws_lb" "test" {
  name               = "test"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  security_groups    = [aws_security_group.allow_http.id]

}

# Attach the instances to the load balancer target group
resource "aws_lb_target_group" "test" {
  name_prefix     = "test"
  port            = 80
  protocol        = "HTTP"
  vpc_id          = aws_vpc.test.id
  target_type     = "instance"
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
  }
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.test.arn
  count            = 2
  target_id        = aws_instance.test.*.id[count.index]
}

# Create an auto scaling group for the instances
resource "aws_launch_configuration" "test" {
  name_prefix = "test"
  image_id    = "ami-0889a44b331db0194"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_http.id]
}

resource "aws_autoscaling_group" "test" {
  name_prefix         = "test"
  launch_configuration = aws_launch_configuration.test.id
  vpc_zone_identifier = [aws_subnet.private.id]
  min_size            = 2
  max_size            = 4
  target_group_arns   = [aws_lb_target_group.test.arn]
}
