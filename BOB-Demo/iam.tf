# ─── Lambda IAM Role ─────────────────────────────────────────────────────────

resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-lambda-role"
    Project = var.project_name
  }
}

# ─── Basic Lambda execution (CloudWatch Logs) ─────────────────────────────────

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ─── RDS describe policy ──────────────────────────────────────────────────────

resource "aws_iam_policy" "rds_describe" {
  name        = "${var.project_name}-rds-describe-policy"
  description = "Allow Lambda to describe all running RDS instances and clusters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:DescribeDBClusterMembers",
          "rds:ListTagsForResource"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_rds" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.rds_describe.arn
}

# ─── EC2 describe policy ──────────────────────────────────────────────────────

resource "aws_iam_policy" "ec2_describe" {
  name        = "${var.project_name}-ec2-describe-policy"
  description = "Allow Lambda to describe EC2 instances and related resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeRegions",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ec2" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.ec2_describe.arn
}
