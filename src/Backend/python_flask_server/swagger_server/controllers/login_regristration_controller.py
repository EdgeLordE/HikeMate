##
# @file user_controller.py
# @brief API-Controller für Benutzerverwaltung (Registrierung, Login, Passwort/Username ändern).
# @details Diese Datei enthält Endpunkte zur Verwaltung von Benutzern über eine Supabase-Datenbank.
# @author Emil Wagner, Mathias Florea
# @date 2025-06-17
# @version 1.0
##

import connexion  
import bcrypt     
from supabase import create_client  # Supabase Python SDK
from ..logger import logger         # Logger importieren

## @brief Supabase-Projekt-URL
SUPABASE_URL = "https://cyzdfdweghhrlquxwaxl.supabase.co"

## @brief Öffentlicher API-Schlüssel zur Verbindung mit Supabase
# @warning Verwende diesen Key nur im Backend. Nicht geeignet für den Client!
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"

## @brief Erstellt einen Supabase-Client für Datenbankoperationen
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def post_regristration():
    """
    @brief Registriert einen neuen Benutzer.

    @details
    Erwartet einen JSON-Body mit:
      - Username (str)
      - Password (str)
      - FirstName (str)
      - LastName (str)

    Prüft, ob der Username bereits existiert. Das Passwort wird mit bcrypt gehasht.

    @return
      200: Benutzer erfolgreich registriert.
      409: Username existiert bereits.
      400: Fehlerhafte Eingabedaten.
    """
    if connexion.request.is_json:
        data = connexion.request.get_json()
        username = data.get("Username")
        logger.info(f"Registrierungsversuch für Username: {username}")
        exists = supabase.table('User').select("Username").eq("Username", username).execute()
        if exists.data and len(exists.data) > 0:
            logger.warning(f"Registrierung fehlgeschlagen: Username {username} existiert bereits.")
            return {"error": "Username already exists"}, 409

        password = data.get("Password")
        hashed_pw = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

        user_data = {
            "FirstName": data.get("FirstName"),
            "LastName": data.get("LastName"),
            "Username": username,
            "Password": hashed_pw
        }

        response = supabase.table('User').insert(user_data).execute()
        logger.info(f"Benutzer {username} erfolgreich registriert.")
        return {"message": "User registered successfully"}, 200

def post_login():
    """
    @brief Loggt einen Benutzer ein.

    @details
    Erwartet einen JSON-Body mit:
      - Username (str)
      - Password (str)

    Prüft, ob Username und Passwort korrekt sind.

    @return
      200: Login erfolgreich, Benutzerdaten werden zurückgegeben.
      401: Ungültiger Username oder Passwort.
      400: Fehlerhafte Eingabedaten.
    """
    if connexion.request.is_json:
        data = connexion.request.get_json()
        username = data.get("Username")
        password = data.get("Password")
        logger.info(f"Loginversuch für Username: {username}")

        user_data = supabase.table('User').select("*").eq("Username", username).execute()

        if not user_data.data or len(user_data.data) == 0:
            logger.warning(f"Login fehlgeschlagen: Username {username} nicht gefunden.")
            return {"error": "Invalid username or password"}, 401

        user = user_data.data[0]
        if bcrypt.checkpw(password.encode("utf-8"), user["Password"].encode("utf-8")):
            logger.info(f"Login erfolgreich für Username: {username}")
            return {
                "message": "Login successful",
                "UserID": user["UserID"],
                "FirstName": user["FirstName"],
                "LastName": user["LastName"],
                "Username": user["Username"]
            }, 200
        else:
            logger.warning(f"Login fehlgeschlagen: Falsches Passwort für Username {username}.")
            return {"error": "Invalid username or password"}, 401

