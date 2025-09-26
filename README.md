# gatherDiagnostics

A lightweight shell script to capture Java thread dumps (`jstack`) from a running Java process at regular intervals, and compress the results for easy sharing and analysis.

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
./jstack_sampler.sh [arg1-PID] [arg2-PNAME] 

e.g) ./jstack_sampler.sh $(cat "/opt/mapr/pid/cldb.pid") CLDB
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

You can edit these variables at the top of the script jstack_sampler.sh:

INTERVAL=15     # Interval between jstack dumps (in seconds)
DURATION=600    # Total duration to run (in seconds, e.g. 600 = 10 mins)

After successful execution, you’ll get:

.
├── jstack_dumps_20250925_143000/
│   ├── jstack_12345_20250925_143001.txt
│   ├── jstack_12345_20250925_143016.txt
│   └── ...
└── jstack_dumps_20250925_143000.tar.gz

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
./collect_cldb_diagnostics.sh
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

- Runs the following diagnostic commands for **30 seconds** each:
  - `/opt/mapr/bin/crguts`
  - `/opt/mapr/bin/crguts hbstats:all`
  - `/opt/mapr/bin/cldbguts`
  - `/opt/mapr/bin/cldbguts containers`
- Captures `jstat -gcutil` for CLDB Java process (`cldb.pid`)
- Saves each command’s full output to a timestamped `.txt` file
- Compresses all output into a single `.tar.gz` archive for easy sharin

You can edit these variables at the top of the script collect_cldb_diagnostics.sh:
DURATION=30

- After execution, you will find:

  .
├── mapr_diagnostics/
│   ├── crguts_<timestamp>.txt
│   ├── crguts_hbstats_all_<timestamp>.txt
│   ├── cldbguts_<timestamp>.txt
│   ├── cldbguts_containers_<timestamp>.txt
│   └── jstat_gcutil_<timestamp>.txt
└── mapr_diagnostics_<timestamp>.tar.gz
