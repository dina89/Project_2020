resource "tls_private_key" "bastion_key"{
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "bastion_key"{
  key_name = "bastion_key"
  public_key = tls_private_key.bastion_key.public_key_openssh
}

resource "local_file" "bastion_key" {
  sensitive_content  = tls_private_key.bastion_key.private_key_pem
  filename           = "bastion.pem"
}

resource "tls_private_key" "consul_key"{
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "consul_key"{
  key_name = "consul_key"
  public_key = tls_private_key.consul_key.public_key_openssh
}

resource "local_file" "consul_key" {
  sensitive_content  = tls_private_key.consul_key.private_key_pem
  filename           = "consul.pem"
}

resource "tls_private_key" "grafana_key"{
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "grafana_key"{
  key_name = "grafana_key"
  public_key = tls_private_key.grafana_key.public_key_openssh
}

resource "local_file" "grafana_key" {
  sensitive_content  = tls_private_key.grafana_key.private_key_pem
  filename           = "grafana.pem"
}

resource "tls_private_key" "elk_key"{
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "elk_key"{
  key_name = "elk_key"
  public_key = tls_private_key.elk_key.public_key_openssh
}

resource "local_file" "elk_key" {
  sensitive_content  = tls_private_key.elk_key.private_key_pem
  filename           = "elk.pem"
}