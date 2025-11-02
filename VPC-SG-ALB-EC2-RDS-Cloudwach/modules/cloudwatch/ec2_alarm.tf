# =============================
# 告警 3：EC2 CPU > 80%
# =============================
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  count               = length(var.ec2_instance_ids)
  alarm_name          = "${local.name}-ec2-cpu>80-${count.index}"
  alarm_description   = "EC2 instance CPU usage exceeds 80%"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    InstanceId = var.ec2_instance_ids[count.index]
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
  tags          = local.tags
}

# =============================
# 告警 4：EC2 系统检查失败
# =============================
resource "aws_cloudwatch_metric_alarm" "ec2_status_failed" {
  count               = length(var.ec2_instance_ids)
  alarm_name          = "${local.name}-ec2-status-failed-${count.index}"
  alarm_description   = "EC2 instance system status check failed"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed_Instance"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    InstanceId = var.ec2_instance_ids[count.index]
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
  tags          = local.tags
}
