import connexion
import json

from supabase import create_client

SUPABASE_URL="https://cyzdfdweghhrlquxwaxl.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def post_watchlist(user_id, mountain_id):
    """
    Add a new item to the watchlist
    """
    try:
        watchlist_item = {
            "UserID": user_id,
            "MountainID": mountain_id
        }
        response = supabase.table('Watchlist').insert(watchlist_item).execute()
        if response.data:
            return {"response": response.data}, 200
        else:
            return {"message": "Failed to add item to watchlist"}, 404
    except Exception as e:
        return {"error": str(e)}, 500