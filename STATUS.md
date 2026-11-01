# STATUS — INAR Under-reporting Lab

> **Sumber kebenaran status & progres.** Baca file ini dulu sebelum melanjutkan pekerjaan.
> Riwayat rilis: [`CHANGELOG.md`](CHANGELOG.md) · Keputusan: [`docs/adr/`](docs/adr/) · Kebutuhan: [`PRD.md`](PRD.md).
> **Jangan simpan kredensial di file ini.**

- **Terakhir diperbarui**: 2026-11-01
- **Versi produksi aktif**: belum dirilis
- **Platform**: R Shiny (bslib + plotly + DT) · Docker · EasyPanel `m/inar`

## TL;DR (konteks 30 detik)
Web laboratorium under-reporting yang merekonstruksi Fernández-Fontelo dkk. (2016, INAR(1)-hidden Markov chain) dari kode R suplemen + data publik. HPV terverifikasi (statistik/naive eksak; MLE dalam 2,5%), Botulism terverifikasi deskriptif (MLE masih perkiraan), mesothelioma ekstensi berlabel. Aplikasi bilingual ID/EN dengan lab parameter dan PDF inline berpassword.

## Checklist Tahap
| Tahap | Judul | Status |
|---|---|---|
| 0 | Setup & Fondasi | 🔄 |
| 1 | Dokumentasi & ADR | 🔄 |
| 2 | Data & provenance | ⬜ |
| 3 | Pipeline R + verifikasi | ⬜ |
| 4 | Web (dashboard, metodologi, lab) | ⬜ |
| 5 | PDF gate + viewer inline | ⬜ |
| 6 | Kualitas (test, CI, formatter) | ⬜ |
| 7 | Deploy EasyPanel | ⬜ |
| 8 | Hub portofolio & rilis | ⬜ |

> Fase dikerjakan: tandai 🔄 saat mulai dan ✅ saat selesai, lalu jalankan `npm run hub:report` di tiap perubahan — hub portofolio mengirim notifikasi (inbox + Web Push).

## Kondisi saat ini
- Data mentah dipindahkan ke `data/raw/`; PDF ke `private/paper/` (tidak di `www/`).
- R 4.5.3 tersedia; `shiny`, `bslib`, `plotly`, `DT`, `readxl`, `digest`, `testthat`, `styler`, `lintr` terpasang.
- Uji awal: HPV 260 obs, mean 1,2692, var 1,6029, ACF(1) 0,1338; EM 2-Poisson 1,0426/2,7658/ω=0,8685.
- MLE HPV rekonstruksi 0,520/1,647/0,926/0,320 vs paper 0,517/1,623/0,922/0,326 (likelihood rekonstruksi lebih tinggi).
- Botulism: counts turunan dari rate×populasi; MLE 0,566/2,630/0,714/0,333 belum sama dengan paper.

## Yang belum selesai / menunggu
| Item | Catatan |
|---|---|
| `bot.csv` & `popC.csv` asli | dicari di suplemen publisher; jika tidak ada, status MLE = WARN |
| PDF.js assets | di-vendor saat build |
| Docker daemon | Docker Desktop belum berjalan saat scaffold |
| Kredensial registry privat | dipasang saat deploy |

## Cara menjalankan & menguji
```sh
Rscript scripts/run_analysis.R      # pipeline + verifikasi
Rscript -e "shiny::runApp('.', port=3838)"  # aplikasi
Rscript tests/testthat.R            # unit + golden test
npm run hub:report                  # lapor progres
```

## Rilis
`docker build -t aasatech/inar:<versi> .` → push ke registry privat → deploy EasyPanel `m/inar`. Detail: [`docs/runbooks/deploy.md`](docs/runbooks/deploy.md).

## Referensi cepat
- PRD: `PRD.md` · Changelog: `CHANGELOG.md` · ADR: `docs/adr/README.md` · Runbook: `docs/runbooks/`
