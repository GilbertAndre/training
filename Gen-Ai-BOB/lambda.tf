# ─── Lambda zip with RDS describe + Secrets Manager handler ──────────────────

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"

  source {
    content  = <<-EOF
      import boto3
      import json
      import os

      def handler(event, context):
          region      = os.environ["AWS_REGION"]
          secret_name = os.environ["SECRET_NAME"]

          # ── Fetch secret from Secrets Manager ──────────────────────────
          sm_client = boto3.client("secretsmanager", region_name=region)
          secret_response = sm_client.get_secret_value(SecretId=secret_name)
          secret = json.loads(secret_response["SecretString"])
          print(f"Secret fetched for: {secret.get('username', 'N/A')}")

          # ── Fetch all running RDS instances ────────────────────────────
          rds_client = boto3.client("rds", region_name=region)

          instances = []
          paginator = rds_client.get_paginator("describe_db_instances")
          for page in paginator.paginate():
              for db in page["DBInstances"]:
                  if db["DBInstanceStatus"] == "available":
                      instances.append({
                          "DBInstanceIdentifier": db["DBInstanceIdentifier"],
                          "DBInstanceClass":      db["DBInstanceClass"],
                          "Engine":               db["Engine"],
                          "EngineVersion":        db["EngineVersion"],
                          "Status":               db["DBInstanceStatus"],
                          "Endpoint":             db.get("Endpoint", {}).get("Address", "N/A"),
                          "MultiAZ":              db["MultiAZ"],
                          "Region":               region
                      })

          # ── Fetch all running RDS clusters ─────────────────────────────
          clusters = []
          cluster_paginator = rds_client.get_paginator("describe_db_clusters")
          for page in cluster_paginator.paginate():
              for cluster in page["DBClusters"]:
                  if cluster["Status"] == "available":
                      clusters.append({
                          "DBClusterIdentifier": cluster["DBClusterIdentifier"],
                          "Engine":              cluster["Engine"],
                          "EngineVersion":       cluster["EngineVersion"],
                          "Status":              cluster["Status"],
                          "Endpoint":            cluster.get("Endpoint", "N/A"),
                          "MultiAZ":             cluster.get("MultiAZ", False),
                          "Region":              region
                      })

          result = {
              "rds_instances": instances,
              "rds_clusters":  clusters,
              "total_instances": len(instances),
              "total_clusters":  len(clusters)
          }

          print(json.dumps(result, indent=2))
          return {"statusCode": 200, "body": json.dumps(result)}
    EOF
    filename = "lambda_function.py"
  }
}

# ─── Lambda Function ──────────────────────────────────────────────────────────

resource "aws_lambda_function" "this" {
  function_name    = "${var.project_name}-lambda"
  role             = aws_iam_role.lambda_role.arn
  runtime          = var.lambda_runtime
  handler          = var.lambda_handler
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory

  environment {
    variables = {
      PROJECT     = var.project_name
      SECRET_NAME = var.secret_name
    }
  }

  tags = {
    Name    = "${var.project_name}-lambda"
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
