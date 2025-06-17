##
# @file done_mountains_controller.py
# @brief API-Controller zum Verwalten erledigter Berge eines Benutzers.
# @details Diese Datei enthält Endpunkte zur Verwaltung von "Done"-Einträgen über eine Supabase-Datenbank.
# @author Emil Wagner, Mathias Florea
# @date 2025-06-17
# @version 1.0
##

import connexion  # REST-Framework zur Verbindung mit OpenAPI-Spezifikationen
import json       # Für das Parsen und Erzeugen von JSON-Daten
from datetime import datetime  # Für Zeitstempel

from supabase import create_client  # Supabase Python SDK
from ..logger import logger  # Logger aus dem übergeordneten Package importieren

## @brief Supabase-Projekt-URL
SUPABASE_URL = "https://cyzdfdweghhrlquxwaxl.supabase.co"

## @brief Öffentlicher API-Schlüssel zur Verbindung mit Supabase
# @warning Verwende diesen Key nur im Backend. Nicht geeignet für den Client.
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"

## @brief Erstellt einen Supabase-Client
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def post_done_mountain_with_user_id():
    """
    @brief Markiert einen Berg als erledigt für einen Benutzer.

    @details
    Erwartet einen JSON-Body mit:
      - UserID (int): Die ID des Benutzers.
      - MountainID (int): Die ID des Berges.

    @return
      201: Erfolgsmeldung mit gespeicherten Daten.
      400: Fehlermeldung bei ungültigem oder fehlendem Input.
      500: Serverfehler bei der Datenbankoperation.
    """
    logger.info("POST /Done aufgerufen.")
    if not connexion.request.is_json:
        logger.warning("Request ist nicht JSON.")
        return {"error": "Request must be JSON"}, 400

    data = connexion.request.get_json()
    user_id = data.get("UserID")
    mountain_id = data.get("MountainID")

    if not mountain_id or not user_id:
        logger.warning("UserID oder MountainID fehlt im Request.")
        return {"error": "UserID and MountainID are required"}, 400

    done_data = {
        "UserID": user_id,
        "MountainID": mountain_id,
        "Date": datetime.now().isoformat()
    }

    try:
        logger.info(f"Füge Done-Eintrag hinzu: {done_data}")
        response = supabase.table('Done').insert(done_data).execute()
        logger.info(f"Done-Eintrag erfolgreich gespeichert: {response.data}")
        return {"message": "Mountain marked as done", "done_mountain": response.data}, 201
    except Exception as e:
        logger.error(f"Fehler beim Speichern des Done-Eintrags: {e}", exc_info=True)
        return {"error": str(e)}, 500


def check_if_mountain_is_done():
    """
    @brief Prüft, ob ein bestimmter Berg für einen Benutzer erledigt ist.

    @details
    Erwartet Query-Parameter:
      - UserID (int): Die ID des Benutzers.
      - MountainID (int): Die ID des Berges.

    @return
      200: { "response": { "isDone": true/false } }
      400: Fehlerhafte oder fehlende Parameter.
      500: Serverfehler.
    """
    try:
        user_id = connexion.request.args.get("UserID")
        mountain_id = connexion.request.args.get("MountainID")
        logger.info(f"GET /Done/check?UserID={user_id}&MountainID={mountain_id} aufgerufen.")

        if not user_id or not mountain_id:
            logger.warning("UserID oder MountainID fehlt in den Query-Parametern.")
            return {"error": "UserID und MountainID sind erforderlich."}, 400

        try:
            user_id = int(user_id)
            mountain_id = int(mountain_id)
        except ValueError:
            logger.warning(f"Ungültige UserID oder MountainID: {user_id}, {mountain_id}")
            return {"error": "UserID und MountainID müssen Integer sein."}, 400

        response = supabase.table('Done').select("*") \
            .eq("UserID", user_id).eq("MountainID", mountain_id).execute()

        is_done = bool(response.data and len(response.data) > 0)
        logger.info(f"isDone={is_done} für UserID={user_id}, MountainID={mountain_id}")
        return {"response": {"isDone": is_done}}, 200

    except Exception as e:
        logger.error(f"Fehler bei der Prüfung, ob Berg erledigt ist: {e}", exc_info=True)
        return {"error": str(e)}, 500


