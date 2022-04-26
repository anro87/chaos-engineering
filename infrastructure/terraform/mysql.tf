resource "aws_db_subnet_group" "subnet_group_cecs" {
  name       = "private_subnet_group_cecs"
  subnet_ids = [aws_subnet.private_subnet_cecs.id, aws_subnet.public_subnet_cecs.id]
  tags = {
    Owner = "anro"
  }
}

resource "aws_db_instance" "cecs_db" {
  identifier           = "cecsdb"
  name                 = "cecs_db"
  skip_final_snapshot  = true
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = var.database_user
  password             = var.database_password
  db_subnet_group_name = aws_db_subnet_group.subnet_group_cecs.id
}