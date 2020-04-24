provider "aws" {
  region = var.region
}

resource "aws_security_group" "elk" {
  name        = "elk"
  description = "Allow ssh & vpc inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ingressCIDRblock
    description = "Allow ssh from the vpc"
  }

  ingress {
    from_port   = 5601 
    to_port     = 5601 
    protocol    = "tcp"
    cidr_blocks = var.ingressCIDRblock
    description = "Allow kibana from the vpc"
  }

    ingress {
    from_port   = 9200 
    to_port     = 9200 
    protocol    = "tcp"
    cidr_blocks = var.ingressCIDRblock
    description = "Allow kibana from the vpc"
  }

   egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow all outside security group"
  }
}

# # Create an IAM role for the auto-join
# resource "aws_iam_role" "grafana" {
#   name               = "opsschool-grafana"
#   assume_role_policy = file("${path.module}/templates/policies/assume-role.json")
# }

# # Create the policy
# resource "aws_iam_policy" "grafana" {
#   name        = "opsschool-grafana"
#   description = "Allows grafana access"
#   policy      = file("${path.module}/templates/policies/describe-instances.json")
# }

# # Attach the policy
# resource "aws_iam_policy_attachment" "grafana" {
#   name       = "opsschool-grafana"
#   roles      = ["${aws_iam_role.grafana.name}"]
#   policy_arn = aws_iam_policy.grafana.arn
# }

# # Create the instance profile
# resource "aws_iam_instance_profile" "grafana" {
#   name  = "opsschool-grafana"
#   role = aws_iam_role.grafana.name
# }
