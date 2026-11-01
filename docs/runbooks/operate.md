# Runbook — Operasi

## Startup lokal
```sh
Rscript -e "shiny::runApp('.', port=3838)"
```
Buka http://localhost:3838.

## Log
- Lokal: output R di terminal.
- Produksi: log container EasyPanel (`inar`).

## Rotasi password PDF
1. Pilih password baru.
2. Buat salt acak 32 hex.
3. Hitung hash:
   ```sh
   Rscript -e "cat(digest::hmac(key='<SALT>', object='<PASSWORD>', algo='sha256'))"
   ```
4. Perbarui `PDF_PASSWORD_SALT` dan `PDF_PASSWORD_HASH` di environment service (MCP `updateAppEnv`, konfirmasi karena destruktif), lalu redeploy.
5. Catat di CHANGELOG tanpa menulis password.

## Health
- `GET /` harus 200.
- Tidak ada endpoint `/healthz` terpisah; EasyPanel memakai path `/`.

## Insiden
- Bila PDF bocor: rotasi password, nonaktifkan service, ganti image tag, audit log akses.
- Bila verifikasi gagal di produksi: jangan tampilkan angka; deploy tag terakhir yang lulus.
