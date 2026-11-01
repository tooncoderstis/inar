# Security Policy

## Melaporkan masalah
Kirim email ke pemilik repositori. Jangan membuka issue publik untuk kerentanan.

## Kontrol
- Kredensial hanya lewat environment; `.env` di-ignore.
- PDF di luar `www/`; disajikan inline setelah password, dengan rate limit.
- Password disimpan sebagai HMAC-SHA256 + salt; tidak pernah dicatat di log.
- Dependency minimal; image privat untuk PDF berhak cipta.
- Tidak ada data pribadi; data yang disajikan adalah agregat publik.

## Rotasi
Lihat `docs/runbooks/operate.md`.
