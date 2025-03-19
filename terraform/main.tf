terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  access_key = var.akey
  secret_key = var.skey
}

resource "aws_vpc" "soo_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "soo_vpc"
  }
}

resource "aws_internet_gateway" "soo_igw" {
  vpc_id = aws_vpc.soo_vpc.id

  tags = {
    Name = "soo_vpc_igw"
  }
}

resource "aws_subnet" "subnet_az1" {
  vpc_id     = aws_vpc.soo_vpc.id
  cidr_block = var.subnet_az1_cidr 
    
  map_public_ip_on_launch = true  
  availability_zone = var.az1  
  tags = {
    Name = "soo_subnet_az1"
  }
}

resource "aws_subnet" "subnet_az2" {
  vpc_id     = aws_vpc.soo_vpc.id
  cidr_block = var.subnet_az2_cidr 

  map_public_ip_on_launch = true      
  availability_zone = var.az2
  tags = {
    Name = "soo_subnet_az2"
  }
}

# map_public_ip_on_launch, availability_zone

resource "aws_route_table" "soo_rt" {
  vpc_id = aws_vpc.soo_vpc.id

  route {
    cidr_block = var.out_all_traffic
    gateway_id = aws_internet_gateway.soo_igw.id
  }

  tags = {
    Name = "soo_rt"
  }
}

resource "aws_route_table_association" "rt_subnet1" {
  subnet_id      = aws_subnet.subnet_az1.id
  route_table_id = aws_route_table.soo_rt.id
}

resource "aws_route_table_association" "rt_subnet2" {
  subnet_id      = aws_subnet.subnet_az2.id
  route_table_id = aws_route_table.soo_rt.id
}

resource "aws_security_group" "sg_soo_alb" {
  name        = "sg_soo_alb"
  description = "As Load Balancer, receiving HTTP/HTTPS"
  vpc_id      = aws_vpc.soo_vpc.id

  tags = {
    Name = "sg_soo_alb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_in_http" {
  security_group_id = aws_security_group.sg_soo_alb.id
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "alb_in_https" {
  security_group_id = aws_security_group.sg_soo_alb.id
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "alb_out_traffic" {
  security_group_id = aws_security_group.sg_soo_alb.id
  cidr_ipv4         = var.out_all_traffic
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "sg_soo_web" {
  name        = "sg_soo_web"
  description = "As Web Server, Receiving HTTP/HTTPS/SSH"
  vpc_id      = aws_vpc.soo_vpc.id

  tags = {
    Name = "sg_soo_web"
  }
}

resource "aws_vpc_security_group_ingress_rule" "web_in_flask" {
  security_group_id = aws_security_group.sg_soo_web.id
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
}
resource "aws_vpc_security_group_ingress_rule" "web_in_ssh" {
  security_group_id = aws_security_group.sg_soo_web.id
  cidr_ipv4         = var.out_all_traffic
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "web_in_http" {
  security_group_id = aws_security_group.sg_soo_web.id
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "web_in_https" {
  security_group_id = aws_security_group.sg_soo_web.id
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "web_out_traffic" {
  security_group_id = aws_security_group.sg_soo_web.id
  cidr_ipv4         = var.out_all_traffic
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#resource "aws_key_pair" "soo_ssh" {
#  key_name   = "soo_ssh_key"    
#  public_key = var.ssh_key
#}


resource "aws_instance" "web_ec2" {
  ami           = data.aws_ami.soo_ec2_image.id
  instance_type = var.ec2_type
  vpc_security_group_ids = [aws_security_group.sg_soo_web.id]
  subnet_id = aws_subnet.subnet_az1.id
  #count = 1
  #element([aws_subnet.subnet_az1.id,aws_subnet.subnet_az2.id],count.index)
  tags = {
    Name = "soo_web_ec2"
    #"soo_web_ec2_${(count.index)+1}"
  }
  # key_name = aws_key_pair.soo_ssh.key_name
  # when increasing the number of server, use it!
}

# vpc_security_group_ids, key_name, subnet_id, count

resource "aws_s3_bucket" "soo_s3_bucket" {
  bucket = "soo-s3-bucket-net"
  tags = {
    Name        = "soo_s3_bucket"
  }
  force_destroy = true
}

resource "aws_s3_bucket_policy" "s3_static_policy" {
  bucket = aws_s3_bucket.soo_s3_bucket.id
  policy = data.aws_iam_policy_document.soo_s3_policy.json
}

# LOAD BALANCER SETTING


resource "aws_lb_target_group" "soo_alb_tg" {
  name     = "soo-alb-target-group-com"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.soo_vpc.id

  health_check{
    healthy_threshold = 3
    path = "/health"
    unhealthy_threshold = 5
    interval = 20           # healthcheck gap time[sec]
    timeout = 15            # no response time[sec]
    matcher = "200,301,302"
  }
  stickiness{
    type = "lb_cookie"
    cookie_duration = 86400     # 1 day
  }
}

resource "aws_lb_target_group_attachment" "ec2_target_attach" {
  target_group_arn = aws_lb_target_group.soo_alb_tg.arn
  target_id        = aws_instance.web_ec2.id
  port             = 80
}
# overall lb target group check

resource "aws_lb" "soo_alb" {
  name               = "soo-alb-com"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_soo_alb.id]
  subnets            = [aws_subnet.subnet_az1.id,aws_subnet.subnet_az2.id]

  #enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.soo_s3_bucket.id
    prefix  = "logs-soo-alb"         # which key will be applied  
    enabled = true
  }
  
  tags = {
    Environment = "production"
    Name = "soo-alb"
  }
}


# [HTTPS:ALB]
resource "aws_lb_listener" "https_to_alb" {
  load_balancer_arn = aws_lb.soo_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  #"ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.soo_alb_tg.arn
  }
}

# [HTTP:HTPS]
resource "aws_lb_listener" "http_to_https" {
  load_balancer_arn = aws_lb.soo_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      status_code = "HTTP_301"
      port        = "443"
      protocol    = "HTTPS"
      host        = "#{host}"
      path        = "/#{path}"
    }
  }
}

resource "aws_route53_record" "root_domain" {
  zone_id = data.aws_route53_zone.soo_dns.zone_id
  name    = "littledogtomsky.com"  # Root domain
  type    = "A"

  alias {
    name                   = aws_lb.soo_alb.dns_name
    zone_id                = aws_lb.soo_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_redirect" {
  zone_id = data.aws_route53_zone.soo_dns.zone_id
  name    = "www.littledogtomsky.com"
  type    = "CNAME"
  ttl     = 300
  records = ["littledogtomsky.com"]
}
