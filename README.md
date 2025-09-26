# gatherDiagnostics

A lightweight shell script to capture Java thread dumps (`jstack`) from a running Java process at regular intervals, and compress the results for easy sharing and analysis.

./jstack_sampler.sh 12345

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
