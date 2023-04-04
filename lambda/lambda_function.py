""" Cloud Resume Visitor Counter """
import json
import os
import boto3


# pylint: disable=unused-argument
def lambda_handler(event, context):
    """
    connect to DynamoDB using Environment variable "table_name"
    updates the value of hits and increase of 1
    """
    d_db_name = os.environ["table_name"]
    try:
        client = boto3.client("dynamodb", region_name="ca-central-1")
        response = client.update_item(
            TableName=d_db_name,
            Key={"id": {"S": "visitor"}},
            UpdateExpression="SET hits = hits + :incr",
            ExpressionAttributeValues={":incr": {"N": "1"}},
            ReturnValues="UPDATED_NEW",
        )
        new_count = response["Attributes"]["hits"]["N"]
        response_message = {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "OPTION, POST",
                "Access-Control-Allow-Headers": "Content-Type",
            },
            "body": json.dumps(
                {
                    "message": "success",
                    "count": new_count,
                }
            ),
        }
        return response_message
    # pylint: disable=broad-exception-caught
    except Exception as error_message:
        return {"statusCode": 500, "error": str(error_message)}
