locals {
    resource_name = "${var.project_name}-${var.environment_name}" # this is expression or condition so we keep in locals 
  az_names = slice(data.aws_availability_zones.available.names,0,2) # slice(fet the availabilityanmes,startindex,exculdeindex)
  # we get only 2 values.
}