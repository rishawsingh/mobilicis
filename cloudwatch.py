import boto3

ec2 = boto3.resource('ec2')
cw = boto3.client('cloudwatch')

# Get the instance ID of the EC2 instance
instance_id = ec2.InstanceMetadata().get('instance-id')

# Define the metric for CPU utilization
metric_name = 'CPUUtilization'
namespace = 'AWS/EC2'
dimensions = [{'Name': 'InstanceId', 'Value': instance_id}]
period = 60
statistic = 'Average'

# Define the alarm threshold
alarm_name = 'HighCPUUtilization'
alarm_description = 'Alarm when CPU exceeds 80% for 5 consecutive minutes'
alarm_threshold = 80.0
alarm_evaluation_periods = 5
alarm_period = period * alarm_evaluation_periods
alarm_comparison_operator = 'GreaterThanOrEqualToThreshold'

# Create the CloudWatch alarm
response = cw.put_metric_alarm(
    AlarmName=alarm_name,
    AlarmDescription=alarm_description,
    MetricName=metric_name,
    Namespace=namespace,
    Dimensions=dimensions,
    Period=period,
    Statistic=statistic,
    Threshold=alarm_threshold,
    EvaluationPeriods=alarm_evaluation_periods,
    ComparisonOperator=alarm_comparison_operator,
    AlarmActions=[SNS_TOPIC_ARN],
)

print('Created CloudWatch alarm: ' + response['AlarmArn'])
