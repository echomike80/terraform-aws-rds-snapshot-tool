data "aws_caller_identity" "current" {
}

##############
# CloudWatch
##############

resource "aws_cloudwatch_event_rule" "backup_rds" {
  count         = var.is_source_account ? 1 : 0
  name          = format("cw-eventrule-%s-backupRDS", var.name)
  description   = "Triggers the takeSnapshotsRDS state machine"

  schedule_expression   = "cron(${var.backup_schedule})"
}

resource "aws_cloudwatch_event_target" "backup_rds" {
  count     = var.is_source_account ? 1 : 0
  rule      = aws_cloudwatch_event_rule.backup_rds[0].name
  arn       = aws_sfn_state_machine.take_snapshots_rds[0].arn
  role_arn  = aws_iam_role.events[0].arn
}

resource "aws_cloudwatch_event_rule" "share_snapshot_rds" {
  count         = var.is_source_account && var.share_snapshots ? 1 : 0
  name          = format("cw-eventrule-%s-shareSnapshotsRDS", var.name)
  description   = "Triggers the shareSnapshotsRDS state machine"

  schedule_expression   = "cron(/10 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "share_snapshot_rds" {
  count     = var.is_source_account && var.share_snapshots ? 1 : 0
  rule      = aws_cloudwatch_event_rule.share_snapshot_rds[0].name
  arn       = aws_sfn_state_machine.share_snapshots_rds[0].arn
  role_arn  = aws_iam_role.events[0].arn
}

resource "aws_cloudwatch_event_rule" "delete_old_snapshots_rds" {
  count         = var.is_source_account && var.delete_old_snapshots ? 1 : 0
  name          = format("cw-eventrule-%s-deleteOldSnapshotsRDS", var.name)
  description   = "Triggers the deleteOldSnapshotsRDS state machine"

  schedule_expression   = "cron(0 /1 * * ? *)"
}

resource "aws_cloudwatch_event_target" "delete_old_snapshots_rds" {
  count     = var.is_source_account && var.delete_old_snapshots ? 1 : 0
  rule      = aws_cloudwatch_event_rule.delete_old_snapshots_rds[0].name
  arn       = aws_sfn_state_machine.delete_old_snapshots_rds[0].arn
  role_arn  = aws_iam_role.events[0].arn
}

resource "aws_cloudwatch_event_rule" "copy_snapshots_dest_rds" {
  count         = var.is_source_account == false ? 1 : 0
  name          = format("cw-eventrule-%s-copySnapshotsDestRDS", var.name)
  description   = "Triggers the copySnapshotsDestRDS state machine"

  schedule_expression   = "cron(/30 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "copy_snapshots_dest_rds" {
  count     = var.is_source_account == false ? 1 : 0
  rule      = aws_cloudwatch_event_rule.copy_snapshots_dest_rds[0].name
  arn       = aws_sfn_state_machine.copy_snapshots_dest_rds[0].arn
  role_arn  = aws_iam_role.events[0].arn
}

resource "aws_cloudwatch_event_rule" "delete_old_snapshots_dest_rds" {
  count         = var.is_source_account == false && var.delete_old_snapshots ? 1 : 0
  name          = format("cw-eventrule-%s-deleteOldSnapshotsDestRDS", var.name)
  description   = "Triggers the deleteOldSnapshotsDestRDS state machine"

  schedule_expression   = "cron(0 /1 * * ? *)"
}

resource "aws_cloudwatch_event_target" "delete_old_snapshots_dest_rds" {
  count     = var.is_source_account == false && var.delete_old_snapshots ? 1 : 0
  rule      = aws_cloudwatch_event_rule.delete_old_snapshots_dest_rds[0].name
  arn       = aws_sfn_state_machine.delete_old_snapshots_dest_rds[0].arn
  role_arn  = aws_iam_role.events[0].arn
}

