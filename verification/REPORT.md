# Laporan verifikasi

Digenerate: 2026-11-01T23:11:47+0700

Paper: Fernandez-Fontelo A., Cabana A., Puig P., Morina D. - Statistics in Medicine 35(26):4875-4890 (2016)

| Contoh | Metrik | Paper | Rekonstruksi | Selisih | Status | Catatan |
|---|---|---|---|---|---|---|
| HPV | Jumlah observasi |     260 |     260 | 0 | **PASS** |  |
| HPV | Rata-rata |    1.27 | 1.26923 | -0.000769231 | **PASS** | Paper membulatkan ke 2 desimal. |
| HPV | Varians |     1.6 | 1.60291 | 0.0029106 | **PASS** |  |
| HPV | Indeks dispersi |    1.26 |  1.2629 | 0.00289926 | **PASS** |  |
| HPV | ACF(1) observasi |   0.133 | 0.133789 | 0.000788715 | **PASS** |  |
| HPV | Campuran: lambda1/(1-alpha) |   2.765 | 2.76584 | 0.000844886 | **PASS_TOLERANCE** | EM 2-Poisson (setara poisregmixEM), komponen besar. |
| HPV | Campuran: q*lambda1/(1-alpha) |   1.042 | 1.04257 | 0.000574947 | **PASS_TOLERANCE** |  |
| HPV | Campuran: omega |   0.868 | 0.868473 | 0.000473408 | **PASS_TOLERANCE** |  |
| HPV | Campuran: q |   0.377 | 0.376946 | -0.0000537179 | **PASS_TOLERANCE** |  |
| HPV | Naive: alpha1 |    0.37 | 0.369465 | -0.00053535 | **PASS_TOLERANCE** |  |
| HPV | Naive: lambda1 |   1.744 | 1.74396 | -0.0000370276 | **PASS_TOLERANCE** |  |
| HPV | Naive: alpha2 |   0.504 | 0.504275 | 0.000274642 | **PASS_TOLERANCE** |  |
| HPV | Naive: lambda2 |   1.372 |  1.3711 | -0.000900555 | **PASS_TOLERANCE** |  |
| HPV | AIC Poisson | 787.075 | 787.075 | -0.000428825 | **PASS_TOLERANCE** |  |
| HPV | AIC campuran 2-Poisson | 783.843 | 783.843 | -0.000342325 | **PASS_TOLERANCE** |  |
| HPV | MLE alpha |   0.517 | 0.516653 | -0.000347375 | **PASS** | nlm mereproduksi nilai paper pada 3 desimal. |
| HPV | MLE lambda |   1.623 | 1.62317 | 0.000166152 | **PASS** |  |
| HPV | MLE omega |   0.922 | 0.922046 | 0.0000459548 | **PASS** |  |
| HPV | MLE q |   0.326 | 0.325623 | -0.000377391 | **PASS** |  |
| HPV | SE alpha |   0.227 | 0.227244 | 0.00024417 | **PASS** |  |
| HPV | SE lambda |   0.616 | 0.616366 | 0.000365725 | **PASS** |  |
| HPV | SE omega |   0.073 | 0.0731598 | 0.000159806 | **PASS** |  |
| HPV | SE q |   0.085 | 0.0852721 | 0.000272064 | **PASS** |  |
| HPV | Cakupan tercatat (%) |      38 | 37.7952 | -0.204771 | **PASS** |  |
| Botulism | Jumlah observasi |      44 |      44 | 0 | **PASS** |  |
| Botulism | Rata-rata |       9 | 8.84091 | -0.159091 | **PASS_TOLERANCE** | Counts diturunkan dari rate x populasi. |
| Botulism | Varians |    44.7 | 44.9741 | 0.274101 | **PASS_TOLERANCE** |  |
| Botulism | Median |       7 |     7.5 |     0.5 | **PASS_TOLERANCE** |  |
| Botulism | Minimum | 0 | 0 | 0 | **PASS** |  |
| Botulism | Maksimum |      36 |      36 | 0 | **PASS** |  |
| Botulism | MLE alpha |   0.592 | 0.548817 | -0.0431826 | **ESTIMATED** | Data counts asli (bot.csv) tidak tersedia; angka ditampilkan sebagai perkiraan. |
| Botulism | MLE a |   2.475 | 2.76714 | 0.292136 | **ESTIMATED** |  |
| Botulism | MLE omega |   0.671 | 0.701054 | 0.0300539 | **ESTIMATED** |  |
| Botulism | MLE q |   0.317 | 0.325774 | 0.00877405 | **ESTIMATED** |  |
| Botulism | AIC |  296.72 | 301.775 | 5.05502 | **ESTIMATED** |  |
| Mesothelioma | Jumlah observasi |      46 |      46 | 0 | **N/A** | Ekstensi memakai seri HSE; bukan seri ONS paper. |
| Mesothelioma | Rata-rata (paper) |      14 | 1133.07 | 1119.07 | **N/A** | Seri HSE yang tersedia tidak sama dengan seri paper. |
| Mesothelioma | Varians (paper) |      34 |  610067 |  610033 | **N/A** |  |
| Mesothelioma | Rentang (paper) | 3-30 | 153-2560 | - | **N/A** |  |

## Ringkasan
- PASS: 17
- PASS_TOLERANCE: 13
- ESTIMATED: 5
- N/A: 4
- FAIL: 0

## Catatan optimizer HPV
MLE direkonstruksi dengan nlm dan fungsi likelihood yang sama seperti kode suplemen.
Setelah orientasi matriks transisi diperbaiki (kolom = state berikutnya), nlm mencapai
titik optimum yang sama dengan paper pada 3 desimal untuk alpha, lambda, omega, q, dan SE.
