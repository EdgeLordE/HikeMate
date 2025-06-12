import connexion
import json

from supabase import create_client

SUPABASE_URL="https://cyzdfdweghhrlquxwaxl.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def post_watchlist():
    """
    Add a new item to the watchlist (expects JSON body)
    """
    if not connexion.request.is_json:
        return {"error": "Request must be JSON"}, 400

    data = connexion.request.get_json()
    user_id = data.get("UserID")
    mountain_id = data.get("MountainID")

    if not user_id or not mountain_id:
        return {"error": "UserID and MountainID are required"}, 400

    try:
        watchlist_item = {
            "UserID": user_id,
            "MountainID": mountain_id
        }
        response = supabase.table('Watchlist').insert(watchlist_item).execute()
        if response.data:
            return {"response": response.data}, 201
        else:
            return {"message": "Failed to add item to watchlist"}, 400
    except Exception as e:
        return {"error": str(e)}, 500

def get_watchlist_by_user_id():
    """
    Get watchlist by UserID
    """
    user_id = connexion.request.args.get('UserID')
    if not user_id:
        return {"error": "UserID is required"}, 400

    try:
        response = supabase.table('Watchlist').select("MountainID").eq("UserID", user_id).execute()
        if response.data:
            return {"response": response.data}, 200
        else:
            return {"message": "No items found in watchlist for this user"}, 404
    except Exception as e:
        return {"error": str(e)}, 500