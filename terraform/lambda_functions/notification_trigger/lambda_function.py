import json
import os
import boto3
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize clients
sns = boto3.client('sns')
ses = boto3.client('ses')
topic_arn = os.environ['SNS_TOPIC_ARN']
sender_email = os.environ['SENDER_EMAIL']  

def lambda_handler(event, context):
    try:
        for record in event['Records']:
            if record['eventName'] == 'INSERT':
                new_event = record['dynamodb']['NewImage']
                title = new_event['title']['S']
                date = new_event['date']['S']
                description = new_event['description']['S']
                message = f"New Event: {title} on {date}\nDescription: {description}"
                
                # Publish to SNS topic for confirmed subscribers
                sns.publish(
                    TopicArn=topic_arn,
                    Message=message,
                    Subject='New Event Notification'
                )
                logger.info(f"Published event {title} to SNS topic {topic_arn}")
                
                # Fetch confirmed email subscribers from SNS
                subscriptions = sns.list_subscriptions_by_topic(TopicArn=topic_arn)['Subscriptions']
                for sub in subscriptions:
                    if sub['Protocol'] == 'email' and sub['SubscriptionArn'] != 'PendingConfirmation':
                        ses.send_email(
                            Source=sender_email,
                            Destination={'ToAddresses': [sub['Endpoint']]},
                            Message={
                                'Subject': {'Data': 'New Event Notification'},
                                'Body': {'Text': {'Data': message}}
                            }
                        )
                        logger.info(f"Sent email to {sub['Endpoint']}")
        
        return {'statusCode': 200}
    
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }