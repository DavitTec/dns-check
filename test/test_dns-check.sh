#!/usr/bin/env bash
# TESTING SCRIPT FOR DNS CHECK
# test_dns-check.sh
version=0.0.11

# Setup logs directory
logs="/opt/davit/development/dns-check/logs"
if [ ! -d "$logs" ]; then
  mkdir -p "$logs"
fi
logfile="$logs/test_dns-check.log"
if [ ! -f "$logfile" ]; then
  touch "$logfile"
fi

bin="/opt/davit/bin"
target="dns-check.sh"
targetv=$(grep "version" "$bin/$target" 2>/dev/null | head -n 1 | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' || echo "unknown")

# Simple spinner function (terminal only)
spinner() {
  local pid=$1
  local delay=0.1
  #local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏' # Unicode spinner (or use '|/-\' for basic)
  local spinstr='|/-\' # Unicode spinner (or use '|/-\' for basic)
  while kill -0 "$pid" 2>/dev/null; do
    local temp=${spinstr#?}
    printf "\rChecking... [%c] " "$spinstr" >&2 # stderr to terminal
    spinstr=$temp${spinstr%"$temp"}
    sleep "$delay"
  done
  #printf "\rDone          \n" >&2 # Clear line on completion
}

echo "Test DNS Check"

# Use > to overwrite log file
{
  date
  echo "==================================================="
  echo "# TEST SCRIPT FOR DNS CHECK"
  echo "Located at: # $bin/$target version: $targetv"
  echo "# $0 version: $version"

  echo "using $(basename "$0") with tests"

  # Function to run test and log output
  run_test() {
    local test_name="$1"
    local cmd="$2"
    local tmpfile=$(mktemp)
    echo "TEST $test_name"
    echo "dns-check.sh $cmd"
    echo "-------------------------------------------"
    dns-check.sh $cmd >"$tmpfile" 2>/dev/null &
    local pid=$!
    spinner "$pid"
    wait "$pid"
    cat "$tmpfile"
    echo " "
    rm -f "$tmpfile"
  }

  run_test "1 - no options or arguments" ""
  run_test "2 provided domain using google.com" "google.com"
  run_test "3 using Verbose with using x.com" "-v x.com"
  run_test "4 using google.com and test_dns-check-subdomains.txt" "-v \"google.com\" \"tests/test_dns-check-subdomains.txt\""
  run_test "5 using google.com with 'www'" "google.com \"www\""
  run_test "6 Print help" "-h"
  run_test "7 print log (with arguments)" "-l $logs/test_google.com.log google.com"

  echo "TEST 8 print log (without arguments)"
  echo "dns-check.sh -l"
  echo "-------------------------------------------"
  dns-check.sh -l 2>>"$logfile"
  echo " "

  echo "==================================================="
  echo "done: review logs at file://$logs/test_dns-check.log"
} >"$logfile"

echo "done: review logs at file://$logs/test_dns-check.log"
exit 0
