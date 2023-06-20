resource "aws_iam_role" "POC_ROLE" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = upper("poc-role")
  }
}

resource "aws_iam_policy_attachment" "POC_POLICY" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ])
  name       = upper("poc_policy")
  roles      = [aws_iam_role.POC_ROLE.name]
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "poc-profile" {
  name = "poc-profile"
  role = aws_iam_role.POC_ROLE.name
}

data "aws_ami" "amimumbai" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "web" {
  ami              = data.aws_ami.amimumbai.id
  instance_type    = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.poc-profile.name
  tags = {
    Name = upper("role_ec2")
  }
}
