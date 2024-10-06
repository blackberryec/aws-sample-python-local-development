import json
from layers.shared_layer_one import utils_one


def handler(event, context):
    message = utils_one.get_message()
    return {
        "statusCode": 200,
        "body": json.dumps({"message": message})
    }
