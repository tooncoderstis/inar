# PRD: INAR Under-reporting Lab

**Status**: dikembangkan — rekonstruksi, verifikasi, dan web sedang dibangun.
**Versi dokumen**: 0.1
**Terkait**: `STATUS.md`, `CHANGELOG.md`, `docs/adr/`

> Dokumen ini menjawab **apa & kenapa**. Progres ada di `STATUS.md`, riwayat rilis di `CHANGELOG.md`, keputusan teknis di `docs/adr/`.

## 1. Ringkasan Produk

Banyak data kesehatan masyarakat **under-reported**: kasus yang tercatat lebih sedikit daripada kasus sebenarnya. Fernández-Fontelo, Cabaña, Puig & Moriña (2016, *Statistics in Medicine* 35:4875–4890) mengusulkan model **INAR(1)-hidden Markov chain** untuk mendeteksi under-reporting, mengestimasi frekuensi (ω) dan intensitasnya (q), serta merekonstruksi deret tersembunyi dengan algoritma Viterbi.

Proyek ini merekonstruksi penelitian tersebut dari kode R suplemen dan data publik, memverifikasi setiap angka terhadap paper, lalu menyajikannya sebagai **web laboratorium** berbahasa Indonesia/Inggris: dashboard untuk pengguna data dan stakeholder, catatan metodologi langkah demi langkah, lab parameter interaktif, dan akses PDF penelitian yang dilindungi password.

## 2. Prinsip Desain Utama

1. **Jujur secara statistik** — setiap angka paper ditampilkan berdampingan dengan hasil rekonstruksi, selisih, dan status verifikasi. Perbedaan optimizer tidak disembunyikan.
2. **Dapat direproduksi** — pipeline R deterministik, data mentah disimpan, provenance dicatat, CI menjalankan verifikasi.
3. **Ramah non-statistikawan** — bahasa awam dulu, rumus belakangan; setiap grafik punya interpretasi.
4. **Satu bahasa (R)** — mesin analisis dan aplikasi memakai kode R yang sama, mengurangi risiko implementasi ganda.
5. **Aman secara default** — PDF tidak pernah berada di `www/`, hanya disajikan inline setelah password; kredensial tidak masuk repo.

## 3. Peran Pengguna (Roles)

| Role | Deskripsi | Akses |
|---|---|---|
| Pengguna data / analis | Eksplorasi hasil, unduh data & parameter, memakai lab | Publik |
| Stakeholder / pembuat kebijakan | Membaca ringkasan under-reporting dan implikasinya | Publik |
| Pembelajar | Mengikuti panduan metodologi, mencoba lab parameter | Publik |
| Pemilik dokumen | Membaca PDF penelitian | Publik + password |

## 4. Fase / Modul Pengembangan

```
FASE 1 -> Fondasi & dokumentasi
FASE 2 -> Data & provenance
FASE 3 -> Pipeline R + verifikasi
FASE 4 -> Web (dashboard, metodologi, lab)
FASE 5 -> PDF gate + viewer inline
FASE 6 -> Kualitas (test, CI, formatter)
FASE 7 -> Deploy EasyPanel
FASE 8 -> Hub portofolio & rilis
```

### 4.1 Ringkasan & dashboard per contoh
- Tab Ringkasan menjelaskan masalah under-reporting, model, dan temuan utama.
- Tab HPV dan Botulism menampilkan deret observasi vs rekonstruksi, ACF/PACF, pseudo-residual, tabel parameter, dan interpretasi coverage.
- **Acceptance criteria**: angka di UI identik dengan `verification/report.json`; grafik interaktif; tersedia unduh CSV.

### 4.2 Metodologi & panduan pembelajaran
- Penjelasan INAR(1), thinning binomial, emisi under-reporting, forward algorithm, Viterbi, mid-pseudo-residual.
- Potongan kode R asli dengan anotasi; glosarium; latihan mandiri.
- **Acceptance criteria**: setiap langkah punya penjelasan ID dan EN; rumus dirender (MathJax); tidak ada klaim yang tidak ada di paper/kode.

### 4.3 Lab parameter
- Slider α, λ, ω, q dan pilihan dataset; rekonstruksi dihitung ulang di server R.
- Menampilkan observed vs hidden, estimasi coverage, dan peringatan bila parameter di batas.
- **Acceptance criteria**: reaktif < 3 detik untuk HPV; hasil sama dengan engine verifikasi pada parameter identik.

### 4.4 Verifikasi
- Tabel paper vs reproduced dengan toleransi dan status PASS/WARN/FAIL/N/A.
- Halaman menjelaskan mengapa HPV MLE berbeda sedikit dan mengapa Botulism masih perkiraan.
- **Acceptance criteria**: status dihasilkan otomatis dari `scripts/run_analysis.R`, bukan ditulis manual.

