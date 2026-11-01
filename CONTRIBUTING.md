# Contributing

1. Baca `STATUS.md` dan ADR terkait sebelum mengubah kode.
2. Buat branch pendek dari `main`.
3. Jalankan `Rscript scripts/run_analysis.R` dan `Rscript tests/testthat.R`.
4. Format: `Rscript -e "styler::style_dir('.')"`; lint: `Rscript -e "lintr::lint_dir()"`.
5. Perbarui `CHANGELOG.md`, `STATUS.md`, dan ADR bila ada keputusan.
6. Commit dengan Conventional Commits (`feat:`, `fix:`, `docs:`, `test:`, `chore:`).
7. Jangan commit `.env`, PDF, atau data eksternal.

## Aturan data
- `data/raw/` tidak diubah.
- Transformasi baru harus tercatat di `data/processed/PROVENANCE.md`.
- Angka baru harus muncul di `verification/report.json` dengan status.
