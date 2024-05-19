resource "aws_route_table" "ec2_private_rt" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "elb_public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "ec2_private_1" {
  subnet_id      = aws_subnet.ec2_private_1.id
  route_table_id = aws_route_table.ec2_private_rt.id
}

resource "aws_route_table_association" "ec2_private_2" {
  subnet_id      = aws_subnet.ec2_private_2.id
  route_table_id = aws_route_table.ec2_private_rt.id
}

resource "aws_route_table_association" "elb_public_1" {
  subnet_id      = aws_subnet.elb_public_1.id
  route_table_id = aws_route_table.elb_public_rt.id
}

resource "aws_route_table_association" "elb_public_2" {
  subnet_id      = aws_subnet.elb_public_2.id
  route_table_id = aws_route_table.elb_public_rt.id
}
