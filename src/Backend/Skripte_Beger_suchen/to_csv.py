import csv


csv_to_db_mapping = {
    "1": 9,  
    "2": 6,  
    "3": 5,  
    "4": 4,  
    "5": 3,  # Salzburg
    "6": 8,  # Steiermark
    "7": 2,  # Tirol
    "8": 1,  # Vorarlberg
    "9": 7,  # Wien
    "0": 10,   # Unbekannt/Sonstige
    "00": 10,
    "": 10

}

with open("AT.txt", encoding="utf-8") as infile, open("berge_at.csv", "w", newline='', encoding="utf-8") as outfile:
    reader = csv.reader(infile, delimiter='\t')
    writer = csv.writer(outfile)

    # Schreibe Header
    writer.writerow(["Name", "Height", "FederalStateid"])

    for row in reader:
        if len(row) > 16 and row[6] == "T" and row[7] == "MT":
            name = row[1]
            region_code = row[10].lstrip("0")  # z.B. "04" -> "4"
            federal_state_id = csv_to_db_mapping.get(region_code, 0)
            hoehe = row[16]
            writer.writerow([name, hoehe, federal_state_id])