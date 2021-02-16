#!/bin/bash
set -eo pipefail
shopt -s extglob
shopt -s globstar
source /ez/util.sh

cd /var/run/s6/services

# Use 'status' as the default command
if [ -z "$1" ] || [[ "$1" = "-"* ]]; then cmd=status
else cmd=$1; shift; fi

# Parse args
verbose=0; nofollow=0; lines=8
while getopts "vcn:" opt; do case $opt in
  v ) verbose=1 ;;
  c ) nofollow=1 ;;
  n ) lines=$OPTARG ;;
  * ) error service Invalid arguments ;;
esac; done
shift $((OPTIND -1))

mgmtusage="expected service(s) name(s)"

case "$cmd" in
  # Some basic management commands
  up | u | start) xargs -n 1 s6-svc -uwu <<< ${@:?$mgmtusage} && $0 s $@;;
  down | d | stop) xargs -n 1 s6-svc -dwd <<< ${@:?$mgmtusage} && $0 s $@;;
  restart | r) xargs -n 1 s6-svc -ruwr <<< ${@:?$mgmtusage} && $0 s $@;;
  reload | h) xargs -n 1 s6-svc -h <<< ${@:?$mgmtusage} && $0 s $@;;

  # Logs viewer/tailer
  logs | log | l)
    logargs="-v -n $lines $([ $nofollow -eq 1 ] && echo '-c' || true)"
    if [ "$#" -eq 0 ]; then
      $0 logs $logargs *
    elif [ "$#" -eq 1 ]; then
      log_files=$(cat $1/log/location || error service No log files for $1)
      exec tail $([ $verbose -eq 1 ] && echo '-v') $([ $nofollow -eq 0 ] && echo '-F') \
                -n $lines $log_files
    else
      trap 'kill 0' EXIT
      for service in $@; do if [ -f $service/log/location ]; then
        $0 logs $logargs $service 2> /dev/null | sed "s|^| ${BOLD}$service${RESTORE} |" &
      fi; done
      wait && exit
    fi
    ;;

  # Service(s) status
  status | s)
    if [ "$#" -eq 0 ]; then
      $0 status $([ $verbose -eq 1 ] && echo "-v") !(s6-fdholderd)
    else for service in $@; do
      stat() { s6-svstat -o $1 $service; }
      up=$(stat up 2> /dev/null || echo unsupervised)

      echo -n "${BOLD}$service${RESTORE} "
      if [ $up == "unsupervised" ]; then
        echo "${RED}not supervised${RESTORE}"
      else
        if [ $up == "true" ]; then echo -n "${GREEN}up${RESTORE} "
        elif [ $(stat wantedup) == "false" ]; then echo -n "${CYAN}disabled${RESTORE} "
        else echo -n "${RED}down${RESTORE} "; fi
        s6-svstat $service | cut -d' ' -f2- | sed -r "s/want (up|down)/${ORANGE}\0${RESTORE}/"
      fi

      if [ $verbose -eq 1 ]; then
        if [ $up == "true" ]; then
          pid=$(stat pid); user=$(ps -o user= -p $pid); cmd=$(xargs -0 echo < /proc/$pid/cmdline)
          echo "   ${LGRAY}$user${BOLD}\$${RESTORE}${LGRAY} $cmd${RESTORE}"
        fi
        log_file=$(head -n 1 $service/log/location 2> /dev/null || true)
        [ -f "$log_file" ] && log_line=$(tail -n 1 "$log_file" | sed -r 's/\x1b\[[0-9;]*m|^\s+|\s+$//g')
        [ -n "$log_line" ] && echo "   ${BOLD}${LGRAY}last log:${RESTORE} ${LGRAY}${log_line}${RESTORE}"
        echo
      fi
    done; fi
    ;;
  *) error service Unknow command: $cmd
esac
