import unittest
from unittest.mock import patch, MagicMock
import sys


import swagger_server.controllers.activity_controller as activity_controller


class TestActivityController(unittest.TestCase):
    @patch('swagger_server.controllers.activity_controller.supabase')
    @patch('swagger_server.controllers.activity_controller.connexion')
    def test_get_activities_by_user_id_success(self, mock_connexion, mock_supabase):
        
        mock_connexion.request.args.get.return_value = "42"
        
        mock_response = MagicMock()
        mock_response.data = [
            {"Distance": 10, "Increase": 500, "Duration": 120, "Calories": 800, "MaxAltitude": 2000, "Date": "2024-06-01"}
        ]
        mock_supabase.table.return_value.select.return_value.eq.return_value.order.return_value.execute.return_value = mock_response

        result, status = activity_controller.get_activities_by_user_id()
        self.assertEqual(status, 200)
        self.assertIn("activities", result)
        self.assertEqual(len(result["activities"]), 1)

    @patch('swagger_server.controllers.activity_controller.connexion')
    def test_get_activities_by_user_id_missing_user_id(self, mock_connexion):
        mock_connexion.request.args.get.return_value = None
        result, status = activity_controller.get_activities_by_user_id()
        self.assertEqual(status, 400)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.activity_controller.connexion')
    def test_get_activities_by_user_id_invalid_user_id(self, mock_connexion):
        mock_connexion.request.args.get.return_value = "abc"
        result, status = activity_controller.get_activities_by_user_id()
        self.assertEqual(status, 400)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.activity_controller.supabase')
    @patch('swagger_server.controllers.activity_controller.connexion')
    def test_get_activities_by_user_id_server_error(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.return_value = "42"
        mock_supabase.table.side_effect = Exception("DB error")
        result, status = activity_controller.get_activities_by_user_id()
        self.assertEqual(status, 500)
        self.assertIn("error", result)

if __name__ == '__main__':
    unittest.main()