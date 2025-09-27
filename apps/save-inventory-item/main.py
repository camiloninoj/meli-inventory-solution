import os
import redis
import json
import boto3

redis_client = redis.Redis(host=os.environ['REDIS_HOST'], port=6379, db=0)
sqs = boto3.client('sqs')

def handler(event, context):
    try:
        body = json.loads(event['body'])
        item_id = body['item_id']
        
        # Update cache
        redis_client.setex(item_id, 3600, json.dumps(body))
        
        # Send update events to SQS for async processing
        sqs.send_message(
            QueueUrl=os.environ['SQS_QUEUE_URL'],
            MessageBody=json.dumps({
                'action': 'update_local_db',
                'item': body
            })
        )
        
        sqs.send_message(
            QueueUrl=os.environ['SQS_QUEUE_URL'],
            MessageBody=json.dumps({
                'action': 'update_central_db',
                'item': body
            })
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Item update initiated'})
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
