resource "aws_security_group" "allow_ssh"{
   name = var.cluster_name_sg
    vpc_id = var.vpc_id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["85.250.123.195/32"]
    }

    ingress {
        from_port = 30036
        to_port = 30036
        protocol = "tcp"
        cidr_blocks = ["85.250.123.195/32"]
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

