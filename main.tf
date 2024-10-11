
 
# Creación de la VPC 
resource "aws_vpc" "cloud_vpc" { 
  cidr_block = "30.0.0.0/16"  # Rango de IP para la VPC 
  enable_dns_support = true    # Habilitar soporte DNS 
  enable_dns_hostnames = true   # Habilitar nombres de host DNS 
 
  tags = { 
    Name = "cloud_vpc"         # Etiqueta para la VPC 
  } 
} 
 
# Subredes públicas 
 
# Primera subred pública 
resource "aws_subnet" "public_subnet_1" { 
  vpc_id            = aws_vpc.cloud_vpc.id  # ID de la VPC donde se crea la subred 
  cidr_block        = "30.0.1.0/24"           # Rango de IP para la subred pública 1 
  availability_zone = "us-west-2a"            # Zona de disponibilidad 
 
  tags = { 
    Name = "public_subnet_1"  # Etiqueta para la subred pública 1 
  } 
} 
 
# Segunda subred pública 
resource "aws_subnet" "public_subnet_2" { 
  vpc_id            = aws_vpc.cloud_vpc.id  # ID de la VPC donde se crea la subred 
  cidr_block        = "30.0.2.0/24"           # Rango de IP para la subred pública 2 
  availability_zone = "us-west-2b"            # Zona de disponibilidad 
 
  tags = { 
    Name = "public_subnet_2"  # Etiqueta para la subred pública 2 
  } 
} 
 
# Subredes privadas 
 
# Primera subred privada 
resource "aws_subnet" "private_subnet_1" { 
  vpc_id            = aws_vpc.cloud_vpc.id  # ID de la VPC donde se crea la subred 
  cidr_block        = "30.0.3.0/24"           # Rango de IP para la subred privada 1 
  availability_zone = "us-west-2a"            # Zona de disponibilidad 
 
  tags = { 
    Name = "private_subnet_1" # Etiqueta para la subred privada 1 
  } 
} 
 
# Segunda subred privada 
resource "aws_subnet" "private_subnet_2" { 
  vpc_id            = aws_vpc.cloud_vpc.id  # ID de la VPC donde se crea la subred 
  cidr_block        = "30.0.4.0/24"           # Rango de IP para la subred privada 2 
  availability_zone = "us-west-2b"            # Zona de disponibilidad 
 
  tags = { 
    Name = "private_subnet_2" # Etiqueta para la subred privada 2 
  } 
} 
 
# Internet Gateway 
resource "aws_internet_gateway" "igw" { 
  vpc_id = aws_vpc.cloud_vpc.id  # ID de la VPC a la que se asocia el gateway 
 
  tags = { 
    Name = "internet_gateway"    # Etiqueta para el Internet Gateway 
  } 
} 
 
# Tabla de enrutamiento para subredes públicas 
resource "aws_route_table" "public_rt" { 
  vpc_id = aws_vpc.cloud_vpc.id  # ID de la VPC a la que pertenece la tabla de enrutamiento 
 
  route { 
    cidr_block = "0.0.0.0/0"        # Ruta para todo el tráfico saliente 
    gateway_id = aws_internet_gateway.igw.id  # ID del Internet Gateway 
  } 
 
  tags = { 
    Name = "public_route_table"    # Etiqueta para la tabla de enrutamiento pública 
  } 
} 
 
# Asociación de la tabla de enrutamiento a la subred pública 1 
resource "aws_route_table_association" "public_association_1" { 
  subnet_id      = aws_subnet.public_subnet_1.id  # ID de la subred pública 1 
  route_table_id = aws_route_table.public_rt.id    # ID de la tabla de enrutamiento pública 
} 
 
# Asociación de la tabla de enrutamiento a la subred pública 2 
resource "aws_route_table_association" "public_association_2" { 
  subnet_id      = aws_subnet.public_subnet_2.id  # ID de la subred pública 2 
  route_table_id = aws_route_table.public_rt.id    # ID de la tabla de enrutamiento pública 
} 
 
 
 
