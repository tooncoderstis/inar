# ADR 0002 — Provenance data dan kebijakan verifikasi

- **Status**: accepted
- **Tanggal**: 2026-11-01
- **Konteks**: File yang dipakai paper (`diagnosticat4.csv`, `bot.csv`, `popC.csv`) tidak tersedia. Yang ada: data mingguan Catalonia, file rate botulism PHAC, dan tabel HSE mesothelioma. Tujuan proyek menuntut verifikasi terhadap paper.

## Keputusan
1. HPV memakai `data/raw/hpv_catalonia_weekly.csv` (kolom `Girona`, buang minggu 53) → seri 2010–2014 (260 observasi).
2. Botulism memakai rate PHAC × populasi Kanada (World Bank/StatCan) untuk menurunkan counts; koreksi 2010 = 2 mengikuti skrip penulis. Seri ini diberi label **derived**.
3. Mesothelioma memakai total HSE 1968–2013 sebagai **ekstensi**, bukan reproduksi. Angka Table II paper tidak diklaim.
4. Setiap angka punya status: `exact`, `within_tolerance`, `estimated`, `not_applicable`.
5. MLE HPV harus sama dengan paper pada 3 desimal (toleransi 0,0005) setelah orientasi matriks transisi diperbaiki.

## Alternatif yang dipertimbangkan
| Opsi | Kelebihan | Kekurangan |
|---|---|---|
| Hanya menampilkan yang eksak | Bersih | Kehilangan dua dari tiga contoh |
| Mengklaim semua cocok | Terlihat lengkap | Tidak jujur; melanggar prinsip |
| Status bertingkat (dipilih) | Jujur & tetap informatif | UI harus menjelaskan nuansa |

## Konsekuensi
- Positif: integritas ilmiah terjaga; pengguna tahu mana yang benar-benar direproduksi.
- Negatif: Botulism MLE tidak bisa PASS sampai data asli ditemukan.
- Tindak lanjut: cari `bot.csv`/`popC.csv` di suplemen Wiley; jika ditemukan, ubah status dan catat di CHANGELOG.
