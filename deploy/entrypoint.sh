#!/bin/sh
set -eu

# PDF berhak cipta disimpan terenkripsi di repo/image (paper.enc).
# Kunci hanya diberikan lewat environment PDF_ENC_KEY saat runtime.
if [ -n "${PDF_ENC_KEY:-}" ] && [ -f /app/private/paper/paper.enc ]; then
  openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 \
    -in /app/private/paper/paper.enc \
    -out /tmp/paper.pdf \
    -pass env:PDF_ENC_KEY
  export PDF_PATH=/tmp/paper.pdf
fi

exec R --quiet -e "shiny::runApp('.', host='0.0.0.0', port=as.integer(Sys.getenv('PORT', '3838')))"
