import json
import os
import boto3
import logging
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize SNS client
sns = boto3.client('sns')
sns_topic_arn = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    """
    Triggered by DynamoDB Streams to publish event notifications to SNS topic.
    Publishes a message for each INSERT event in the Events table.
    """
    logger.info(f"Received DynamoDB Stream event: {json.dumps(event)}")

    try:
        for record in event['Records']:
            if record['eventName'] == 'INSERT':
                new_image = record['dynamodb']['NewImage']
                event_data = {
                    'title': new_image['title']['S'],
                    'date': new_image['date']['S']
                }
                
                message = f"New Event: {event_data['title']} on {event_data['date']}"
                sns.publish(
                    TopicArn=sns_topic_arn,
                    Message=message,
                    Subject='New Event Announcement'
                )
                logger.info(f"Published SNS message for event: {event_data['title']}")
        
        return {
            'status': 'Success'
        }
    
    except ClientError as e:
        logger.error(f"SNS error: {e.response['Error']['Message']}")
        raise Exception(f"SNS error: {e.response['Error']['Message']}")
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        raise Exception(f"Unexpected error: {str(e)}")