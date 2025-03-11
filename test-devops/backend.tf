provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "meu-terraform-bucket-BL"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30  # Exclui versões antigas após 30 dias
    }
  }
}

resource "aws_iam_user" "terraform_user" {
  name = "terraform-backend-user"
}

resource "aws_iam_access_key" "terraform_key" {
  user = aws_iam_user.terraform_user.name
}

resource "aws_iam_policy" "terraform_s3_policy" {
  name        = "TerraformS3Policy"
  description = "Permite que o Terraform acesse o S3 para armazenar o state"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.terraform_state.id}",
          "arn:aws:s3:::${aws_s3_bucket.terraform_state.id}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "terraform_user_policy_attachment" {
  user       = aws_iam_user.terraform_user.name
  policy_arn = aws_iam_policy.terraform_s3_policy.arn
}

output "aws_access_key_id" {
  value     = aws_iam_access_key.terraform_key.id
  sensitive = true
}

output "aws_secret_access_key" {
  value     = aws_iam_access_key.terraform_key.secret
  sensitive = true
}

terraform {
  backend "s3" {
    bucket        = "meu-terraform-bucket-BL"
    key           = "terraform/state.tfstate"
    region        = "us-east-1"
    encrypt       = true
    use_lockfile  = true
  }
}

resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "minha-chave-ssh"
  public_key = tls_private_key.my_key.public_key_openssh
}

output "private_key_pem" {
  value     = tls_private_key.my_key.private_key_pem
  sensitive = true
}

resource "aws_instance" "k8s_ec2" {
  ami = "ami-04b4f1a9cf54c11d0" 
  instance_type = "t3.medium"
  key_name      = "minha-chave-ssh"

  security_groups = [aws_security_group.k8s_sg.name]

  user_data = <<-EOF
      #!/bin/bash
      sudo apt update -y
      sudo apt install -y docker.io
      sudo systemctl start docker
      sudo systemctl enable docker
      sudo usermod -aG docker ubuntu

      curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.21.2/2021-07-05/bin/linux/amd64/kubectl
      chmod +x ./kubectl
      sudo mv ./kubectl /usr/local/bin/

      curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
      chmod +x minikube
      sudo mv minikube /usr/local/bin/

      curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
      chmod 700 get_helm.sh
      ./get_helm.sh

      minikube start --driver=docker
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
