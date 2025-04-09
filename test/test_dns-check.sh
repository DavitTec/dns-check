#!/usr/bin/env bash
# TESTING SCRIPT FOR DNS CHECK
# test_dns-check.sh
version=0.0.4

# Setup logs directory
logs="logs"
if [ ! -d "$logs" ]; then
  mkdir -p "$logs"
fi
logfile="$logs/test_dns-check.log"
if [ ! -f "$logfile" ]; then
  touch "$logfile"
fi

# Simple spinning indicator function (terminal only)
spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  while [ "$(ps a | awk '{print $1}' | grep -w $pid)" ]; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr" >&2 # Redirect to stderr for terminal
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b" >&2
  done
  printf "    \b\b\b\b" >&2
}

bin="/opt/davit/bin"
target=dns-check.sh
targetv=$(grep version $bin/$target | sed -i 's/[^0-9.]*\([0-9.]*\).*/\1/')

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
    local args=($cmd)
    if [ ${#args[@]} -eq 0 ]; then
      total=$((${#default_subdomains[@]} + 1))
    elif [ ${#args[@]} -eq 1 ]; then
      total=$((${#default_subdomains[@]} + 1))
    elif [ ${#args[@]} -ge 2 ]; then
      if [ -f "${args[1]}" ]; then
        total=$(wc -l <"${args[1]}")
        ((total++))
      else
        total=2
      fi
    fi
    dns-check.sh $cmd >"$tmpfile" 2>/dev/null &
    pid=$!
    local count=0
    while [ "$(ps a | awk '{print $1}' | grep -w $pid)" ]; do
      count=$(grep -c "has address\|not found" "$tmpfile" || echo 0)
      printf "Checking %d/%d [%c]  " "$count" "$total" "$spinstr" >&2
      local temp=${spinstr#?}
      spinstr=$temp${spinstr%"$temp"}
      sleep 0.1
      printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b" >&2
    done
    printf "                \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b" >&2
    cat "$tmpfile"
    echo " "
    rm -f "$tmpfile"
  }

  run_test "1 - no options or arguments" ""
  run_test "2 provided domain using google.com" "google.com"
  run_test "3 using Verbose with using x.com" "-v x.com"
  run_test "4 using google.com and test_dns-check-subdomains.txt" "-v \"google.com\" \"/opt/davit/test/test_dns-check-subdomains.txt\""
  run_test "5 using google.com with 'www'" "google.com \"www\""
  run_test "6 Print help" "-h"
  run_test "7 print log (with arguments)" "-l $logs/test_google.com.log google.com"

  echo "TEST 8 print log (without arguments)"
  echo "dns-check.sh -l"
  echo "-------------------------------------------"
  dns-check.sh -l 2>>"$logfile" # Expect error, append to log
  echo " "

  echo "==================================================="
  echo "done: review logs at file://$logs/test_dns-check.log"
} >"$logfile" # Overwrite log file

echo "done: review logs at file://$logs/test_dns-check.log"
exit 0
# end of script
