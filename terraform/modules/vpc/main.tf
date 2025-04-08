resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnet" {
  for_each = {
    subnet1 = {
      cidr = var.vpc_public_subnets[0]
      az   = var.vpc_availability_zones[0]
    }
    subnet2 = {
      cidr = var.vpc_public_subnets[1]
      az   = var.vpc_availability_zones[1]
    }
  }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet_${each.key}"
    Type = "public"
    "kubernetes.io/cluster/kubernetes" = "shared" 
    "kubernetes.io/role/elb"                    = "1"   
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.vpc_private_subnets, 0)
  availability_zone = element(var.vpc_availability_zones, 1)

  tags = {
    Name = "subnet_private_main"
    Type = "private"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route" "route_igw" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.public_subnet["subnet1"].id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.public_subnet["subnet2"].id
  route_table_id = aws_route_table.route_table.id
}