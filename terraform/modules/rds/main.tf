# Security Group pour RDS PostgreSQL (Port 5432 depuis EKS)
resource "aws_security_group" "rds_sg" {
  name        = "rds-postgres-sg-${var.environment}"
  description = "Allow inbound PostgreSQL traffic from EKS cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-postgres-sg-${var.environment}"
  }
}

# Instance PostgreSQL RDS
resource "aws_db_instance" "postgres" {
  identifier             = "app-db-${var.environment}"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true

  tags = {
    Environment = var.environment
  }
}