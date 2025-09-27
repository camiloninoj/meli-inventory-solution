import json
import cx_Oracle
import os

def handler(event, context):
    try:
        for record in event['Records']:
            message = json.loads(record['body'])
            if message['action'] != 'update_central_db':
                continue
                
            item = message['item']
            
            # Connect to Oracle central database
            connection = cx_Oracle.connect(
                user=os.environ['DB_USER'],
                password=os.environ['DB_PASSWORD'],
                dsn=os.environ['DB_CENTRAL_DSN']
            )
            
            cursor = connection.cursor()
            cursor.execute("""
                MERGE INTO central_inventory i
                USING DUAL
                ON (i.item_id = :item_id AND i.store_id = :store_id)
                WHEN MATCHED THEN
                    UPDATE SET quantity = :quantity
                WHEN NOT MATCHED THEN
                    INSERT (item_id, store_id, quantity)
                    VALUES (:item_id, :store_id, :quantity)
                """, 
                item_id=item['item_id'],
                store_id=item['store_id'],
                quantity=item['quantity'])
            
            connection.commit()
            cursor.close()
            connection.close()
            
    except Exception as e:
        print(f"Error processing message: {str(e)}")
        raise
