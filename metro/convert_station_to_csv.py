import json
import csv

with open("stations.json") as stations:
  data = json.load(stations)

with open("stations.csv", "w+") as file:
  csvWriter = csv.writer(file)
  csvWriter.writerow(["id", "name", "city", "district", "traffic", "longitude", "latitude"])
  for station in data["features"]:
    csvWriter.writerow([
      station["properties"]["ID"],
      station["properties"]["STATION"],
      station["properties"]['CITY'].encode('utf8'),
      station["properties"]['QUARTER'],
      station["properties"]['TRAFIC'],
      station['geometry']['coordinates'][1],
      station['geometry']['coordinates'][0],
    ])