def post_change_password():
    """
    @brief Ändert das Passwort eines Benutzers.

    @details
    Erwartet einen JSON-Body mit:
      - Username (str)
      - OldPassword (str)
      - NewPassword (str)

    Prüft, ob der Benutzer existiert und das alte Passwort korrekt ist.

    @return
      200: Passwort erfolgreich geändert.
      401: Altes Passwort ist falsch.
      404: Benutzer nicht gefunden.
      400: Fehlerhafte Eingabedaten.
      500: Fehler beim Ändern des Passworts.
    """
    if connexion.request.is_json:
        data = connexion.request.get_json()
        username = data.get("Username")
        old_password = data.get("OldPassword")
        new_password = data.get("NewPassword")

        logger.info(f"Passwortänderung für Username: {username}")

        if not username or not old_password or not new_password:
            logger.warning("Fehlende Felder bei Passwortänderung.")
            return {"error": "Username, OldPassword, and NewPassword are required"}, 400

        user_data = supabase.table('User').select("Password").eq("Username", username).execute()
        if not user_data.data or len(user_data.data) == 0:
            logger.warning(f"Passwortänderung fehlgeschlagen: Benutzer {username} nicht gefunden.")
            return {"error": "User not found"}, 404

        hashed_old_pw = user_data.data[0]["Password"]
        if not bcrypt.checkpw(old_password.encode("utf-8"), hashed_old_pw.encode("utf-8")):
            logger.warning(f"Passwortänderung fehlgeschlagen: Altes Passwort falsch für {username}.")
            return {"error": "Old password is incorrect"}, 401

        hashed_new_pw = bcrypt.hashpw(new_password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
        response = supabase.table('User').update({"Password": hashed_new_pw}).eq("Username", username).execute()

        if response.data:
            logger.info(f"Passwort erfolgreich geändert für {username}.")
            return {"message": "Password changed successfully"}, 200
        else:
            logger.error(f"Fehler beim Ändern des Passworts für {username}.")
            return {"error": "Failed to change password"}, 500
    logger.warning("Request zur Passwortänderung war nicht JSON.")
    return {"error": "Request must be JSON"}, 400

def post_change_username():
    """
    @brief Ändert den Benutzernamen eines Benutzers.

    @details
    Erwartet einen JSON-Body mit:
      - Username (str): Der aktuelle Benutzername.
      - NewUsername (str): Der neue gewünschte Benutzername.

    Prüft, ob der Benutzer existiert und ob der neue Username noch nicht vergeben ist.

    @return
      200: Benutzername erfolgreich geändert.
      404: Benutzer nicht gefunden.
      409: Neuer Username existiert bereits.
      400: Fehlerhafte Eingabedaten.
      500: Fehler beim Ändern des Benutzernamens.
    """
    if connexion.request.is_json:
        data = connexion.request.get_json()
        new_username = data.get("NewUsername")
        username = data.get("Username")

        logger.info(f"Username-Änderung: {username} -> {new_username}")

        if not username or not new_username:
            logger.warning("Fehlende Felder bei Username-Änderung.")
            return {"error": "UserID and NewUsername are required"}, 400

        exists = supabase.table('User').select("Username").eq("Username", username).eq("Username", username).execute()
        if not exists.data or len(exists.data) == 0:
            logger.warning(f"Username-Änderung fehlgeschlagen: Benutzer {username} nicht gefunden.")
            return {"error": "User not found"}, 404

        exists = supabase.table('User').select("Username").eq("Username", new_username).execute()
        if exists.data and len(exists.data) > 0:
            logger.warning(f"Username-Änderung fehlgeschlagen: Neuer Username {new_username} existiert bereits.")
            return {"error": "Username already exists"}, 409

        response = supabase.table('User').update({"Username": new_username}).eq("Username", username).execute()

        if response.data:
            logger.info(f"Username erfolgreich geändert: {username} -> {new_username}")
            return {"message": "Username changed successfully"}, 200
        else:
            logger.error(f"Fehler beim Ändern des Usernames für {username}.")
            return {"error": "Failed to change username"}, 500
    logger.warning("Request zur Username-Änderung war nicht JSON.")
    return {"error": "Request must be JSON"}, 400