import os
import redis
import json
import boto3

redis_client = redis.Redis(host=os.environ['REDIS_HOST'], port=6379, db=0)
dynamodb = boto3.client('dynamodb')

def handler(event, context):
    try:
        item_id = event['pathParameters']['item_id']
        
        # First check in cache
        cached_item = redis_client.get(item_id)
        if cached_item:
            return {
                'statusCode': 200,
                'body': cached_item.decode('utf-8')
            }
        
        # If not in cache, query central database
        response = dynamodb.get_item(
            TableName='inventory_items',
            Key={'item_id': {'S': item_id}}
        )
        
        if 'Item' in response:
            item = response['Item']
            # Cache the result
            redis_client.setex(item_id, 3600, json.dumps(item))
            return {
                'statusCode': 200,
                'body': json.dumps(item)
            }
        
        return {
            'statusCode': 404,
            'body': json.dumps({'message': 'Item not found'})
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
