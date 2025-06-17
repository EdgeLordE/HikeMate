import connexion
import json
from supabase import create_client, Client

SUPABASE_URL="https://cyzdfdweghhrlquxwaxl.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def add_mountain_to_watchlist():
    """
    Add a mountain to a user's watchlist.
    Corresponds to operationId: add_mountain_to_watchlist
    Expects JSON body: {"UserID": user_id, "MountainID": mountain_id}
    """
    if not connexion.request.is_json:
        return {"error": "Request must be JSON"}, 400

    try:
        data = connexion.request.json
        user_id = data.get('UserID')
        mountain_id = data.get('MountainID')

        if not user_id or not mountain_id:
            return {"error": "UserID and MountainID are required"}, 400

        # Check if already on watchlist
        existing_watchlist = supabase.table('Watchlist').select('WatchlistID').eq('UserID', user_id).eq('MountainID', mountain_id).limit(1).execute()
        if existing_watchlist.data:
            return {"message": "Mountain already on watchlist"}, 409 # Conflict

        # Check if already done (as per frontend logic, user cannot add done mountain to watchlist)
        existing_done = supabase.table('Done').select('DoneID').eq('UserID', user_id).eq('MountainID', mountain_id).limit(1).execute()
        if existing_done.data:
            return {"error": "Mountain is already marked as done, cannot add to watchlist"}, 403 # Forbidden

        insert_data = {'UserID': user_id, 'MountainID': mountain_id}
        response = supabase.table('Watchlist').insert(insert_data).execute()

        if response.data:
            # Supabase insert returns a list with the inserted item(s)
            created_item = response.data[0] if isinstance(response.data, list) and len(response.data) > 0 else response.data
            return {"response": created_item, "message": "Mountain added to watchlist"}, 201
        elif response.error:
            return {"error": "Failed to add mountain to watchlist", "details": str(response.error.message if response.error else "Unknown error")}, 500
        else:
            return {"error": "Failed to add mountain to watchlist and no specific error reported"}, 500

    except Exception as e:
        print(f"Error in add_mountain_to_watchlist: {e}")
        return {"error": str(e)}, 500

def remove_mountain_from_watchlist():
    """
    Entfernt einen Berg von der Watchlist eines Benutzers anhand von UserID und MountainID.
    Erwartet: DELETE /Watchlist/entry?UserID=...&MountainID=...
    """
    from flask import request

    user_id = request.args.get("UserID")
    mountain_id = request.args.get("MountainID")

    if not user_id or not mountain_id:
        return {"error": "UserID und MountainID sind erforderlich."}, 400

    try:
        user_id = int(user_id)
        mountain_id = int(mountain_id)
    except Exception:
        return {"error": "UserID und MountainID müssen Integer sein."}, 400

    try:
        response = supabase.table('Watchlist').delete().eq('UserID', user_id).eq('MountainID', mountain_id).execute()

        if response.data:  # Supabase delete returns the deleted rows
            return {"message": "Mountain removed from watchlist"}, 200
        elif getattr(response, 'error', None):
            return {"error": "Failed to remove mountain from watchlist", "details": str(response.error.message if response.error else "Unknown error")}, 500
        else:
            return {"message": "Mountain not found on watchlist or already removed"}, 404

    except Exception as e:
        print(f"Error in remove_mountain_from_watchlist: {e}")
        import traceback
        traceback.print_exc()
        return {"error": str(e)}, 500

def check_if_mountain_is_on_watchlist():
    try:
        user_id = connexion.request.args.get("UserID")
        mountain_id = connexion.request.args.get("MountainID")

        if not user_id or not mountain_id:
            return {"error": "UserID und MountainID sind erforderlich."}, 400

        # IDs in Integer umwandeln (optional, falls nötig)
        try:
            user_id = int(user_id)
            mountain_id = int(mountain_id)
        except ValueError:
            return {"error": "UserID und MountainID müssen Integer sein."}, 400

        response = supabase.table('Watchlist').select("*").eq("UserID", user_id).eq("MountainID", mountain_id).execute()

        is_on_watchlist = bool(response.data and len(response.data) > 0)
        return {"response": {"isOnWatchlist": is_on_watchlist}}, 200

    except Exception as e:
        return {"error": str(e)}, 500

def fetch_watchlist():
    # Holt die UserID als Query-Parameter (z.B. /Watchlist?UserID=49)
    from flask import request
    import traceback

    UserID = request.args.get("UserID")
    print(f"fetch_watchlist called with UserID={UserID}")
    if not UserID:
        return {"error": "UserID query parameter is required"}, 400

    try:
        user_id = int(UserID)
    except Exception:
        return {"error": "UserID muss eine Zahl sein."}, 400

    try:
        response = supabase.table('Watchlist').select(
            'WatchlistID, MountainID, Mountain (Mountainid, Name, Height, Picture, FederalStateid (Name))'
        ).eq('UserID', user_id).execute()
        print(f"Supabase response: {response.data}, error: {getattr(response, 'error', None)}")
        if response.data is not None:
            return {"response": response.data}, 200
        elif getattr(response, 'error', None):
            return {"error": "Failed to fetch watchlist", "details": str(response.error.message if response.error else "Unknown error")}, 500
        else:
            return {"response": [], "message": "Watchlist is empty or an issue occurred"}, 200
    except Exception as e:
        print("Error in fetch_watchlist:")
        traceback.print_exc()
        return {"error": str(e)}, 500

def delete_watchlist_entry_by_id():
    """
    Löscht einen Watchlist-Eintrag anhand von WatchlistID und UserID.
    Erwartet: DELETE /DeleteWatchlist?WatchlistID=...&UserID=...
    """
    from flask import request

    watchlist_id = request.args.get("WatchlistID")
    user_id = request.args.get("UserID")

    if not watchlist_id or not user_id:
        return {"error": "WatchlistID und UserID sind erforderlich."}, 400

    try:
        watchlist_id = int(watchlist_id)
        user_id = int(user_id)
    except Exception:
        return {"error": "WatchlistID und UserID müssen Integer sein."}, 400

    try:
        # Prüfen, ob der Eintrag existiert und dem User gehört
        verify_response = supabase.table('Watchlist').select('WatchlistID').eq('WatchlistID', watchlist_id).eq('UserID', user_id).limit(1).execute()
        if not verify_response.data:
            return {"error": "Watchlist-Eintrag nicht gefunden oder nicht autorisiert."}, 404

        response = supabase.table('Watchlist').delete().eq('WatchlistID', watchlist_id).eq('UserID', user_id).execute()
        if response.data:
            return {"message": "Watchlist-Eintrag erfolgreich gelöscht"}, 200
        elif getattr(response, 'error', None):
            return {"error": "Fehler beim Löschen des Watchlist-Eintrags", "details": str(response.error.message if response.error else "Unknown error")}, 500
        else:
            return {"error": "Watchlist-Eintrag nicht gefunden oder bereits gelöscht"}, 404
    except Exception as e:
        import traceback
        traceback.print_exc()
        return {"error": str(e)}, 500