##
# @file watchlist_controller.py
# @brief API-Controller für die Verwaltung der Watchlist eines Benutzers.
# @details Enthält Endpunkte zum Hinzufügen, Entfernen, Prüfen und Abrufen von Watchlist-Einträgen über Supabase.
# @author Emil Wagner, Mathias Florea
# @date 2025-06-17
# @version 1.0
##

import connexion
import json
from supabase import create_client, Client
from ..logger import logger  # Logger importieren

## @brief Supabase-Projekt-URL
SUPABASE_URL = "https://cyzdfdweghhrlquxwaxl.supabase.co"

## @brief Öffentlicher API-Schlüssel zur Verbindung mit Supabase
# @warning Verwende diesen Key nur im Backend. Nicht geeignet für den Client!
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"

## @brief Erstellt einen Supabase-Client für Datenbankoperationen
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def add_mountain_to_watchlist():
    """
    /**
     * @brief Fügt einen Berg zur Watchlist eines Benutzers hinzu.
     * @details
     *  - Erwartet einen JSON-Body mit:
     *      - UserID (int): Die ID des Benutzers.
     *      - MountainID (int): Die ID des Berges.
     *  - Prüft, ob der Berg bereits auf der Watchlist oder als erledigt markiert ist.
     * @return
     *  - 201: Berg erfolgreich zur Watchlist hinzugefügt.
     *  - 400: Fehlerhafte Eingabedaten.
     *  - 403: Berg ist bereits als erledigt markiert.
     *  - 409: Berg ist bereits auf der Watchlist.
     *  - 500: Serverfehler.
     */
    """
    if not connexion.request.is_json:
        logger.warning("Request zum Hinzufügen zur Watchlist ist nicht JSON.")
        return {"error": "Request must be JSON"}, 400

    try:
        data = connexion.request.json
        user_id = data.get('UserID')
        mountain_id = data.get('MountainID')

        logger.info(f"Füge Berg {mountain_id} zur Watchlist von User {user_id} hinzu.")

        if not user_id or not mountain_id:
            logger.warning("UserID oder MountainID fehlt beim Hinzufügen zur Watchlist.")
            return {"error": "UserID and MountainID are required"}, 400

        # Prüfen, ob bereits auf der Watchlist
        existing_watchlist = supabase.table('Watchlist').select('WatchlistID').eq('UserID', user_id).eq('MountainID', mountain_id).limit(1).execute()
        if existing_watchlist.data:
            logger.info(f"Berg {mountain_id} ist bereits auf der Watchlist von User {user_id}.")
            return {"message": "Mountain already on watchlist"}, 409

        # Prüfen, ob bereits erledigt
        existing_done = supabase.table('Done').select('DoneID').eq('UserID', user_id).eq('MountainID', mountain_id).limit(1).execute()
        if existing_done.data:
            logger.warning(f"Berg {mountain_id} ist bereits als erledigt markiert, kann nicht zur Watchlist hinzugefügt werden.")
            return {"error": "Mountain is already marked as done, cannot add to watchlist"}, 403

        insert_data = {'UserID': user_id, 'MountainID': mountain_id}
        response = supabase.table('Watchlist').insert(insert_data).execute()

        if response.data:
            created_item = response.data[0] if isinstance(response.data, list) and len(response.data) > 0 else response.data
            logger.info(f"Berg {mountain_id} zur Watchlist von User {user_id} hinzugefügt.")
            return {"response": created_item, "message": "Mountain added to watchlist"}, 201
        elif getattr(response, 'error', None):
            logger.error(f"Fehler beim Hinzufügen zur Watchlist: {getattr(response.error, 'message', 'Unbekannter Fehler')}")
            return {"error": "Failed to add mountain to watchlist", "details": str(response.error.message if response.error else "Unknown error")}, 500
        else:
            logger.error("Fehler beim Hinzufügen zur Watchlist: Kein spezifischer Fehler gemeldet.")
            return {"error": "Failed to add mountain to watchlist and no specific error reported"}, 500

    except Exception as e:
        logger.error(f"Exception beim Hinzufügen zur Watchlist: {e}", exc_info=True)
        return {"error": str(e)}, 500

