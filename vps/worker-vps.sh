#!/usr/bin/env bash
set -euo pipefail

cd /opt/oj-judge

set -a
source /opt/oj-judge/.env
set +a

echo "[OJ-VPS-Worker] Bắt đầu lắng nghe hàng đợi bài nộp..."

while true; do
  SUB_ID=$(curl -sS -X POST "${SUPABASE_URL}/rest/v1/rpc/claim_next_submission" \
    -H "apikey: ${SUPABASE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_KEY}" \
    -H "Content-Type: application/json" \
    -d '{}' || echo "null")

  if [[ -n "$SUB_ID" && "$SUB_ID" != "null" && "$SUB_ID" =~ ^[0-9]+$ ]]; then
    echo "[OJ-VPS-Worker] Đang chấm bài #${SUB_ID}..."
    ./judge "$SUB_ID" || echo "[OJ-VPS-Worker] Lỗi khi chấm bài #${SUB_ID}"
  else
    sleep 0.25
  fi
done
