#!/bin/bash

# PostgreSQL Role and Database Creation Script
# This script automates the creation of a PostgreSQL role and database

set -euo pipefail
trap 'echo "❌ Create role and database at line $LINENO"; exit 1' ERR

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Prompt for role name
read -p "Enter the role name: " role_name
if [ -z "$role_name" ]; then
    print_error "Role name cannot be empty"
    exit 1
fi

# Prompt for password (hidden input)
read -s -p "Enter the password for role '$role_name': " password
echo
if [ -z "$password" ]; then
    print_error "Password cannot be empty"
    exit 1
fi

# Prompt for password confirmation
read -s -p "Confirm the password: " password_confirm
echo
if [ "$password" != "$password_confirm" ]; then
    print_error "Passwords do not match"
    exit 1
fi

# Prompt for database name
read -p "Enter the database name: " db_name
if [ -z "$db_name" ]; then
    print_error "Database name cannot be empty"
    exit 1
fi

# Display summary
echo
print_info "Summary of operations:"
echo "  Role name: $role_name"
echo "  Database name: $db_name"
echo
read -p "Proceed with creation? (y/n): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    print_warning "Operation cancelled"
    exit 0
fi

# Execute PostgreSQL commands
print_info "Creating PostgreSQL role and database..."

sudo su - postgres <<EOF
psql -c "CREATE ROLE ${role_name} WITH PASSWORD '${password}';" 2>/dev/null || {
    echo "Role may already exist, attempting to continue..."
}
psql -c "ALTER ROLE ${role_name} WITH LOGIN;"
psql -c "CREATE DATABASE ${db_name} WITH OWNER ${role_name};"
EOF

if [ $? -eq 0 ]; then
    echo
    print_info "Configuring pg_hba.conf..."
    
    # Find pg_hba.conf location
    PG_HBA_CONF=$(sudo su - postgres -c "psql -t -P format=unaligned -c 'SHOW hba_file';" | tr -d '[:space:]')
    
    if [ -z "$PG_HBA_CONF" ]; then
        print_error "Could not locate pg_hba.conf file"
        exit 1
    fi
    
    print_info "Found pg_hba.conf at: $PG_HBA_CONF"
    
    # Check if the entry already exists
    if sudo grep -q "local.*${db_name}.*${role_name}.*127.0.0.1/32.*scram-sha-256" "$PG_HBA_CONF"; then
        print_warning "Authentication rule already exists in pg_hba.conf"
    else
        # Backup pg_hba.conf
        sudo cp "$PG_HBA_CONF" "${PG_HBA_CONF}.backup.$(date +%Y%m%d_%H%M%S)"
        print_info "Created backup of pg_hba.conf"
        
        # Add the new rule
        echo "local    ${db_name}    ${role_name}    scram-sha-256" | sudo tee -a "$PG_HBA_CONF" > /dev/null
        print_info "Added authentication rule to pg_hba.conf"
        
        # Reload PostgreSQL configuration
        sudo su - postgres -c "psql -c 'SELECT pg_reload_conf();'" > /dev/null
        print_info "Reloaded PostgreSQL configuration"
    fi
    
    echo
    print_info "Successfully created:"
    echo "  ✓ Role: $role_name (with login privileges)"
    echo "  ✓ Database: $db_name (owned by $role_name)"
    echo "  ✓ Authentication rule in pg_hba.conf"
    echo
    print_info "Connection string example:"
    echo "  psql -U $role_name -d $db_name -h localhost"
    echo -e "✅ Database creation and configuration complete! \n\n"
else
    print_error "Failed to create role and/or database"
    exit 1
fi