from src.another_lambda.handler import handler


def test_handler():
    event = {}
    context = None
    response = handler(event, context)
    assert response["statusCode"] == 200
    assert "message" in response["body"]
