
# =============================================================
# VPC
# =============================================================

resource "aws_vpc" "startuptech-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "startuptech-vpc"
  }
}

# =============================================================
# SUBNETS
# =============================================================

resource "aws_subnet" "startuptech-public-subnet-one" {
  vpc_id                  = aws_vpc.startuptech-vpc.id
  cidr_block              = var.public_subnet_one_cidr
  availability_zone       = var.availability_zone_one
  map_public_ip_on_launch = true

  tags = {
    Name = "startuptech-public-subnet-one"
  }
}

resource "aws_subnet" "startuptech-public-subnet-two" {
  vpc_id                  = aws_vpc.startuptech-vpc.id
  cidr_block              = var.public_subnet_two_cidr
  availability_zone       = var.availability_zone_two
  map_public_ip_on_launch = true

  tags = {
    Name = "startuptech-public-subnet-two"
  }
}

resource "aws_subnet" "startuptech-private-subnet-one" {
  vpc_id            = aws_vpc.startuptech-vpc.id
  cidr_block        = var.private_subnet_one_cidr
  availability_zone = var.availability_zone_one

  tags = {
    Name = "startuptech-private-subnet-one"
  }
}

resource "aws_subnet" "startuptech-private-subnet-two" {
  vpc_id            = aws_vpc.startuptech-vpc.id
  cidr_block        = var.private_subnet_two_cidr
  availability_zone = var.availability_zone_two

  tags = {
    Name = "startuptech-private-subnet-two"
  }
}

# =============================================================
# INTERNET GATEWAY
# =============================================================

resource "aws_internet_gateway" "startuptech-igw" {
  vpc_id = aws_vpc.startuptech-vpc.id

  tags = {
    Name = "startuptech-igw"
  }
}

# =============================================================
# ELASTIC IP + NAT GATEWAY
# =============================================================

resource "aws_eip" "startuptech-nat-eip" {
  domain = "vpc"

  tags = {
    Name = "startuptech-nat-eip"
  }
}

resource "aws_nat_gateway" "startuptech-nat-gateway" {
  allocation_id = aws_eip.startuptech-nat-eip.id
  subnet_id     = aws_subnet.startuptech-public-subnet-one.id

  tags = {
    Name = "startuptech-nat-gateway"
  }

  depends_on = [aws_internet_gateway.startuptech-igw]
}

# =============================================================
# ROUTE TABLES
# =============================================================

resource "aws_route_table" "startuptech-public-route-table" {
  vpc_id = aws_vpc.startuptech-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.startuptech-igw.id
  }

  tags = {
    Name = "startuptech-public-route-table"
  }
}

resource "aws_route_table" "startuptech-private-route-table" {
  vpc_id = aws_vpc.startuptech-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.startuptech-nat-gateway.id
  }

  tags = {
    Name = "startuptech-private-route-table"
  }
}

# =============================================================
# ROUTE TABLE ASSOCIATIONS
# =============================================================

resource "aws_route_table_association" "startuptech-public-subnet-one-association" {
  subnet_id      = aws_subnet.startuptech-public-subnet-one.id
  route_table_id = aws_route_table.startuptech-public-route-table.id
}

resource "aws_route_table_association" "startuptech-public-subnet-two-association" {
  subnet_id      = aws_subnet.startuptech-public-subnet-two.id
  route_table_id = aws_route_table.startuptech-public-route-table.id
}

resource "aws_route_table_association" "startuptech-private-subnet-one-association" {
  subnet_id      = aws_subnet.startuptech-private-subnet-one.id
  route_table_id = aws_route_table.startuptech-private-route-table.id
}

resource "aws_route_table_association" "startuptech-private-subnet-two-association" {
  subnet_id      = aws_subnet.startuptech-private-subnet-two.id
  route_table_id = aws_route_table.startuptech-private-route-table.id
}

# =============================================================
# AMI
# =============================================================

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# =============================================================
# SECURITY GROUPS
# =============================================================

# --- ALB Security Group ---
resource "aws_security_group" "startuptech-alb-sg" {
  name        = "startuptech-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.startuptech-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from internet"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "startuptech-alb-sg"
  }
}

