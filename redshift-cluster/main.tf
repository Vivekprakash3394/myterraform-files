# Create IAM Role for redshift
resource "aws_iam_role" "redshift" {
  name = "${var.fes_redshift}-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "redshift.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# Attach Policy to IAM Role
resource "aws_iam_role_policy_attachment" "redshift" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.redshift.name
}

# Create S3 Bucket
resource "aws_s3_bucket" "redshift_au" {
  bucket = "redshift-au"
}

resource "aws_s3_bucket_ownership_controls" "redshift_au" {
  bucket = aws_s3_bucket.redshift_au.bucket
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


resource "aws_s3_bucket_acl" "redshift_au" {
  depends_on = [aws_s3_bucket_ownership_controls.fe_redshift_au]

  bucket = aws_s3_bucket.redshift_au.bucket
  acl    = "private"
}

# Create Redshift Cluster
resource "aws_redshift_cluster" "redshift" {
  cluster_identifier         = "redshift-cluster"
  database_name              = "redshiftdb"
  master_username            = "admin"
  master_password            = "Passw0rd1234"
  node_type                  = "dc2.large"
  cluster_type               = "single-node"
  publicly_accessible        = false
  iam_roles                  = [aws_iam_role.redshift.arn] # Attach IAM role to Redshift cluster
  vpc_security_group_ids     = [aws_security_group.redshift_sg.id]
  cluster_subnet_group_name  = aws_redshift_subnet_group.redshift.name
  skip_final_snapshot        = true
}

# Create Security Group for Redshift Cluster
resource "aws_security_group" "redshift_sg" {
  name        = "redshift_sg"
  description = "Redshift security group"

  vpc_id = "vpc-0f7850de79f23af**"

  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Redshift Subnet Group
resource "aws_redshift_subnet_group" "redshift" {
  name       = "redshift-subnet-group"
  subnet_ids = ["subnet-0f4d15b157f3e7***", "subnet-0cf77933b28723***","subnet-0b0690f403e780***"] # Add your subnet IDs
}
