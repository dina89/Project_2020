data "template_file" "elk" {
  template = file("${path.module}/templates/elk.sh.tpl")
}



resource "aws_instance" "elk" {
  count = 1
  ami           = lookup(var.ami, var.region)
  instance_type = "t2.micro"
  key_name      = var.key_name

  # iam_instance_profile   = aws_iam_instance_profile.grafana.name
  vpc_security_group_ids = ["${aws_security_group.elk.id}"]

  associate_public_ip_address = true
  subnet_id = var.subnet_id

  tags = {
    Name = "elk"
  }

  provisioner "file" {
    source      = "configs"
    destination = "/temp/"
  }

  user_data = data.template_file.elk.rendered
}


output "elk" {
  value = aws_instance.elk.*.public_ip
}

