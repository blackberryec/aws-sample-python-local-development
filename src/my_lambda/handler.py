import json
from shared_layer_one import utils_one
from shared_layer_two import utils_two


def handler(event, context):
    message_one = utils_one.get_message()
    message_two = utils_two.get_another_message()
    return {
        "statusCode": 200,
        "body": json.dumps({"message_one": message_one,
                            "message_two": message_two})
    }