def remove_mountain_from_watchlist():
    """
    /**
     * @brief Entfernt einen Berg von der Watchlist eines Benutzers.
     * @details
     *  - Erwartet Query-Parameter:
     *      - UserID (int): Die ID des Benutzers.
     *      - MountainID (int): Die ID des Berges.
     * @return
     *  - 200: Berg erfolgreich entfernt.
     *  - 400: Fehlerhafte Eingabedaten.
     *  - 404: Berg nicht auf der Watchlist gefunden.
     *  - 500: Serverfehler.
     */
    """
    user_id = connexion.request.args.get("UserID")
    mountain_id = connexion.request.args.get("MountainID")

    logger.info(f"Entferne Berg {mountain_id} von Watchlist für User {user_id}.")

    if not user_id or not mountain_id:
        logger.warning("UserID oder MountainID fehlt beim Entfernen von der Watchlist.")
        return {"error": "UserID und MountainID sind erforderlich."}, 400

    try:
        user_id = int(user_id)
        mountain_id = int(mountain_id)
    except Exception:
        logger.warning("UserID oder MountainID ist keine gültige Zahl beim Entfernen von der Watchlist.")
        return {"error": "UserID und MountainID müssen Integer sein."}, 400

    try:
        response = supabase.table('Watchlist').delete().eq('UserID', user_id).eq('MountainID', mountain_id).execute()

        if response.data:
            logger.info(f"Berg {mountain_id} von Watchlist für User {user_id} entfernt.")
            return {"message": "Mountain removed from watchlist"}, 200
        if getattr(response, 'error', None):
            logger.error(f"Fehler beim Entfernen von der Watchlist: {getattr(response.error, 'message', 'Unbekannter Fehler')}")
            return {"error": "Failed to remove mountain from watchlist", "details": str(response.error.message if response.error else "Unknown error")}, 500
        # Wenn keine Daten und kein Fehler: 404
        logger.warning(f"Berg {mountain_id} war nicht auf der Watchlist von User {user_id} oder wurde bereits entfernt.")
        return {"message": "Mountain not found on watchlist or already removed"}, 404

    except Exception as e:
        logger.error(f"Exception beim Entfernen von der Watchlist: {e}", exc_info=True)
        return {"error": str(e)}, 500
    

def check_if_mountain_is_on_watchlist():
    """
    /**
     * @brief Prüft, ob ein Berg auf der Watchlist eines Benutzers ist.
     * @details
     *  - Erwartet Query-Parameter:
     *      - UserID (int): Die ID des Benutzers.
     *      - MountainID (int): Die ID des Berges.
     * @return
     *  - 200: { "isOnWatchlist": true/false }
     *  - 400: Fehlerhafte Eingabedaten.
     *  - 500: Serverfehler.
     */
    """
    try:
        user_id = connexion.request.args.get("UserID")
        mountain_id = connexion.request.args.get("MountainID")

        logger.info(f"Prüfe, ob Berg {mountain_id} auf der Watchlist von User {user_id} ist.")

        if not user_id or not mountain_id:
            logger.warning("UserID oder MountainID fehlt bei der Watchlist-Prüfung.")
            return {"error": "UserID und MountainID sind erforderlich."}, 400

        try:
            user_id = int(user_id)
            mountain_id = int(mountain_id)
        except ValueError:
            logger.warning("UserID oder MountainID ist keine gültige Zahl bei der Watchlist-Prüfung.")
            return {"error": "UserID und MountainID müssen Integer sein."}, 400

        response = supabase.table('Watchlist').select("*").eq("UserID", user_id).eq("MountainID", mountain_id).execute()

        is_on_watchlist = bool(response.data and len(response.data) > 0)
        logger.info(f"isOnWatchlist={is_on_watchlist} für UserID={user_id}, MountainID={mountain_id}")
        return {"response": {"isOnWatchlist": is_on_watchlist}}, 200

    except Exception as e:
        logger.error(f"Exception bei der Watchlist-Prüfung: {e}", exc_info=True)
        return {"error": str(e)}, 500