# --- Bastion Security Group ---
resource "aws_security_group" "startuptech-bastion-sg" {
  name        = "startuptech-bastion-sg"
  description = "Security group for Bastion Host"
  vpc_id      = aws_vpc.startuptech-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
    description = "SSH from my IP only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "startuptech-bastion-sg"
  }
}

# --- Backend Security Group ---
resource "aws_security_group" "startuptech-backend-sg" {
  name        = "startuptech-backend-sg"
  description = "Security group for Backend"
  vpc_id      = aws_vpc.startuptech-vpc.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.startuptech-alb-sg.id]
    description     = "Allow traffic from ALB on port 8080"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.startuptech-bastion-sg.id]
    description     = "SSH from Bastion only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "startuptech-backend-sg"
  }
}

# --- MongoDB Security Group ---
resource "aws_security_group" "startuptech-mongodb-sg" {
  name        = "startuptech-mongodb-sg"
  description = "Security group for MongoDB"
  vpc_id      = aws_vpc.startuptech-vpc.id

  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.startuptech-backend-sg.id]
    description     = "MongoDB from Backend only"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.startuptech-bastion-sg.id]
    description     = "SSH from Bastion only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "startuptech-mongodb-sg"
  }
}

# =============================================================
# EC2 INSTANCES
# =============================================================

# --- Bastion Host (Public Subnet One) ---
resource "aws_instance" "startuptech-bastion" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.startuptech-public-subnet-one.id
  vpc_security_group_ids      = [aws_security_group.startuptech-bastion-sg.id]
  key_name                    = var.key_name

  tags = {
    Name = "startuptech-bastion"
  }
}

# --- Bastion Elastic IP (Static IP for consistent SSH access) ---
resource "aws_eip" "startuptech-bastion-eip" {
  instance = aws_instance.startuptech-bastion.id
  domain   = "vpc"

  tags = {
    Name = "startuptech-bastion-eip"
  }

  depends_on = [aws_internet_gateway.startuptech-igw]
}

# --- Backend Server (Private Subnet One) ---
resource "aws_instance" "startuptech-backend-server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.startuptech-private-subnet-one.id
  vpc_security_group_ids = [aws_security_group.startuptech-backend-sg.id]
  key_name               = var.key_name
  user_data              = file("user_data/backend.sh")

  tags = {
    Name = "startuptech-backend-server"
  }
}

# --- MongoDB Server (Private Subnet Two) ---
resource "aws_instance" "startuptech-mongodb-server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.startuptech-private-subnet-two.id
  vpc_security_group_ids = [aws_security_group.startuptech-mongodb-sg.id]
  key_name               = var.key_name
  user_data              = file("user_data/MongoDB.sh")

  tags = {
    Name = "startuptech-mongodb-server"
  }
}

# =============================================================
# APPLICATION LOAD BALANCER
# =============================================================

resource "aws_lb" "startuptech-alb" {
  name               = "startuptech-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.startuptech-alb-sg.id]
  subnets            = [aws_subnet.startuptech-public-subnet-one.id, aws_subnet.startuptech-public-subnet-two.id]

  enable_deletion_protection = false

  tags = {
    Name = "startuptech-alb"
  }
}

# --- Target Group (Backend on port 8080) ---
resource "aws_lb_target_group" "startuptech-backend-tg" {
  name     = "startuptech-backend-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.startuptech-vpc.id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  tags = {
    Name = "startuptech-backend-tg"
  }
}

# --- Register Backend Instance to Target Group ---
resource "aws_lb_target_group_attachment" "startuptech-backend-attachment" {
  target_group_arn = aws_lb_target_group.startuptech-backend-tg.arn
  target_id        = aws_instance.startuptech-backend-server.id
  port             = 8080
}

# --- HTTP Listener (Port 80 → Forward to Backend) ---
resource "aws_lb_listener" "startuptech-http-listener" {
  load_balancer_arn = aws_lb.startuptech-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.startuptech-backend-tg.arn
  }
}

