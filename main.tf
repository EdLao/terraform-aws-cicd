module "network" {
  source = "./modules/network"


  vpc_cidr = "10.40.0.0/16"
}


resource "aws_subnet" "public" {
  vpc_id                  = module.network.vpc_id
  cidr_block              = "10.40.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true


  tags = {
    Name = "cicd-public-subnet"
  }
}



resource "aws_subnet" "private" {
  vpc_id                  = module.network.vpc_id
  cidr_block              = "10.40.2.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = false


  tags = {
    Name = "cicd-private-subnet"
  }
}



resource "aws_internet_gateway" "main" {
  vpc_id = module.network.vpc_id


  tags = {
    Name = "cicd-igw"
  }
}



resource "aws_route_table" "public" {
  vpc_id = module.network.vpc_id


  tags = {
    Name = "cicd-public-rt"
  }
}



resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}


resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}



resource "aws_route_table" "private" {
  vpc_id = module.network.vpc_id


  tags = {
    Name = "cicd-private-rt"
  }
}


resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}



resource "aws_security_group" "web" {
  name        = "cicd-web-sg"
  description = "Allow HTTP traffic"
  vpc_id      = module.network.vpc_id

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
    Name = "cicd-web-sg"
  }
}



data "aws_ami" "ubuntu" {
  most_recent = true


  filter {
    name = "name"


    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }


  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }


  owners = ["099720109477"]
}



resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]


  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y  nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>Deployed automatically with Terraform</h1>" > /var/www/html/index.html
  EOF


  tags = {
    Name        = "cicd-web-server"
    Environment = "Production"
  }
}



resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "cicd-web-high-cpu"
  comparison_operator = "GreaterThanThreshold"


  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = 300
  statistic          = "Average"
  threshold          = 80
  evaluation_periods = 2

  dimensions = {
    InstanceId = aws_instance.web.id
  }
}
