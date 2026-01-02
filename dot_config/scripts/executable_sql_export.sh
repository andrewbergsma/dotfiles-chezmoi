#!/usr/bin/env bash
set -euo pipefail

# Defaults
DEFAULT_SERVER="127.0.0.1,1433"
DEFAULT_USERNAME="sa"
# Use ASCII 0x1F (unit separator) as intermediate delimiter to avoid conflicts
INTERMEDIATE_DELIM=$'\x1F'

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Export SQL Server table to Parquet file.

Options:
  -s, --server SERVER     Server address (default: ${DEFAULT_SERVER})
  -d, --database DB       Database name (required)
  -t, --table TABLE       Table name (required)
  -u, --username USER     Username (default: ${DEFAULT_USERNAME})
  -p, --password PASS     Password (required, or set SQL_PASSWORD env var)
  -o, --output FILE       Output file (default: TABLE.parquet)
  -h, --help              Show this help

Examples:
  $(basename "$0") -d MyDB -t dbo.Users -p secret
  $(basename "$0") -s localhost,1433 -d MyDB -t Users -u sa -p secret -o users.parquet
  SQL_PASSWORD=secret $(basename "$0") -d MyDB -t Users

Interactive mode:
  Run without arguments for interactive prompts.
EOF
  exit 0
}

# Initialize variables
SERVER=""
DB=""
TABLE=""
USERNAME=""
PASSWORD="${SQL_PASSWORD:-}"
OUTFILE=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -s|--server)   SERVER="$2"; shift 2 ;;
    -d|--database) DB="$2"; shift 2 ;;
    -t|--table)    TABLE="$2"; shift 2 ;;
    -u|--username) USERNAME="$2"; shift 2 ;;
    -p|--password) PASSWORD="$2"; shift 2 ;;
    -o|--output)   OUTFILE="$2"; shift 2 ;;
    -h|--help)     usage ;;
    *)             echo "Unknown option: $1"; usage ;;
  esac
done

# If no arguments provided, run interactive mode
if [ -z "${DB}" ] && [ -z "${TABLE}" ]; then
  echo "=== SQL Server table export to Parquet ==="

  read -rp "Server [${DEFAULT_SERVER}]: " SERVER

  read -rp "Database name: " DB
  if [ -z "${DB}" ]; then
    echo "Error: Database name is required."
    exit 1
  fi

  read -rp "Table name (e.g. dbo.VIEWPROP): " TABLE
  if [ -z "${TABLE}" ]; then
    echo "Error: Table name is required."
    exit 1
  fi

  read -rp "Username [${DEFAULT_USERNAME}]: " USERNAME

  read -srp "Password: " PASSWORD
  echo

  DEFAULT_OUTFILE="${TABLE//./_}.parquet"
  read -rp "Output file [${DEFAULT_OUTFILE}]: " OUTFILE
  OUTFILE="${OUTFILE:-$DEFAULT_OUTFILE}"
fi

# Apply defaults
SERVER="${SERVER:-$DEFAULT_SERVER}"
USERNAME="${USERNAME:-$DEFAULT_USERNAME}"
OUTFILE="${OUTFILE:-${TABLE//./_}.parquet}"

# Validate required fields
if [ -z "${DB}" ]; then
  echo "Error: Database name is required (-d)."
  exit 1
fi

if [ -z "${TABLE}" ]; then
  echo "Error: Table name is required (-t)."
  exit 1
fi

if [ -z "${PASSWORD}" ]; then
  echo "Error: Password is required (-p or SQL_PASSWORD env var)."
  exit 1
fi

# Check for sqlcmd
if ! command -v sqlcmd >/dev/null 2>&1; then
  echo "Error: sqlcmd not found in PATH. Install mssql-tools / sqlcmd first."
  exit 1
fi

# Check for Python with required modules
if ! python3 -c "import pandas, pyarrow" 2>/dev/null; then
  echo "Error: Python3 with pandas and pyarrow required."
  echo "Install with: pip install pandas pyarrow"
  exit 1
fi

TMPDIR=$(mktemp -d)
HEADER_FILE="${TMPDIR}/header.tmp"
DATA_FILE="${TMPDIR}/data.tmp"
RAW_FILE="${TMPDIR}/raw.txt"

echo "Generating header row from sys.columns..."

sqlcmd \
  -S "${SERVER}" \
  -U "${USERNAME}" \
  -P "${PASSWORD}" \
  -d "${DB}" \
  -W \
  -h-1 \
  -Q "SET NOCOUNT ON; SELECT name FROM sys.columns WHERE object_id = OBJECT_ID('${TABLE}') ORDER BY column_id;" \
  -o "${HEADER_FILE}"

# Build a single-line header with the intermediate delimiter
paste -sd "${INTERMEDIATE_DELIM}" "${HEADER_FILE}" > "${RAW_FILE}"

echo "Exporting data rows from ${TABLE}..."

# Data export with no truncation, using the intermediate delimiter
sqlcmd \
  -S "${SERVER}" \
  -U "${USERNAME}" \
  -P "${PASSWORD}" \
  -d "${DB}" \
  -s "${INTERMEDIATE_DELIM}" \
  -y 0 \
  -Y 0 \
  -Q "SET NOCOUNT ON; SELECT * FROM ${TABLE};" \
  -o "${DATA_FILE}"

# Append data to raw file
cat "${DATA_FILE}" >> "${RAW_FILE}"

echo "Converting to Parquet..."

# Convert to Parquet using Python/pandas
# - Reads with 0x1F delimiter
# - Preserves all data types and special characters natively
python3 << PYEOF
import pandas as pd
import sys

delim = '\x1f'
raw_file = '${RAW_FILE}'
out_file = '${OUTFILE}'

# Read header
with open(raw_file, 'r', encoding='utf-8', errors='replace') as f:
    header_line = f.readline().rstrip('\n')
    columns = header_line.split(delim)
    num_cols = len(columns)

    # Read rest of file
    content = f.read()

# Split all data by delimiter
fields = content.split(delim)

# Build rows (num_cols fields per row)
rows = []
for i in range(0, len(fields), num_cols):
    row = fields[i:i+num_cols]
    if len(row) == num_cols:
        # Clean up: strip trailing newline from last field of each row
        row[-1] = row[-1].rstrip('\n')
        rows.append(row)

# Create DataFrame and save to Parquet
df = pd.DataFrame(rows, columns=columns)
df.to_parquet(out_file, index=False, engine='pyarrow')
print(f"Rows: {len(df)}", file=sys.stderr)
PYEOF

# Cleanup temp files
rm -rf "${TMPDIR}"

echo "Done."
echo "Export written to: ${OUTFILE}"
