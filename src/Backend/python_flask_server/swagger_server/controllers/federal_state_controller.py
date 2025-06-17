##
# @file federal_state_controller.py
# @brief API-Controller zum Abrufen von Bundesländern aus der Supabase-Datenbank.
# @details Diese Datei enthält Endpunkte zur Abfrage von Bundesländern anhand ihrer ID.
# @author [Dein Name]
# @date 2025-06-17
# @version 1.0
##

import connexion  # REST-Framework zur Verbindung mit OpenAPI/OpenAPI-Spezifikationen
import json       # Für das Parsen und Erzeugen von JSON-Daten
from supabase import create_client  # Supabase Python SDK

## @brief Supabase-Projekt-URL
SUPABASE_URL = "https://cyzdfdweghhrlquxwaxl.supabase.co"

## @brief Öffentlicher API-Schlüssel zur Verbindung mit Supabase
# @warning Verwende diesen Key nur im Backend. Nicht geeignet für den Client!
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"

## @brief Erstellt einen Supabase-Client für Datenbankoperationen
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def get_federal_state_by_id(federal_state_id):
    """
    @brief Gibt ein Bundesland anhand seiner ID zurück.

    @details
    Diese Funktion sucht in der Supabase-Tabelle `FederalState` nach einem Eintrag mit der angegebenen ID.

    @param federal_state_id Die ID des Bundeslandes (als Funktionsparameter).

    @return
      200: JSON-Objekt mit den Daten des Bundeslandes.
      404: Bundesland nicht gefunden.
      500: Serverfehler.
    """
    try:
        # Anfrage an die Supabase-Datenbank: Suche nach Bundesland mit passender ID
        response = supabase.table('FederalState').select("*").eq("FederalStateid", federal_state_id).execute()
        if response.data:
            # Bundesland gefunden, gib das erste Ergebnis zurück
            return {"response": response.data[0]}, 200
        else:
            # Kein Bundesland mit dieser ID gefunden
            return {"message": "Federal state not found"}, 404
    except Exception as e:
        # Fehler bei der Datenbankabfrage
        return {"error": str(e)}, 500