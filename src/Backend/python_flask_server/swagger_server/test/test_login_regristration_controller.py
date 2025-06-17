import unittest
from unittest.mock import patch, MagicMock
import swagger_server.controllers.login_regristration_controller as login_registration_controller

class TestLoginRegistrationController(unittest.TestCase):

    @patch('swagger_server.controllers.login_regristration_controller.supabase')
    @patch('swagger_server.controllers.login_regristration_controller.connexion')
    def test_post_regristration_success(self, mock_connexion, mock_supabase):
        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = {
            "Username": "testuser",
            "Password": "pw",
            "FirstName": "Max",
            "LastName": "Mustermann"
        }
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        mock_supabase.table.return_value.insert.return_value.execute.return_value = MagicMock()
        result, status = login_registration_controller.post_regristration()
        self.assertEqual(status, 200)
        self.assertIn("message", result)

    @patch('swagger_server.controllers.login_regristration_controller.supabase')
    @patch('swagger_server.controllers.login_regristration_controller.connexion')
    def test_post_regristration_username_exists(self, mock_connexion, mock_supabase):
        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = {
            "Username": "testuser",
            "Password": "pw",
            "FirstName": "Max",
            "LastName": "Mustermann"
        }
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [{"Username": "testuser"}]
        result, status = login_registration_controller.post_regristration()
        self.assertEqual(status, 409)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.login_regristration_controller.supabase')
    @patch('swagger_server.controllers.login_regristration_controller.connexion')
    def test_post_login_success(self, mock_connexion, mock_supabase):
        import bcrypt
        pw = bcrypt.hashpw("pw".encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = {
            "Username": "testuser",
            "Password": "pw"
        }
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [{
            "UserID": 1,
            "FirstName": "Max",
            "LastName": "Mustermann",
            "Username": "testuser",
            "Password": pw
        }]
        result, status = login_registration_controller.post_login()
        self.assertEqual(status, 200)
        self.assertIn("message", result)
        self.assertIn("UserID", result)

    @patch('swagger_server.controllers.login_regristration_controller.supabase')
    @patch('swagger_server.controllers.login_regristration_controller.connexion')
    def test_post_login_wrong_password(self, mock_connexion, mock_supabase):
        import bcrypt
        pw = bcrypt.hashpw("pw".encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = {
            "Username": "testuser",
            "Password": "wrongpw"
        }
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [{
            "UserID": 1,
            "FirstName": "Max",
            "LastName": "Mustermann",
            "Username": "testuser",
            "Password": pw
        }]
        result, status = login_registration_controller.post_login()
        self.assertEqual(status, 401)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.login_regristration_controller.supabase')
    @patch('swagger_server.controllers.login_regristration_controller.connexion')
    def test_post_login_user_not_found(self, mock_connexion, mock_supabase):
        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = {
            "Username": "testuser",
            "Password": "pw"
        }
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        result, status = login_registration_controller.post_login()
        self.assertEqual(status, 401)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.login_regristration_controller.supabase')
    @patch('swagger_server.controllers.login_regristration_controller.connexion')
    def test_post_change_password_success(self, mock_connexion, mock_supabase):
        import bcrypt
        old_pw = bcrypt.hashpw("oldpw".encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = {
            "Username": "testuser",
            "OldPassword": "oldpw",
            "NewPassword": "newpw"
        }
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [{
            "Password": old_pw
        }]
        mock_supabase.table.return_value.update.return_value.eq.return_value.execute.return_value.data = [{"Password": "newpw"}]
        result, status = login_registration_controller.post_change_password()
        self.assertEqual(status, 200)
        self.assertIn("message", result)

    @patch('swagger_server.controllers.login_regristration_controller.supabase')
    @patch('swagger_server.controllers.login_regristration_controller.connexion')
    def test_post_change_password_wrong_old(self, mock_connexion, mock_supabase):
        import bcrypt
        old_pw = bcrypt.hashpw("oldpw".encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = {
            "Username": "testuser",
            "OldPassword": "wrongpw",
            "NewPassword": "newpw"
        }
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [{
            "Password": old_pw
        }]
        result, status = login_registration_controller.post_change_password()
        self.assertEqual(status, 401)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.login_regristration_controller.supabase')
    @patch('swagger_server.controllers.login_regristration_controller.connexion')
    def test_post_change_password_user_not_found(self, mock_connexion, mock_supabase):
        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = {
            "Username": "testuser",
            "OldPassword": "oldpw",
            "NewPassword": "newpw"
        }
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        result, status = login_registration_controller.post_change_password()
        self.assertEqual(status, 404)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.login_regristration_controller.supabase')
    @patch('swagger_server.controllers.login_regristration_controller.connexion')
    def test_post_change_username_success(self, mock_connexion, mock_supabase):
        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = {
            "Username": "testuser",
            "NewUsername": "newuser"
        }
        mock_supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.execute.return_value.data = [{"Username": "testuser"}]
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = []
        mock_supabase.table.return_value.update.return_value.eq.return_value.execute.return_value.data = [{"Username": "newuser"}]
        result, status = login_registration_controller.post_change_username()
        self.assertEqual(status, 200)
        self.assertIn("message", result)

    @patch('swagger_server.controllers.login_regristration_controller.supabase')
    @patch('swagger_server.controllers.login_regristration_controller.connexion')
    def test_post_change_username_user_not_found(self, mock_connexion, mock_supabase):
        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = {
            "Username": "testuser",
            "NewUsername": "newuser"
        }
        mock_supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.execute.return_value.data = []
        result, status = login_registration_controller.post_change_username()
        self.assertEqual(status, 404)
        self.assertIn("error", result)

    @patch('swagger_server.controllers.login_regristration_controller.supabase')
    @patch('swagger_server.controllers.login_regristration_controller.connexion')
    def test_post_change_username_username_exists(self, mock_connexion, mock_supabase):
        mock_connexion.request.is_json = True
        mock_connexion.request.get_json.return_value = {
            "Username": "testuser",
            "NewUsername": "newuser"
        }
        mock_supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.execute.return_value.data = [{"Username": "testuser"}]
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [{"Username": "newuser"}]
        result, status = login_registration_controller.post_change_username()
        self.assertEqual(status, 409)
        self.assertIn("error", result)

if __name__ == '__main__':
    unittest.main()