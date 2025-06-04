import connexion
import six
import sqlite3
import json
import time

from supabase import create_client 

SUPABASE_URL="https://cyzdfdweghhrlquxwaxl.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def post_regristration():
    
    if connexion.request.is_json:
        data = connexion.request.get_json()
        username = data.get("Username")
        # Prüfen, ob Username schon existiert
        exists = supabase.table('User').select("Username").eq("Username", username).execute()
        if exists.data and len(exists.data) > 0:
            return {"error": "Username already exists"}, 409

        user_data = {
            "FirstName": data.get("FirstName"),
            "LastName": data.get("LastName"),
            "Username": username,
            "Password": data.get("Password")
        }

        response = supabase.table('User').insert(user_data).execute()
        
        return {"User registered successfully"}, 200
            
    



