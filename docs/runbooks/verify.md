# Runbook — Verifikasi rekonstruksi

## Tujuan
Menghasilkan `verification/report.json`, `verification/REPORT.md`, dan artefak `public/data/` dari data mentah, lalu memastikan status verifikasi tidak menurun.

## Jalankan
```sh
Rscript scripts/run_analysis.R
```

Keluaran:
- `data/processed/hpv_girona.csv`
- `data/processed/botulism_canada.csv`
- `data/processed/mesothelioma_gb.csv`
- `public/data/hpv.json`, `botulism.json`, `mesothelioma.json`, `summary.json`
- `verification/report.json`, `verification/REPORT.md`
- `verification/golden/*.json`

## Status
| Status | Arti |
|---|---|
| `PASS` | Sama persis (toleransi 1e-9) |
| `PASS_TOLERANCE` | Dalam toleransi yang disepakati |
| `ESTIMATED` | Angka paper tidak dapat direproduksi karena data asli tidak tersedia |
| `N/A` | Bukan bagian reproduksi (ekstensi) |
| `FAIL` | Di luar toleransi — CI gagal |

## Aturan toleransi
- Statistik deskriptif & estimasi naive: absolut `1e-6` (dibulatkan ke presisi paper).
- MLE HPV: sama dengan paper pada 3 desimal (toleransi 0,0005).
- MLE Botulism: `ESTIMATED` sampai `bot.csv`/`popC.csv` asli ditemukan.

## Menambah metrik
Tambahkan entri di `R/verification.R` (`metric(...)`) dengan `paper`, `reproduced`, `tolerance`, `unit`, `note`. Jangan menulis status manual.

## CI
Workflow `.github/workflows/ci.yml` menjalankan pipeline dan gagal bila ada entri `PASS`/`PASS_TOLERANCE` berubah menjadi `FAIL`.
