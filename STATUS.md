# STATUS — INAR Under-reporting Lab

> **Sumber kebenaran status & progres.** Baca file ini dulu sebelum melanjutkan pekerjaan.
> Riwayat rilis: [`CHANGELOG.md`](CHANGELOG.md) · Keputusan: [`docs/adr/`](docs/adr/) · Kebutuhan: [`PRD.md`](PRD.md).
> **Jangan simpan kredensial di file ini.**

- **Terakhir diperbarui**: 2026-11-01
- **Versi produksi aktif**: 0.1.0
- **Platform**: R Shiny (bslib + plotly + DT) · Docker · EasyPanel `m/inar`
- **URL**: https://m-inar.hgteop.easypanel.host
- **Repo**: https://github.com/tooncoderstis/inar

## TL;DR (konteks 30 detik)
Web lab under-reporting merekonstruksi Fernández-Fontelo dkk. (2016, INAR(1)-hidden Markov chain). HPV kini **PASS eksak** (statistik, naive, MLE, SE) setelah orientasi matriks transisi diperbaiki. Botulism PASS deskriptif; MLE ESTIMATED karena counts diturunkan dari rate. Mesothelioma ekstensi berlabel N/A. Aplikasi bilingual ID/EN dengan lab parameter dan PDF inline berpassword (tersimpan terenkripsi).

## Checklist Tahap
| Tahap | Judul | Status |
|---|---|---|
| 0 | Setup & Fondasi | ✅ |
| 1 | Dokumentasi & ADR | ✅ |
| 2 | Data & provenance | ✅ |
| 3 | Pipeline R + verifikasi | ✅ |
| 4 | Web (dashboard, metodologi, lab) | ✅ |
| 5 | PDF gate + viewer inline | ✅ |
| 6 | Kualitas (test, CI, formatter) | ✅ |
| 7 | Deploy EasyPanel | ✅ |
| 8 | Hub portofolio & rilis | 🔄 |

> Fase dikerjakan: tandai 🔄 saat mulai dan ✅ saat selesai, lalu jalankan `npm run hub:report` di tiap perubahan.

## Kondisi saat ini
- Live di `https://m-inar.hgteop.easypanel.host` (HTTP 200, PDF 16 halaman, terverifikasi Playwright 375/768/1440).
- `Rscript scripts/run_analysis.R`: **17 PASS, 13 PASS_TOLERANCE, 5 ESTIMATED, 4 N/A, 0 FAIL**.
- `Rscript tests/testthat.R`: 28 test lulus; `lintr` bersih; `styler` diterapkan.
- HPV: n=260, mean 1,2692, var 1,6029, ACF(1) 0,1338; MLE α=0,5167, λ=1,6232, ω=0,9220, q=0,3256; coverage 37,8%.
- Botulism: n=44, mean 8,84, var 44,97; MLE α=0,5488, a=2,7671, ω=0,7011, q=0,3258 (ESTIMATED).
- Mesothelioma: seri HSE tidak sama dengan seri paper; tidak diklaim.
- Deploy memakai build Git (ADR 0004) karena push registry timeout; PDF hanya ada sebagai `paper.enc` dengan kunci di env.

## Yang belum selesai / menunggu
| Item | Catatan |
|---|---|
| Image privat di registry | push Docker Hub timeout; GHCR token tanpa `write:packages`. Pindahkan saat jaringan/kredensial membaik. |
| `bot.csv` & `popC.csv` asli | jika ditemukan, ubah Botulism MLE dari ESTIMATED ke verifikasi penuh. |
| Rotasi password PDF | `12334567` sudah terekspos di chat; rotasi via runbook operate. |
| Foto/screenshot UI | belum diambil untuk dokumentasi. |

## Cara menjalankan & menguji
```sh
Rscript scripts/run_analysis.R      # pipeline + verifikasi (~4 menit)
Rscript scripts/run_app.R           # aplikasi di :3838
Rscript tests/testthat.R            # unit + golden test
npm run hub:report                  # lapor progres
```

## Rilis
`git push origin main` → EasyPanel build dari Git (source `inar`). Detail: [`docs/runbooks/deploy.md`](docs/runbooks/deploy.md).

## Referensi cepat
- PRD: `PRD.md` · Changelog: `CHANGELOG.md` · ADR: `docs/adr/README.md` · Runbook: `docs/runbooks/`
