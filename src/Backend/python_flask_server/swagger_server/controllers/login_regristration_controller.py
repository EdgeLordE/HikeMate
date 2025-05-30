import connexion
import six
import sqlite3
import json
import time

from supabase import create_client 

SUPABASE_URL="https://cyzdfdweghhrlquxwaxl.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0ODI0OTg4NiwiZXhwIjoyMDYzODI1ODg2fQ.oy_jDpYbgoqvEbYuPrHT8kUVuo5YpeQKvVZKZEuulZE"

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def post_regristration():
    try:
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

            if hasattr(response, "status_code") and response.status_code == 201:
                return {"message": "User registered successfully"}, 201
            else:
                return {"error": str(response)}, 400
        else:
            return {"error": "Invalid input"}, 400
    except Exception as e:
        return {"error": str(e)}, 500



