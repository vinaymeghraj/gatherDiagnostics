#!/bin/bash

# -------- Configuration --------
PID=$1                       # Java process ID
INTERVAL=15                  # Interval in seconds (change to 10 or 15 as needed)
DURATION=60                 # Total duration in seconds (10 minutes)
OUT_DIR="jstack_dumps_$2_$(date +%Y%m%d_%H%M%S)"
ARCHIVE_NAME="${OUT_DIR}.tar.gz"
# -------------------------------

# -------- Checks --------
if [ -z "$PID" ]; then
  echo "Usage: $0 <Java_PID>"
  exit 1
fi

if ! command -v jstack &> /dev/null; then
  echo "Error: 'jstack' not found in PATH."
  exit 1
fi

if ! ps -p "$PID" > /dev/null 2>&1; then
  echo "Error: No process found with PID $PID"
  exit 1
fi

# -------- Setup --------
mkdir -p "$OUT_DIR"
ITERATIONS=$((DURATION / INTERVAL))

echo "[INFO] Capturing jstack for PID $PID every $INTERVAL seconds for $((DURATION / 60)) minutes ($ITERATIONS samples)."
# -----------------------

for i in $(seq 1 "$ITERATIONS"); do
  TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
  FILE="$OUT_DIR/jstack_${PID}_$TIMESTAMP.txt"
  echo "[INFO] Dumping jstack to $FILE"
  jstack "$PID" > "$FILE" 2>&1
  sleep "$INTERVAL"
done

# -------- Compress --------
echo "[INFO] Compressing output to $ARCHIVE_NAME"
tar -czf "$ARCHIVE_NAME" "$OUT_DIR"

if [ $? -eq 0 ]; then
  echo "[INFO] Compression successful: $ARCHIVE_NAME"
  echo "[INFO] You may now remove $OUT_DIR if desired."
else
  echo "[ERROR] Compression failed."
fi

echo "[DONE] jstack sampling complete."

