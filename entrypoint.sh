#!/bin/sh

set -eu

PYTHON="su-exec ${PUID}:${PGID} python"
ELODIE="${PYTHON} /elodie/elodie.py"

IMPORT_OPTIONS="--destination ${DESTINATION}"

if [ "${TRASH:-}" ]; then
  mkdir -p "${XDG_DATA_HOME:-~/.local/share}"
  ln -s "${TRASH}" "${XDG_DATA_HOME:-${HOME}/.local/share}/Trash"
  IMPORT_OPTIONS="${IMPORT_OPTIONS} --trash"
fi

if [ "${EXCLUDE:-}" ]; then
  IMPORT_OPTIONS="${IMPORT_OPTIONS} --exclude-regex ${EXCLUDE}"
fi

if [ "${ALLOW_DUPLICATE:-}" ]; then
  IMPORT_OPTIONS="${IMPORT_OPTIONS} --allow-duplicates}"
fi

if [ "${ALBUM_FROM_FOLDER:-}" ]; then
  IMPORT_OPTIONS="${IMPORT_OPTIONS} --album-from-folder"
fi

if [ "${DEBUG:-}" ]; then
  IMPORT_OPTIONS="${IMPORT_OPTIONS} --debug"
fi

if [ ! -e "${ELODIE_APPLICATION_DIRECTORY}/config.ini" ] && [ "${MAPQUEST_KEY:-}" ] ; then
 echo -e "[MapQuest]\nkey=${MAPQUEST_KEY}\nprefer_english_names=False" > "${ELODIE_APPLICATION_DIRECTORY}/config.ini"
fi

case "${1:-watch}" in
  watch)
    inotifywait -e close_write -mr "${SOURCE}" | while read -r EV;
    do
      (
        NOW=$($PYTHON -c "import time;print(time.time());")
        echo "${NOW}" > /tmp/elodie-last-debounce
        sleep 60
        LAST_DEBOUNCE=$(cat /tmp/elodie-last-debounce)
        if [ "${NOW}" = "${LAST_DEBOUNCE}" ]; then
          exec ${ELODIE} import ${IMPORT_OPTIONS} ${SOURCE}
        fi
       ) &
    done
    ;;
  *)
    exec ${ELODIE} $@
    ;;
    
esac