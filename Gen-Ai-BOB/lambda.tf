# ─── Lambda zip with Python handler to fetch running RDS ─────────────────────

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"

  source {
    content  = <<-EOF
      import boto3
      import json
      import os

      def handler(event, context):
          region = os.environ.get("AWS_REGION", "us-east-1")
          rds    = boto3.client("rds", region_name=region)

          # ── Fetch running RDS instances ────────────────────────────────
          instances = []
          paginator = rds.get_paginator("describe_db_instances")
          for page in paginator.paginate():
              for db in page["DBInstances"]:
                  if db["DBInstanceStatus"] == "available":
                      instances.append({
                          "Identifier":    db["DBInstanceIdentifier"],
                          "Class":         db["DBInstanceClass"],
                          "Engine":        db["Engine"],
                          "EngineVersion": db["EngineVersion"],
                          "Status":        db["DBInstanceStatus"],
                          "Endpoint":      db.get("Endpoint", {}).get("Address", "N/A"),
                          "MultiAZ":       db["MultiAZ"],
                          "StorageGB":     db["AllocatedStorage"],
                      })

          # ── Fetch running Aurora clusters ──────────────────────────────
          clusters = []
          cluster_pager = rds.get_paginator("describe_db_clusters")
          for page in cluster_pager.paginate():
              for c in page["DBClusters"]:
                  if c["Status"] == "available":
                      clusters.append({
                          "Identifier":    c["DBClusterIdentifier"],
                          "Engine":        c["Engine"],
                          "EngineVersion": c["EngineVersion"],
                          "Status":        c["Status"],
                          "Endpoint":      c.get("Endpoint", "N/A"),
                          "MultiAZ":       c.get("MultiAZ", False),
                      })

          result = {
              "region":          region,
              "rds_instances":   instances,
              "rds_clusters":    clusters,
              "total_instances": len(instances),
              "total_clusters":  len(clusters),
          }

          print(json.dumps(result, indent=2))
          return {
              "statusCode": 200,
              "body":       json.dumps(result)
          }
    EOF
    filename = "lambda_function.py"
  }
}

# ─── Lambda Function ──────────────────────────────────────────────────────────

resource "aws_lambda_function" "this" {
  function_name    = "${var.project_name}-rds-fetcher"
  role             = aws_iam_role.lambda_role.arn
  runtime          = var.lambda_runtime
  handler          = var.lambda_handler
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory

  environment {
    variables = {
      PROJECT = var.project_name
    }
  }

  tags = {
    Name    = "${var.project_name}-rds-fetcher"
    Project = var.project_name
  }
}

# ─── CloudWatch Log Group ─────────────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 14

  tags = {
    Project = var.project_name
  }
}
