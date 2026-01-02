#!/bin/bash

# Fast file indexing script for home folder using fd
# This creates an index file that can be used for quick searches

INDEX_DIR="$HOME/.cache/file-index"
INDEX_FILE="$INDEX_DIR/home-index.txt"
FOLDERS_INDEX="$INDEX_DIR/folders-index.txt"
XML_INDEX="$INDEX_DIR/xml-index.txt"
MD_INDEX="$INDEX_DIR/md-index.txt"
XLSX_INDEX="$INDEX_DIR/xlsx-index.txt"
PDF_INDEX="$INDEX_DIR/pdf-index.txt"
JSON_INDEX="$INDEX_DIR/json-index.txt"
YAML_INDEX="$INDEX_DIR/yaml-index.txt"
TXT_INDEX="$INDEX_DIR/txt-index.txt"
PY_INDEX="$INDEX_DIR/py-index.txt"
JS_INDEX="$INDEX_DIR/js-index.txt"
ALL_FILES_INDEX="$INDEX_DIR/all-files-index.txt"

# Parse command line arguments
BACKGROUND=false
QUICK=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--background)
            BACKGROUND=true
            shift
            ;;
        -q|--quick)
            QUICK=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Create index directory if it doesn't exist
mkdir -p "$INDEX_DIR"

# Extended exclusion list for faster indexing
EXCLUDES="--exclude .git --exclude node_modules --exclude .cache --exclude Library --exclude .Trash --exclude .npm --exclude .cargo --exclude .rustup --exclude .docker --exclude .vscode --exclude .idea --exclude target --exclude dist --exclude build --exclude .next --exclude .nuxt --exclude venv --exclude .venv --exclude __pycache__"

# Function to run indexing
run_indexing() {
    echo "Starting file indexing..."
    
    if [[ "$QUICK" == true ]]; then
        # Quick mode - only index common project directories
        echo "Quick mode: indexing common directories only..."
        SEARCH_PATHS="$HOME/Documents $HOME/Desktop $HOME/Downloads $HOME/Projects $HOME/GitHub $HOME/.config"
    else
        SEARCH_PATHS="$HOME"
    fi
    
    # Create folders-only index sorted by modification time
    echo "Creating folders index..."
    fd . $SEARCH_PATHS --type d --hidden $EXCLUDES --max-depth 8 -x stat -f "%m %N" {} \; 2>/dev/null | sort -rn > "$FOLDERS_INDEX.tmp"
    mv "$FOLDERS_INDEX.tmp" "$FOLDERS_INDEX"
    echo "  Folders indexed: $(wc -l < "$FOLDERS_INDEX") directories"
    
    # Create file type specific indexes
    echo "Creating file type indexes..."
    
    # XML files
    fd -e xml . $SEARCH_PATHS --type f --hidden $EXCLUDES --max-depth 10 -x stat -f "%m %N" {} \; 2>/dev/null | sort -rn > "$XML_INDEX.tmp"
    mv "$XML_INDEX.tmp" "$XML_INDEX"
    echo "  XML files: $(wc -l < "$XML_INDEX")"
    
    # Markdown files
    fd -e md -e markdown . $SEARCH_PATHS --type f --hidden $EXCLUDES --max-depth 10 -x stat -f "%m %N" {} \; 2>/dev/null | sort -rn > "$MD_INDEX.tmp"
    mv "$MD_INDEX.tmp" "$MD_INDEX"
    echo "  Markdown files: $(wc -l < "$MD_INDEX")"
    
    # Excel files
    fd -e xlsx -e xls . $SEARCH_PATHS --type f --hidden $EXCLUDES --max-depth 10 -x stat -f "%m %N" {} \; 2>/dev/null | sort -rn > "$XLSX_INDEX.tmp"
    mv "$XLSX_INDEX.tmp" "$XLSX_INDEX"
    echo "  Excel files: $(wc -l < "$XLSX_INDEX")"
    
    # PDF files
    fd -e pdf . $SEARCH_PATHS --type f --hidden $EXCLUDES --max-depth 10 -x stat -f "%m %N" {} \; 2>/dev/null | sort -rn > "$PDF_INDEX.tmp"
    mv "$PDF_INDEX.tmp" "$PDF_INDEX"
    echo "  PDF files: $(wc -l < "$PDF_INDEX")"
    
    # JSON files
    fd -e json . $SEARCH_PATHS --type f --hidden $EXCLUDES --max-depth 10 -x stat -f "%m %N" {} \; 2>/dev/null | sort -rn > "$JSON_INDEX.tmp"
    mv "$JSON_INDEX.tmp" "$JSON_INDEX"
    echo "  JSON files: $(wc -l < "$JSON_INDEX")"
    
    # YAML files
    fd -e yaml -e yml . $SEARCH_PATHS --type f --hidden $EXCLUDES --max-depth 10 -x stat -f "%m %N" {} \; 2>/dev/null | sort -rn > "$YAML_INDEX.tmp"
    mv "$YAML_INDEX.tmp" "$YAML_INDEX"
    echo "  YAML files: $(wc -l < "$YAML_INDEX")"
    
    # Text files
    fd -e txt . $SEARCH_PATHS --type f --hidden $EXCLUDES --max-depth 10 -x stat -f "%m %N" {} \; 2>/dev/null | sort -rn > "$TXT_INDEX.tmp"
    mv "$TXT_INDEX.tmp" "$TXT_INDEX"
    echo "  Text files: $(wc -l < "$TXT_INDEX")"
    
    # Python files
    fd -e py . $SEARCH_PATHS --type f --hidden $EXCLUDES --max-depth 10 -x stat -f "%m %N" {} \; 2>/dev/null | sort -rn > "$PY_INDEX.tmp"
    mv "$PY_INDEX.tmp" "$PY_INDEX"
    echo "  Python files: $(wc -l < "$PY_INDEX")"
    
    # JavaScript/TypeScript files
    fd -e js -e jsx -e ts -e tsx . $SEARCH_PATHS --type f --hidden $EXCLUDES --max-depth 10 -x stat -f "%m %N" {} \; 2>/dev/null | sort -rn > "$JS_INDEX.tmp"
    mv "$JS_INDEX.tmp" "$JS_INDEX"
    echo "  JS/TS files: $(wc -l < "$JS_INDEX")"
    
    # All files index
    echo "Creating all files index..."
    fd . $SEARCH_PATHS --type f --hidden $EXCLUDES --max-depth 10 -x stat -f "%m %N" {} \; 2>/dev/null | sort -rn > "$ALL_FILES_INDEX.tmp"
    mv "$ALL_FILES_INDEX.tmp" "$ALL_FILES_INDEX"
    echo "  Total files: $(wc -l < "$ALL_FILES_INDEX")"
    
    echo ""
    echo "Indexing complete!"
    echo "  Index directory: $INDEX_DIR"
}

if [[ "$BACKGROUND" == true ]]; then
    echo "Starting background indexing..."
    run_indexing > "$INDEX_DIR/indexing.log" 2>&1 &
    echo "Indexing running in background (PID: $!)"
    echo "Check progress: tail -f $INDEX_DIR/indexing.log"
else
    run_indexing
fi