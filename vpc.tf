resource "aws_vpc" "myvpc" {
  tags = {
    Name = "terraform-vpc"
  }
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
}

resource "aws_subnet" "mysubnet1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "mysubnet2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "public-subnet-2"
  }
}


resource "aws_internet_gateway" "myig" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "terraform_igw"
  }
}


resource "aws_route_table" "myrt" {
  tags = {
    Name = "terraform_rt"
  }
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myig.id
  }
}



resource "aws_route_table_association" "mysubnet1-ass" {
  subnet_id      = aws_subnet.mysubnet1.id
  route_table_id = aws_route_table.myrt.id
}
resource "aws_route_table_association" "mysubnet2-ass" {
  subnet_id      = aws_subnet.mysubnet2.id
  route_table_id = aws_route_table.myrt.id
}

