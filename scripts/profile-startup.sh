#!/usr/bin/env bash
set -euo pipefail

runs=${RUNS:-12}
target=${1:-}
out_dir=${OUT_DIR:-$(mktemp -d)}

profile_one() {
  local label=$1
  shift
  for i in $(seq 1 "$runs"); do
    nvim --headless --startuptime "$out_dir/$label-$i.log" "$@" +qa >/dev/null 2>&1
  done
}

profile_one current ${target:+"$target"}
profile_one clean --clean ${target:+"$target"}

python3 - "$out_dir" <<'PY'
from pathlib import Path
import re
import statistics
import sys

out_dir = Path(sys.argv[1])


def startup_times(label: str) -> list[float]:
    times = []
    for path in sorted(out_dir.glob(f"{label}-*.log")):
        match = re.search(r"^(\d+\.\d+).*NVIM STARTED", path.read_text(), re.M)
        if match:
            times.append(float(match.group(1)))
    return times


def summarize(label: str) -> None:
    times = startup_times(label)
    if not times:
        print(f"{label}: no startup times found")
        return
    print(
        f"{label}: mean={statistics.mean(times):.3f}ms "
        f"median={statistics.median(times):.3f}ms min={min(times):.3f}ms max={max(times):.3f}ms"
    )


def top_self(label: str, limit: int = 20) -> None:
    rows: dict[str, list[float]] = {}
    for path in sorted(out_dir.glob(f"{label}-*.log")):
        for line in path.read_text().splitlines():
            match = re.match(r"\s*(\d+\.\d+)\s+(\d+\.\d+)(?:\s+(\d+\.\d+))?:\s+(.*)", line)
            if not match:
                continue
            _, elapsed, self_time, message = match.groups()
            rows.setdefault(message, []).append(float(self_time or elapsed))

    print(f"\nTop {label} self-time entries:")
    for message, values in sorted(rows.items(), key=lambda item: statistics.mean(item[1]), reverse=True)[:limit]:
        print(f"{statistics.mean(values):8.3f}ms  {message}")


summarize("clean")
summarize("current")
top_self("current")
print(f"\nRaw logs: {out_dir}")
PY
