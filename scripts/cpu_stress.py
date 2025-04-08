# cpu_stress.py
# 模擬高 CPU 負載的程式

import threading

def stress():
    while True:
        pass  # 死迴圈，狂吃 CPU

# 建立多個 thread 模擬多核心壓力
threads = []
for _ in range(24):  # 你可以依 CPU 核心數調整這裡
    t = threading.Thread(target=stress)
    t.start()
    threads.append(t)

# 等待所有 thread（實際上永遠不會結束）
for t in threads:
    t.join()
