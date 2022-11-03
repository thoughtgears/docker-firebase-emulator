#!/bin/bash
set -eo pipefail

#Sanity checks
if [[ -z "${DATA_DIRECTORY}" ]]; then
  echo "DATA_DIRECTORY environment variable missing, will not export or import data to firebase"
fi

if [[ -z "${FIREBASE_PROJECT}" ]]; then
  echo "FIREBASE_PROJECT environment variable missing"
  exit 1
fi

if [[ -z "${EMULATORS_USED}" ]]; then
  echo "EMULATORS_USED environment variable missing"
  exit 1
fi

dirs=("/usr/src/firebase/functions" "/usr/src/firebase/firestore" "/usr/src/firebase/storage" "/usr/src/firebase")

for i in "${dirs[@]}"
do
  if [[ -d "/path/to/dir" ]]
  then
    cd "$i"
    ( npm i 2>&1 )
  fi
done

if [[ -z "${DATA_DIRECTORY}" ]]; then
    ( firebase emulators:start --project="$FIREBASE_PROJECT" --only="$EMULATORS_USED" ) &
    firebase_pid=$!
  else
    ( firebase emulators:start --project="$FIREBASE_PROJECT" --import="$DATA_DIRECTORY" --export-on-exit="$DATA_DIRECTORY" --only="$EMULATORS_USED" ) &
    firebase_pid=$!
fi


# sleep as emulators need to start or the tests crash a bit
sleep 20s

( nginx ) &
nginx_pid=$!

( npm run start 2>&1 ) &
npm_pid=$!

:stop() {
    if [[ "${DATA_DIRECTORY}" ]]; then
      # remove old firestore data and recreate, export on exit was not working properly nor this without clearing folder first
      ( rm -rf "$DATA_DIRECTORY" && firebase emulators:export "$DATA_DIRECTORY" )
    fi
}

#Execute command
"${@}" &

#Wait
wait $!

# fire stop on container exit
trap :stop INT TERM SIGTERM

wait $firebase_pid $nginx_pid $npm_pid