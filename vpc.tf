# step:1 create VPC                                         #1. vpc only one resourse should give "main"
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr                   #2. cidr_block="10.0.0.0/16"
  instance_tenancy = "default"
#   tags = {
#     Name = "main"
#   }
   enable_dns_hostnames = var.enable_dns_hostnames    # 3. enable_dns_host_name====>by default--->false.

tags =merge(
    var.common_tags,
    var.vpc_tags,{
        #Name = "${var.project_name}-${var.environment_name}"  #expense-Dev
        Name = local.resource_name
    }

)
 
}

#step2: create Internetgateway(Igw) and attached to vpc

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id # this code is for attach to VPC id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
        #Name = "${var.project_name}-${var.environment_name}"  #expense-Dev
        Name = local.resource_name
    }

  )
}

# step3: create subnets---2 public,2private,2 databases
#############  public subnet
resource "aws_subnet" "public" {
    #count = 2
  count = length(var.public_subnet_cidr)
  availability_zone = local.az_names[count.index] # select the availability zones
  map_public_ip_on_launch = true # public ip subnet we need. bydefault=false.
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr[count.index]

  tags = merge(
    var.common_tags,
    var.public_subnet_cidr_tags,
    {
    Name = "${local.resource_name}-${local.az_names[count.index]}"  # expense-dev-us-ease-1a
  })
}
# for private subnet.......... 
resource "aws_subnet" "private" {
    #count = 2
  count = length(var.private_subnet_cidr)
  availability_zone = local.az_names[count.index] # select the availability zones
  #map_public_ip_on_launch = true # public ip subnet we need. bydefault=false.
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr[count.index]

  tags = merge(
    var.common_tags,
    var.private_subnet_cidr_tags,
    {
    Name = "${local.resource_name}-${local.az_names[count.index]}"
  })
}

# for database subnet.......... 
resource "aws_subnet" "database" {
    #count = 2
  count = length(var.database_subnet_cidr)
  availability_zone = local.az_names[count.index] # select the availability zones
  #map_public_ip_on_launch = true # public ip subnet we need. bydefault=false.
   vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidr[count.index]

  tags = merge(
    var.common_tags,
    var.database_subnet_cidr_tags,
    {
    Name = "${local.resource_name}-${local.az_names[count.index]}" # firstname is public[0] and second name is public[1]
  })
}

# subnet database group---peering connections
resource "aws_db_subnet_group" "default" {
  name = "${local.resource_name}"
  subnet_ids = aws_subnet.database[*].id # subnet is list 

  tags = merge(
    var.common_tags,
    var.database_subnet_group_tags,
    {
        Name = "${local.resource_name}"
    }
  )
}

# for Elastic Ip in Terraform
resource "aws_eip" "eipnat" {
 # instance = aws_instance.web.id
  domain   = "vpc"
}

# for NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eipnat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.common_tags,
    var.nat_gateway_tags,
    {
    Name = "${local.resource_name}" # eg: expense-dev
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw] # explicit dependency
}
# for route table creation----for public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "10.0.1.0/24"
#     gateway_id = aws_internet_gateway.example.id
#   }

#   route {
#     ipv6_cidr_block        = "::/0"
#     egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
#   }

  tags = merge(
    var.common_tags,
    var.route_table_public_tags,
    {
    Name = "${local.resource_name}-public" # eg: expense-dev-public
  })
}

# for route table creation----for private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.route_table_private_tags,
    {
    Name = "${local.resource_name}-private" # eg: expense-dev
  })
}

# for route table creation----for database route table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.route_table_database_tags,
    {
    Name = "${local.resource_name}-database" # eg: expense-dev
  })
}
# adding routes to the public,private,database route tables
resource "aws_route" "public_routes" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
  # vpc_peering_connection_id = "pcx-45ff3dc1"
}
resource "aws_route" "private_routes_nat" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat.id
  # vpc_peering_connection_id = "pcx-45ff3dc1"
}
resource "aws_route" "database_routes_nat" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat.id
  # vpc_peering_connection_id = "pcx-45ff3dc1"
}
# associate this route table to the subnet
resource "aws_route_table_association" "public" {
    count = length(var.public_subnet_cidr) # 2 times
  subnet_id      = element(aws_subnet.public[*].id, count.index ) # total public so we get list in this list pick a first value and second valueby element(list,0)
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
    count = length(var.private_subnet_cidr) # 2 times
  subnet_id      = element(aws_subnet.private[*].id, count.index) # total public
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "database" {
    count = length(var.database_subnet_cidr) # 2 times
  subnet_id      = element(aws_subnet.database[*].id, count.index) # total public
  route_table_id = aws_route_table.database.id
}


