output "availability_zone_0" {
  value = var.vpc_availability_zones[0]
}

output "availability_zone_1" {
  value = var.vpc_availability_zones[1]
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  value       = aws_subnet.public_subnet["subnet1"].id
}

output "private_subnet_id" {
  value       = aws_subnet.private_subnet.id
}

output "public_subnet_azs" {
  value = {
    for k, s in aws_subnet.public_subnet :
    k => s.availability_zone
  }
}

output "private_subnet_az" {
  value       = aws_subnet.private_subnet.availability_zone
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.id
}

output "route_table_id" {
  value       = aws_route_table.route_table.id
}

output "route_id" {
  value       = aws_route.route_igw.id
}

output "public_subnet_association_ids" {
  description = "Route Table Association IDs for Public Subnets"
  value = [
    aws_route_table_association.public_subnet_1.id,
    aws_route_table_association.public_subnet_2.id
  ]
}

output "public_subnet_ids" {
  description = "IDs of all public subnets"
  value = [
    aws_subnet.public_subnet["subnet1"].id,
    aws_subnet.public_subnet["subnet2"].id
  ]
}