#!/bin/bash

# -------- Config --------
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
HOSTNAME=$(hostname)
OUT_DIR="cldb_diagnostics_${HOSTNAME}_$TIMESTAMP"
ARCHIVE_NAME="cldb_diagnostics_$TIMESTAMP.tar.gz"
DURATION=30
CRGUTS="/opt/mapr/bin/crguts"
CLDBGUTS="/opt/mapr/bin/cldbguts"
CLDB_PID_FILE="/opt/mapr/pid/cldb.pid"
mkdir -p "$OUT_DIR"
# ------------------------

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

run_with_timeout() {
  local name="$1"
  shift
  local cmd=("$@")
  local outfile="$OUT_DIR/${name}_${TIMESTAMP}.txt"

  log "Running '${cmd[*]}' for $DURATION seconds -> $outfile"
  timeout "${DURATION}s" "${cmd[@]}" > "$outfile" 2>&1

  if [ $? -eq 124 ]; then
    log "Command '$name' reached timeout ($DURATION s)."
  fi
}

log "Starting diagnostics collection. Output will be saved in $OUT_DIR"

# -------- Initial Info Capture --------
INFO_FILE="$OUT_DIR/date_alarm_nodelist_info_${TIMESTAMP}.txt"
log "Capturing initial server info -> $INFO_FILE"

{
  echo "====[ Current Server Time ]===="
  date
  echo

  if command -v maprcli >/dev/null 2>&1; then
    echo "====[ maprcli node list -columns svc,csvc,id ]===="
    maprcli node list -columns svc,csvc,id 2>&1
    echo

    echo "====[ maprcli alarm list ]===="
    maprcli alarm list 2>&1
    echo
  else
    echo "[WARN] maprcli not found in PATH. Skipping maprcli output."
  fi
} >> "$INFO_FILE"

# -------- Diagnostics Collection --------

# 1. crguts
run_with_timeout "crguts" "$CRGUTS"

# 2. crguts hbstats:all
run_with_timeout "crguts_hbstats_all" "$CRGUTS" "hbstats:all"

# 3. cldbguts
run_with_timeout "cldbguts" "$CLDBGUTS"

# 4. cldbguts containers
run_with_timeout "cldbguts_containers" "$CLDBGUTS" "containers"

# 5. jstat
if [ -f "$CLDB_PID_FILE" ]; then
  CLDB_PID=$(cat "$CLDB_PID_FILE")
  if ps -p "$CLDB_PID" > /dev/null 2>&1; then
    log "Found CLDB PID: $CLDB_PID"
    JSTAT_OUT="$OUT_DIR/jstat_gcutil_${TIMESTAMP}.txt"
    log "Running: jstat -gcutil $CLDB_PID 10 1000 -> $JSTAT_OUT"
    jstat -gcutil "$CLDB_PID" 10 1000 > "$JSTAT_OUT" 2>&1
  else
    log "CLDB PID $CLDB_PID not running"
  fi
else
  log "CLDB PID file not found at $CLDB_PID_FILE"
fi

# -------- Compress Output --------
log "Compressing output directory '$OUT_DIR' -> $ARCHIVE_NAME"
tar -czf "$ARCHIVE_NAME" "$OUT_DIR"

if [ $? -eq 0 ]; then
  log "Compression successful: $ARCHIVE_NAME"
  log "You can now delete '$OUT_DIR' if not needed."
else
  log "Compression failed."
fi

log "Diagnostics collection and compression completed."