resource "aws_cloudwatch_log_group" "take_snapshots_rds" {
  count = var.is_source_account ? 1 : 0
  name  = format("/aws/lambda/fn-%s-takeSnapshotsRDS", var.name)

  retention_in_days = var.lambda_cw_log_retention

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "share_snapshots_rds" {
  count = var.is_source_account && var.share_snapshots ? 1 : 0
  name  = format("/aws/lambda/fn-%s-shareSnapshotsRDS", var.name)

  retention_in_days = var.lambda_cw_log_retention

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "delete_old_snapshots_rds" {
  count = var.is_source_account && var.delete_old_snapshots ? 1 : 0
  name  = format("/aws/lambda/fn-%s-deleteOldSnapshotsRDS", var.name)

  retention_in_days = var.lambda_cw_log_retention

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "copy_snapshots_dest_rds" {
  count = var.is_source_account == false ? 1 : 0
  name  = format("/aws/lambda/fn-%s-copySnapshotsDestRDS", var.name)

  retention_in_days = var.lambda_cw_log_retention

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "delete_old_snapshots_dest_rds" {
  count = var.is_source_account == false && var.delete_old_snapshots ? 1 : 0
  name  = format("/aws/lambda/fn-%s-deleteOldSnapshotsDestRDS", var.name)

  retention_in_days = var.lambda_cw_log_retention

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "backup_rds_failed" {
  count                     = var.is_source_account ? 1 : 0
  alarm_name                = format("cw-alarm-%s-backupsFailedRDS", var.name)
  namespace                 = "AWS/States"
  evaluation_periods        = "1"
  period                    = "300"
  alarm_actions             = [aws_sns_topic.backup_rds_failed[0].arn]
  statistic                 = "Sum"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "1.0"
  metric_name               = "ExecutionsFailed"
  dimensions = {
    StateMachineArn = aws_sfn_state_machine.take_snapshots_rds[0].arn
  }
}

resource "aws_cloudwatch_metric_alarm" "share_snapshots_rds_failed" {
  count                     = var.is_source_account && var.share_snapshots ? 1 : 0
  alarm_name                = format("cw-alarm-%s-shareSnapshotsFailedRDS", var.name)
  namespace                 = "AWS/States"
  evaluation_periods        = "2"
  period                    = "3600"
  alarm_actions             = [aws_sns_topic.share_snapshots_rds_failed[0].arn]
  statistic                 = "Sum"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "2.0"
  metric_name               = "ExecutionsFailed"
  dimensions = {
    StateMachineArn = aws_sfn_state_machine.share_snapshots_rds[0].arn
  }
}

resource "aws_cloudwatch_metric_alarm" "delete_old_snapshots_rds_failed" {
  count                     = var.is_source_account && var.delete_old_snapshots ? 1 : 0
  alarm_name                = format("cw-alarm-%s-deleteOldSnapshotsFailedRDS", var.name)
  namespace                 = "AWS/States"
  evaluation_periods        = "2"
  period                    = "3600"
  alarm_actions             = [aws_sns_topic.delete_old_snapshots_rds_failed[0].arn]
  statistic                 = "Sum"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "2.0"
  metric_name               = "ExecutionsFailed"
  dimensions = {
    StateMachineArn = aws_sfn_state_machine.delete_old_snapshots_rds[0].arn
  }
}

resource "aws_cloudwatch_metric_alarm" "copy_snapshots_rds_failed" {
  count                     = var.is_source_account == false ? 1 : 0
  alarm_name                = format("cw-alarm-%s-copySnapshotsFailedDestRDS", var.name)
  namespace                 = "AWS/States"
  evaluation_periods        = "1"
  period                    = "300"
  alarm_actions             = [aws_sns_topic.copy_snapshots_dest_rds_failed[0].arn]
  statistic                 = "Sum"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "1.0"
  metric_name               = "ExecutionsFailed"
  dimensions = {
    StateMachineArn = aws_sfn_state_machine.copy_snapshots_dest_rds[0].arn
  }
}

resource "aws_cloudwatch_metric_alarm" "delete_old_snapshots_dest_rds_failed" {
  count                     = var.is_source_account == false && var.delete_old_snapshots ? 1 : 0
  alarm_name                = format("cw-alarm-%s-deleteOldSnapshotsFailedRDS", var.name)
  namespace                 = "AWS/States"
  evaluation_periods        = "2"
  period                    = "3600"
  alarm_actions             = [aws_sns_topic.delete_old_snapshots_dest_rds_failed[0].arn]
  statistic                 = "Sum"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "2.0"
  metric_name               = "ExecutionsFailed"
  dimensions = {
    StateMachineArn = aws_sfn_state_machine.delete_old_snapshots_dest_rds[0].arn
  }
}

##############
# IAM
##############

resource "aws_iam_role" "lambda_snapshots_rds" {
  count     = var.is_source_account ? 1 : 0
  name      = format("rl-%s-lambdaSnapshotsRDS", var.name)

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_snapshots_rds" {
  count         = var.is_source_account ? 1 : 0
  name          = format("pol-%s-lambdaSnapshotsRDS", var.name)

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "rds:CreateDBSnapshot",
                "rds:DeleteDBSnapshot",
                "rds:DescribeDBInstances",
                "rds:DescribeDBSnapshots",
                "rds:ModifyDBSnapshotAttribute",
                "rds:DescribeDBSnapshotAttributes",
                "rds:ListTagsForResource",
                "rds:AddTagsToResource"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_snapshots_rds" {
  count         = var.is_source_account ? 1 : 0
  role          = aws_iam_role.lambda_snapshots_rds[0].name
  policy_arn    = aws_iam_policy.lambda_snapshots_rds[0].arn
}

resource "aws_iam_role" "state_machine" {
  count     = var.is_source_account || var.is_source_account == false  ? 1 : 0
  name      = format("rl-%s-stateExecution", var.name)

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "states.${var.region}.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "state_machine" {
  count         = var.is_source_account || var.is_source_account == false ? 1 : 0
  name          = format("pol-%s-stateExecution", var.name)

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "state_machine" {
  count         = var.is_source_account || var.is_source_account == false  ? 1 : 0
  role          = aws_iam_role.state_machine[0].name
  policy_arn    = aws_iam_policy.state_machine[0].arn
}


resource "aws_iam_role" "events" {
  count     = var.is_source_account || var.is_source_account == false ? 1 : 0
  name      = format("rl-%s-stepInvocation", var.name)

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "events" {
  count         = var.is_source_account || var.is_source_account == false ? 1 : 0
  name          = format("pol-%s-stepInvocation", var.name)

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "states:StartExecution"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "events" {
  count         = var.is_source_account || var.is_source_account == false ? 1 : 0
  role          = aws_iam_role.events[0].name
  policy_arn    = aws_iam_policy.events[0].arn
}

resource "aws_iam_role" "snapshots_dest_rds" {
  count     = var.is_source_account == false ? 1 : 0
  name      = format("rl-%s-snapshotsRDS", var.name)

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "snapshots_dest_rds" {
  count         = var.is_source_account == false ? 1 : 0
  name          = format("pol-%s-lambdaSnapshotsRDS", var.name)

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "rds:CreateDBSnapshot",
                "rds:DeleteDBSnapshot",
                "rds:DescribeDBInstances",
                "rds:DescribeDBSnapshots",
                "rds:ModifyDBSnapshotAttribute",
                "rds:DescribeDBSnapshotAttributes",
                "rds:CopyDBSnapshot",
                "rds:ListTagsForResource",
                "rds:AddTagsToResource"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow",
            "Sid": "AllowUseOfTheKey"
        },
        {
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow",
            "Sid": "AllowAttachmentOfPersistentResources"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "snapshots_dest_rds" {
  count         = var.is_source_account == false ? 1 : 0
  role          = aws_iam_role.snapshots_dest_rds[0].name
  policy_arn    = aws_iam_policy.snapshots_dest_rds[0].arn
}

##############
# Lambda
##############

# Code source: https://snapshots-tool-rds-eu-west-1.s3-eu-west-1.amazonaws.com/take_snapshots_rds.zip
resource "aws_lambda_function" "take_snapshots_rds" {
  count         = var.is_source_account ? 1 : 0
  filename      = "${path.module}/lambda_functions/take_snapshots_rds.zip"
  function_name = format("fn-%s-takeSnapshotsRDS", var.name)
  role          = aws_iam_role.lambda_snapshots_rds[0].arn
  handler       = "lambda_function.lambda_handler"

  description   = "This functions triggers snapshots creation for RDS instances. It checks for existing snapshots following the pattern and interval specified in the environment variables with the following format: <dbinstancename>-YYYY-MM-DD-HH-MM"

  runtime       = "python3.7"
  timeout       = 300
  memory_size   = 512

  environment {
    variables           = {
      INTERVAL          = var.backup_interval,
      PATTERN           = var.instance_name_pattern,
      LOG_LEVEL         = var.log_level,
      REGION_OVERRIDE   = var.source_region_override,
      TAGGEDINSTANCE    = var.tagged_instance
    }
  }

  tags = var.tags
}

# Code source: https://snapshots-tool-rds-eu-west-1.s3-eu-west-1.amazonaws.com/share_snapshots_rds.zip
resource "aws_lambda_function" "share_snapshots_rds" {
  count         = var.is_source_account && var.share_snapshots ? 1 : 0
  filename      = "${path.module}/lambda_functions/share_snapshots_rds.zip"
  function_name = format("fn-%s-shareSnapshotsRDS", var.name)
  role          = aws_iam_role.lambda_snapshots_rds[0].arn
  handler       = "lambda_function.lambda_handler"

  description   = "This function shares snapshots created by the take_snapshots_rds function with DEST_ACCOUNT specified in the environment variables."

  runtime       = "python3.7"
  timeout       = 300
  memory_size   = 512

  environment {
    variables           = {
      DEST_ACCOUNT      = var.destination_account,
      PATTERN           = var.instance_name_pattern,
      LOG_LEVEL         = var.log_level,
      REGION_OVERRIDE   = var.source_region_override
    }
  }

  tags = var.tags
}

# Code source: https://snapshots-tool-rds-eu-west-1.s3-eu-west-1.amazonaws.com/delete_old_snapshots_rds.zip
resource "aws_lambda_function" "delete_old_snapshots_rds" {
  count         = var.is_source_account && var.delete_old_snapshots ? 1 : 0
  filename      = "${path.module}/lambda_functions/delete_old_snapshots_rds.zip"
  function_name = format("fn-%s-deleteOldSnapshotsRDS", var.name)
  role          = aws_iam_role.lambda_snapshots_rds[0].arn
  handler       = "lambda_function.lambda_handler"

  description   = "This function deletes snapshots created by the take_snapshots_rds function."

  runtime       = "python3.7"
  timeout       = 300
  memory_size   = 512

  environment {
    variables           = {
      RETENTION_DAYS    = var.retention_days,
      PATTERN           = var.instance_name_pattern,
      LOG_LEVEL         = var.log_level,
      REGION_OVERRIDE   = var.source_region_override
    }
  }

  tags = var.tags
}

# Code source: 
# https://snapshots-tool-rds-eu-west-1.s3-eu-west-1.amazonaws.com/copy_snapshots_dest_rds.zip
# https://snapshots-tool-rds-eu-west-1.s3-eu-west-1.amazonaws.com/copy_snapshots_no_x_account_rds.zip
resource "aws_lambda_function" "copy_snapshots_dest_rds" {
  count         = var.is_source_account == false ? 1 : 0
  filename      = var.cross_account_copy ? "${path.module}/lambda_functions/copy_snapshots_dest_rds.zip" : "${path.module}/lambda_functions/copy_snapshots_no_x_account_rds.zip"
  function_name = format("fn-%s-copySnapshotsDestRDS", var.name)
  role          = aws_iam_role.snapshots_dest_rds[0].arn
  handler       = "lambda_function.lambda_handler"

  description   = "This functions copies snapshots for RDS Instances shared with this account. It checks for existing snapshots following the pattern specified in the environment variables with the following format: <dbInstanceIdentifier-identifier>-YYYY-MM-DD-HH-MM."

  runtime       = "python3.7"
  timeout       = 300
  memory_size   = 512

  environment {
    variables               = {
      SNAPSHOT_PATTERN      = var.snapshot_pattern,
      DEST_REGION           = var.region_dest,
      LOG_LEVEL             = var.log_level,
      REGION_OVERRIDE       = var.source_region_override,
      KMS_KEY_DEST_REGION   = var.kms_key_destination,
      KMS_KEY_SOURCE_REGION = var.kms_key_source,
      RETENTION_DAYS        = var.retention_days
    }
  }

  tags = var.tags
}

# Code source: 
# https://snapshots-tool-rds-eu-west-1.s3-eu-west-1.amazonaws.com/delete_old_snapshots_dest_rds.zip
# https://snapshots-tool-rds-eu-west-1.s3-eu-west-1.amazonaws.com/delete_old_snapshots_no_x_account_rds.zip
resource "aws_lambda_function" "delete_old_snapshots_dest_rds" {
  count         = var.is_source_account  == false && var.delete_old_snapshots ? 1 : 0
  filename      = var.cross_account_copy ? "${path.module}/lambda_functions/delete_old_snapshots_dest_rds.zip" : "${path.module}/lambda_functions/delete_old_snapshots_no_x_account_rds.zip"
  function_name = format("fn-%s-deleteOldSnapshotsDestRDS", var.name)
  role          = aws_iam_role.snapshots_dest_rds[0].arn
  handler       = "lambda_function.lambda_handler"

  description   = "This function enforces retention on the snapshots shared with the destination account."

  runtime       = "python3.7"
  timeout       = 300
  memory_size   = 512

  environment {
    variables           = {
      SNAPSHOT_PATTERN      = var.snapshot_pattern,
      DEST_REGION           = var.region_dest,
      LOG_LEVEL             = var.log_level,
      RETENTION_DAYS        = var.retention_days
    }
  }

  tags = var.tags
}

##############
# SNS
##############

resource "aws_sns_topic" "backup_rds_failed" {
  count         = var.is_source_account ? 1 : 0
  name          = format("sns-%s-backupsFailedRDS", var.name)
  display_name  = format("sns-%s-backupsFailedRDS", var.name)
}

resource "aws_sns_topic" "share_snapshots_rds_failed" {
  count         = var.is_source_account && var.share_snapshots ? 1 : 0
  name          = format("sns-%s-shareSnapshotsRDS", var.name)
  display_name  = format("sns-%s-shareSnapshotsRDS", var.name)
}

resource "aws_sns_topic" "delete_old_snapshots_rds_failed" {
  count         = var.is_source_account && var.delete_old_snapshots ? 1 : 0
  name          = format("sns-%s-deleteOldSnapshotsRDS", var.name)
  display_name  = format("sns-%s-deleteOldSnapshotsRDS", var.name)
}

resource "aws_sns_topic" "copy_snapshots_dest_rds_failed" {
  count         = var.is_source_account == false ? 1 : 0
  name          = format("sns-%s-copySnapshotsFailedDestRDS", var.name)
  display_name  = format("sns-%s-copySnapshotsFailedDestRDS", var.name)
}

resource "aws_sns_topic" "delete_old_snapshots_dest_rds_failed" {
  count         = var.is_source_account && var.delete_old_snapshots ? 0 : 1
  name          = format("sns-%s-deleteOldSnapshotsDestRDS", var.name)
  display_name  = format("sns-%s-deleteOldSnapshotsDestRDS", var.name)
}

resource "aws_sns_topic_policy" "backup_rds_failed" {
  count     = var.is_source_account ? 1 : 0
  arn       = aws_sns_topic.backup_rds_failed[0].arn

  policy    = data.aws_iam_policy_document.sns_topic_policy.json
}

resource "aws_sns_topic_policy" "share_snapshots_rds_failed" {
  count     = var.is_source_account && var.share_snapshots ? 1 : 0
  arn       = aws_sns_topic.share_snapshots_rds_failed[0].arn

  policy    = data.aws_iam_policy_document.sns_topic_policy.json
}

resource "aws_sns_topic_policy" "delete_old_snapshots_rds_failed" {
  count     = var.is_source_account && var.delete_old_snapshots ? 1 : 0
  arn       = aws_sns_topic.delete_old_snapshots_rds_failed[0].arn

  policy    = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = ["*"]

    sid = "__default_statement_ID"
  }
}

##############
# State machine
##############

resource "aws_sfn_state_machine" "take_snapshots_rds" {
  count     = var.is_source_account ? 1 : 0
  name      = format("sfn-statemachine-%s-takeSnapshotsRDS", var.name)
  role_arn  = aws_iam_role.state_machine[0].arn

  definition = <<EOF
{ 
  "Comment":"Triggers snapshot backup for RDS instances",
  "StartAt":"TakeSnapshots",
  "States":{
    "TakeSnapshots":{
      "Type":"Task",
      "Resource": "${aws_lambda_function.take_snapshots_rds[0].arn}",
        "Retry":[
         {
         "ErrorEquals":[
           "SnapshotToolException"
         ],
         "IntervalSeconds":300,
         "MaxAttempts":20,
         "BackoffRate":1
       },
       {
         "ErrorEquals":[
           "States.ALL"],
           "IntervalSeconds": 30,
           "MaxAttempts": 20,
           "BackoffRate": 1
        }
    ],
    "End": true
    }
  }
}
EOF
}

resource "aws_sfn_state_machine" "share_snapshots_rds" {
  count     = var.is_source_account && var.share_snapshots ? 1 : 0
  name      = format("sfn-statemachine-%s-shareSnapshotsRDS", var.name)
  role_arn  = aws_iam_role.state_machine[0].arn

  definition = <<EOF
{
  "Comment": "Shares snapshots with DEST_ACCOUNT",
  "StartAt": "ShareSnapshots",
  "States": {
    "ShareSnapshots": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.share_snapshots_rds[0].arn}",
      "Retry": [
        {
          "ErrorEquals": [
            "SnapshotToolException"
          ],
          "IntervalSeconds": 300,
          "MaxAttempts": 3,
          "BackoffRate": 1
        },
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "IntervalSeconds": 30,
          "MaxAttempts": 20,
          "BackoffRate": 1
        }
      ],
      "End": true
    }
  }
}
EOF
}

resource "aws_sfn_state_machine" "delete_old_snapshots_rds" {
  count     = var.is_source_account && var.delete_old_snapshots ? 1 : 0
  name      = format("sfn-statemachine-%s-deleteOldSnapshotsRDS", var.name)
  role_arn  = aws_iam_role.state_machine[0].arn

  definition = <<EOF
{
  "Comment": "DeleteOld management for RDS snapshots",
  "StartAt": "DeleteOld",
  "States": {
    "DeleteOld": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.delete_old_snapshots_rds[0].arn}",
      "Retry": [
        {
          "ErrorEquals": [
            "SnapshotToolException"
          ],
          "IntervalSeconds": 300,
          "MaxAttempts": 7,
          "BackoffRate": 1
        },
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "IntervalSeconds": 30,
          "MaxAttempts": 20,
          "BackoffRate": 1
        }
      ],
      "End": true
    }
  }
}
EOF
}

resource "aws_sfn_state_machine" "copy_snapshots_dest_rds" {
  count     = var.is_source_account == false ? 1 : 0
  name      = format("sfn-statemachine-%s-copySnapshotsDestRDS", var.name)
  role_arn  = aws_iam_role.state_machine[0].arn

  definition = <<EOF
{
  "Comment": "Copies snapshots locally and then to DEST_REGION",
  "StartAt": "CopySnapshots",
  "States": {
    "CopySnapshots": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.copy_snapshots_dest_rds[0].arn}",
      "Retry": [
        {
          "ErrorEquals": [
            "SnapshotToolException"
          ],
          "IntervalSeconds": 300,
          "MaxAttempts": 5,
          "BackoffRate": 1
        },
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "IntervalSeconds": 30,
          "MaxAttempts": 20,
          "BackoffRate": 1
        }
      ],
      "End": true
    }
  }
}
EOF
}

resource "aws_sfn_state_machine" "delete_old_snapshots_dest_rds" {
  count     = var.is_source_account == false && var.delete_old_snapshots ? 1 : 0
  name      = format("sfn-statemachine-%s-deleteOldSnapshotsDestRDS", var.name)
  role_arn  = aws_iam_role.state_machine[0].arn

  definition = <<EOF
{
  "Comment": "DeleteOld for RDS snapshots in destination region",
  "StartAt": "DeleteOldDestRegion",
  "States": {
    "DeleteOldDestRegion": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.delete_old_snapshots_dest_rds[0].arn}",
      "Retry": [
        {
          "ErrorEquals": [
            "SnapshotToolException"
          ],
          "IntervalSeconds": 600,
          "MaxAttempts": 5,
          "BackoffRate": 1
        },
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "IntervalSeconds": 30,
          "MaxAttempts": 20,
          "BackoffRate": 1
        }
      ],
      "End": true
    }
  }
}
EOF
}