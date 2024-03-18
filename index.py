import json
import os
import boto3
from botocore.exceptions import BotoCoreError, ClientError

def lambda_handler(event, context):
    print(event)
    CLIENT_ID = os.environ['CLIENT_ID']
    EMAIL = event["headers"]["X-EMAIL"]
    PASSWORD = event["headers"]["X-PASSWORD"]
    
    client = boto3.client('cognito-idp', region_name="us-west-2")
    
    try:
        client.initiate_auth(
        ClientId=CLIENT_ID,
        AuthFlow='USER_PASSWORD_AUTH',
        AuthParameters={
            'USERNAME': EMAIL,
            'PASSWORD': PASSWORD
            }
        )
        return {
            "isBase64Encoded": False,
            "statusCode": 200,
            "headers": {
                            "X-Requested-With": '*',
                            "Access-Control-Allow-Headers": 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,x-requested-with',
                            "Access-Control-Allow-Origin": '*',
                            "Access-Control-Allow-Methods": 'POST,GET,OPTIONS'
                        },
            "body": json.dumps({'result':'success'})
        }
    except client.exceptions.NotAuthorizedException:
        return {
            'statusCode': 401,
            'body':  {'Error':'User is not authorized'}
        }