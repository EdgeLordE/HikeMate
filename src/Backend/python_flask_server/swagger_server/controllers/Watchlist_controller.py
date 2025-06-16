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
    Remove a mountain from a user's watchlist using UserID and MountainID.
    Corresponds to operationId: remove_mountain_from_watchlist
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

        response = supabase.table('Watchlist').delete().eq('UserID', user_id).eq('MountainID', mountain_id).execute()

        if response.data: # Supabase delete returns the deleted rows
            return {"message": "Mountain removed from watchlist"}, 200
        elif response.error:
            return {"error": "Failed to remove mountain from watchlist", "details": str(response.error.message if response.error else "Unknown error")}, 500
        else: # No data and no error means nothing was deleted (e.g., item not found)
            return {"message": "Mountain not found on watchlist or already removed"}, 404

    except Exception as e:
        print(f"Error in remove_mountain_from_watchlist: {e}")
        return {"error": str(e)}, 500

def check_if_mountain_is_on_watchlist(UserID, MountainID):
    """
    Check if a mountain is on a user's watchlist.
    Corresponds to operationId: check_if_mountain_is_on_watchlist
    Query parameters: UserID, MountainID
    """
    if not UserID or not MountainID:
        return {"error": "UserID and MountainID are required as query parameters"}, 400

    try:
        # Explizite Konvertierung zu Integer
        try:
            user_id_int = int(UserID)
            mountain_id_int = int(MountainID)
        except (ValueError, TypeError):
            return {"error": "UserID and MountainID must be valid integers"}, 400

        response = supabase.table('Watchlist').select('WatchlistID', count='exact').eq('UserID', user_id_int).eq('MountainID', mountain_id_int).limit(1).execute()

        is_on_watchlist = response.count > 0 if response.count is not None else bool(response.data)

        return {"response": {"isOnWatchlist": is_on_watchlist}}, 200
    except Exception as e:
        print(f"Error in check_if_mountain_is_on_watchlist: {e}")
        return {"error": str(e)}, 500

def fetch_watchlist(UserID):
    """
    Fetch all watchlist entries for a user, including mountain details.
    Corresponds to operationId: fetch_watchlist
    Path parameter: UserID
    """
    if not UserID: # Basic validation
        return {"error": "UserID path parameter is required"}, 400

    try:
        response = supabase.table('Watchlist').select(
            'WatchlistID, MountainID, Mountain (Mountainid, Name, Height, Picture, FederalStateid (Name))'
        ).eq('UserID', UserID).execute()

        if response.data is not None:
            return {"response": response.data}, 200
        elif response.error:
            return {"error": "Failed to fetch watchlist", "details": str(response.error.message if response.error else "Unknown error")}, 500
        else:
            # Should ideally not happen if data is None and no error, but good to cover
            return {"response": [], "message": "Watchlist is empty or an issue occurred"}, 200
    except Exception as e:
        print(f"Error in fetch_watchlist: {e}")
        return {"error": str(e)}, 500

def delete_watchlist_entry(WatchlistID, UserID):
    """
    Delete a specific entry from the watchlist.
    Corresponds to operationId: delete_watchlist_entry
    Path parameter: WatchlistID
    Query parameter: UserID (for authorization)
    """
    if not WatchlistID or not UserID: # Basic validation
        return {"error": "WatchlistID (path) and UserID (query) are required"}, 400

    try:
        # Verify the entry belongs to the user
        verify_response = supabase.table('Watchlist').select('WatchlistID').eq('WatchlistID', WatchlistID).eq('UserID', UserID).limit(1).execute()
        if not verify_response.data:
            return {"error": "Watchlist entry not found or user not authorized"}, 404

        response = supabase.table('Watchlist').delete().eq('WatchlistID', WatchlistID).eq('UserID', UserID).execute()

        if response.data: # Supabase delete returns the deleted rows
            return {"message": "Watchlist entry deleted successfully"}, 200
        elif response.error:
            return {"error": "Failed to delete watchlist entry", "details": str(response.error.message if response.error else "Unknown error")}, 500
        else: # No data and no error means nothing was deleted (e.g., item not found after verification, which is odd)
            return {"error": "Failed to delete watchlist entry or entry already deleted"}, 404
    except Exception as e:
        print(f"Error in delete_watchlist_entry: {e}")
        return {"error": str(e)}, 500