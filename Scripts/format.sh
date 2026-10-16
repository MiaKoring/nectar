cd "$(dirname "$0")"/../ || exit 1

if [ -z "$1" ]; then
  swiftformat . --exclude
else
  swiftformat "$1"
fi
