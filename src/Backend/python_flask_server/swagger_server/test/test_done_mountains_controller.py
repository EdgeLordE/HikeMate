import unittest
from unittest.mock import patch, MagicMock
import swagger_server.controllers.done_mountains_controller as done_mountains_controller

class TestDoneMountainsController(unittest.TestCase):

    @patch('swagger_server.controllers.done_mountains_controller.supabase')
    @patch('swagger_server.controllers.done_mountains_controller.connexion')
    def test_post_done_mountain_with_user_id_success(self, mock_connexion, mock_supabase):
        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = {"UserID": 1, "MountainID": 2}
        mock_response = MagicMock()
        mock_response.data = [{"DoneID": 1, "UserID": 1, "MountainID": 2, "Date": "2025-06-17T12:00:00"}]
        mock_supabase.table.return_value.insert.return_value.execute.return_value = mock_response

        result, status = done_mountains_controller.post_done_mountain_with_user_id()
        self.assertEqual(status, 201)
        self.assertIn("done_mountain", result)

    @patch('swagger_server.controllers.done_mountains_controller.connexion')
    def test_post_done_mountain_with_user_id_missing_json(self, mock_connexion):
        mock_connexion.request.is_json = False
        result, status = done_mountains_controller.post_done_mountain_with_user_id()
        self.assertEqual(status, 400)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.done_mountains_controller.connexion')
    def test_post_done_mountain_with_user_id_missing_fields(self, mock_connexion):
        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = {"UserID": 1}
        result, status = done_mountains_controller.post_done_mountain_with_user_id()
        self.assertEqual(status, 400)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.done_mountains_controller.supabase')
    @patch('swagger_server.controllers.done_mountains_controller.connexion')
    def test_post_done_mountain_with_user_id_server_error(self, mock_connexion, mock_supabase):
        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = {"UserID": 1, "MountainID": 2}
        mock_supabase.table.return_value.insert.return_value.execute.side_effect = Exception("DB error")
        result, status = done_mountains_controller.post_done_mountain_with_user_id()
        self.assertEqual(status, 500)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.done_mountains_controller.supabase')
    @patch('swagger_server.controllers.done_mountains_controller.connexion')
    def test_check_if_mountain_is_done_true(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.side_effect = lambda k: {"UserID": "1", "MountainID": "2"}.get(k)
        mock_response = MagicMock()
        mock_response.data = [{"DoneID": 1}]
        mock_supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.execute.return_value = mock_response

        result, status = done_mountains_controller.check_if_mountain_is_done()
        self.assertEqual(status, 200)
        self.assertTrue(result["response"]["isDone"])

    @patch('swagger_server.controllers.done_mountains_controller.supabase')
    @patch('swagger_server.controllers.done_mountains_controller.connexion')
    def test_check_if_mountain_is_done_false(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.side_effect = lambda k: {"UserID": "1", "MountainID": "2"}.get(k)
        mock_response = MagicMock()
        mock_response.data = []
        mock_supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.execute.return_value = mock_response

        result, status = done_mountains_controller.check_if_mountain_is_done()
        self.assertEqual(status, 200)
        self.assertFalse(result["response"]["isDone"])

    @patch('swagger_server.controllers.done_mountains_controller.connexion')
    def test_check_if_mountain_is_done_missing_params(self, mock_connexion):
        mock_connexion.request.args.get.side_effect = lambda k: None
        result, status = done_mountains_controller.check_if_mountain_is_done()
        self.assertEqual(status, 400)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.done_mountains_controller.connexion')
    def test_check_if_mountain_is_done_invalid_params(self, mock_connexion):
        mock_connexion.request.args.get.side_effect = lambda k: "abc"
        result, status = done_mountains_controller.check_if_mountain_is_done()
        self.assertEqual(status, 400)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.done_mountains_controller.supabase')
    @patch('swagger_server.controllers.done_mountains_controller.connexion')
    def test_is_mountain_done_by_user_true(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.side_effect = lambda k: {"UserID": "1", "MountainID": "2"}.get(k)
        mock_response = MagicMock()
        mock_response.data = [{"MountainID": 2}]
        mock_supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.limit.return_value.execute.return_value = mock_response

        result, status = done_mountains_controller.is_mountain_done_by_user()
        self.assertEqual(status, 200)
        self.assertTrue(result["isDone"])

    @patch('swagger_server.controllers.done_mountains_controller.supabase')
    @patch('swagger_server.controllers.done_mountains_controller.connexion')
    def test_is_mountain_done_by_user_false(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.side_effect = lambda k: {"UserID": "1", "MountainID": "2"}.get(k)
        mock_response = MagicMock()
        mock_response.data = []
        mock_supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.limit.return_value.execute.return_value = mock_response

        result, status = done_mountains_controller.is_mountain_done_by_user()
        self.assertEqual(status, 200)
        self.assertFalse(result["isDone"])

    @patch('swagger_server.controllers.done_mountains_controller.connexion')
    def test_is_mountain_done_by_user_missing_params(self, mock_connexion):
        mock_connexion.request.args.get.side_effect = lambda k: None
        result, status = done_mountains_controller.is_mountain_done_by_user()
        self.assertEqual(status, 400)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.done_mountains_controller.connexion')
    def test_is_mountain_done_by_user_invalid_params(self, mock_connexion):
        mock_connexion.request.args.get.side_effect = lambda k: "abc"
        result, status = done_mountains_controller.is_mountain_done_by_user()
        self.assertEqual(status, 400)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.done_mountains_controller.supabase')
    @patch('swagger_server.controllers.done_mountains_controller.connexion')
    def test_delete_done_mountain_success(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.side_effect = lambda k: {"DoneID": "1", "UserID": "2"}.get(k)
        mock_response = MagicMock()
        mock_response.data = [{"DoneID": 1}]
        mock_response.error = None  # <--- Diese Zeile hinzufügen!
        mock_supabase.table.return_value.delete.return_value.eq.return_value.eq.return_value.execute.return_value = mock_response

        result, status = done_mountains_controller.delete_done_mountain()
        self.assertEqual(status, 200)
        self.assertIn("message", result)

    @patch('swagger_server.controllers.done_mountains_controller.supabase')
    @patch('swagger_server.controllers.done_mountains_controller.connexion')
    def test_delete_done_mountain_error(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.side_effect = lambda k: {"DoneID": "1", "UserID": "2"}.get(k)
        mock_response = MagicMock()
        mock_response.data = None
        mock_response.error = MagicMock()
        mock_response.error.message = "Fehler"
        mock_supabase.table.return_value.delete.return_value.eq.return_value.eq.return_value.execute.return_value = mock_response

        result, status = done_mountains_controller.delete_done_mountain()
        self.assertEqual(status, 500)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.done_mountains_controller.connexion')
    def test_delete_done_mountain_missing_params(self, mock_connexion):
        mock_connexion.request.args.get.side_effect = lambda k: None
        result, status = done_mountains_controller.delete_done_mountain()
        self.assertEqual(status, 400)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.done_mountains_controller.supabase')
    @patch('swagger_server.controllers.done_mountains_controller.connexion')
    def test_get_done_mountains_by_user_id_success(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.return_value = "1"
        mock_response = MagicMock()
        mock_response.data = [
            {"DoneID": 1, "Date": "2025-06-17T12:00:00", "Mountain": {"Mountainid": 2, "Name": "Berg", "Height": 2000, "FederalState": {"Name": "Tirol"}}}
        ]
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value = mock_response

        result, status = done_mountains_controller.get_done_mountains_by_user_id()
        self.assertEqual(status, 200)
        self.assertIn("data", result)
        self.assertEqual(len(result["data"]), 1)

    @patch('swagger_server.controllers.done_mountains_controller.connexion')
    def test_get_done_mountains_by_user_id_missing_user_id(self, mock_connexion):
        mock_connexion.request.args.get.return_value