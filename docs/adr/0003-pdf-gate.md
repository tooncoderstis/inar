# ADR 0003 — PDF inline dengan password dan image privat

- **Status**: accepted
- **Tanggal**: 2026-11-01
- **Konteks**: PDF penelitian berhak cipta harus dapat dibaca di web, tetapi hanya setelah password, dan tidak boleh dapat diunduh bebas. Password yang diminta: `12334567`.

## Keputusan
- PDF disimpan di `private/paper/` (di luar `www/`), tidak pernah disajikan sebagai file statis.
- Setelah password benar, byte PDF disajikan lewat `session$registerDataObj()` dengan header `Content-Disposition: inline`, `Cache-Control: no-store`, `X-Robots-Tag: noindex`.
- Viewer memakai **PDF.js** yang di-vendor; tanpa tombol unduh.
- Password hanya disimpan sebagai HMAC-SHA256(password, salt) di env `PDF_PASSWORD_HASH` + `PDF_PASSWORD_SALT`. Rate limit 5 percobaan / 5 menit.
- Image registry **privat** agar PDF tidak dapat diekstrak dari image publik.
- `.gitignore` mengecualikan `private/paper/*.pdf`; image dibangun lokal dengan PDF, CI tidak mempublikasikan image.

## Alternatif yang dipertimbangkan
| Opsi | Kelebihan | Kekurangan |
|---|---|---|
| PDF di `www/` + JS gate | Sederhana | Bocor: URL statis dapat diakses langsung |
| `downloadHandler` | Familiar | Memaksa unduh, bukan baca inline |
| registerDataObj + PDF.js (dipilih) | Inline, terkontrol per sesi | Butuh PDF.js dan endpoint kustom |
| Render halaman jadi gambar | Kontrol penuh | Tidak ada pencarian teks; cache besar |

## Konsekuensi
- Positif: tidak ada byte PDF sebelum autentikasi; pengalaman baca konsisten.
- Negatif: browser masih bisa menyimpan PDF setelah ditampilkan (batas teknis); password lemah.
- Tindak lanjut: rotasi password; pertimbangkan watermark; pantau percobaan gagal.
- Catatan implementasi: karena registry push gagal, image dibangun dari Git dan PDF disimpan terenkripsi; lihat ADR 0004.
