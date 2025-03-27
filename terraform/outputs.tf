# RESOURCE INFO

output "vpc_name" {
    value = aws_vpc.soo_vpc.tags_all
    description = "Current VPC Name"
}

output "vpc_cidr_block" {
    value = var.vpc_cidr_block
    description = "CIDR Block for VPC"
}

output "igw_id" {
    value = aws_internet_gateway.soo_igw.id
    description = "Internet Gateway of VPC"
}
    
output "subnet_AZ1" {
    value = aws_subnet.subnet_az1.id
    description = "Subnet ID in Availability Zone 1"
}    

output "subnet_AZ2" {
    value = aws_subnet.subnet_az2.id
    description = "Subnet ID in Availability Zone 2"
}   

output "alb_sg" {
    value = {
        ID = aws_security_group.sg_soo_alb.id 
        ARN = aws_security_group.sg_soo_alb.arn}
    description = "Security Group: Load Balancer" 
}

output "web_sg" {
    value = {
        ID = aws_security_group.sg_soo_web.id 
        ARN = aws_security_group.sg_soo_web.arn}
    description = "Security Group: Web Application"
}

output "ec2_spec" {
    value = {
            ID = aws_instance.web_ec2.id
            STATE = aws_instance.web_ec2.instance_state
            DNS = aws_instance.web_ec2.public_dns
            IP_Address = aws_instance.web_ec2.public_ip}

    description = "EC2 Specification for VPC"
}

output "s3_spec" {
    value = {
        BUCKET_Name = data.aws_s3_bucket.soo_s3_bucket.bucket_domain_name
        REGION = data.aws_s3_bucket.soo_s3_bucket.region
    }
    description = "S3 Brief Specification for VPC"
}

output "alb_spec" {
    value = {
        ID = aws_lb.soo_alb.id
        DNS = aws_lb.soo_alb.dns_name
    }
    description = "Load Balancer for VPC"
}
output "dns_record" {
    value = aws_route53_record.root_domain.name
    description = "DNS record"
}

output "eip_ip" {
    value = aws_eip.ec2_eip.public_ip
    description = "EC2 EIP'S Public IP:"
}