# ec2 inatance creation
resource "aws_instance" "web" {
  ami           = ami-003932de22c285676
  instance_type = "t2.micro"
  key_name = "tf"
  subnet_id   = aws_subnet.ecom-web-sn.id
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  user_data = file(eccom.sh)


  tags = {
    Name = "eccom-web-instance"
  }
}