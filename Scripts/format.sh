cd "$(dirname "$0")"/../ || exit 1

if [ -z "$1" ]; then
  swiftformat .
else
  swiftformat "$1"
fi
