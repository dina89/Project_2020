data "template_file" "grafana" {
  template = file("${path.module}/templates/grafana.sh.tpl")
}



resource "aws_instance" "grafana" {
  count = 1
  ami           = lookup(var.ami, var.region)
  instance_type = "t2.micro"
  key_name      = var.key_name

  # iam_instance_profile   = aws_iam_instance_profile.grafana.name
  vpc_security_group_ids = ["${aws_security_group.grafana.id}"]

  associate_public_ip_address = true
  subnet_id = var.subnet_id

  tags = {
    Name = "grafana-server"
  }

  user_data = data.template_file.grafana.rendered
}


output "grafana" {
  value = aws_instance.grafana.*.public_ip
}

