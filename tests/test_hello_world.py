import unittest

import azure.functions as func
from function_app.hello_world import main


class HelloWorldTests(unittest.TestCase):
    def request(self, params=None, body=b""):
        return func.HttpRequest(
            method="GET", url="http://localhost/api/hello_world",
            params=params or {}, body=body,
        )

    def test_query_name(self):
        response = main(self.request({"name": "홍길동"}))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_body().decode(), "Hello, 홍길동!")

    def test_json_name(self):
        response = main(self.request(body=b'{"name":"Azure"}'))
        self.assertEqual(response.get_body(), b"Hello, Azure!")

    def test_query_takes_precedence(self):
        response = main(self.request({"name": "Query"}, b'{"name":"Body"}'))
        self.assertEqual(response.get_body(), b"Hello, Query!")

    def test_missing_or_invalid_name(self):
        for body in (b"", b"invalid", b"{}", b"null", b"[]", b"42", b'"text"'):
            with self.subTest(body=body):
                self.assertEqual(main(self.request(body=body)).status_code, 400)


if __name__ == "__main__":
    unittest.main()
