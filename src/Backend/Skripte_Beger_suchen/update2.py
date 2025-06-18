import pandas as pd
import requests
import time

HEADERS = {
    'User-Agent': 'MountainImageBot/1.0 (12wemil2008@gmail.com)'
}

def get_image_url(title):
    """Fragt die Wikipedia API nach dem Bild für den angegebenen Titel ab."""
    url = "https://de.wikipedia.org/w/api.php"
    params = {
        "action": "query",
        "format": "json",
        "prop": "pageimages",
        "titles": title,
        "pithumbsize": 1000,
        "redirects": 1
    }
    try:
        response = requests.get(url, params=params, headers=HEADERS, timeout=10)
        data = response.json()
        pages = data.get("query", {}).get("pages", {})
        for page in pages.values():
            if "thumbnail" in page and "source" in page["thumbnail"]:
                return page["thumbnail"]["source"]
    except Exception as e:
        print(f"❌ Fehler bei '{title}': {e}")
    return None

def main():
    try:
        df = pd.read_csv("berge_at.csv")
    except FileNotFoundError:
        print("❌ Datei 'berge_at.csv' nicht gefunden.")
        return

    if "Picture" not in df.columns:
        df["Picture"] = None

    for i, row in df.head(1000).iterrows():
        name = row["Name"]

        if pd.notna(row["Picture"]):
            continue

        print(f"[{i+1}/1000] Suche Bild für: {name}")

        # Erst ohne (Berg) suchen
        image_url = get_image_url(name)

        # Wenn kein Bild gefunden, dann mit (Berg) versuchen
        if not image_url:
            print(f"→ Kein Bild für '{name}', versuche '{name} (Berg)'")
            image_url = get_image_url(f"{name} (Berg)")

        df.at[i, "Picture"] = image_url
        time.sleep(1)

    df.to_csv("berge_mit_bildern_direct_1.csv", index=False)
    print("✅ Fertig: 'berge_mit_bildern_direct.csv' gespeichert.")

if __name__ == "__main__":
    main()
