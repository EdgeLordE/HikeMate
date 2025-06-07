import connexion
import json


from supabase import create_client

SUPABASE_URL="https://cyzdfdweghhrlquxwaxl.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def get_federal_state_by_id(federal_state_id):
    """
    Get federal state by ID
    """
    try:
        response = supabase.table('FederalState').select("*").eq("FederalStateid", federal_state_id).execute()
        if response.data:
            return {"response": response.data[0]}, 200
        else:
            return {"message": "Federal state not found"}, 404
    except Exception as e:
        return {"error": str(e)}, 500