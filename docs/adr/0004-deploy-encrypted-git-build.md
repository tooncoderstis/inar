# ADR 0004 — Build dari Git + PDF terenkripsi (fallback deploy)

- **Status**: accepted (sementara)
- **Tanggal**: 2026-11-01
- **Konteks**: Rencana awal adalah image privat di registry (ADR 0003). Saat eksekusi, push image 1,8 GB ke Docker Hub gagal berulang kali (`net/http: timeout awaiting response headers`), dan token GHCR yang tersedia tidak memiliki `write:packages`. Registry push tidak dapat diandalkan dari mesin ini.

## Keputusan
1. Kode dan artefak dipublikasikan di repo Git publik `tooncoderstis/inar`.
2. PDF penelitian **tidak** masuk repo sebagai PDF. Ia disimpan sebagai `private/paper/paper.enc` (AES-256-CBC, PBKDF2 200.000 iterasi). Kunci hanya ada di env `PDF_ENC_KEY` pada service EasyPanel.
3. Entrypoint mendekripsi ke `/tmp/paper.pdf` saat container start, lalu Shiny menyajikannya inline setelah password.
4. EasyPanel membangun image dari Dockerfile repo (source Git). Image hasil build tetap internal di server, tidak dipublikasikan.
5. `.dockerignore` mengecualikan PDF mentah sehingga image tidak pernah memuat PDF plaintext.

## Alternatif yang dipertimbangkan
| Opsi | Kelebihan | Kekurangan |
|---|---|---|
| Push image ke Docker Hub | Sesuai ADR 0003 | Gagal berulang karena timeout upload |
| GHCR | Registry privat | Token tidak punya `write:packages` |
| Build dari Git + PDF terenkripsi (dipilih) | Tidak butuh registry; PDF aman | Build di server (menyimpang dari preferensi awal) |
| Volume EasyPanel untuk PDF | Image publik tanpa PDF | Perlu unggah manual; tidak programatik |

## Konsekuensi
- Positif: deploy dapat diselesaikan sekarang; PDF tidak dapat dibaca tanpa kunci; repo publik tidak membocorkan dokumen.
- Negatif: build memakai resource server (CPU/RAM) dan tidak melalui CI; deploy lebih lambat.
- Tindak lanjut: pindahkan ke image privat di registry yang dapat diakses saat kredensial/ jaringan membaik; rotasi `PDF_ENC_KEY` dan password; pastikan repo tidak berisi `.env`.
