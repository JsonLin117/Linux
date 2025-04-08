import os
import pandas as pd
import random

config = {}
with open("config.env") as f:
    for line in f:
        if "=" in line and not line.startswith("#"):
            key, value = line.strip().split("=")
            config[key.strip()] = int(value.strip())

NUM_FILES = config["NUM_FILES"]
ROWS_PER_FILE = config["ROWS_PER_FILE"]

os.makedirs("../data/incoming", exist_ok=True)

for i in range(NUM_FILES):
    df = pd.DataFrame({
        "id": range(1, ROWS_PER_FILE + 1),
        "value": [random.randint(1, 100) for _ in range(ROWS_PER_FILE)]
    })
    df.to_csv(f"../data/incoming/data_{i+1}.csv", index=False)

