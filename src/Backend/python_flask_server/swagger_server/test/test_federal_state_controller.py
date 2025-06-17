import unittest
from unittest.mock import patch, MagicMock
import swagger_server.controllers.federal_state_controller as federal_state_controller

class TestFederalStateController(unittest.TestCase):

    @patch('swagger_server.controllers.federal_state_controller.supabase')
    def test_get_federal_state_by_id_success(self, mock_supabase):
        mock_response = MagicMock()
        mock_response.data = [{"FederalStateid": 1, "Name": "Tirol"}]
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value = mock_response

        result, status = federal_state_controller.get_federal_state_by_id(1)
        self.assertEqual(status, 200)
        self.assertIn("response", result)
        self.assertEqual(result["response"]["Name"], "Tirol")

    @patch('swagger_server.controllers.federal_state_controller.supabase')
    def test_get_federal_state_by_id_not_found(self, mock_supabase):
        mock_response = MagicMock()
        mock_response.data = []
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value = mock_response

        result, status = federal_state_controller.get_federal_state_by_id(999)
        self.assertEqual(status, 404)
        self.assertIn("message", result)

    @patch('swagger_server.controllers.federal_state_controller.supabase')
    def test_get_federal_state_by_id_server_error(self, mock_supabase):
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.side_effect = Exception("DB error")
        result, status = federal_state_controller.get_federal_state_by_id(1)
        self.assertEqual(status, 500)
        self.assertIn("error", result)

if __name__ == '__main__':
    unittest.main()