#!/bin/bash

USERNAME="XXXXXXX"
PASSWORD="XXXXXXX"
HOST="Unifi_controller_IP"

COOKIE="/tmp/unifi_cookie.txt"
STATE="/tmp/state.flag"
LOGFILE="/var/log/unifi_recording.log"

CAMERA_IDS=(
  "xxxxxxxxxxxxxxxxxxxxxxxx"
  "xxxxxxxxxxxxxxxxxxxxxxxx"
  "xxxxxxxxxxxxxxxxxxxxxxxx"
  "xxxxxxxxxxxxxxxxxxxxxxxx"
)

if [[ "$1" != "on" && "$1" != "off" ]]; then
  echo "❌ Utilisation : $0 [on|off]"
  exit 1
fi

if [[ "$1" == "on" ]]; then
  TARGET_MODE="detections"
  ACTION="Activation enregistrement (Event Only)"
  EMOJI="✅"
  > "$STATE"
else
  TARGET_MODE="never"
  ACTION="Désactivation enregistrement"
  EMOJI="🛑"
  rm -f "$STATE"
fi

ping -c 1 -W 2 "$HOST" > /dev/null
if [[ $? -ne 0 ]]; then
  echo "❌ Impossible de joindre $HOST. Vérifie la connexion réseau."
  exit 2
fi

echo "🔐 Connexion à UniFi Protect..."
curl -sk -c "$COOKIE" -X POST "https://$HOST/api/auth/login" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"username\":\"$USERNAME\", \"password\":\"$PASSWORD\"}" > /dev/null

JWT_TOKEN=$(grep 'TOKEN' "$COOKIE" | awk '{print $7}' | tail -1)
PAYLOAD=$(echo "$JWT_TOKEN" | cut -d '.' -f2 | tr '_-' '/+' | awk '{print $0"=="}')
CSRF_TOKEN=$(echo "$PAYLOAD" | base64 -d 2>/dev/null | jq -r '.csrfToken')

if [[ -z "$CSRF_TOKEN" || "$CSRF_TOKEN" == "null" ]]; then
  echo "❌ Impossible de récupérer le token CSRF décodé."
  exit 3
fi

for CAMERA_ID in "${CAMERA_IDS[@]}"; do
  echo "$EMOJI $ACTION : $CAMERA_ID"

  curl -sk -b "$COOKIE" -X PATCH "https://$HOST/proxy/protect/api/cameras/$CAMERA_ID" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "X-CSRF-Token: $CSRF_TOKEN" \
    -d "{\"recordingSettings\": {\"mode\": \"$TARGET_MODE\"}}" > /dev/null
  
 NEW_MODE=$(curl -sk -b "$COOKIE" "https://$HOST/proxy/protect/api/cameras/$CAMERA_ID" \
    -H "Accept: application/json" \
    | jq -r '.recordingSettings.mode')
  echo "📡 Caméra $CAMERA_ID → Mode après mise à jour : $NEW_MODE"
  echo "$(date '+%F %T') | $ACTION - $CAMERA_ID → mode : $NEW_MODE" >> "$LOGFILE"
done

#rm -f "$COOKIE"
echo "🎬 $ACTION complétée (mode : $TARGET_MODE)."
