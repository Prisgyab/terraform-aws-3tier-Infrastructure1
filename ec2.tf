
# Fetch latest Ubuntu 22.04 AMI using SSM (region-aware)
data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

# Upload the public key to AWS.
# Generate your own key pair before running `terraform apply` — it is
# gitignored and must never be committed:
#   ssh-keygen -t rsa -b 4096 -f terraform-ec2-key -N ""
resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-ec2-key"
  public_key = file("terraform-ec2-key.pub")
}

# EC2 Instance
resource "aws_instance" "web" {
  ami                    = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.terraform_key.key_name

  tags = {
    Name = "terraform-web-server"
  }
}
