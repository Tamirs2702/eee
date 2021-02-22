# -- expected to be `source`ed

bool_opt() { [ -n "$1" ] && [ "$1" != "0" ] && [ "$1" != "false" ] && [ "$1" != "off" ]; }

wait_for_file() { # (path, timeout=15s)
  timeout=${2:-15s}
  debug $(basename $PWD) waiting for $1 for up to $timeout
  pfile=$(mktemp -u)
  [ -f "$1" ] \
  || (pidfile $pfile timeout $timeout inotifywait -e create,moved_to --format '%f' -m "$(dirname "$1")" 2>&1 \
    | { grep -qx 'Watches established.' && [ -f "$1" ] || grep -qFx "$(basename "$1")" && killpidf $pfile; }) \
  || { warn $(basename $PWD) $1 did not appear && return 1; }
}

wait_for_service() { # (service, timeout=3 minutes)
  timeout=${2:-180000}
  debug $(basename $PWD) waiting for $1 for up to ${timeout}ms
  # wait for the fd readiness notification when the fd file exists (https://skarnet.org/software/s6/notifywhenup.html)
  wait_type=$([ -f /run/s6/services/$1/notification-fd ] && echo '-U' || echo '-u')
  s6-svwait -t $timeout $wait_type /run/s6/services/$1 2> /dev/null \
    || { debug $(basename $PWD) failed waiting for $1 && return 1; }
}

wait_for_bitcoind() {
  dir=/run/s6/services/bitcoind
  if [ -d $dir ] && [ ! -f $dir/down ]; then
    # Wait for up to 15 minutes. bitcoind may occasionally take a long time to load up.
    # it could take even longer, but the waiting service will restart and try again when this timeout is reached.
    wait_for_service bitcoind 900000
  fi
}

abort_service() {
  # expected to be called from `run` scripts, with the service directory as the PWD
  debug $(basename $PWD) service is disabled
  touch down && s6-svc -O . && exit 0
}

# XXX get rid
kill_descendants() { #(pid, command name, signal)wAITING_F
  local pids=$1; local cmd=$2; local sig=${3:-INT}
  while [ -n "$pids" ]; do
    xargs -n1 pkill -$sig -x $cmd -P <<< $pids || true
    pids=$(xargs -n1 pgrep -P <<< $pids)
  done
}

pidfile() { #(pidfile, command...)
  "${@:2}" &
  echo $! > $1
  wait
}
killpidf() { #(pidfile)
  kill $(cat "$1") 2> /dev/null || true
  rm "$1"
}

BOLD=$(echo -en '\e[1m')
RED=$(echo -en '\e[31m')
GREEN=$(echo -en '\e[32m')
YELLOW=$(echo -en '\e[1;33m')
ORANGE=$(echo -en '\e[0;33m')
BLUE=$(echo -en '\e[34m')
LBLUE=$(echo -en '\e[94m')
CYAN=$(echo -en '\e[36m')
#GRAY=$(echo -en '\e[1;30m')
LGRAY=$(echo -en '\e[0;37m')
#BGRAY=$(echo -en '\e[01;37m')
#LGREEN=$(echo -en '\e[1;32m')
RESTORE=$(echo -en '\e[0m')

error() {
  echo >&2 " ${RED}${BOLD}ERROR${RESTORE} ${BOLD}${1}${RESTORE} > ${@:2}"
  exit 1
}
warn() {
  echo >&2 " ${YELLOW}${BOLD}WARN${RESTORE}  ${BOLD}${1}${RESTORE} > ${@:2}"
}
info() {
  if [ "$1" == "-n" ]; then local n="$1"; shift; fi
  echo >&2 $n " ${GREEN}INFO${RESTORE}  ${BOLD}${1}${RESTORE} > ${@:2}"
}
debug() {
  ! bool_opt "$VERBOSE" || \
  echo >&2 $n " ${BLUE}DEBUG${RESTORE} ${BOLD}${1}${RESTORE} > ${@:2}"
}
log_prefix() {
  exec sed "s/^/ ${BOLD}$1${RESTORE} > /"
}
