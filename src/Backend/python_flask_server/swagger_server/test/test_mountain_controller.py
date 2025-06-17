import unittest
from unittest.mock import patch, MagicMock
import swagger_server.controllers.mountain_controller as mountain_controller

class TestMountainController(unittest.TestCase):
    @patch('swagger_server.controllers.mountain_controller.supabase')
    def test_get_mountain_by_name_success(self, mock_supabase):
        """
        @brief Testet das erfolgreiche Finden von Bergen anhand eines Namens.
        @test Erwartet Status 200 und eine Liste mit mindestens einem Berg.
        """
        mock_response = MagicMock()
        mock_response.data = [
            {
                "Mountainid": 1,
                "Name": "Großglockner",
                "Height": 3798,
                "Picture": "grossglockner.jpg",
                "FederalStateid": {"Name": "Tirol"}
            }
        ]
        mock_supabase.table.return_value.select.return_value.ilike.return_value.execute.return_value = mock_response

        result, status = mountain_controller.get_mountain_by_name("glockner")
        self.assertEqual(status, 200)
        self.assertIn("response", result)
        self.assertGreaterEqual(len(result["response"]), 1)

    @patch('swagger_server.controllers.mountain_controller.supabase')
    def test_get_mountain_by_name_not_found(self, mock_supabase):
        mock_response = MagicMock()
        mock_response.data = []
        mock_supabase.table.return_value.select.return_value.ilike.return_value.execute.return_value = mock_response

        result, status = mountain_controller.get_mountain_by_name("unbekannterberg")
        self.assertEqual(status, 404)
        self.assertIn("message", result)

    @patch('swagger_server.controllers.mountain_controller.supabase')
    def test_get_mountain_by_name_server_error(self, mock_supabase):
        mock_supabase.table.return_value.select.return_value.ilike.return_value.execute.side_effect = Exception("DB error")
        result, status = mountain_controller.get_mountain_by_name("glockner")
        self.assertEqual(status, 500)
        self.assertIn("error", result)

if __name__ == '__main__':
    unittest.main()