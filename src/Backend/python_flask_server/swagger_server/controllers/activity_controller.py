##
# @file activity_controller.py
# @brief API-Controller zum Verwalten von Aktivitäten eines Benutzers.
# @details Diese Datei enthält Endpunkte zur Verwaltung und Abfrage von Aktivitäten über eine Supabase-Datenbank.
# @author Emil Wagner, Mathias Florea
# @date 2025-06-17
# @version 1.0
##

import connexion
import json
from supabase import create_client

## @brief Supabase-Projekt-URL
SUPABASE_URL = "https://cyzdfdweghhrlquxwaxl.supabase.co"

## @brief Öffentlicher API-Schlüssel zur Verbindung mit Supabase
# @warning Verwende diesen Key nur im Backend. Nicht geeignet für den Client.
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"

## @brief Erstellt einen Supabase-Client
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def get_activities_by_user_id():
    """
@brief Gibt alle Aktivitäten eines bestimmten Benutzers zurück.

@details
Diese Funktion verarbeitet einen GET-Request der Form `/Aktivitaet?user_id=...`
und gibt eine Liste von Aktivitäten zurück, die dem Benutzer zugeordnet sind.
Die Aktivitätsdaten werden aus der Supabase-Tabelle `Activity` gelesen
und nach Datum absteigend sortiert.

@param user_id Die ID des Benutzers (als Query-Parameter).

@return
    200: JSON-Objekt mit einer Liste von Aktivitäten.
    400: JSON-Fehlermeldung bei fehlender oder ungültiger user_id.
    500: JSON-Fehlermeldung bei Serverfehler.
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