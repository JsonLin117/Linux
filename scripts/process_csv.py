import sys
import pandas as pd
import time
import random
from pathlib import Path

# 讀 config.env
config = {}
with open("config.env") as f:
    for line in f:
        if "=" in line and not line.startswith("#"):
            key, value = line.strip().split("=")
            config[key.strip()] = int(value.strip())

THRESHOLD = config["ERROR_THRESHOLD"]

file_path = Path(sys.argv[1])
log_path = Path("../logs") / (file_path.stem + ".log")
log_path.parent.mkdir(parents=True, exist_ok=True)

time.sleep(random.uniform(0.3, 1.0))  # 模擬處理時間

df = pd.read_csv(file_path)

with open(log_path, 'w') as log:
    log.write(f"Processing file: {file_path.name}\n")
    mean_val = df['value'].mean()
    log.write(f"Average value: {mean_val}\n")
    if mean_val < THRESHOLD:
        log.write("ERROR: Value below threshold\n")
    else:
        log.write("SUCCESS: File processed successfully\n")

