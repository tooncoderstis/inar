# ADR 0001 — Stack R Shiny untuk aplikasi dan mesin analisis

- **Status**: accepted
- **Tanggal**: 2026-11-01
- **Konteks**: Kode acuan penelitian adalah R (forward algorithm, Viterbi, EM, pseudo-residual). Aplikasi harus menampilkan hasil terverifikasi, lab parameter, dan materi pembelajaran bilingual. Tim kecil; deploy ke EasyPanel.

## Keputusan
Memakai **R Shiny** dengan `bslib`, `plotly`, dan `DT`. Mesin analisis dan aplikasi berada di bahasa yang sama. Hasil berat (MLE) dihitung oleh `scripts/run_analysis.R` dan disimpan sebagai artefak; lab parameter menghitung ulang model ringan secara reaktif.

## Alternatif yang dipertimbangkan
| Opsi | Kelebihan | Kekurangan |
|---|---|---|
| Next.js + engine TS + R verifikasi | UI modern, satu runtime web | Implementasi ganda; risiko engine TS menyimpang dari R |
| Next.js + R plumber | UI modern, hitungan R | Dua proses, image lebih berat, kompleksitas deploy |
| Shiny (dipilih) | Satu bahasa, memakai kode asli, cepat dibangun | UI kurang fleksibel, startup lebih berat |
| Static site | Paling ringan | Tidak ada lab reaktif |

## Konsekuensi
- Positif: tidak ada reimplementasi statistik; verifikasi memakai fungsi yang sama dengan UI; sesuai preseden `arima-intervensi`.
- Negatif: image lebih besar (~1 GB); perlu disiplin memisahkan hasil precomputed dari komputasi reaktif.
- Tindak lanjut: pin versi R di Dockerfile; ukur waktu startup dan respons lab.
