variable "backup_automatically" {
  description = "Enable taking snapshots automatically"
  type        = bool
  default     = true
}

variable "backup_interval" {
  description = "Interval for backups in hours. Default is 24."
  type        = number
  default     = 24
}

variable "backup_schedule" {
  description = "Backup schedule in Cloudwatch Event cron format. Needs to run at least once for every Interval. The default value runs once every at 1AM UTC. More information: http://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html"
  type        = string
  default     = "0 1 * * ? *"
}

variable "cross_account_copy" {
  description = "Enable copying snapshots across accounts. Set to FALSE if your source snapshosts are not on a different account."
  type        = bool
  default     = true
}

variable "delete_old_snapshots" {
  description = "Set to true to enable deletion of snapshot based on RetentionDays. Set to false to disable."
  type        = bool
  default     = true
}

variable "destination_account" {
  description = "Destination account with no dashes."
  type        = string
  default     = "000000000000"
}

variable "instance_name_pattern" {
  description = "Python regex for matching cluster identifiers to backup. Use \"ALL_INSTANCES\" to back up every RDS instance in the region."
  type        = string
  default     = "ALL_INSTANCES"
}

variable "is_source_account" {
  description = "Provisioning in source account?"
  type        = bool
  default     = true
}

variable "kms_key_destination" {
  description = "Set to the ARN for the KMS key in the destination region to re-encrypt encrypted snapshots. Leave None if you are not using encryption."
  type        = string
  default     = "None"
}

variable "kms_key_source" {
  description = "Set to the ARN for the KMS key in the SOURCE region to re-encrypt encrypted snapshots. Leave None if you are not using encryption."
  type        = string
  default     = "None"
}

variable "lambda_cw_log_retention" {
  description = "Number of days to retain logs from the lambda functions in CloudWatch Logs."
  type        = number
  default     = 7
}

variable "log_level" {
  description = "Log level for Lambda functions (DEBUG, INFO, WARN, ERROR, CRITICAL are valid values)."
  type        = string
  default     = "ERROR"
}

variable "name" {
  description = "Name to be used on all resources"
  type        = string
}

variable "region" {
  description = "Name of region from the state machine"
  type        = string
  default     = "eu-central-1"
}

variable "region_dest" {
  description = "Destination region for snapshots."
  type        = string
  default     = "eu-central-1"
}

variable "retention_days" {
  description = "Number of days to keep snapshots in retention before deleting them."
  type        = number
  default     = 28
}

variable "share_snapshots" {
  description = "Set to true to enable sharing of snapshots based on destination_account and instance_name_pattern. Set to false to disable."
  type        = bool
  default     = true
}

variable "snapshot_pattern" {
  description = "Python regex for matching instance names to backup. Use \"ALL_SNAPSHOTS\" to back up every RDS instance in the region."
  type        = string
  default     = "ALL_SNAPSHOTS"
}

variable "source_region_override" {
  description = "Set to the region where your RDS instances run, only if such region does not support Step Functions. Leave as NO otherwise."
  type        = string
  default     = "NO"
}

variable "tagged_instance" {
  description = "Set to TRUE to filter instances that have tag CopyDBSnapshot set to True. Set to FALSE to disable."
  type        = string
  default     = "FALSE"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}