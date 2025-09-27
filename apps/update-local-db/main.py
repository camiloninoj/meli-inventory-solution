import json
import cx_Oracle
import os

def handler(event, context):
    try:
        for record in event['Records']:
            message = json.loads(record['body'])
            if message['action'] != 'update_local_db':
                continue
                
            item = message['item']
            
            # Connect to Oracle local database
            connection = cx_Oracle.connect(
                user=os.environ['DB_USER'],
                password=os.environ['DB_PASSWORD'],
                dsn=os.environ['DB_LOCAL_DSN']
            )
            
            cursor = connection.cursor()
            cursor.execute("""
                MERGE INTO inventory_items i
                USING DUAL
                ON (i.item_id = :item_id)
                WHEN MATCHED THEN
                    UPDATE SET quantity = :quantity
                WHEN NOT MATCHED THEN
                    INSERT (item_id, quantity)
                    VALUES (:item_id, :quantity)
                """, item_id=item['item_id'], quantity=item['quantity'])
            
            connection.commit()
            cursor.close()
            connection.close()
            
    except Exception as e:
        print(f"Error processing message: {str(e)}")
        raise
