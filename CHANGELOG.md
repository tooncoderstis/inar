# Changelog

Semua perubahan penting proyek ini didokumentasikan di file ini.
Format mengikuti [Keep a Changelog](https://keepachangelog.com/id/1.1.0/) dan [Semantic Versioning](https://semver.org/lang/id/).

## [0.1.0] - 2026-11-01

### Added
- Scaffold dokumentasi proyek: PRD, STATUS, CHANGELOG, ADR 0001-0004, runbook deploy/verifikasi/operasi.
- Pipeline R deterministik (`scripts/run_analysis.R`) untuk data, model, verifikasi, dan artefak JSON.
- Mesin INAR(1)-hidden Markov chain: emission, transisi, forward algorithm, Viterbi, EM 2-Poisson, mid-pseudo-residual.
- Verifikasi otomatis terhadap paper: 17 PASS, 13 PASS_TOLERANCE, 5 ESTIMATED, 4 N/A, 0 FAIL.
- Aplikasi Shiny bilingual ID/EN: ringkasan, HPV, Botulism, Mesothelioma (ekstensi), metodologi, lab parameter, verifikasi, data, paper, tentang.
- PDF inline dengan PDF.js, password (hash + salt), rate limit, dan endpoint sesi `Content-Disposition: inline`.
- Enkripsi PDF (AES-256-CBC, PBKDF2) dengan kunci runtime `PDF_ENC_KEY`.
- Playwright PDF.js viewer, favicon, CSS responsif, MathJax untuk rumus.
- Test `testthat` untuk engine, verifikasi, dan gate PDF; workflow CI (verifikasi + test + style + docker build).
- Deploy EasyPanel `m/inar` dari Git dengan domain `m-inar.hgteop.easypanel.host`.
- Pelaporan hub portofolio (`npm run hub:report`).

### Fixed
- Orientasi matriks transisi pada forward algorithm (kolom = state berikutnya). Setelah perbaikan, MLE HPV dan SE sama dengan paper pada 3 desimal.
- Rekonstruksi Viterbi memakai rekursi max seperti kode suplemen; semua nol HPV direkonstruksi menjadi 1-3 kasus.
- Format angka tabel verifikasi dan parameter (tidak lagi menampilkan presisi mentah).
- PDF endpoint: status unlock dibaca dari environment, bukan reactive valve di luar reactive context.

### Security
- `.env`, PDF mentah, dan data eksternal tidak masuk repo.
- PDF hanya tersedia terenkripsi di repo; kunci di environment EasyPanel.

[Unreleased]: https://github.com/tooncoderstis/inar/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/tooncoderstis/inar/releases/tag/v0.1.0
