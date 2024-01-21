# Provisioning of Ansible Master and Node

resource "aws_instance" "ansible-master" {
  ami                    = "ami-002070d43b0a4f171"
  instance_type          = "t3.micro"
  subnet_id              =aws_subnet.ecomm-public-subnet.id
  key_name               = "Oje"
  vpc_security_group_ids = [aws_security_group.ecomm-sg.id]
  private_ip             = "10.0.1.10"

  tags = {
    Name = "Ansible Master"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install git",
      "git clone https://github.com/CeeyIT-Solutions/ecomm-3.git",
      "cd ecomm-3",
      "sudo chmod 400 Oje.pem",
      "sudo yum -y install epel-release",
      "sudo yum -y install ansible",
      "ansible -m ping -i aws.ini node1",
      "ansible-playbook TF-Project/setup-ecomm.yaml -i TF-Project/aws.ini",
    ]

    connection {
      type        = "ssh"
      user        = "centos"
      private_key = file("/home/centos/Oje.pem")
      host        = self.public_ip
    }
  }
}

resource "aws_instance" "node1" {
  ami                    = "ami-002070d43b0a4f171"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.ecomm-public-subnet.id
  key_name               = "Oje"
  vpc_security_group_ids = [aws_security_group.ecomm-sg.id]
  private_ip             = "10.0.1.11"

  tags = {
    Name = " Ansible Node1"
  }
}