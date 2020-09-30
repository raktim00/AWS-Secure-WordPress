provider "aws" {
    region = "ap-south-1"
    profile = "raktim"
}

# Generates RSA Keypair
resource "tls_private_key" "wpkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save Private key locally
resource "local_file" "localkey" {
  depends_on = [
    tls_private_key.wpkey,
  ]
  content  = tls_private_key.wpkey.private_key_pem
  filename = "wpkey.pem"
}

# Upload public key to create keypair on AWS
resource "aws_key_pair" "awskey" {
   depends_on = [
    tls_private_key.wpkey,
  ]
  key_name   = "wpkey"
  public_key = tls_private_key.wpkey.public_key_openssh
}

# Creating VPC for Wordpress

resource "aws_vpc" "wp_vpc" {
  cidr_block            = "192.168.0.0/16"
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tags = {
    "Name" = "wp-vpc" 
  }
}

# Creating Public Subnet for Wordpress

resource "aws_subnet" "wp_public" {
  depends_on = [
    aws_vpc.wp_vpc,
  ]
  cidr_block              = "192.168.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.wp_vpc.id
  tags = {
    "Name" = "wp-public"
  }
}

# Creating Private Subnet for Wordpress

resource "aws_subnet" "wp_private" {
  depends_on = [
    aws_vpc.wp_vpc,
  ]
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.wp_vpc.id
  tags = {
    "Name" = "wp-private"
  }
}

# Creating Internet Gateway for wordpress vpc

resource "aws_internet_gateway" "wp_ig" {
  depends_on = [
    aws_vpc.wp_vpc,
  ]
  vpc_id = aws_vpc.wp_vpc.id
  tags = {
    "Name" = "wp-ig"
  }
}

# Creating Routing Table for Internet Gateway

resource "aws_route_table" "wp_rt" {
  depends_on = [
    aws_internet_gateway.wp_ig,
  ]
  vpc_id = aws_vpc.wp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wp_ig.id
  }
  tags = {
    "Name" = "wp-rt"
  }
}

# Associating Routing Table with Public Subnet

resource "aws_route_table_association" "wp_rta" {
  depends_on = [
    aws_route_table.wp_rt,
  ]
  subnet_id      = aws_subnet.wp_public.id
  route_table_id = aws_route_table.wp_rt.id
}

# Security group for wordpress inside public subnet

resource "aws_security_group" "wordpress_sg" {
  depends_on = [
    aws_vpc.wp_vpc,
  ]
  name        = "wordpress-sg"
  description = "Connection between client and Wordpress"
  vpc_id      = aws_vpc.wp_vpc.id

  ingress {
    description = "httpd"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Security group for mysql database inside private subnet

resource "aws_security_group" "mysql_sg" {
  depends_on = [
    aws_vpc.wp_vpc,
  ]
  name        = "mysql-sg"
  description = "Conncetion between wordpress and mysql"
  vpc_id      = aws_vpc.wp_vpc.id

  ingress {
    description = "mysql"
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    security_groups = [aws_security_group.wordpress_sg.id]
  }
}

# EC2 Instance for Database

resource "aws_instance" "Database" {
    depends_on = [
    aws_security_group.mysql_sg,
  ]

  ami           = "ami-039bf3390a9a817e4"
  instance_type = "t2.micro"
  key_name      = "wpkey"
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  subnet_id       = aws_subnet.wp_private.id
  
  tags = {
    Name = "DBServer"
  }
}

# EC2 Instance for Wordpress

resource "aws_instance" "Wordpress" {
    depends_on = [
    aws_security_group.wordpress_sg,
  ]

  ami           = "ami-0e16b35621f2e65f3"
  instance_type = "t2.micro"
  key_name      = "wpkey"
  vpc_security_group_ids = [aws_security_group.wordpress_sg.id]
  subnet_id       = aws_subnet.wp_public.id
  
  tags = {
    Name = "WPServer"
  }
}
