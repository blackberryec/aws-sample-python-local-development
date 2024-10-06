from src.my_lambda.handler import handler


def test_handler():
    event = {}
    context = None
    response = handler(event, context)
    assert response["statusCode"] == 200
    assert "message_one" in response["body"]
    assert "message_two" in response["body"]
