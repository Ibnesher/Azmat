terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-east-1"  # change to your preferred region
}

# -----------------------------
# VPC
# -----------------------------
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MyVPC"
  }
}

# -----------------------------
# Subnet
# -----------------------------
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "MySubnet"
  }
}

# -----------------------------
# Internet Gateway
# -----------------------------
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyIGW"
  }
}

# -----------------------------
# Route Table
# -----------------------------
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyRouteTable"
  }
}

# Route for Internet access
resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.my_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "my_subnet_assoc" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_rt.id
}

# -----------------------------
# Security Group
# -----------------------------
resource "aws_security_group" "my_sg" {
  name        = "MySG"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySG"
  }
}

# -----------------------------
# EC2 Instance
# -----------------------------
resource "aws_instance" "my_ec2" {
  ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI for us-east-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "MyEC2"
  }
}

# -----------------------------
# S3 Bucket
# -----------------------------
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-1234567"  # bucket name must be globally unique
  tags = {
    Name = "MyBucket"
  }
}

resource "aws_s3_bucket_acl" "my_bucket_acl" {
  bucket = aws_s3_bucket.my_bucket.id
  acl    = "private"
}
