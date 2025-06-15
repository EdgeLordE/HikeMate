# File: src/backend/python_flask_server/swagger_server/controllers/mountain_controller.py
import connexion
import json
from supabase import create_client, Client
from datetime import datetime, timezone

# --- Supabase Client Initialisierung ---
SUPABASE_URL="https://cyzdfdweghhrlquxwaxl.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)


def get_mountain_by_name(mountain_name):
    """
    Get mountain by name (case-insensitive partial match)
    Includes: Mountainid, Name, Height, FederalStateid (Name), Picture
    """
    try:
        # Using ilike for case-insensitive partial match
        # Joining with FederalState table to get the Name
        response = supabase.table('Mountain').select(
            "Mountainid, Name, Height, Picture, FederalStateid (Name)"
        ).ilike('Name', f'%{mountain_name}%').execute()

        if response.data:
            return {"response": response.data}, 200
        else:
            return {"message": "No mountains found with that name"}, 404
    except Exception as e:
        print(f"Error in get_mountain_by_name: {e}")
        return {"error": str(e)}, 500



