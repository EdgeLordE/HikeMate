import unittest
from unittest.mock import patch, MagicMock
import swagger_server.controllers.Watchlist_controller as Watchlist_controller

class TestWatchlistController(unittest.TestCase):

    @patch('swagger_server.controllers.Watchlist_controller.supabase')
    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_add_mountain_to_watchlist_success(self, mock_connexion, mock_supabase):
        mock_connexion.request.is_json = True
        mock_connexion.request.json = {"UserID": 1, "MountainID": 2}
        mock_supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.limit.return_value.execute.side_effect = [
            MagicMock(data=[]),  
            MagicMock(data=[])   
        ]
        mock_supabase.table.return_value.insert.return_value.execute.return_value.data = [{"WatchlistID": 1, "UserID": 1, "MountainID": 2}]
        result, status = Watchlist_controller.add_mountain_to_watchlist()
        self.assertEqual(status, 201)
        self.assertIn("message", result)

    @patch('swagger_server.controllers.Watchlist_controller.supabase')
    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_add_mountain_to_watchlist_already_on_watchlist(self, mock_connexion, mock_supabase):
        mock_connexion.request.is_json = True
        mock_connexion.request.json = {"UserID": 1, "MountainID": 2}
        mock_supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.limit.return_value.execute.side_effect = [
            MagicMock(data=[{"WatchlistID": 1}]),  
        ]
        result, status = Watchlist_controller.add_mountain_to_watchlist()
        self.assertEqual(status, 409)
        self.assertIn("message", result)

    @patch('swagger_server.controllers.Watchlist_controller.supabase')
    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_add_mountain_to_watchlist_already_done(self, mock_connexion, mock_supabase):
        mock_connexion.request.is_json = True
        mock_connexion.request.json = {"UserID": 1, "MountainID": 2}
        mock_supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.limit.return_value.execute.side_effect = [
            MagicMock(data=[]),  
            MagicMock(data=[{"DoneID": 1}])  
        ]
        result, status = Watchlist_controller.add_mountain_to_watchlist()
        self.assertEqual(status, 403)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.Watchlist_controller.supabase')
    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_add_mountain_to_watchlist_missing_fields(self, mock_connexion, mock_supabase):
        mock_connexion.request.is_json = True
        mock_connexion.request.json = {"UserID": 1}
        result, status = Watchlist_controller.add_mountain_to_watchlist()
        self.assertEqual(status, 400)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_add_mountain_to_watchlist_not_json(self, mock_connexion):
        mock_connexion.request.is_json = False
        result, status = Watchlist_controller.add_mountain_to_watchlist()
        self.assertEqual(status, 400)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.Watchlist_controller.supabase')
    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_add_mountain_to_watchlist_server_error(self, mock_connexion, mock_supabase):
        mock_connexion.request.is_json = True
        mock_connexion.request.json = {"UserID": 1, "MountainID": 2}
        mock_supabase.table.side_effect = Exception("DB error")
        result, status = Watchlist_controller.add_mountain_to_watchlist()
        self.assertEqual(status, 500)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.Watchlist_controller.supabase')
    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_check_if_mountain_is_on_watchlist_true(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.side_effect = lambda k: {"UserID": "1", "MountainID": "2"}.get(k)
        mock_response = MagicMock()
        mock_response.data = [{"WatchlistID": 1}]
        mock_supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.execute.return_value = mock_response
        result, status = Watchlist_controller.check_if_mountain_is_on_watchlist()
        self.assertEqual(status, 200)
        self.assertTrue(result["response"]["isOnWatchlist"])

    @patch('swagger_server.controllers.Watchlist_controller.supabase')
    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_check_if_mountain_is_on_watchlist_false(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.side_effect = lambda k: {"UserID": "1", "MountainID": "2"}.get(k)
        mock_response = MagicMock()
        mock_response.data = []
        mock_supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.execute.return_value = mock_response
        result, status = Watchlist_controller.check_if_mountain_is_on_watchlist()
        self.assertEqual(status, 200)
        self.assertFalse(result["response"]["isOnWatchlist"])

    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_check_if_mountain_is_on_watchlist_missing_params(self, mock_connexion):
        mock_connexion.request.args.get.side_effect = lambda k: None
        result, status = Watchlist_controller.check_if_mountain_is_on_watchlist()
        self.assertEqual(status, 400)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_check_if_mountain_is_on_watchlist_invalid_params(self, mock_connexion):
        mock_connexion.request.args.get.side_effect = lambda k: "abc"
        result, status = Watchlist_controller.check_if_mountain_is_on_watchlist()
        self.assertEqual(status, 400)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.Watchlist_controller.supabase')
    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_remove_mountain_from_watchlist_success(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.side_effect = lambda k: {"UserID": "1", "MountainID": "2"}.get(k)
        mock_response = MagicMock()
        mock_response.data = [{"WatchlistID": 1}]
        mock_supabase.table.return_value.delete.return_value.eq.return_value.eq.return_value.execute.return_value = mock_response
        result, status = Watchlist_controller.remove_mountain_from_watchlist()
        self.assertEqual(status, 200)
        self.assertIn("message", result)

    @patch('swagger_server.controllers.Watchlist_controller.supabase')
    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_remove_mountain_from_watchlist_invalid_params(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.side_effect = lambda k: {"UserID": "abc", "MountainID": "2"}.get(k)
        result, status = Watchlist_controller.remove_mountain_from_watchlist()
        self.assertEqual(status, 400)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.Watchlist_controller.supabase')
    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_remove_mountain_from_watchlist_server_error(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.side_effect = lambda k: {"UserID": "1", "MountainID": "2"}.get(k)
        mock_supabase.table.side_effect = Exception("DB error")
        result, status = Watchlist_controller.remove_mountain_from_watchlist()
        self.assertEqual(status, 500)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.Watchlist_controller.supabase')
    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_fetch_watchlist_success(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.return_value = "1"
        mock_response = MagicMock()
        mock_response.data = [
            {"WatchlistID": 1, "MountainID": 2, "Mountain": {"Name": "Berg", "Height": 2000}}
        ]
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value = mock_response
        result, status = Watchlist_controller.fetch_watchlist()
        self.assertEqual(status, 200)
        self.assertIn("response", result)

    @patch('swagger_server.controllers.Watchlist_controller.supabase')
    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_fetch_watchlist_invalid_user_id(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.return_value = "abc"
        result, status = Watchlist_controller.fetch_watchlist()
        self.assertEqual(status, 400)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.Watchlist_controller.supabase')
    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_fetch_watchlist_server_error(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.return_value = "1"
        mock_supabase.table.side_effect = Exception("DB error")
        result, status = Watchlist_controller.fetch_watchlist()
        self.assertEqual(status, 500)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.Watchlist_controller.supabase')
    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_delete_watchlist_entry_by_id_success(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.side_effect = lambda k: {"WatchlistID": "1", "UserID": "2"}.get(k)
        mock_supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.limit.return_value.execute.return_value.data = [{"WatchlistID": 1}]
        mock_supabase.table.return_value.delete.return_value.eq.return_value.eq.return_value.execute.return_value.data = [{"WatchlistID": 1}]
        result, status = Watchlist_controller.delete_watchlist_entry_by_id()
        self.assertEqual(status, 200)
        self.assertIn("message", result)

    @patch('swagger_server.controllers.Watchlist_controller.supabase')
    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_delete_watchlist_entry_by_id_not_found(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.side_effect = lambda k: {"WatchlistID": "1", "UserID": "2"}.get(k)
        mock_supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.limit.return_value.execute.return_value.data = []
        result, status = Watchlist_controller.delete_watchlist_entry_by_id()
        self.assertEqual(status, 404)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.Watchlist_controller.supabase')
    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_delete_watchlist_entry_by_id_invalid_params(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.side_effect = lambda k: {"WatchlistID": "abc", "UserID": "2"}.get(k)
        result, status = Watchlist_controller.delete_watchlist_entry_by_id()
        self.assertEqual(status, 400)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.Watchlist_controller.supabase')
    @patch('swagger_server.controllers.Watchlist_controller.connexion')
    def test_delete_watchlist_entry_by_id_server_error(self, mock_connexion, mock_supabase):
        mock_connexion.request.args.get.side_effect = lambda k: {"WatchlistID": "1", "UserID": "2"}.get(k)
        mock_supabase.table.side_effect = Exception("DB error")
        result, status = Watchlist_controller.delete_watchlist_entry_by_id()
        self.assertEqual(status, 500)
        self.assertIn("error", result)

if __name__ == '__main__':
    unittest.main()