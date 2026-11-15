#!/usr/bin/env bash
# سرو کردن نسخه وب بیلدشده ONTIME (پورت قابل تغییر با آرگومان اول)
set -e
PORT="${1:-8080}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
if [ ! -f build/web/index.html ]; then
  echo "خروجی وب موجود نیست؛ در حال ساخت…"
  flutter build web --release --no-tree-shake-icons --no-web-resources-cdn --no-wasm-dry-run
fi
echo "ONTIME در حال اجرا روی http://0.0.0.0:$PORT"
cd build/web && exec python3 -m http.server "$PORT" --bind 0.0.0.0