### 4.5 PDF penelitian
- Password `12334567` (hash + salt di env), lalu PDF dirender inline dengan PDF.js.
- Tidak ada tombol unduh; `Content-Disposition: inline`; `no-store`; `noindex`.
- **Acceptance criteria**: tanpa password tidak ada byte PDF yang terkirim; viewer berfungsi di desktop/mobile.

### 4.6 Mesothelioma (ekstensi)
- Menampilkan data HSE 1968–2013 sebagai **ekstensi berlabel**, bukan reproduksi paper.
- **Non-goals**: mengklaim angka Table II paper; seri asli ONS tidak tersedia.

## 5. Model Data

Tidak ada database. Artefak statis + data mentah:

```
data/raw/            # HPV.csv, botulisme.xlsx, meso0*.xlsx
data/processed/      # seri siap analisis (CSV) + kolom provenance
data/reference/      # populasi Kanada/UK + sumber
verification/        # report.json, REPORT.md, golden/*.json
public/data/         # artefak JSON/CSV yang dibaca aplikasi (via R, bukan www)
```

Entitas utama: `series` (id, contoh, tahun/minggu, nilai, sumber), `model_fit` (α, λ/a, ω, q, SE, nll, AIC), `verification` (metrik, paper, reproduced, diff, toleransi, status).

## 6. Non-Functional Requirements

- **Performa**: halaman < 2 s; lab < 3 s (HPV); startup < 20 s.
- **Keamanan**: password di-hash; rate-limit; tidak ada path statis PDF; dependency minimal.
- **Reliabilitas**: pipeline deterministik; CI memblokir regresi verifikasi.
- **Aksesibilitas**: kontras WCAG AA, navigasi keyboard, grafik punya tabel alternatif.
- **Responsif**: 375/768/1024/1440 px.
- **Reproducibility**: versi R dan paket dipin di Dockerfile.

## 7. KPI & Metrik Keberhasilan

| Area | Metrik | Target |
|---|---|---|
| Verifikasi | Metrik PASS | 100% dari yang dapat diverifikasi |
| Verifikasi | MLE HPV | Sama pada 3 desimal |
| Kualitas | Test lulus | 100% |
| Akses | Halaman utama 200 | Ya |
| Pembelajaran | Tab metodologi lengkap ID/EN | Ya |

## 8. Kepatuhan & Keamanan

- Data adalah agregat publik (Generalitat de Catalunya, PHAC, HSE); tidak ada data pribadi.
- PDF paper © Wiley; disimpan di image privat dan hanya disajikan setelah password untuk penggunaan terbatas. Tidak diindeks mesin pencari.
- Password `12334567` sudah terekspos di chat; rotasi dianjurkan. Hanya hash yang disimpan. PDF di repo disimpan terenkripsi (AES-256) dan kunci hanya di env.
- Tidak ada kredensial di repo; `.env` di-ignore.

## 9. Risiko & Mitigasi

| # | Risiko | Dampak | Mitigasi |
|---|---|---|---|
| 1 | `bot.csv`/`popC.csv` asli tidak tersedia | MLE Botulism tidak eksak | counts turunan + status WARN; cari suplemen publisher |
| 2 | Registry push gagal (timeout) | Deploy tertunda | fallback build dari Git + PDF terenkripsi (ADR 0004) |
| 3 | Data mesothelioma berbeda dari paper | Klaim berlebihan | label ekstensi, tanpa angka Table II |
| 4 | Password lemah/terekspos | Akses tidak sah | hash, rate-limit, rotasi |
| 5 | PDF diekstrak dari image | Pelanggaran hak cipta | registry privat + noindex |
| 6 | Optimizer R lambat saat startup | Startup lambat | hasil precomputed; lab hanya untuk parameter cepat |

## 10. Out of Scope

- Upload data pengguna dan analisis otomatis.
- Autentikasi multi-user / akun.
- Database, CMS, atau API publik.
- Klaim kausal atau rekomendasi kebijakan di luar interpretasi model.

## 11. Ringkasan Keputusan

| # | Pertanyaan | Keputusan |
|---|---|---|
| 1 | Stack | R Shiny (bslib + plotly + DT) |
| 2 | Interaktivitas | Dashboard + lab parameter, tanpa upload |
| 3 | Contoh | HPV + Botulism; mesothelioma ekstensi |
| 4 | PDF | Inline PDF.js, password, hash + enkripsi di env |
| 5 | Deploy | EasyPanel `m/inar`, image privat, port 3838 |
| 6 | Bahasa | Bilingual ID/EN |
