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
    Handles API Gateway POST requests to manage subscriptions.
    - POST: Adds a new subscriber to the Subscriptions table and SNS topic.
    """
    http_method = event.get('httpMethod')
    logger.info(f"Received {http_method} request: {json.dumps(event, indent=2)}")

    try:
        if http_method == 'POST':
            body = json.loads(event.get('body', '{}'))
            email = body.get('email')
            phone = body.get('phone')
            
            if not email and not phone:
                logger.error("No email or phone provided in request body")
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
            logger.info(f"Saved subscriber {subscriber_id} to DynamoDB: {json.dumps(item, indent=2)}")
            
            # Subscribe to SNS topic
            subscription_arn = None
            if email:
                response = sns.subscribe(
                    TopicArn=sns_topic_arn,
                    Protocol='email',
                    Endpoint=email,
                    ReturnSubscriptionArn=True
                )
                subscription_arn = response['SubscriptionArn']
                logger.info(f"Subscribed email {email} to SNS topic {sns_topic_arn}, SubscriptionArn: {subscription_arn}")
            
            if phone:
                response = sns.subscribe(
                    TopicArn=sns_topic_arn,
                    Protocol='sms',
                    Endpoint=phone,
                    ReturnSubscriptionArn=True
                )
                subscription_arn = response['SubscriptionArn']
                logger.info(f"Subscribed phone {phone} to SNS topic {sns_topic_arn}, SubscriptionArn: {subscription_arn}")
            
            # Update DynamoDB with subscription ARN
            if subscription_arn:
                table.update_item(
                    Key={'subscriber_id': subscriber_id},
                    UpdateExpression='SET subscription_arn = :arn',
                    ExpressionAttributeValues={':arn': subscription_arn}
                )
                logger.info(f"Updated subscriber {subscriber_id} with SubscriptionArn: {subscription_arn}")
            
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'Subscribed',
                    'subscriber_id': subscriber_id,
                    'subscription_arn': subscription_arn
                })
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