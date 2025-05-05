import psycopg2

def init_db():
    conn = psycopg2.connect(
        dbname="NAME",
        user="admin",
        password="PW",
        host="localhost", 
        port="5000"
    )
    cursor = conn.cursor()

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS "User" (
            UserID SERIAL PRIMARY KEY,
            FirstName TEXT,
            LastName TEXT,
            PasswordHash TEXT,
            Email TEXT,
            Rolle TEXT,
            GesamtHoehenmeter REAL,
            GesamtKilometer REAL
        );
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS "Berg" (
            BergID SERIAL PRIMARY KEY,
            Name TEXT,
            Hoehe REAL,
            Beschreibung TEXT,
            Bild TEXT,
            Region TEXT
        );
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS "Aktivitaet" (
            AktivitaetID SERIAL PRIMARY KEY,
            UserID INTEGER REFERENCES "User"(UserID),
            BergID INTEGER REFERENCES "Berg"(BergID),
            Datum DATE,
            Dauer REAL,
            Hoehenmeter REAL,
            Anstieg REAL,
            Kalorien REAL
        );
    ''')

    cursor.execute('''  
        CREATE TABLE IF NOT EXISTS "Donelist" (
            DoneID SERIAL PRIMARY KEY,
            UserID INTEGER REFERENCES "User"(UserID),
            BergID INTEGER REFERENCES "Berg"(BergID),
            AktivitaetID INTEGER REFERENCES "Aktivitaet"(AktivitaetID),
            Datum DATE
        );
    ''')

    conn.commit()
    cursor.close()
    conn.close()
    print("PostgreSQL-Datenbank erfolgreich erstellt!")

if __name__ == "__main__":
    init_db()
