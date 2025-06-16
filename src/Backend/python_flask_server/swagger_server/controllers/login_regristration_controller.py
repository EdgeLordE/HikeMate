import connexion
import six
import sqlite3
import json
import time
import bcrypt

from supabase import create_client 

SUPABASE_URL="https://cyzdfdweghhrlquxwaxl.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def post_regristration():
    if connexion.request.is_json:
        data = connexion.request.get_json()
        username = data.get("Username")
        exists = supabase.table('User').select("Username").eq("Username", username).execute()
        if exists.data and len(exists.data) > 0:
            return {"error": "Username already exists"}, 409

        password = data.get("Password")
        hashed_pw = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

        user_data = {
            "FirstName": data.get("FirstName"),
            "LastName": data.get("LastName"),
            "Username": username,
            "Password": hashed_pw
        }

        response = supabase.table('User').insert(user_data).execute()
        return {"message": "User registered successfully"}, 200
    
def post_login():
    if connexion.request.is_json:
        data = connexion.request.get_json()
        username = data.get("Username")
        password = data.get("Password")

        user_data = supabase.table('User').select("*").eq("Username", username).execute()

        if not user_data.data or len(user_data.data) == 0:
            return {"error": "Invalid username or password"}, 401

        user = user_data.data[0]
        if bcrypt.checkpw(password.encode("utf-8"), user["Password"].encode("utf-8")):
            return {
                "message": "Login successful",
                "UserID": user["UserID"],
                "FirstName": user["FirstName"],
                "LastName": user["LastName"],
                "Username": user["Username"]
            }, 200
        else:
            return {"error": "Invalid username or password"}, 401
        

        
def post_change_password():
    if connexion.request.is_json:
        data = connexion.request.get_json()
        username = data.get("Username")
        old_password = data.get("OldPassword")
        new_password = data.get("NewPassword")

        if not username or not old_password or not new_password:
            return {"error": "Username, OldPassword, and NewPassword are required"}, 400

        user_data = supabase.table('User').select("Password").eq("Username", username).execute()
        if not user_data.data or len(user_data.data) == 0:
            return {"error": "User not found"}, 404

        hashed_old_pw = user_data.data[0]["Password"]
        if not bcrypt.checkpw(old_password.encode("utf-8"), hashed_old_pw.encode("utf-8")):
            return {"error": "Old password is incorrect"}, 401

        hashed_new_pw = bcrypt.hashpw(new_password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
        response = supabase.table('User').update({"Password": hashed_new_pw}).eq("Username", username).execute()

        if response.data:
            return {"message": "Password changed successfully"}, 200
        else:
            return {"error": "Failed to change password"}, 500
    return {"error": "Request must be JSON"}, 400



def post_change_username():
    if connexion.request.is_json:
        data = connexion.request.get_json()
        new_username = data.get("NewUsername")
        username = data.get("Username")

        if not username or not new_username:
            return {"error": "UserID and NewUsername are required"}, 400
        
        exists = supabase.table('User').select("Username").eq("Username", username).eq("Username", username).execute()
        if not exists.data or len(exists.data) == 0:
            return {"error": "User not found"}, 404

        exists = supabase.table('User').select("Username").eq("Username", new_username).execute()
        if exists.data and len(exists.data) > 0:
            return {"error": "Username already exists"}, 409

        response = supabase.table('User').update({"Username": new_username}).eq("Username", username).execute()

        if response.data:
            return {"message": "Username changed successfully"}, 200
        else:
            return {"error": "Failed to change username"}, 500
    return {"error": "Request must be JSON"}, 400


def get_phone_number():
    """
    Gibt die Telefonnummer (ContactNumber) eines Users zurück.
    Erwartet: GET /User/phone?UserID=...
    """
    try:
        user_id = connexion.request.args.get("UserID")
        if not user_id:
            return {"error": "UserID ist erforderlich."}, 400
        try:
            user_id = int(user_id)
        except ValueError:
            return {"error": "UserID muss eine Zahl sein."}, 400

        response = supabase.table('User').select("ContactNumber").eq("UserID", user_id).single().execute()
        if response.data and "ContactNumber" in response.data:
            return {"ContactNumber": response.data["ContactNumber"]}, 200
        else:
            return {"ContactNumber": ""}, 200
    except Exception as e:
        return {"error": str(e)}, 500

def update_phone_number():
    """
    Aktualisiert die Telefonnummer (ContactNumber) eines Users.
    Erwartet: PUT /User/phone mit JSON {"UserID": ..., "ContactNumber": "..."}
    """
    if not connexion.request.is_json:
        return {"error": "Request must be JSON"}, 400
    data = connexion.request.get_json()
    user_id = data.get("UserID")
    phone = data.get("ContactNumber")
    if not user_id or phone is None:
        return {"error": "UserID und ContactNumber sind erforderlich."}, 400
    try:
        user_id = int(user_id)
    except ValueError:
        return {"error": "UserID muss eine Zahl sein."}, 400

    try:
        response = supabase.table('User').update({"ContactNumber": phone}).eq("UserID", user_id).execute()
        return {"message": "Telefonnummer gespeichert"}, 200
    except Exception as e:
        return {"error": str(e)}, 500
    


