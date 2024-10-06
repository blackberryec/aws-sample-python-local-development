from layers.shared_layer_two import utils_two


def test_get_another_message():
    assert utils_two.get_another_message() == \
        "Hello from shared utility in Layer Two!"
