#!/bin/bash

# p6-interactive.sh - Interactive wrapper for p6 command
# Makes it easier to use p6 commands without remembering all the options

source ~/.zshrc  # or ~/.bashrc if using bash

set -e  # Exit on error

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${BLUE}${BOLD}=== $1 ===${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to get user input with default value
get_input() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " value
        value=${value:-$default}
    else
        read -p "$prompt: " value
    fi
    
    eval "$var_name='$value'"
}

# Function to get yes/no confirmation
confirm() {
    local prompt="$1"
    local default="${2:-n}"
    
    if [ "$default" = "y" ]; then
        read -p "$prompt [Y/n]: " response
        response=${response:-y}
    else
        read -p "$prompt [y/N]: " response
        response=${response:-n}
    fi
    
    [[ "$response" =~ ^[Yy]$ ]]
}

# Main menu
print_header "P6 EPPM API Interactive Tool"
echo ""
echo "Common Operations:"
echo "  1) Read data from P6"
echo "  2) Delete records"
echo "  3) Export projects"
echo "  4) Import project"
echo "  5) Test connectivity"
echo "  6) Compare servers"
echo "  7) List endpoints"
echo "  8) Custom command"
echo ""
read -p "Choose operation [1-8]: " choice

case $choice in
    1)  # READ
        print_header "Read Data from P6"
        
        # Server selection
        echo -e "\nAvailable servers:"
        echo "  1) dev_cloud"
        echo "  2) dev_local"
        echo "  3) stage_cloud"
        echo "  4) prod_cloud"
        echo "  5) Other"
        read -p "Select server [1-5]: " server_choice
        
        case $server_choice in
            1) server="dev_cloud";;
            2) server="dev_local";;
            3) server="stage_cloud";;
            4) server="prod_cloud";;
            5) get_input "Enter server name" "" "server";;
            *) print_error "Invalid choice"; exit 1;;
        esac
        
        # Endpoint selection
        echo -e "\nCommon endpoints:"
        echo "  1) project"
        echo "  2) activity"
        echo "  3) resource"
        echo "  4) resourceAssignment"
        echo "  5) eps"
        echo "  6) obs"
        echo "  7) Other"
        read -p "Select endpoint [1-7]: " endpoint_choice
        
        case $endpoint_choice in
            1) endpoint="project";;
            2) endpoint="activity";;
            3) endpoint="resource";;
            4) endpoint="resourceAssignment";;
            5) endpoint="eps";;
            6) endpoint="obs";;
            7) get_input "Enter endpoint name" "" "endpoint";;
            *) print_error "Invalid choice"; exit 1;;
        esac
        
        # Fields configuration
        echo -e "\nField configuration:"
        echo "  1) Core fields (recommended)"
        echo "  2) All fields"
        echo "  3) Minimal fields"
        echo "  4) Specific fields"
        echo "  5) List available fields first"
        read -p "Select fields option [1-5]: " fields_choice
        
        cmd="p6eppm read $server $endpoint"
        
        case $fields_choice in
            1) cmd="$cmd -fields core";;
            2) cmd="$cmd -fields all";;
            3) cmd="$cmd -fields min";;
            4) 
                get_input "Enter comma-separated field names" "ObjectId,Name,Status" "fields"
                cmd="$cmd --specific-fields \"$fields\""
                ;;
            5) 
                echo "Fetching available fields..."
                p6 read $server $endpoint -list-fields
                echo ""
                get_input "Enter fields configuration" "core" "fields"
                cmd="$cmd -fields $fields"
                ;;
        esac
        
        # Filter
        if confirm "Add filter condition?"; then
            echo "Examples:"
            echo "  Status='ACTIVE'"
            echo "  DataDate>'2024-01-01'"
            echo "  Name LIKE '%Test%'"
            get_input "Enter filter" "" "filter"
            cmd="$cmd -filter \"$filter\""
        fi
        
        # Order by
        if confirm "Add ordering?"; then
            get_input "Order by field" "ObjectId desc" "orderby"
            cmd="$cmd -orderby \"$orderby\""
        fi
        
        # Output options
        if confirm "Save to file?"; then
            if confirm "CSV format?" "n"; then
                cmd="$cmd --csv"
                get_input "Output path" "./output.csv" "output"
            else
                get_input "Output path" "./output.json" "output"
            fi
            
            if confirm "Also display on screen?" "y"; then
                cmd="$cmd -output-both -outputpath \"$output\""
            else
                cmd="$cmd -outputfile -outputpath \"$output\""
            fi
        fi
        
        # Store to database
        if confirm "Store to database for analysis?" "n"; then
            cmd="$cmd --store-to-database"
        fi
        ;;
        
    2)  # DELETE
        print_header "Delete Records from P6"
        print_warning "This operation is destructive!"
        
        # Server selection (similar to READ)
        echo -e "\nAvailable servers:"
        echo "  1) dev_cloud"
        echo "  2) dev_local"
        echo "  3) stage_cloud"
        echo "  4) prod_cloud (⚠️  PRODUCTION)"
        read -p "Select server [1-4]: " server_choice
        
        case $server_choice in
            1) server="dev_cloud";;
            2) server="dev_local";;
            3) server="stage_cloud";;
            4) 
                if confirm "Are you SURE you want to delete from PRODUCTION?" "n"; then
                    server="prod_cloud"
                else
                    print_error "Cancelled"; exit 0
                fi
                ;;
            *) print_error "Invalid choice"; exit 1;;
        esac
        
        # Endpoint
        get_input "Enter endpoint" "project" "endpoint"
        
        # Object IDs
        echo -e "\nHow to specify records to delete:"
        echo "  1) Enter ObjectIds manually"
        echo "  2) Load from JSON file"
        read -p "Choose method [1-2]: " method
        
        cmd="p6eppm delete $server $endpoint"
        
        case $method in
            1)
                get_input "Enter comma-separated ObjectIds" "" "objectids"
                cmd="$cmd --objectIds \"$objectids\""
                ;;
            2)
                get_input "Path to JSON file" "./delete_ids.json" "jsonfile"
                cmd="$cmd --json-file \"$jsonfile\""
                ;;
        esac
        
        # Batch size
        get_input "Batch size" "50" "batch"
        cmd="$cmd --batch-size $batch"
        
        # Delete baselines for projects
        if [ "$endpoint" = "project" ]; then
            if confirm "Also delete associated baselines?" "n"; then
                cmd="$cmd --delete-baselines"
            fi
        fi
        
        # Save response
        if confirm "Save response to file?" "y"; then
            cmd="$cmd -save"
        fi
        
        # Final confirmation
        print_warning "About to execute: $cmd"
        if ! confirm "Proceed with deletion?" "n"; then
            print_error "Cancelled"
            exit 0
        fi
        ;;
        
    3)  # EXPORT
        print_header "Export Projects from P6"
        
        get_input "Server" "dev_cloud" "server"
        get_input "Project ID or 'all'" "" "project"
        
        cmd="p6eppm export $server"
        
        if [ "$project" != "all" ]; then
            cmd="$cmd --project-id \"$project\""
        fi
        
        # Export format
        echo -e "\nExport format:"
        echo "  1) XML"
        echo "  2) XER"
        echo "  3) ZIP"
        read -p "Select format [1-3]: " format
        
        case $format in
            1) cmd="$cmd --format XML";;
            2) cmd="$cmd --format XER";;
            3) cmd="$cmd --format ZIP";;
        esac
        
        if confirm "Include baselines?" "n"; then
            cmd="$cmd --include-baselines"
        fi
        ;;
        
    4)  # IMPORT
        print_header "Import Project to P6"
        
        get_input "Server" "dev_cloud" "server"
        get_input "File path" "./project.xml" "filepath"
        
        echo -e "\nImport method:"
        echo "  1) ASAP (async)"
        echo "  2) Direct (createNewProject)"
        read -p "Select method [1-2]: " method
        
        case $method in
            1)
                cmd="p6eppm import $server \"$filepath\""
                if confirm "Check pending imports first?" "y"; then
                    cmd="$cmd --check-pending"
                fi
                ;;
            2)
                cmd="p6eppm project-import $server \"$filepath\""
                get_input "Target EPS ID (optional)" "" "eps"
                if [ -n "$eps" ]; then
                    cmd="$cmd --eps-id $eps"
                fi
                ;;
        esac
        ;;
        
    5)  # CONNECTIVITY
        print_header "Test Server Connectivity"
        
        echo "Test all servers or specific ones?"
        echo "  1) All servers"
        echo "  2) Specific servers"
        read -p "Choose [1-2]: " test_choice
        
        case $test_choice in
            1)
                cmd="p6eppm connectivity"
                ;;
            2)
                get_input "Enter comma-separated server names" "dev_cloud,stage_cloud" "servers"
                cmd="p6eppm connectivity --servers \"$servers\""
                ;;
        esac
        
        if confirm "Run tests in parallel?" "y"; then
            cmd="$cmd --parallel"
        fi
        ;;
        
    6)  # COMPARE
        print_header "Compare Servers"
        
        get_input "First server" "dev_cloud" "server1"
        get_input "Second server" "stage_cloud" "server2"
        get_input "Endpoint to compare" "project" "endpoint"
        
        cmd="p6eppm compare $server1 $server2 $endpoint"
        
        get_input "Limit records" "10" "limit"
        cmd="$cmd --limit $limit"
        ;;
        
    7)  # LIST ENDPOINTS
        cmd="p6eppm list-endpoints"
        ;;
        
    8)  # CUSTOM
        print_header "Custom P6 Command"
        echo "Enter the full p6 command (without 'p6' prefix)"
        get_input "Command" "read dev_cloud project -fields core" "custom"
        cmd="p6eppm $custom"
        ;;
        
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

# Execute command
echo ""
print_header "Executing Command"
echo -e "${BOLD}$cmd${NC}"
echo ""

if confirm "Execute this command?" "y"; then
    eval $cmd
    print_success "Command completed"
else
    print_error "Command cancelled"
fi

# Save command to history
HISTFILE="$HOME/.p6_history"
echo "$(date '+%Y-%m-%d %H:%M:%S') | $cmd" >> "$HISTFILE"
print_success "Command saved to ~/.p6_history"
