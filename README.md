# AWS S3 Bucket with replica Terraform module

Terraform module which creates ressources for the RDS snapshot tool on source and destination accounts on AWS.

This module is based on the CloudFormation templates from https://github.com/awslabs/rds-snapshot-tool

## Terraform versions

Terraform 0.12 and newer. 

## Usage

Source account:

```hcl
module "rds_snapshot_tool_src" {
  source                = "/path/to/terraform-aws-rds-snapshot-tool"

  name                  = var.name
  region                = var.region
  is_source_account     = true

  backup_interval       = var.backup_interval
  delete_old_snapshots  = true
  destination_account   = var.destination_account_id
  share_snapshots       = true
}
```

Destination account:

```hcl
module "rds_snapshot_tool_dest" {
  source                = "/path/to/terraform-aws-rds-snapshot-tool"

  name                  = var.name
  region                = var.region
  is_source_account     = false

  delete_old_snapshots  = true
  kms_key_source        = var.kms_key_source
  kms_key_destination   = var.kms_key_destination
  region_dest           = var.region_dest
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.65 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.65 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.copy_snapshots_dest_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.delete_old_snapshots_dest_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.delete_old_snapshots_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.share_snapshot_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.take_snapshots_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.copy_snapshots_dest_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.delete_old_snapshots_dest_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |      
| [aws_cloudwatch_event_target.delete_old_snapshots_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.share_snapshot_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.take_snapshots_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.copy_snapshots_dest_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.delete_old_snapshots_dest_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.delete_old_snapshots_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.share_snapshots_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.take_snapshots_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.copy_snapshots_rds_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.delete_old_snapshots_dest_rds_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.delete_old_snapshots_rds_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |    
| [aws_cloudwatch_metric_alarm.share_snapshots_rds_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.take_snapshots_rds_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_policy.events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda_snapshots_dest_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda_snapshots_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.state_machine](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.lambda_snapshots_dest_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.lambda_snapshots_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.state_machine](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_snapshots_dest_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |    
| [aws_iam_role_policy_attachment.lambda_snapshots_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.state_machine](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.copy_snapshots_dest_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.delete_old_snapshots_dest_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.delete_old_snapshots_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.share_snapshots_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.take_snapshots_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_sfn_state_machine.copy_snapshots_dest_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |
| [aws_sfn_state_machine.delete_old_snapshots_dest_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |
| [aws_sfn_state_machine.delete_old_snapshots_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |
| [aws_sfn_state_machine.share_snapshots_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |
| [aws_sfn_state_machine.take_snapshots_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |
| [aws_sns_topic.copy_snapshots_dest_rds_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.delete_old_snapshots_dest_rds_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.delete_old_snapshots_rds_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.share_snapshots_rds_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.take_snapshots_rds_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.delete_old_snapshots_rds_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.share_snapshots_rds_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_policy.take_snapshots_rds_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.sns_topic_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_automatically"></a> [backup\_automatically](#input\_backup\_automatically) | Enable taking snapshots automatically | `bool` | `true` | no |
| <a name="input_backup_interval"></a> [backup\_interval](#input\_backup\_interval) | Interval for backups in hours. Default is 24. | `number` | `24` | no |
| <a name="input_backup_schedule"></a> [backup\_schedule](#input\_backup\_schedule) | Backup schedule in Cloudwatch Event cron format. Needs to run at least once for every Interval. The default value runs once every at 1AM UTC. More information: http://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html | `string` | `"0 1 * * ? *"` | no |  
| <a name="input_cross_account_copy"></a> [cross\_account\_copy](#input\_cross\_account\_copy) | Enable copying snapshots across accounts. Set to FALSE if your source snapshosts are not on a different account. | `bool` | `true` | no |
| <a name="input_delete_old_snapshots"></a> [delete\_old\_snapshots](#input\_delete\_old\_snapshots) | Set to true to enable deletion of snapshot based on RetentionDays. Set to false to disable. | `bool` | `true` | no |
| <a name="input_destination_account"></a> [destination\_account](#input\_destination\_account) | Destination account with no dashes. | `string` | `"000000000000"` | no |
| <a name="input_instance_name_pattern"></a> [instance\_name\_pattern](#input\_instance\_name\_pattern) | Python regex for matching cluster identifiers to backup. Use "ALL\_INSTANCES" to back up every RDS instance in the region. | `string` | `"ALL_INSTANCES"` | no |
| <a name="input_is_source_account"></a> [is\_source\_account](#input\_is\_source\_account) | Provisioning in source account? | `bool` | `true` | no |
| <a name="input_kms_key_destination"></a> [kms\_key\_destination](#input\_kms\_key\_destination) | Set to the ARN for the KMS key in the destination region to re-encrypt encrypted snapshots. Leave None if you are not using encryption. | `string` | `"None"` | no |
| <a name="input_kms_key_source"></a> [kms\_key\_source](#input\_kms\_key\_source) | Set to the ARN for the KMS key in the SOURCE region to re-encrypt encrypted snapshots. Leave None if you are not using encryption. | `string` | `"None"` | no |
| <a name="input_lambda_cw_log_retention"></a> [lambda\_cw\_log\_retention](#input\_lambda\_cw\_log\_retention) | Number of days to retain logs from the lambda functions in CloudWatch Logs. | `number` | `7` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Log level for Lambda functions (DEBUG, INFO, WARN, ERROR, CRITICAL are valid values). | `string` | `"ERROR"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on all resources | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Name of region from the state machine | `string` | `"eu-central-1"` | no |
| <a name="input_region_dest"></a> [region\_dest](#input\_region\_dest) | Destination region for snapshots. | `string` | `"eu-central-1"` | no |
| <a name="input_retention_days"></a> [retention\_days](#input\_retention\_days) | Number of days to keep snapshots in retention before deleting them. | `number` | `28` | no |      
| <a name="input_share_snapshots"></a> [share\_snapshots](#input\_share\_snapshots) | Set to true to enable sharing of snapshots based on destination\_account and instance\_name\_pattern. Set to false to disable. | `bool` | `true` | no |
| <a name="input_snapshot_pattern"></a> [snapshot\_pattern](#input\_snapshot\_pattern) | Python regex for matching instance names to backup. Use "ALL\_SNAPSHOTS" to back up every RDS instance in the region. | `string` | `"ALL_SNAPSHOTS"` | no |
| <a name="input_source_region_override"></a> [source\_region\_override](#input\_source\_region\_override) | Set to the region where your RDS instances run, only if such region does not support Step Functions. Leave as NO otherwise. | `string` | `"NO"` | no |
| <a name="input_tagged_instance"></a> [tagged\_instance](#input\_tagged\_instance) | Set to TRUE to filter instances that have tag CopyDBSnapshot set to True. Set to FALSE to disable. | `string` | `"FALSE"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

No outputs.

## Authors

Module managed by [Marcel Emmert](https://github.com/echomike80).

## License

Apache 2 Licensed. See LICENSE for full details.
