resource "aws_vpc_peering_connection" "peering" {
    # peering is optional. so he likes to peer otherwise no peering bydefault---false--0
    # if count is using this resource should be consider as a list
    count = var.is_peering_required? 1 : 0
     vpc_id        = aws_vpc.main.id # requester....expense vpc
     peer_vpc_id   = var.accepter_vpcid == "" ? data.aws_vpc.default.id : var.accepter_vpcid.id    #accepter....default vpc
     auto_accept = var.accepter_vpcid == "" ? true : false # for different account/region...(send the req & approve)# for same account(we only approved)
     tags = merge(
    var.common_tags,
    var.vpc_peering_tags,
    {
    Name = "${local.resource_name}-peering" # eg: expense-dev-peering
  })

  }
  # for routes --->expensevpcpublic-----defaultvpccidr
  resource "aws_route" "public_routes_peering" {
    # count is  helps for resource is required then its created other wise it is not created.
    count = var.is_peering_required && var.accepter_vpcid == "" ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

resource "aws_route" "private_routes_peering" {
    # count is  helps for resource is required then its created other wise it is not created.
    count = var.is_peering_required && var.accepter_vpcid == "" ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

resource "aws_route" "database_routes_peering" {
    # count is  helps for resource is required then its created other wise it is not created.
    count = var.is_peering_required && var.accepter_vpcid == "" ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id # count is set, it can consider as a list peering[0]
}

# route ---->default_vpc to vpc_expense

resource "aws_route" "default_routes_peering" {
    # count is  helps for resource is required then its created other wise it is not created.
    count = var.is_peering_required && var.accepter_vpcid == "" ? 1 : 0
  route_table_id            = data.aws_route_table.main.id # default vpc route table
  destination_cidr_block    = var.vpc_cidr  
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id # count is set, it can consider as a list peering[0]
}