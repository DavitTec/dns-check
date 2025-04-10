#!/bin/bash
# dns-check.sh - Check DNS resolution for a domain and its subdomains
# Version: 0.0.12
# Created: 2025-04-01
# Updated: 2025-04-09
# Author: David
# Contact: david@davit.ie
# Description:
#   This script performs DNS lookups on a specified domain and its subdomains,
#   distinguishing between aliases and direct addresses. It supports default
#   subdomains, custom subdomains from a file, or a single subdomain input.
# Usage: dns-check.sh [-v] [-l logfile] [-h] [domain] [wordlist or subdomain]
# Manpage: https://davit.ie/docs/dns-check
# License: MIT

# TODO  add help option
# Usage: ./dns-check.sh [-v] [-l logfile] [-h] [domain] [wordlist or subdomain]

# Define default domain and subdomains
default_domain="github.com"
default_subdomains=(www dns ns ns1 mail est dev rdp remote)

# Initialize counters for summary
success_count=0
not_found_count=0

# Parse options
VERBOSE=0
LOGFILE=""
while getopts "vhl:" opt; do
  case $opt in
  v) VERBOSE=1 ;;
  h)
    echo "Usage: $0 [-v] [-l logfile] [-h] [domain] [wordlist or subdomain]"
    echo "Options:"
    echo "  -v          Enable verbose output"
    echo "  -h          Display this help message"
    echo "  -l logfile  Log results to the specified file"
    echo "Examples:"
    echo "  $0                         # Uses default domain and subdomains"
    echo "  $0 google.com             # Uses provided domain with default subdomains"
    echo "  $0 google.com www         # Uses provided domain and single subdomain"
    echo "  $0 google.com dns-names.txt  # Uses provided domain and subdomains from file"
    exit 0
    ;;
  l) LOGFILE="$OPTARG" ;;
  ?)
    echo "Invalid option: -$OPTARG"
    echo "Usage: $0 [-v] [-l logfile] [-h] [domain] [wordlist or subdomain]"
    exit 1
    ;;
  esac
done
shift $((OPTIND - 1))

# Handle arguments based on the number provided
if [ $# -eq 0 ]; then
  # Option 1: No arguments
  domain="$default_domain"
  subdomains=("${default_subdomains[@]}")
  [ $VERBOSE -eq 1 ] && echo "No arguments provided. Using default domain: $domain"
  [ $VERBOSE -eq 1 ] && echo "Using default subdomains: ${subdomains[*]}"
elif [ $# -eq 1 ]; then
  # Option 2: One argument (domain)
  domain="$1"
  subdomains=("${default_subdomains[@]}")
  [ $VERBOSE -eq 1 ] && echo "Using provided domain: $domain"
  [ $VERBOSE -eq 1 ] && echo "Using default subdomains: ${subdomains[*]}"
elif [ $# -eq 2 ]; then
  # Option 3: Two arguments (domain and either a file or a single subdomain)
  domain="$1"
  if [ -f "$2" ] && [ -r "$2" ]; then
    mapfile -t subdomains <"$2"
    [ $VERBOSE -eq 1 ] && echo "Using provided domain: $domain"
    [ $VERBOSE -eq 1 ] && echo "Using subdomains from file: $2"
  else
    subdomains=("$2")
    [ $VERBOSE -eq 1 ] && echo "Using provided domain: $domain"
    [ $VERBOSE -eq 1 ] && echo "Using provided subdomain: $2"
  fi
else
  echo "Usage: $0 [-v] [-l logfile] [-h] [domain] [wordlist or subdomain]"
  exit 1
fi

# Function to log messages
log_message() {
  if [ -n "$LOGFILE" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >>"$LOGFILE"
  fi
}

# Check the base domain first
host_output=$(host "$domain" 2>/dev/null)
if [ $? -eq 0 ]; then
  address_line=$(echo "$host_output" | grep "has address" | head -n 1)
  if [ -n "$address_line" ]; then
    echo "$address_line"
    log_message "SUCCESS: $address_line"
    ((success_count++))
  else
    log_message "NOT FOUND: No address for $domain"
    ((not_found_count++))
  fi
else
  echo "Error: DNS resolution failed for $domain"
  log_message "ERROR: DNS resolution failed for $domain"
  ((not_found_count++))
fi

# Check each subdomain
for sub in "${subdomains[@]}"; do
  if [ -n "$sub" ]; then
    full_domain="${sub}.${domain}"
    host_output=$(host "$full_domain" 2>/dev/null)
    if [ $? -eq 0 ]; then
      if echo "$host_output" | grep -q "is an alias for"; then
        base_address=$(host "$domain" 2>/dev/null | grep "has address" | head -n 1)
        if [ -n "$base_address" ]; then
          result=$(echo "$base_address" | sed "s/$domain/(${sub}.)$domain/")
          echo "$result"
          log_message "SUCCESS: $result (alias)"
          ((success_count++))
        else
          log_message "NOT FOUND: No address for alias $full_domain"
          ((not_found_count++))
        fi
      else
        address_line=$(echo "$host_output" | grep "has address" | head -n 1)
        if [ -n "$address_line" ]; then
          echo "$address_line"
          log_message "SUCCESS: $address_line"
          ((success_count++))
        else
          log_message "NOT FOUND: No address for $full_domain"
          ((not_found_count++))
        fi
      fi
    else
      [ $VERBOSE -eq 1 ] && echo "DNS resolution not found for $full_domain"
      log_message "NOT FOUND: DNS resolution not found for $full_domain"
      ((not_found_count++))
    fi
  fi
done

echo "Summary: $success_count successful, $not_found_count not found"
log_message "Summary: $success_count successful, $not_found_count not found"

exit 0
# end of script
