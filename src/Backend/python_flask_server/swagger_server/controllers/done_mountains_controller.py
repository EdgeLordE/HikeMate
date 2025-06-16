import connexion
import json
from datetime import datetime


from supabase import create_client

SUPABASE_URL="https://cyzdfdweghhrlquxwaxl.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

    
def post_done_mountain_with_user_id():
    """
    Post done mountain with user ID (expects JSON body)
    """
    if not connexion.request.is_json:
        return {"error": "Request must be JSON"}, 400

    data = connexion.request.get_json()
    user_id = data.get("UserID")
    mountain_id = data.get("MountainID")

    if not mountain_id or not user_id:
        return {"error": "UserID and MountainID are required"}, 400

    done_data = {
        "UserID": user_id,
        "MountainID": mountain_id,
        "Date": datetime.now().isoformat()
    }

    try:
        response = supabase.table('Done').insert(done_data).execute()
        return {"message": "Mountain marked as done", "done_mountain": response.data}, 201
    except Exception as e:
        return {"error": str(e)}, 500
    
def check_if_mountain_is_done():
    """
    Prüft, ob ein Berg für einen User als erledigt markiert ist.
    Erwartet: GET /DoneBerg/check?UserID=...&MountainID=...
    """
    try:
        user_id = connexion.request.args.get("UserID")
        mountain_id = connexion.request.args.get("MountainID")

        if not user_id or not mountain_id:
            return {"error": "UserID und MountainID sind erforderlich."}, 400

        try:
            user_id = int(user_id)
            mountain_id = int(mountain_id)
        except ValueError:
            return {"error": "UserID und MountainID müssen Integer sein."}, 400

        response = supabase.table('Done').select("*") \
            .eq("UserID", user_id).eq("MountainID", mountain_id).execute()

        is_done = bool(response.data and len(response.data) > 0)
        return {"response": {"isDone": is_done}}, 200

    except Exception as e:
        return {"error": str(e)}, 500
    

def is_mountain_done_by_user():
    """
    Prüft, ob ein Berg für einen User als erledigt markiert ist.
    Erwartet: GET /DoneBerg/is_done?UserID=...&MountainID=...
    """
    try:
        user_id = connexion.request.args.get("UserID")
        mountain_id = connexion.request.args.get("MountainID")

        if not user_id or not mountain_id:
            return {"error": "UserID und MountainID sind erforderlich."}, 400

        try:
            user_id = int(user_id)
            mountain_id = int(mountain_id)
        except ValueError:
            return {"error": "UserID und MountainID müssen Integer sein."}, 400

        response = supabase.table('Done').select("MountainID") \
            .eq("UserID", user_id).eq("MountainID", mountain_id).limit(1).execute()

        is_done = response.data is not None and len(response.data) > 0
        return {"isDone": is_done}, 200

    except Exception as e:
        return {"error": str(e)}, 500


def delete_done_mountain():
    """
    Löscht einen erledigten Berg für einen User.
    Erwartet: DELETE /Done?DoneID=...&UserID=...
    """
    try:
        done_id = connexion.request.args.get("DoneID")
        user_id = connexion.request.args.get("UserID")
        if not done_id or not user_id:
            return {"error": "DoneID und UserID sind erforderlich."}, 400

        response = supabase.table('Done').delete().eq("DoneID", done_id).eq("UserID", user_id).execute()
        return {"message": "Done-Eintrag gelöscht."}, 200
    except Exception as e:
        return {"error": str(e)}, 500
    

def get_done_mountains_by_user_id():
    """
    Gibt alle erledigten Berge eines Users zurück.
    Erwartet: GET /Done?UserID=...
    """
    user_id = connexion.request.args.get("UserID")
    if not user_id:
        return {"error": "UserID ist erforderlich."}, 400

    try:
        user_id = int(user_id)
    except ValueError:
        return {"error": "UserID muss eine Zahl sein."}, 400

    try:
        response = supabase.table('Done').select(
            'DoneID, Date, Mountain(Mountainid,Name,Height,FederalState(Name))'
        ).eq('UserID', user_id).execute()
        if response.data is not None:
            return {"data": response.data}, 200
        else:
            return {"data": []}, 200
    except Exception as e:
        return {"error": str(e)}, 500





    