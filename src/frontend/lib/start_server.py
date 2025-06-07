import os
import sys

# Absoluten Pfad zur ursprünglichen Python-Datei ermitteln
current_dir = os.path.dirname(os.path.abspath(__file__))
server_file = os.path.join(current_dir, '../Backend/python_flask_server/start_server.py')

# Sicherstellen, dass der Pfad korrekt ist
if not os.path.exists(server_file):
    print(f"Fehler: Datei {server_file} nicht gefunden.")
    sys.exit(1)

# Server starten
exec(open(server_file).read())