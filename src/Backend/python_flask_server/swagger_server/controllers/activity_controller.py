import connexion
import json


from supabase import create_client

SUPABASE_URL="https://cyzdfdweghhrlquxwaxl.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)


    

def get_activities_by_user_id():
    """
    Gibt alle Aktivitäten eines Users zurück.
    Erwartet: GET /Aktivitaet?user_id=...
    """
    try:
        user_id = connexion.request.args.get("user_id")
        if not user_id:
            return {"error": "user_id ist erforderlich."}, 400
        try:
            user_id = int(user_id)
        except ValueError:
            return {"error": "user_id muss eine Zahl sein."}, 400

        response = supabase.table('Activity').select(
            "Distance, Increase, Duration, Calories, MaxAltitude, Date"
        ).eq("UserID", user_id).order("Date", desc=True).execute()

        return {"activities": response.data}, 200
    except Exception as e:
        return {"error": str(e)}, 500
    

