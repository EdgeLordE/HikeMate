import connexion
import json


from supabase import create_client

SUPABASE_URL="https://cyzdfdweghhrlquxwaxl.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def get_activities():
    """
    Get all activities
    """
    try:
        response = supabase.table('Activity').select("*").execute()
        if response.data:
            return {"response": response.data}, 200
        else:
            return {"message": "No activities found"}, 404
    except Exception as e:
        return {"error": str(e)}, 500
    

def get_activities_by_user_id(user_id):
    """
    Get activity by ID
    """
    try:
        response = supabase.table('Activity').select("*").eq("UserID", user_id).execute()
        if response.data:
            return {"response": response.data}, 200
        else:
            return {"message": "Activity not found"}, 404
    except Exception as e:
        return {"error": str(e)}, 500
