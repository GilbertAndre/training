# ─── IAM Role ────────────────────────────────────────────────────────────────

resource "aws_iam_role" "this" {
  name = "${var.project_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      },
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-role"
    Project = var.project_name
  }
}

# ─── IAM Policy ──────────────────────────────────────────────────────────────

resource "aws_iam_policy" "this" {
  name        = "${var.project_name}-policy"
  description = "Policy for ${var.project_name} EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction"]
        Resource = "arn:aws:lambda:*:*:function:${var.project_name}-*"
      }
    ]
  })
}

# ─── Attach policy to role ────────────────────────────────────────────────────

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

# ─── Attach AWS managed Lambda basic execution policy ────────────────────────

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ─── Instance Profile (attach role to EC2) ───────────────────────────────────

resource "aws_iam_instance_profile" "this" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.this.name
}