def fetch_watchlist():
    """
    /**
     * @brief Gibt die gesamte Watchlist eines Benutzers zurück.
     * @details
     *  - Erwartet Query-Parameter:
     *      - UserID (int): Die ID des Benutzers.
     *  - Gibt eine Liste aller Berge auf der Watchlist zurück, inkl. Bergdetails.
     * @return
     *  - 200: Liste der Watchlist-Einträge.
     *  - 400: Fehlerhafte Eingabedaten.
     *  - 500: Serverfehler.
     */
    """
    UserID = connexion.request.args.get("UserID")
    logger.info(f"Watchlist für UserID={UserID} wird abgefragt.")
    if not UserID:
        logger.warning("UserID fehlt bei der Watchlist-Abfrage.")
        return {"error": "UserID query parameter is required"}, 400

    try:
        user_id = int(UserID)
    except Exception:
        logger.warning("UserID ist keine gültige Zahl bei der Watchlist-Abfrage.")
        return {"error": "UserID muss eine Zahl sein."}, 400

    try:
        response = supabase.table('Watchlist').select(
            'WatchlistID, MountainID, Mountain (Mountainid, Name, Height, Picture, FederalStateid (Name))'
        ).eq('UserID', user_id).execute()
        if response.data is not None:
            logger.info(f"{len(response.data)} Einträge auf der Watchlist für UserID={user_id} gefunden.")
            return {"response": response.data}, 200
        elif getattr(response, 'error', None):
            logger.error(f"Fehler beim Abrufen der Watchlist: {getattr(response.error, 'message', 'Unbekannter Fehler')}")
            return {"error": "Failed to fetch watchlist", "details": str(response.error.message if response.error else "Unknown error")}, 500
        else:
            logger.info(f"Watchlist für UserID={user_id} ist leer oder es gab ein Problem.")
            return {"response": [], "message": "Watchlist is empty or an issue occurred"}, 200
    except Exception as e:
        logger.error(f"Exception beim Abrufen der Watchlist: {e}", exc_info=True)
        return {"error": str(e)}, 500

def delete_watchlist_entry_by_id():
    """
    /**
     * @brief Löscht einen Watchlist-Eintrag anhand von WatchlistID und UserID.
     * @details
     *  - Erwartet Query-Parameter:
     *      - WatchlistID (int): Die ID des Watchlist-Eintrags.
     *      - UserID (int): Die ID des Benutzers.
     *  - Löscht den Eintrag, falls vorhanden und autorisiert.
     * @return
     *  - 200: Watchlist-Eintrag erfolgreich gelöscht.
     *  - 400: Fehlerhafte Eingabedaten.
     *  - 404: Eintrag nicht gefunden oder nicht autorisiert.
     *  - 500: Serverfehler.
     */
    """
    watchlist_id = connexion.request.args.get("WatchlistID")
    user_id = connexion.request.args.get("UserID")

    logger.info(f"Lösche Watchlist-Eintrag {watchlist_id} für User {user_id}.")

    if not watchlist_id or not user_id:
        logger.warning("WatchlistID oder UserID fehlt beim Löschen eines Watchlist-Eintrags.")
        return {"error": "WatchlistID und UserID sind erforderlich."}, 400

    try:
        watchlist_id = int(watchlist_id)
        user_id = int(user_id)
    except Exception:
        logger.warning("WatchlistID oder UserID ist keine gültige Zahl beim Löschen eines Watchlist-Eintrags.")
        return {"error": "WatchlistID und UserID müssen Integer sein."}, 400

    try:
        verify_response = supabase.table('Watchlist').select('WatchlistID').eq('WatchlistID', watchlist_id).eq('UserID', user_id).limit(1).execute()
        if not verify_response.data:
            logger.warning(f"Watchlist-Eintrag {watchlist_id} für User {user_id} nicht gefunden oder nicht autorisiert.")
            return {"error": "Watchlist-Eintrag nicht gefunden oder nicht autorisiert."}, 404

        response = supabase.table('Watchlist').delete().eq('WatchlistID', watchlist_id).eq('UserID', user_id).execute()
        if response.data:
            logger.info(f"Watchlist-Eintrag {watchlist_id} für User {user_id} erfolgreich gelöscht.")
            return {"message": "Watchlist-Eintrag erfolgreich gelöscht"}, 200
        elif getattr(response, 'error', None):
            logger.error(f"Fehler beim Löschen des Watchlist-Eintrags: {getattr(response.error, 'message', 'Unbekannter Fehler')}")
            return {"error": "Fehler beim Löschen des Watchlist-Eintrags", "details": str(response.error.message if response.error else "Unknown error")}, 500
        else:
            logger.warning(f"Watchlist-Eintrag {watchlist_id} für User {user_id} nicht gefunden oder bereits gelöscht.")
            return {"error": "Watchlist-Eintrag nicht gefunden oder bereits gelöscht"}, 404
    except Exception as e:
        logger.error(f"Exception beim Löschen des Watchlist-Eintrags: {e}", exc_info=True)
        return {"error": str(e)}, 500