# Use the standalone vpc module to create a VPC
module "vpc" {
  source              = "../standalone_resources/vpc"
  cidr                = var.cidr
  prefix              = var.prefix
  infra_environment   = var.infra_environment
}

# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.public_subnets)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-${var.infra_environment}-public-${count.index}-subnet"
  }
}

# Create a private subnet
resource "aws_subnet" "private" {
  vpc_id            = module.vpc.vpc_id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  count             = length(var.private_subnets)

  tags = {
    Name = "${var.prefix}-${var.infra_environment}-private-${count.index}-subnet"
  }
}

# Create an Internet Gateway and attach it to the VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "${var.prefix}-${var.infra_environment}-internet-gateway"
  }
}

# Create a route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = module.vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.prefix}-${var.infra_environment}-public-route-table"
  }
}

# Associate the public subnet with the route table
resource "aws_route_table_association" "a" {
  count           = length(aws_subnet.public.*.id)
  subnet_id       = aws_subnet.public[count.index].id
  route_table_id  = aws_route_table.public.id
}