# Creación del Security Group 
resource "aws_security_group" "allow_ssh" { 
    name        = "allow_ssh" 
  description = "Allow SSH inbound traffic" 
  vpc_id = aws_vpc.cloud_vpc.id  # ID de la VPC donde se crea el grupo de seguridad 
 
  // Reglas de entrada 
  ingress { 
    description = "SSH from VPC" 
    from_port   = 22             # Puerto de entrada 22 (SSH) 
    to_port     = 22             # Puerto de entrada 22 (SSH) 
    protocol    = "tcp"          # Protocolo TCP 
    cidr_blocks = ["0.0.0.0/0"]  # Permitir acceso desde cualquier dirección IP 
  } 
 
  ingress { 
    from_port   = 80             # Puerto de entrada 80 (web) 
    to_port     = 80             # Puerto de entrada 80 (web) 
    protocol    = "tcp"          # Protocolo TCP 
    cidr_blocks = ["0.0.0.0/0"]  # Permitir acceso desde cualquier dirección IP 
  } 
 
 
  // Reglas de salida (opcional, permite todo el tráfico saliente) 
  egress { 
    from_port   = 0 
    to_port     = 0 
    protocol    = "-1"           # Permitir todo el tráfico 
    cidr_blocks = ["0.0.0.0/0"]  # Permitir acceso a cualquier dirección IP 
  } 
 
  tags = { 
    Name = "allow_ssh"  # Etiqueta para el grupo de seguridad 
  } 
} 
 
 
 
 
# Asociación del Security Group a la instancia EC2 
resource "aws_instance" "ec2_public_1" { 
  ami                    = "ami-0d081196e3df05f4d" 
  instance_type         = "t2.micro" 
  subnet_id             = aws_subnet.public_subnet_1.id 
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]  # Asociación del Security Group 
  associate_public_ip_address = true 
  key_name      = "cloud2" 
  tags = { 
    Name = "EC2 Specialization 1" 
  } 
  user_data = file("comands.sh") 
} 
 
 
 
# Asociación del Security Group a la instancia EC2 
resource "aws_instance" "ec2_public_2" { 
  ami                    = "ami-0d081196e3df05f4d" 
  instance_type         = "t2.micro" 
  subnet_id             = aws_subnet.public_subnet_2.id 
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]  # Asociación del Security Group 
  key_name      = "cloud2" 
  associate_public_ip_address = true 
 
  tags = { 
    Name = "EC2 Specialization 2" 
  } 
   user_data = file("comands.sh") 
} 
 
 
output "ec2_public_1_ip" { 
  value = aws_instance.ec2_public_1.public_ip 
} 
 
 
output "ec2_public_2_ip" { 
  value = aws_instance.ec2_public_2.public_ip 
} 
 
# Crear Load Balancer 
resource "aws_lb" "cloud_lb" { 
  name               = "cloud-lb" 
  internal           = false 
  load_balancer_type = "application" 
  security_groups    = [aws_security_group.allow_ssh.id]  # Asocia el Security Group 
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id] 
 
  tags = { 
    Name = "cloud_lb" 
  } 
} 
 
# Crear el Target Group 
resource "aws_lb_target_group" "cloud_tg" { 
  name     = "cloud-tg" 
  port     = 80 
  protocol = "HTTP" 
  vpc_id   = aws_vpc.cloud_vpc.id 
 
  health_check { 
    interval            = 30 
    path                = "/" 
    timeout             = 5 
    healthy_threshold   = 2 
    unhealthy_threshold = 2 
    matcher             = "200" 
  } 
 
  tags = { 
    Name = "cloud_tg" 
  } 
} 
 
# Asociar instancias EC2 al Target Group 
resource "aws_lb_target_group_attachment" "ec2_public_1" { 
  target_group_arn = aws_lb_target_group.cloud_tg.arn 
  target_id        = aws_instance.ec2_public_1.id 
  port             = 80 
} 
 
resource "aws_lb_target_group_attachment" "ec2_public_2" { 
  target_group_arn = aws_lb_target_group.cloud_tg.arn 
  target_id        = aws_instance.ec2_public_2.id 
  port             = 80 
} 
 
# Crear Listener para el Load Balancer 
resource "aws_lb_listener" "cloud_listener" { 
  load_balancer_arn = aws_lb.cloud_lb.arn 
  port              = "80" 
  protocol          = "HTTP" 
 
  default_action { 
    type             = "forward" 
    target_group_arn = aws_lb_target_group.cloud_tg.arn 
  } 
} 
 
 
# Crear Subredes Privadas para RDS (Ya definidas anteriormente) 
 
# Crear un Security Group para RDS 
resource "aws_security_group" "rds_sg" { 
  name        = "rds_sg" 
  description = "Allow MySQL traffic" 
  vpc_id      = aws_vpc.cloud_vpc.id 
 
  ingress { 
    from_port   = 3306 
    to_port     = 3306 
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]  # Cambiar esto para permitir solo tráfico específico 
  } 
 
  egress { 
    from_port   = 0 
    to_port     = 0 
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  } 
 
  tags = { 
    Name = "rds_sg" 
  } 
} 
 
# Crear RDS MySQL 
resource "aws_db_instance" "cloud_rds" { 
  allocated_storage    = 20 
  storage_type         = "gp2" 
  engine               = "mysql" 
  engine_version       = "8.0" 
  instance_class       = "db.t3.micro" 
  username             = "admin" 
  password             = "Cloud2024*" 
  skip_final_snapshot  = true 
  vpc_security_group_ids = [aws_security_group.rds_sg.id] 
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name 
 
  tags = { 
    Name = "cloud_rds" 
  } 
} 
 
# Crear Subnet Group para RDS 
resource "aws_db_subnet_group" "rds_subnet_group" { 
  name       = "rds_subnet_group" 
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id] 
 
  tags = { 
    Name = "rds_subnet_group" 
  } 
}  
 