def is_mountain_done_by_user():
    """
    @brief Alternativer Endpunkt zur Prüfung, ob ein Berg erledigt wurde.

    @details
    Erwartet Query-Parameter:
      - UserID (int): Die ID des Benutzers.
      - MountainID (int): Die ID des Berges.

    @return
      200: { "isDone": true/false }
      400: Fehlerhafte oder fehlende Parameter.
      500: Serverfehler.
    """
    try:
        user_id = connexion.request.args.get("UserID")
        mountain_id = connexion.request.args.get("MountainID")
        logger.info(f"GET /Done/is_done?UserID={user_id}&MountainID={mountain_id} aufgerufen.")

        if not user_id or not mountain_id:
            logger.warning("UserID oder MountainID fehlt in den Query-Parametern.")
            return {"error": "UserID und MountainID sind erforderlich."}, 400

        try:
            user_id = int(user_id)
            mountain_id = int(mountain_id)
        except ValueError:
            logger.warning(f"Ungültige UserID oder MountainID: {user_id}, {mountain_id}")
            return {"error": "UserID und MountainID müssen Integer sein."}, 400

        response = supabase.table('Done').select("MountainID") \
            .eq("UserID", user_id).eq("MountainID", mountain_id).limit(1).execute()

        is_done = response.data is not None and len(response.data) > 0
        logger.info(f"isDone={is_done} für UserID={user_id}, MountainID={mountain_id}")
        return {"isDone": is_done}, 200

    except Exception as e:
        logger.error(f"Fehler bei der alternativen Prüfung, ob Berg erledigt ist: {e}", exc_info=True)
        return {"error": str(e)}, 500


def delete_done_mountain():
    """
    @brief Löscht einen Eintrag eines erledigten Berges für einen Benutzer.

    @details
    Erwartet Query-Parameter:
      - DoneID (int): Die ID des Done-Eintrags.
      - UserID (int): Die ID des Benutzers.

    @return
      200: Erfolgreich gelöscht.
      400: Fehlerhafte oder fehlende Parameter.
      500: Serverfehler.
    """
    try:
        done_id = connexion.request.args.get("DoneID")
        user_id = connexion.request.args.get("UserID")
        logger.info(f"DELETE /Done?DoneID={done_id}&UserID={user_id} aufgerufen.")

        if not done_id or not user_id:
            logger.warning("DoneID oder UserID fehlt in den Query-Parametern.")
            return {"error": "DoneID und UserID sind erforderlich."}, 400

        response = supabase.table('Done').delete().eq("DoneID", done_id).eq("UserID", user_id).execute()

        if getattr(response, 'error', None):
            logger.error(f"Fehler beim Löschen des Done-Eintrags: {getattr(response.error, 'message', 'Unbekannter Fehler')}")
            return {"error": "Fehler beim Löschen des Done-Eintrags", "details": str(response.error.message if response.error else "Unknown error")}, 500

        logger.info(f"Done-Eintrag DoneID={done_id} für UserID={user_id} gelöscht.")
        return {"message": "Done-Eintrag gelöscht."}, 200

    except Exception as e:
        logger.error(f"Fehler beim Löschen des Done-Eintrags: {e}", exc_info=True)
        return {"error": str(e)}, 500


def get_done_mountains_by_user_id():
    """
    @brief Gibt alle erledigten Berge eines Benutzers zurück.

    @details
    Erwartet Query-Parameter:
      - UserID (int): Die ID des Benutzers.

    @return
      200: Liste der erledigten Berge (inkl. Name, Höhe, Bundesland).
      400: Fehlerhafte oder fehlende Parameter.
      500: Serverfehler.
    """
    user_id = connexion.request.args.get("UserID")
    logger.info(f"GET /Done?UserID={user_id} aufgerufen.")
    if not user_id:
        logger.warning("UserID fehlt in den Query-Parametern.")
        return {"error": "UserID ist erforderlich."}, 400

    try:
        user_id = int(user_id)
    except ValueError:
        logger.warning(f"Ungültige UserID: {user_id}")
        return {"error": "UserID muss eine Zahl sein."}, 400

    try:
        logger.info(f"Suche erledigte Berge für UserID={user_id}")
        response = supabase.table('Done').select(
            'DoneID, Date, Mountain(Mountainid,Name,Height,FederalState(Name))'
        ).eq('UserID', user_id).execute()
        if response.data is not None:
            logger.info(f"{len(response.data)} erledigte Berge für UserID={user_id} gefunden.")
            return {"data": response.data}, 200
        else:
            logger.info(f"Keine erledigten Berge für UserID={user_id} gefunden.")
            return {"data": []}, 200
    except Exception as e:
        logger.error(f"Fehler beim Abrufen der erledigten Berge: {e}", exc_info=True)
        return {"error": str(e)},