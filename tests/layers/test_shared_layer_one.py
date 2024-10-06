from layers.shared_layer_one import utils_one


def test_get_message():
    assert utils_one.get_message() == "Hello from shared utility in Layer One!"
