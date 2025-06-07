import connexion
import json


from supabase import create_client

SUPABASE_URL="https://cyzdfdweghhrlquxwaxl.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def get_mountain_by_name(mountain_name):
    """
    Get mountain by name
    """
    try:
        response = supabase.table('Mountain').select("*").ilike("Name", f"%{mountain_name}%").execute()
        if response.data:
            return {"response": response.data}, 200
        else:
            return {"message": "No mountains found with that name"}, 404
    except Exception as e:
        return {"error": str(e)}, 500