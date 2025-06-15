import json
import os
import boto3
import logging
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table_name = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    """
    Handles API Gateway requests to create or list events.
    - POST: Creates a new event in the Events table.
    - GET: Lists all events from the Events table.
    """
    http_method = event.get('httpMethod')
    logger.info(f"Received {http_method} request: {json.dumps(event)}")

    try:
        if http_method == 'POST':
            body = json.loads(event.get('body', '{}'))
            if not body.get('title') or not body.get('description') or not body.get('date'):
                return {
                    'statusCode': 400,
                    'body': json.dumps({'error': 'Missing required fields: title, description, date'})
                }
            
            # Generate event ID using timestamp
            event_id = str(int(context.get_remaining_time_in_millis() * 1000))
            item = {
                'event_id': event_id,
                'title': body['title'],
                'description': body['description'],
                'date': body['date'],
                'status': 'active'
            }
            
            table.put_item(Item=item)
            logger.info(f"Created event: {event_id}")
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'Event created', 'event_id': event_id})
            }
        
        elif http_method == 'GET':
            response = table.scan()
            items = response.get('Items', [])
            logger.info(f"Retrieved {len(items)} events")
            return {
                'statusCode': 200,
                'body': json.dumps(items)
            }
        
        else:
            logger.warning(f"Unsupported HTTP method: {http_method}")
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Unsupported HTTP method'})
            }
    
    except ClientError as e:
        logger.error(f"DynamoDB error: {e.response['Error']['Message']}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f"DynamoDB error: {e.response['Error']['Message']}"})
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