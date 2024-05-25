# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
 # name = "us-east-1"
}

# for vpn peering: default vpn data source
data "aws_vpc" "default" {
  default = true
}
# default route to connect main route table
# search--->find the default route table of a specific subnet
data "aws_route_table" "main" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name = "association.main"
    values = ["true"]
  }
}
