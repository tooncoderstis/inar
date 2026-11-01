# AGENTS — INAR Under-reporting Lab

## Project Bootstrap
- Baca `STATUS.md` lebih dulu (auto-load). Jangan membaca `PRD.md` penuh; ambil section relevan.
- Sumber kebenaran: `STATUS.md`. Riwayat: `CHANGELOG.md`. Keputusan: `docs/adr/`. Kebutuhan: `PRD.md`.
- Jangan pernah commit kredensial, `.env`, atau PDF penelitian. PDF hanya di `private/paper/`.
- Konvensi commit: Conventional Commits. Trunk-based. Tag SemVer.

## Perintah
```sh
Rscript scripts/run_analysis.R   # pipeline data + verifikasi -> verification/, data/processed/
Rscript -e "shiny::runApp('.', port=3838)"
Rscript tests/testthat.R
Rscript -e "styler::style_dir('.')"      # formatter
Rscript -e "lintr::lint_dir()"           # lint
npm run hub:report                       # lapor progres ke hub portofolio
```

## Arsitektur
- `app.R` + `R/` — aplikasi Shiny dan mesin statistik (forward algorithm, Viterbi, EM 2-Poisson, pseudo-residual).
- `scripts/run_analysis.R` — satu-satunya jalur produksi angka. UI membaca artefak di `verification/` dan `data/processed/`.
- `analysis/original/` — kode R penulis paper (referensi, jangan diubah tanpa ADR).
- `content/{id,en}/` — materi pembelajaran Markdown.
- `private/paper/` — PDF; disajikan inline via endpoint sesi setelah password. Jangan pindahkan ke `www/`.

## Aturan verifikasi
- Setiap angka paper harus punya entri di `verification/report.json` dengan `paper`, `reproduced`, `diff`, `tolerance`, `status`.
- HPV: statistik, estimasi naive, dan MLE harus eksak pada 3 desimal (toleransi 0,0005).
- Botulism: deskriptif eksak; MLE berstatus `estimated` sampai data asli ditemukan.
- Mesothelioma: `N/A` (ekstensi, bukan reproduksi). Jangan menampilkan angka Table II sebagai hasil.
- CI gagal bila status `PASS` berubah menjadi `FAIL`.

## Data
- `data/raw/` tidak diubah. Semua transformasi di `scripts/` dan didokumentasikan di `data/processed/PROVENANCE.md`.
- Populasi Kanada/UK disimpan di `data/reference/` beserta URL dan tanggal akses.

## Deploy
- EasyPanel project `m`, service `inar`, domain `m-inar.hgteop.easypanel.host`, port 3838.
- Saat ini build dari Git (source `inar`) karena push registry timeout (ADR 0004). Deploy via MCP EasyPanel; jangan menaruh PDF mentah di repo.
- Env wajib: `APP_VERSION`, `PORT=3838`, `PDF_PASSWORD_HASH`, `PDF_PASSWORD_SALT`, `PDF_ENC_KEY`.
