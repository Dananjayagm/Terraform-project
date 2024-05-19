resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "ecs-vpc"
  }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet1_cidr
  availability_zone = "${var.region}a"

  tags = {
    Name = "ecs-private-subnet-1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet2_cidr
  availability_zone = "${var.region}b"

  tags = {
    Name = "ecs-private-subnet-2"
  }
}

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet1_cidr
  availability_zone = "${var.region}a"

  tags = {
    Name = "ecs-public-subnet-1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet2_cidr
  availability_zone = "${var.region}b"

  tags = {
    Name = "ecs-public-subnet-2"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ecs-private-rt"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ecs-public-rt"
  }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ecs-igw"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ecs-private-nacl"
  }
}

resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ecs-public-nacl"
  }
}
