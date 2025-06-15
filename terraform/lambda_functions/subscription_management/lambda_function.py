import json
import os
import boto3
import logging
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize clients
dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')
table_name = os.environ['DYNAMODB_TABLE']
sns_topic_arn = os.environ['SNS_TOPIC_ARN']
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    """
    Handles API Gateway requests to manage subscriptions.
    - POST: Adds a new subscriber to the Subscriptions table and SNS topic.
    """
    http_method = event.get('httpMethod')
    logger.info(f"Received {http_method} request: {json.dumps(event)}")

    try:
        if http_method == 'POST':
            body = json.loads(event.get('body', '{}'))
            email = body.get('email')
            phone = body.get('phone')
            
            if not email and not phone:
                return {
                    'statusCode': 400,
                    'body': json.dumps({'error': 'At least one of email or phone is required'})
                }
            
            # Generate subscriber ID
            subscriber_id = str(int(context.get_remaining_time_in_millis() * 1000))
            item = {
                'subscriber_id': subscriber_id,
                'status': 'active'
            }
            if email:
                item['email'] = email
            if phone:
                item['phone'] = phone
            
            # Save to DynamoDB
            table.put_item(Item=item)
            
            # Subscribe to SNS topic
            if email:
                sns.subscribe(
                    TopicArn=sns_topic_arn,
                    Protocol='email',
                    Endpoint=email
                )
                logger.info(f"Subscribed email {email} to SNS topic")
            
            if phone:
                sns.subscribe(
                    TopicArn=sns_topic_arn,
                    Protocol='sms',
                    Endpoint=phone
                )
                logger.info(f"Subscribed phone {phone} to SNS topic")
            
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'Subscribed', 'subscriber_id': subscriber_id})
            }
        
        else:
            logger.warning(f"Unsupported HTTP method: {http_method}")
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Unsupported HTTP method'})
            }
    
    except ClientError as e:
        logger.error(f"AWS error: {e.response['Error']['Message']}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f"AWS error: {e.response['Error']['Message']}"})
        }
    except json.JSONDecodeError:
        logger.error("Invalid JSON in request body")
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid JSON in request body'})
        }
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f"Unexpected error: {str(e)}"})
        }