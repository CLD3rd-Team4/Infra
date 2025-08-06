import json
import urllib3
import os
from datetime import datetime

def lambda_handler(event, context):
    """
    SNS에서 받은 CloudWatch 알람을 슬랙으로 전송
    """
    
    # SNS 메시지 파싱
    sns_message = json.loads(event['Records'][0]['Sns']['Message'])
    
    # 알람 정보 추출
    alarm_name = sns_message.get('AlarmName', 'Unknown')
    alarm_description = sns_message.get('AlarmDescription', '')
    new_state = sns_message.get('NewStateValue', 'UNKNOWN')
    reason = sns_message.get('NewStateReason', '')
    timestamp = sns_message.get('StateChangeTime', '')
    
    # 서비스 이름 추출 (알람 이름에서)
    service_name = 'unknown'
    if 'oauth' in alarm_name.lower():
        service_name = 'oauth'
    elif 'recommend' in alarm_name.lower():
        service_name = 'recommend'
    elif 'schedule' in alarm_name.lower():
        service_name = 'schedule'
    
    # 웹훅 URL 가져오기
    webhook_url = os.environ.get(f'{service_name.upper()}_WEBHOOK_URL')
    
    if not webhook_url:
        print(f"No webhook URL found for service: {service_name}")
        return {
            'statusCode': 400,
            'body': json.dumps(f'No webhook URL configured for {service_name}')
        }
    
    # 상태에 따른 이모지 및 색상
    if new_state == 'ALARM':
        emoji = '🚨'
        color = '#FF0000'  # 빨간색
    elif new_state == 'OK':
        emoji = '✅'
        color = '#00FF00'  # 초록색
    else:
        emoji = '⚠️'
        color = '#FFA500'  # 주황색
    
    # 슬랙 메시지 구성
    slack_message = {
        "attachments": [
            {
                "color": color,
                "blocks": [
                    {
                        "type": "header",
                        "text": {
                            "type": "plain_text",
                            "text": f"{emoji} DB 알림 - {service_name.upper()}"
                        }
                    },
                    {
                        "type": "section",
                        "fields": [
                            {
                                "type": "mrkdwn",
                                "text": f"*알람명:*\n{alarm_name}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": f"*상태:*\n{new_state}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": f"*시간:*\n{timestamp}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": f"*사유:*\n{reason}"
                            }
                        ]
                    }
                ]
            }
        ]
    }
    
    # 슬랙으로 전송
    http = urllib3.PoolManager()
    
    try:
        response = http.request(
            'POST',
            webhook_url,
            body=json.dumps(slack_message),
            headers={'Content-Type': 'application/json'}
        )
        
        print(f"Slack response: {response.status}")
        
        return {
            'statusCode': 200,
            'body': json.dumps('Message sent to Slack successfully')
        }
        
    except Exception as e:
        print(f"Error sending to Slack: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }
