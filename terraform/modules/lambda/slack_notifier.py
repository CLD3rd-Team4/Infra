import json
import urllib3
import os
from datetime import datetime, timezone, timedelta

def lambda_handler(event, context):
    """
    SNS에서 받은 CloudWatch 알람을 슬랙으로 전송
    """
    
    # 디버깅: 전체 이벤트 로그
    print(f"DEBUG: Full event: {json.dumps(event, indent=2)}")
    
    # SNS 메시지 파싱
    sns_message_raw = event['Records'][0]['Sns']['Message']
    print(f"DEBUG: Raw SNS message: {sns_message_raw}")
    
    sns_message = json.loads(sns_message_raw)
    print(f"DEBUG: Parsed SNS message: {json.dumps(sns_message, indent=2)}")
    
    # 알람 정보 추출
    alarm_name = sns_message.get('AlarmName', 'Unknown')
    alarm_description = sns_message.get('AlarmDescription', '')
    new_state = sns_message.get('NewStateValue', 'UNKNOWN')
    reason = sns_message.get('NewStateReason', '')
    timestamp = sns_message.get('StateChangeTime', '')
    
    print(f"DEBUG: Basic alarm info - Name: {alarm_name}, State: {new_state}, Time: {timestamp}")
    
    # 메트릭 정보 추출
    metric_name = sns_message.get('MetricName', 'Unknown')
    namespace = sns_message.get('Namespace', 'Unknown')
    threshold = sns_message.get('Threshold', 'Unknown')
    
    print(f"DEBUG: Metric info - Name: {metric_name}, Namespace: {namespace}, Threshold: {threshold}")
    
    # Trigger 정보에서 실제 값 추출
    trigger = sns_message.get('Trigger', {})
    print(f"DEBUG: Trigger info: {json.dumps(trigger, indent=2)}")
    
    dimensions = trigger.get('Dimensions', [])
    print(f"DEBUG: Dimensions: {json.dumps(dimensions, indent=2)}")
    
    # 리소스 이름 추출
    resource_name = 'Unknown'
    for dimension in dimensions:
        print(f"DEBUG: Processing dimension: {dimension}")
        if dimension.get('name') in ['DBClusterIdentifier', 'CacheClusterId', 'TableName']:
            resource_name = dimension.get('value', 'Unknown')
            print(f"DEBUG: Found resource name: {resource_name}")
            break
    
    # 실제 메트릭 값 추출 (reason에서 파싱)
    current_value = 'Unknown'
    try:
        print(f"DEBUG: Parsing reason for metric value: {reason}")
        # "Threshold Crossed: 1 datapoint [44.079166666666666 (07/08/25 00:07:00)] was greater than the threshold (80.0)."
        if '[' in reason and ']' in reason:
            value_part = reason.split('[')[1].split(' ')[0]
            current_value = f"{float(value_part):.2f}"
            print(f"DEBUG: Extracted current value: {current_value}")
    except Exception as e:
        print(f"DEBUG: Error parsing current value: {e}")
        current_value = 'Unknown'
    
    # 시간을 한국 표준시로 변환 (pytz 없이)
    kst_time = 'Unknown'
    try:
        print(f"DEBUG: Converting timestamp: {timestamp}")
        # ISO 형식의 UTC 시간을 파싱
        utc_dt = datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
        print(f"DEBUG: Parsed UTC datetime: {utc_dt}")
        # KST는 UTC+9
        kst_dt = utc_dt.astimezone(timezone(timedelta(hours=9)))
        kst_time = kst_dt.strftime('%Y-%m-%d %H:%M:%S KST')
        print(f"DEBUG: Converted to KST: {kst_time}")
    except Exception as e:
        print(f"DEBUG: Error converting timestamp: {e}")
        kst_time = timestamp
    
    # 서비스 이름 추출
    service_name = os.environ.get('SERVICE_NAME', 'unknown')
    print(f"DEBUG: Service name: {service_name}")
    
    # 웹훅 URL 가져오기
    webhook_url = os.environ.get(f'{service_name.upper()}_WEBHOOK_URL')
    print(f"DEBUG: Webhook URL exists: {webhook_url is not None}")
    
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
        status_emoji = '❌'
    elif new_state == 'OK':
        emoji = '✅'
        color = '#00FF00'  # 초록색
        status_emoji = '✅'
    else:
        emoji = '⚠️'
        color = '#FFA500'  # 주황색
        status_emoji = '⚠️'
    
    # 메트릭 타입별 단위 설정
    metric_unit = ''
    if 'CPU' in metric_name:
        metric_unit = '%'
    elif 'Memory' in metric_name:
        if 'Percentage' in metric_name:
            metric_unit = '%'
        else:
            metric_unit = ' bytes'
    elif 'Latency' in metric_name:
        metric_unit = ' ms'
    elif 'Connections' in metric_name:
        metric_unit = ' connections'
    elif 'Rate' in metric_name:
        metric_unit = '%'
    elif 'Throttled' in metric_name or 'Errors' in metric_name:
        metric_unit = ' requests'
    
    # 임계값에 단위 추가
    threshold_display = f"{threshold}{metric_unit}" if threshold != 'Unknown' else 'Unknown'
    current_value_display = f"{current_value}{metric_unit}" if current_value != 'Unknown' else 'Unknown'
    
    print(f"DEBUG: Final values - Threshold: {threshold_display}, Current: {current_value_display}")
    
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
                                "text": f"*📋 알람명*\n`{alarm_name}`"
                            },
                            {
                                "type": "mrkdwn",
                                "text": f"*{status_emoji} 상태*\n`{new_state}`"
                            },
                            {
                                "type": "mrkdwn",
                                "text": f"*🕐 시간*\n`{kst_time}`"
                            },
                            {
                                "type": "mrkdwn",
                                "text": f"*🎯 리소스*\n`{resource_name}`"
                            },
                            {
                                "type": "mrkdwn",
                                "text": f"*📊 현재값*\n`{current_value_display}`"
                            },
                            {
                                "type": "mrkdwn",
                                "text": f"*⚡ 임계값*\n`{threshold_display}`"
                            }
                        ]
                    },
                    {
                        "type": "context",
                        "elements": [
                            {
                                "type": "mrkdwn",
                                "text": f"💡 *메트릭:* {metric_name} | *네임스페이스:* {namespace}"
                            }
                        ]
                    }
                ]
            }
        ]
    }
    
    print(f"DEBUG: Slack message: {json.dumps(slack_message, indent=2)}")
    
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
        print(f"DEBUG: Slack response body: {response.data.decode('utf-8')}")
        
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
