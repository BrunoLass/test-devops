provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "bruno-lassakoski-bucket-325"
    key            = "terraform/state.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = "bruno-lassakoski-bucket-325"
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = "bruno-lassakoski-bucket-325"

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    filter {
      prefix = ""  # Aplica a todos os objetos no bucket
    }

    noncurrent_version_expiration {
      noncurrent_days = 30  # Exclui versões antigas após 30 dias
    }
  }
}
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "minha-chave-ssh"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

output "private_key_pem" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

resource "aws_instance" "k8s_ec2" {
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = "t3.medium"
  key_name      = aws_key_pair.ssh_key.key_name 

  security_groups = [aws_security_group.k8s_sg.name]

  user_data = <<-EOF
      #!/bin/bash
      sudo apt update -y
      sudo apt install -y docker.io curl jq

      sudo systemctl start docker
      sudo systemctl enable docker
      sudo usermod -aG docker ubuntu

      # Instalar Minikube
      curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
      chmod +x minikube
      sudo mv minikube /usr/local/bin/

      # Instalar kubectl
      curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
      echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
      sudo apt update
      sudo apt install -y kubectl

      # Instalar Helm
      curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

  EOF

  tags = {
    Name = "k8s-ec2"
  }
}

resource "aws_security_group" "k8s_sg" {
  name        = "k8s-security-group"
  description = "libera as portas SSH e do K8s"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
