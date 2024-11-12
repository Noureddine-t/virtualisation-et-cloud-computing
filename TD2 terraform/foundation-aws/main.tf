/* Configurer Terraform pour AWS */
provider "aws" {
  region = var.regionId
}

# Créer un VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Créer un sous-réseau dans le VPC
resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
}

# Créer un groupe de sécurité pour les instances EC2
resource "aws_security_group" "allow_traffic" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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

# Créer des instances EC2 avec un meta-argument pour la haute disponibilité
resource "aws_instance" "web_server" {
  count         = 2
  ami           = "ami-0c55b159cbfafe1f0" # AMI Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main_subnet.id
  security_groups = [aws_security_group.allow_traffic.name]

  tags = {
    Name = "web-server-${count.index + 1}"
  }
}

# Créer une base de données RDS
resource "aws_db_instance" "mydb" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "password" # Remplacez par un mot de passe sécurisé
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.allow_traffic.id]
}

# Créer un enregistrement DNS avec Route 53
resource "aws_route53_zone" "main_zone" {
  name = "example.com"
}

resource "aws_route53_record" "dns_record" {
  zone_id = aws_route53_zone.main_zone.zone_id
  name    = "web.example.com"
  type    = "A"
  ttl     = 300
  records = [for instance in aws_instance.web_server : instance.public_ip]
}

