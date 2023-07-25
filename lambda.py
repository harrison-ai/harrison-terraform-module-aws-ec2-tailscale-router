import boto3
import logging
from os import environ

autoscaling = boto3.client("autoscaling")


def handler(event, context):
    try:
        response = autoscaling.start_instance_refresh(
            AutoScalingGroupName=environ["AUTO_SCALING_GROUP_NAME"], Strategy="Rolling"
        )
        logging.info(response)
        return True
    except Exception as ex:
        logging.exception(ex)
        return None
