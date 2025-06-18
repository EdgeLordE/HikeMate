import pandas as pd
import requests
import time

HEADERS = {
    'User-Agent': 'MountainImageBot/1.0 (your_email@example.com)'  # <-- Setze ggf. echte Kontaktadresse ein
}

def search_wikipedia_title(query):
    """Suche nach dem besten Wikipedia-Titel für eine Suchanfrage."""
    url = "https://en.wikipedia.org/w/api.php"
    params = {
        "action": "query",
        "list": "search",
        "srsearch": query,
        "format": "json"
    }
    try:
        response = requests.get(url, params=params, headers=HEADERS, timeout=10).json()
        results = response.get("query", {}).get("search", [])
        if results:
            return results[0]["title"]
    except Exception as e:
        print(f"Fehler bei der Suche nach '{query}': {e}")
    return None

def get_image_url_from_wikimedia(title):
    """Hole die Bild-URL von Wikipedia anhand des Artikeltitels."""
    url = "https://en.wikipedia.org/w/api.php"
    params = {
        "action": "query",
        "format": "json",
        "prop": "pageimages",
        "titles": title,
        "pithumbsize": 1000,
        "redirects": 1
    }
    try:
        response = requests.get(url, params=params, headers=HEADERS, timeout=10).json()
        pages = response.get("query", {}).get("pages", {})
        for page in pages.values():
            if "thumbnail" in page:
                return page["thumbnail"]["source"]
    except Exception as e:
        print(f"Fehler beim Abrufen von Bild für '{title}': {e}")
    return None

def try_variants(name):
    """Versuche mehrere Titel-Varianten, um ein Bild zu finden."""
    variants = [
        name,
        f"{name} (mountain)",
        f"{name} (Alps)",
        f"{name}, Austria",
        f"{name} (peak)",
        f"{name} (Berg)"
    ]
    for variant in variants:
        title = search_wikipedia_title(variant)
        if title:
            img_url = get_image_url_from_wikimedia(title)
            if img_url:
                return img_url
    return None

def main():
    # CSV-Datei laden
    try:
        df = pd.read_csv("berge_at.csv")
    except FileNotFoundError:
        print("Datei 'berge_at.csv' nicht gefunden.")
        return

    if "Picture" not in df.columns:
        df["Picture"] = None

    for i, row in df.iterrows():
        name = row["Name"]

        # Überspringen, wenn bereits Bild vorhanden
        if pd.notna(row["Picture"]):
            continue

        print(f"[{i+1}/{len(df)}] Suche Bild für: {name}, count: {i}")
        image_url = try_variants(name)
        df.at[i, "Picture"] = image_url
        time.sleep(1)  # API-Schutz

    # Ergebnis speichern
    df.to_csv("berge_mit_bildern.csv", index=False)
    print("✅ Fertig. Datei gespeichert als 'berge_mit_bildern.csv'.")

if __name__ == "__main__":
    main()
