import connexion
import json


from supabase import create_client

SUPABASE_URL="https://cyzdfdweghhrlquxwaxl.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN5emRmZHdlZ2hocmxxdXh3YXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNDk4ODYsImV4cCI6MjA2MzgyNTg4Nn0.8ImbDPx5rBu2zVQHMGQJNfs3lguOz4k0EUdycqmiTW0"

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)


    

def get_activities_by_user_id():
    """
    Gibt alle Aktivitäten eines Users zurück.
    Erwartet: GET /Aktivitaet?user_id=...
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
    
def save_activity():
    """
    Speichert eine neue Aktivität für einen User.
    Erwartet: POST /Aktivitaet mit JSON {UserID, Distance, Increase, Duration, Date}
    Berechnet automatisch die Kalorien.
    """
    if not connexion.request.is_json:
        return {"error": "Request must be JSON"}, 400

    data = connexion.request.get_json()
    user_id = data.get("UserID")
    distance = data.get("Distance")  # Meter
    increase = data.get("Increase")  # Höhenmeter
    duration = data.get("Duration")  # Sekunden
    date = data.get("Date")

    if not all([user_id, distance, increase, duration, date]):
        return {"error": "Alle Felder sind erforderlich."}, 400

    try:
        user_id = int(user_id)
        distance = float(distance)
        increase = int(increase)
        duration = int(duration)
    except ValueError:
        return {"error": "Ungültige Werte für UserID, Distance, Increase oder Duration."}, 400

    # Einfache Kalorienberechnung (z.B. 0.7 kcal pro kg pro km, angenommenes Gewicht 75kg)
    # + 10 kcal pro 100 Höhenmeter
    gewicht = 75  # kg, kann später dynamisch gemacht werden
    distanz_km = distance / 1000.0
    kalorien = int((0.7 * gewicht * distanz_km) + (increase / 100 * 10))

    try:
        response = supabase.table('Activity').insert({
            "UserID": user_id,
            "Distance": distance,
            "Increase": increase,
            "Duration": duration,
            "Date": date,
            "Calories": kalorien
        }).execute()
        return {"message": "Aktivität erfolgreich gespeichert", "Calories": kalorien}, 201
    except Exception as e:
        return {"error": str(e)}, 500
