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
    


