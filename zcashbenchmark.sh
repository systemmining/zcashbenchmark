#!/bin/bash
#===============================================================================
#
# FILE: zcash-benchmark.sh
#
# USAGE: zcash-benchmark.sh
#
# DESCRIPTION: Simple script to run zcash benchmark and general info of system
# with command `zcash-cli zcbenchmark solveequihash 20`
# It's easy to share it on zcashbenchmark.com
#
# AUTHOR: smining, system_mining@gmail.com
# CREATED AT: 10-28-2016w
# VERSION: 0.1
#
#===============================================================================

#=== FUNCTION ==================================================================
# Name: command_exists
# Description: Check command is exit
#===============================================================================
function command_exists () {
    type "$1" &> /dev/null ;
}

#=== FUNCTION ==================================================================
# Name: confirm
# Description: confirm to share result
#===============================================================================
function confirm () {
    # call with a prompt string or use a default
    read -r -p "${1:-Do your want to share it? [Y/n]} " response
    case $response in
        [yY][eE][sS]|[yY])
            true
            ;;
        [nN])
            false
            ;;
        *)
            true
            ;;
    esac
}

#=== FUNCTION ==================================================================
#
# Name: get_system_info
# Description: Get general info of system
# Parammeter: ---
#
#===============================================================================
function get_system_info () {
  SYSINFO=`head -n 1 /etc/issue | rev | cut -c7- | rev`
  NUMBER_CORES=`nproc`
  ARCH=`arch`
  PROCESSOR=`cat /proc/cpuinfo | grep "model name\|processor" | awk '
  /model\ name/{
  i=5
  while(i<=NF){
    printf $i
    if(i<NF){
      printf " "
    }
    i++
  }
  printf "\n"
  }' | head -n 1`;

  CPU_SPEED=`echo $PROCESSOR | awk '{print $5}'`
  TOTAL_MEMORY=`free -mt | awk '/Mem/{print $2}'`
  TOTAL_SWAP=`free -mt | awk '/Swap/{print $2}'`

}

#=== FUNCTION ==================================================================
#
# Name: read_zcash_path
# Description: Read zcash_path for running benchmark
# Parammeter: ---
#
#===============================================================================
function read_zcash_path () {
  echo "==================== ZCASH BENCHMARK ==================================="
  printf "\n\n"
  echo "Please enter your zcash-cli path if it not is executable command"
  echo "Example: ~/zcash/zcash-cli "
  read ZCASH_PATH_CLI
  echo "Your zcash-cli path: $ZCASH_PATH_CLI"

  if [[ -z "$ZCASH_PATH_CLI" ]]; then
    if ! command_exists zcash-cli; then
      echo "ERROR: zcash-cli command is not exist";
      exit 1;
    fi
  elif [ ! [[ -f "$ZCASH_PATH_CLI" && -f "$ZCASH_PATH_CLI" ]] ]; then
    echo "ERROR: $ZCASH_PATH_CLI is invalid executable file";
    exit 1;
  else
   export ZCASH_PATH_CLI=$ZCASH_PATH_CLI;
  fi;
}

#=== FUNCTION ==================================================================
#
# Name: ask_for_share_result
# Description: Ask user to confirm share benchmark result
#
#===============================================================================
function ask_for_share_result () {
  SHARE_RESULT=1
  if confirm ; then
    read -r -p "What's your name? [anonymous] " username
    USERNAME=${username:-'anonymous'}
  else
   SHARE_RESULT=0;
  fi;
}

#=== FUNCTION ==================================================================
#
# Name: run_benchmark
# Description: run zcash benchmark
#
#===============================================================================
function run_benchmark () {
  echo ""
  echo ""
  echo "Starting benchmark your system"
  echo ""
  echo "WARNING: - Make sure that your zcashd is running"
  echo "         - It can take several minutes, please don't interrupt it"
  echo ""
  echo "1. Run zcash-cli zcbenchmark solveequihash 20 to run 20 benchmark tests"
  echo "2. Calculate the average time of those results (total time / 20)"
  printf "\n"

  if [[ -z "$ZCASH_PATH_CLI" ]]; then
    RAW_RESULT=`zcash-cli zcbenchmark solveequihash 20`
  else
    BENCHMARK_CMD="$ZCASH_PATH_CLI zcbenchmark solveequihash 20"
    RAW_RESULT=$(eval "$BENCHMARK_CMD")
  fi;
  RESULT=`echo -e "$RAW_RESULT" | grep 'runningtime' | awk '{sum+=$3} END {print sum/NR}'`

  echo "-----------------------------------------------------------------------"
  echo -e "$RAW_RESULT"
  eval $BENCHMARK_CMD

  echo "-----------------------------------------------------------------------"
  printf "\n"
}

#=== FUNCTION ==================================================================
#
# Name: show_result
# Description: Show benchmark result
# Parammeter: ---
#
#===============================================================================
function show_result () {
  echo "============== ZCASH BENCHMARK RESULT ================================="
  printf "\n"
  echo "============== SYSTEM INFO ============================================="
  printf "\n"
  echo "  Distro info:	    "$SYSINFO""
  echo "  Processor:        "$PROCESSOR""
  echo "  Number of cores:  "$NUMBER_CORES""
  echo "  Speed:            "$CPU_SPEED""
  echo "  Architecture:     "$ARCH""
  echo "  Total Memory:     "$TOTAL_MEMORY"Mb"
  echo "  Total Swap:       "$TOTAL_SWAP"Mb"
  printf "\n"
  echo "======================================================================="
  printf "\n"
  echo "  RESULT: $RESULT"
  printf "\n"
  echo "======================================================================="
}

#=== FUNCTION ==================================================================
#
# Name: share_result
# Description: Share benchmark result to zcashbenchmark.com
# Parammeter: ---
#
#===============================================================================
function share_result () {
  API_SHARE="http://localhost:3000/api/benchmark"
  DATA="username=$USERNAME&distro=$SYSINFO&processor=$PROCESSOR&cores=$NUMBER_CORES&speed=$CPU_SPEED&architecture=$ARCH&mem=$TOTAL_MEMORY&swap=$TOTAL_SWAP&result=$RESULT"
  curl --data $DATA $API_SHARE
}

#=== FUNCTION ==================================================================
#
# Name: main
# Description: Main function
# Parammeter: ---
#
#===============================================================================
function main () {
  read_zcash_path;
  ask_for_share_result;
  get_system_info;
  run_benchmark;
  show_result;
}

# MAIN
main
