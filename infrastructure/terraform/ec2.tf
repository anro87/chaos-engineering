###################################
# Create Bastion Host
###################################
resource "aws_instance" "cecs_bastion_host" {
     ami = "ami-0dcc0ebde7b2e00db"
     instance_type = "t2.nano"
     key_name      = "${aws_key_pair.bastion_keypair.key_name}"
     subnet_id     = aws_subnet.public_subnet_cecs.id
     associate_public_ip_address = "true"
     user_data = file("${path.module}/ec2_appserver_startup.sh")
 }

resource "tls_private_key" "bastion_privatekey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_keypair" {
  key_name   = "bastion_ec2key"
  public_key = "${tls_private_key.bastion_privatekey.public_key_openssh}"
}

resource "local_file" "bastion_ec2key" {
  content  = "${tls_private_key.bastion_privatekey.private_key_pem}"
  filename = "keys/${aws_key_pair.bastion_keypair.key_name}.pem"
}

resource "aws_eip_association" "bastion_host_eip_assoc" {
  instance_id   = aws_instance.cecs_bastion_host.id
  allocation_id = aws_eip.bastion_host_ip.id
}

resource "aws_eip" "bastion_host_ip" {
  vpc = true
}

resource "aws_network_interface_sg_attachment" "bastion_sg_attachment" {
  security_group_id    = "${aws_security_group.cecs_sg.id}"
  network_interface_id = "${aws_instance.cecs_bastion_host.primary_network_interface_id}"
}

###################################
# Create server for hosting app
###################################

resource "aws_instance" "app_server" {
     ami = "ami-0dcc0ebde7b2e00db"
     instance_type = "t2.nano"
     key_name      = "${aws_key_pair.appserver_keypair.key_name}"
     associate_public_ip_address = "false"
     subnet_id = aws_subnet.private_subnet_cecs.id
     user_data = file("${path.module}/ec2_appserver_startup.sh")
}

resource "tls_private_key" "appserver_privatekey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "appserver_keypair" {
  key_name   = "appserver_ec2key"
  public_key = "${tls_private_key.appserver_privatekey.public_key_openssh}"
}

resource "local_file" "appserver_ec2key" {
  content  = "${tls_private_key.appserver_privatekey.private_key_pem}"
  filename = "keys/${aws_key_pair.appserver_keypair.key_name}.pem"
}

resource "aws_network_interface_sg_attachment" "appserver_sg_attachment" {
  security_group_id    = "${aws_security_group.cecs_sg.id}"
  network_interface_id = "${aws_instance.app_server.primary_network_interface_id}"
}


########################################
# Create Toxiproxy host for hosting app
########################################

resource "aws_instance" "toxiproxy" {
     ami = "ami-042ad9eec03638628"
     instance_type = "t2.nano"
     key_name      = "${aws_key_pair.toxiproxy_keypair.key_name}"
     subnet_id     = aws_subnet.public_subnet_cecs.id
     associate_public_ip_address = "true"
     user_data = file("${path.module}/ec2_toxiproxy_startup.sh")
}

resource "tls_private_key" "toxiproxy_privatekey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "toxiproxy_keypair" {
  key_name   = "toxiproxy_ec2key"
  public_key = "${tls_private_key.toxiproxy_privatekey.public_key_openssh}"
}

resource "local_file" "toxiproxy_ec2key" {
  content  = "${tls_private_key.toxiproxy_privatekey.private_key_pem}"
  filename = "keys/${aws_key_pair.toxiproxy_keypair.key_name}.pem"
}

resource "aws_eip_association" "toxiproxy_eip_assoc" {
  instance_id   = aws_instance.toxiproxy.id
  allocation_id = aws_eip.toxiproxy_ip.id
}

resource "aws_eip" "toxiproxy_ip" {
  vpc = true
}

resource "aws_network_interface_sg_attachment" "toxiproxy_sg_attachment" {
  security_group_id    = "${aws_security_group.cecs_sg.id}"
  network_interface_id = "${aws_instance.toxiproxy.primary_network_interface_id}"
}