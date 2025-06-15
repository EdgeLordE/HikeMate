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








def add_mountain_to_done():
    """
    Add a mountain to a user's done list.
    Expects JSON body: {"UserID": user_id, "MountainID": mountain_id}
    """
    try:
        data = connexion.request.json
        user_id = data.get('UserID')
        mountain_id = data.get('MountainID')

        if not user_id or not mountain_id:
            return {"error": "UserID and MountainID are required"}, 400

        # Check if already done
        existing_entry = supabase.table('Done').select('DoneID').eq('UserID', user_id).eq('MountainID', mountain_id).limit(1).execute()
        if existing_entry.data:
            return {"message": "Mountain already marked as done"}, 409 # Conflict

        insert_data = {
            'UserID': user_id,
            'MountainID': mountain_id,
            'Date': datetime.now(timezone.utc).isoformat()
        }
        response = supabase.table('Done').insert(insert_data).execute()

        if response.data:
            return {"response": response.data[0], "message": "Mountain added to done list"}, 201
        else:
            # Supabase insert error handling can be more specific if needed
            return {"error": "Failed to add mountain to done list", "details": str(response.error)}, 500
    except Exception as e:
        print(f"Error in add_mountain_to_done: {e}")
        return {"error": str(e)}, 500

def check_if_mountain_is_done(UserID, MountainID):
    """
    Check if a mountain is in a user's done list.
    Query parameters: UserID, MountainID
    """
    try:
        response = supabase.table('Done').select('DoneID').eq('UserID', UserID).eq('MountainID', MountainID).limit(1).execute()
        is_done = bool(response.data)
        return {"response": {"isDone": is_done}}, 200
    except Exception as e:
        print(f"Error in check_if_mountain_is_done: {e}")
        return {"error": str(e)}, 500

def fetch_done_list(UserID):
    """
    Fetch all done entries for a user, including mountain details.
    Query parameter: UserID
    """
    try:
        response = supabase.table('Done').select(
            'DoneID, Date, MountainID, Mountain (Mountainid, Name, Height, Picture, FederalStateid (Name))'
        ).eq('UserID', UserID).execute()

        if response.data is not None: # Check if data is not None, even if it's an empty list
            return {"response": response.data}, 200
        else:
            # This case might indicate an error rather than an empty list
            return {"error": "Failed to fetch done list", "details": str(response.error)}, 500
    except Exception as e:
        print(f"Error in fetch_done_list: {e}")
        return {"error": str(e)}, 500

def delete_done_entry(DoneID, UserID):
    """
    Delete a specific entry from the done list.
    Path parameter: DoneID
    Query parameter: UserID (for authorization)
    """
    try:
        # First, verify the entry belongs to the user
        verify_response = supabase.table('Done').select('DoneID').eq('DoneID', DoneID).eq('UserID', UserID).limit(1).execute()
        if not verify_response.data:
            return {"error": "Done entry not found or user not authorized"}, 404

        response = supabase.table('Done').delete().eq('DoneID', DoneID).eq('UserID', UserID).execute()

        # Check if delete was successful (Supabase delete often returns data of deleted items or an empty list if successful)
        # A more robust check might be needed based on Supabase's specific behavior for successful deletes vs. not found
        if response.data or response.error is None: # Assuming empty data list on success is possible
            return {"message": "Done entry deleted successfully"}, 200 # Or 204 No Content
        else:
            return {"error": "Failed to delete done entry", "details": str(response.error)}, 500
    except Exception as e:
        print(f"Error in delete_done_entry: {e}")
        return {"error": str(e)}, 500
    