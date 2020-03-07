# Create the user-data for the Consul server
data "template_file" "consul_server" {
  count    = var.servers
  template = file("${path.module}/templates/consul.sh.tpl")

  vars = {
    consul_version = var.consul_version
    config = <<EOF
     "node_name": "opsschool-server-${count.index+1}",
     "server": true,
     "bootstrap_expect": 3,
     "ui": true,
     "client_addr": "0.0.0.0"
    EOF
  }
}

data "template_file" "consul_client" {
  count    = var.servers
  template = file("${path.module}/templates/consul.sh.tpl")

  vars = {
      consul_version = var.consul_version
      config = <<EOF
       "node_name": "opsschool-client-${count.index+1}",
       "enable_script_checks": true,
       "server": false
      EOF
  }
}

# Create the user-data for the Consul agent
data "template_cloudinit_config" "consul_client" {
  count    = var.clients
  part {
    content = element(data.template_file.consul_client.*.rendered, count.index)

  }
  part {
    content = file("${path.module}/templates/webserver.sh.tpl")
  }
}

# Get Subnet Id for the VPC
data "aws_subnet_ids" "subnets" {
  vpc_id = var.vpc_id
}

resource "tls_private_key" "consul_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "consul_key" {
  key_name   = "consul_key"
  public_key = "${tls_private_key.consul_key.public_key_openssh}"
}

# Create the Consul cluster
resource "aws_instance" "consul_server" {
  count = var.servers

  subnet_id = element(tolist(data.aws_subnet_ids.subnets.ids), count.index)

  ami           = lookup(var.ami, var.region)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.consul_key.key_name

  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = ["${aws_security_group.opsschool_consul.id}"]

  tags = {
    Name = "opsschool-server-${count.index+1}"
    consul_server = "true"
  }

  user_data = element(data.template_file.consul_server.*.rendered, count.index)
}

resource "aws_instance" "consul_client" {
  count = var.clients

  subnet_id = element(tolist(data.aws_subnet_ids.subnets.ids), count.index)

  ami           = lookup(var.ami, var.region)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.consul_key.key_name

  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = ["${aws_security_group.opsschool_consul.id}"]

  tags = {
    Name = "opsschool-client-${count.index+1}"
  }

  user_data = element(data.template_cloudinit_config.consul_client.*.rendered, count.index)
}

output "servers" {
  value = ["${aws_instance.consul_server.*.public_ip}"]
}

output "clients" {
  value = ["${aws_instance.consul_client.*.public_ip}"]
}
