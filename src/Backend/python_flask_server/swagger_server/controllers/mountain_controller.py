##
# @file mountain_controller.py
# @brief API-Controller für Bergabfragen aus der Supabase-Datenbank.
# @details Enthält Endpunkte zur Suche von Bergen nach Name.
# @author Emil Wagner, Mathias Florea
# @date 2025-06-17
# @version 1.0
##

import connexion
from supabase import create_client, Client
from swagger_server.logger import logger  # Logger importieren

## @brief Supabase-Projekt-URL
SUPABASE_URL = "https://cyzdfdweghhrlquxwaxl.supabase.co"

## @brief Öffentlicher API-Schlüssel zur Verbindung mit Supabase
# @warning Verwende diesen Key nur im Backend. Nicht geeignet für den Client!
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"

## @brief Erstellt einen Supabase-Client für Datenbankoperationen
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def get_mountain_by_name(mountain_name):
    """
    @brief Sucht Berge anhand eines Namens (case-insensitive, Teilstring).

    @details
    Gibt alle Berge zurück, deren Name (teilweise, Groß-/Kleinschreibung ignorierend) mit dem Suchbegriff übereinstimmt.
    Es werden folgende Felder zurückgegeben: Mountainid, Name, Height, Picture, FederalStateid (Name).

    @param mountain_name Der (Teil-)Name des gesuchten Berges.

    @return
      200: JSON-Objekt mit einer Liste passender Berge.
      404: Kein Berg mit diesem Namen gefunden.
      500: Serverfehler.
    """
    try:
        logger.info(f"Suche Berge mit Name wie: {mountain_name}")
        response = supabase.table('Mountain').select(
            "Mountainid, Name, Height, Picture, FederalStateid (Name)"
        ).ilike('Name', f'%{mountain_name}%').execute()

        if response.data:
            logger.info(f"{len(response.data)} Berge gefunden für Suchbegriff '{mountain_name}'.")
            return {"response": response.data}, 200
        else:
            logger.warning(f"Kein Berg mit Name wie '{mountain_name}' gefunden.")
            return {"message": "No mountains found with that name"}, 404
    except Exception as e:
        logger.error(f"Fehler bei der Bergsuche: {e}", exc_info=True)
        return {"error": str(e)}, 500