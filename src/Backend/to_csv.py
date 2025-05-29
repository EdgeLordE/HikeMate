import geopandas as gpd
import pandas as pd

# 1. Lade Berge-GeoJSON aus Overpass
berge = gpd.read_file("C:/Users/43681/source/repos/HikeMate/src/Backend/export.geojson")


# 2. Lade österreichische Bundesländer (als GeoJSON)
bundeslaender = gpd.read_file("bundeslaender.geojson")

# 3. Setze Koordinatensystem (falls nötig)
berge = berge.set_crs("EPSG:4326")
bundeslaender = bundeslaender.to_crs("EPSG:4326")

# 4. Spatial Join: Finde zu jedem Berg das Bundesland
berge_mit_region = gpd.sjoin(berge, bundeslaender, how="left", predicate="within")

# 5. Wähle relevante Spalten
df = pd.DataFrame({
    "name": berge_mit_region["name"],
    "elevation": berge_mit_region.get("ele", ""),
    "region": berge_mit_region["NAME"]  # kann auch anders heißen, je nach Datei
})

# 6. Speichere als CSV
df.to_csv("berge_mit_region.csv", index=False, encoding="utf-8")

print("✅ Fertig: 'berge_mit_region.csv' wurde erstellt.")
