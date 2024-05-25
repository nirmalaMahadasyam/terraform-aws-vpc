# for vpc variables........
variable "vpc_cidr" {                #2. cidr_block
    type = string
    default = "10.0.0.0/16"
    
  
}
variable "enable_dns_hostnames" {  #3. enable_dns_hostnames
    type = bool
    default = true
  
}
variable "vpc_tags" {  # for vpc tags
    type = map
    default = {}
  
}

# for tagging strategy
#######    Project variables  #################
variable "project_name"{
    type = string
# user to force to give projectname
}
variable "environment_name" {
    type = string
    default = "dev"
  
}
variable "common_tags" {
    type = map
  
}

##########   Internetgateway variables.............
variable "igw_tags" {
    type = map  
default = { }
}


##############  public subnet variables.............

variable "public_subnet_cidr" {
    type = list
  validation {
    condition = length(var.public_subnet_cidr) == 2
    error_message = "Please provide 2 valid public subnet CIDR"
  }
}

variable "public_subnet_cidr_tags" {
    type = map
  default = {}
}

############ private subnet variables ................

variable "private_subnet_cidr" {
    type = list
  validation {
    condition = length(var.private_subnet_cidr) == 2
    error_message = "Please provide 2 valid private subnet CIDR"
  }
}

variable "private_subnet_cidr_tags" {
    type = map
  default = {}
}

################## database  subnet variables...............
  
  variable "database_subnet_cidr" {
type = list
    validation {
      condition = length(var.database_subnet_cidr) == 2
      error_message = "please provide 2 valid database subnet CIDR"
    }
  }
  variable "database_subnet_cidr_tags" {
    type = map
   default = { } 
  }

  # nat gateway tags
  variable "nat_gateway_tags" {

    type = map
    default = {}
  
  }
  # route table tags... for public,private and database..................
  variable "route_table_public_tags" {

     type = map
    default = {}
  }
   variable "route_table_private_tags" {

     type = map
    default = {}
  }
   variable "route_table_database_tags" {

     type = map
    default = {}
  }
  # for peering connection with vpc
# peering is optional ..by default-->false.
variable "is_peering_required"{
    type = bool
    default = false
  }
  variable "accepter_vpcid" {    # accepter_vpcid--->""---->defaultvpc
    type = string
    default = ""
    
  }
  variable "vpc_peering_tags" {
    type = map
    default = {}
    
  }

  variable "database_subnet_group_tags" {
    type = map
    default = {}
}
