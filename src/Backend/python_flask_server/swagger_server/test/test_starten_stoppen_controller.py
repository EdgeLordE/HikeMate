# coding: utf-8

from __future__ import absolute_import

from flask import json
from six import BytesIO

from swagger_server.test import BaseTestCase


class TestStartenStoppenController(BaseTestCase):
    """StartenStoppenController integration test stubs"""

    def test_start_post(self):
        """Test case for start_post

        Startet die Kaffeemaschine
        """
        response = self.client.open(
            '/start',
            method='POST')
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    def test_stop_post(self):
        """Test case for stop_post

        Stoppt die Kaffeemaschine
        """
        response = self.client.open(
            '/stop',
            method='POST')
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))


if __name__ == '__main__':
    import unittest
    unittest.main()
