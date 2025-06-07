import connexion
import json
from datetime import datetime


from supabase import create_client

SUPABASE_URL="https://cyzdfdweghhrlquxwaxl.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def get_done_mountains_by_user_id(user_id):
    """
    Get done activities by user ID
    """
    try:
        response = supabase.table('Done').select("*").eq("UserID", user_id).execute()
        if response.data:
            return {"response": response.data}, 200
        else:
            return {"message": "No done activities found for this user"}, 404
    except Exception as e:
        return {"error": str(e)}, 500
    
def post_done_mountain_with_user_id(mountain_id, user_id):
    """
    Post done mountain with user ID
    """
    
    if not mountain_id:
        return {"error": "MountainID is required"}, 400
    
    done_data = {
        "UserID": user_id,
        "MountainID": mountain_id,
        "Date": datetime.now().isoformat()
    }
    
    try:
        response = supabase.table('Done').insert(done_data).execute()
        return {"message": "Mountain marked as done", "done_mountain": response.data}, 200
    except Exception as e:
        return {"error": str(e)}, 500
    