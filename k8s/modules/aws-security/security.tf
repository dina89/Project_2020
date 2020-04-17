resource "aws_security_group" "allow_ssh"{
   name = var.cluster_name_sg
    vpc_id = var.vpc_id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = var.ingressCIDRblock
    }

    ingress {
        from_port = 30036
        to_port = 30036
        protocol = "tcp"
        cidr_blocks = var.ingressCIDRblock
    }

    ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = var.ingressCIDRblock
    description = "Allow consul UI access from the world"
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = var.ingressCIDRblock
    description = "Allow consul UI access from the world"
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = var.ingressCIDRblock
    description = "Allow consul UI access from the world"
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = var.ingressCIDRblock
    description = "Allow consul UI access from the world"
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = var.ingressCIDRblock
    description = "Allow consul UI access from the world"
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = var.ingressCIDRblock
    description = "Allow consul UI access from the world"
  }

  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = var.ingressCIDRblock
    description = "Allow consul UI access from the world"
  }

  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "udp"
    cidr_blocks = var.ingressCIDRblock
    description = "Allow consul UI access from the world"
  }

    ingress {
    from_port   = 8502
    to_port     = 8502
    protocol    = "tcp"
    cidr_blocks = var.ingressCIDRblock
    description = "Allow consul UI access from the world"
  }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "aws_ssh_id" {
    value = [aws_security_group.allow_ssh.id]
}

