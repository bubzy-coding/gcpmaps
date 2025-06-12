from flask import Flask, jsonify
from google.cloud import bigquery

app = Flask(__name__)
client = bigquery.Client()

@app.route("/paths")
def get_paths():
    query = """
        SELECT id, ST_AsText(geom) AS linestring
        FROM `your_project.your_dataset.your_table`
        LIMIT 10
    """
    results = client.query(query).result()

    def parse_wkt(wkt):
        coords = wkt.replace("LINESTRING(", "").replace(")", "").split(", ")
        return [
            {"lat": float(p.split()[1]), "lng": float(p.split()[0])}
            for p in coords
        ]

    return jsonify([
        {"id": row.id, "path": parse_wkt(row.linestring)}
        for row in results
    ])

