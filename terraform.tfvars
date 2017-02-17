#--------------------------------------------------------------
# Define Variables for Development Environment
#--------------------------------------------------------------

#--------------------------------------------------------------
# General
#--------------------------------------------------------------

region             = "us-east-1"
environment        = "platform9"
availability_zones = "us-east-1b"

#--------------------------------------------------------------
# Network
#--------------------------------------------------------------

vpc_cidr        = "10.0.0.0/16"
private_subnets = "10.0.1.0/24"
public_subnets  = "10.0.2.0/24"

#--------------------------------------------------------------
# Compute
#--------------------------------------------------------------

# Autoscaling Groups
# Kube-Master
kube_master_min           = "1"
kube_master_max           = "5"
kube_master_desired       = "1"
kube_master_instance_type = "m3.medium"

# Kube-Node
kube_node_min             = "2"
kube_node_max             = "30"
kube_node_desired         = "2"
kube_node_instance_type   = "m3.medium"

# Launch Configuration
p9_instance_ami           = "ami-7f28c369"
p9_instance_profile       = "iam-p9-instance"
p9_instance_key_name      = "p9"

# Bastion
bastion_instance_type = "t2.micro"

