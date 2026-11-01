# INAR Under-reporting Lab

**Live**: https://m-inar.hgteop.easypanel.host

Web laboratorium untuk memahami **under-reporting** pada data hitungan kesehatan masyarakat dengan model **INAR(1)-hidden Markov chain**, berdasarkan:

> Fernández-Fontelo, A., Cabaña, A., Puig, P., & Moriña, D. (2016). *Under-reported data analysis with INAR-hidden Markov chains*. **Statistics in Medicine**, 35(26), 4875–4890. DOI: [10.1002/sim.7026](https://doi.org/10.1002/sim.7026)

## Apa isinya
- **Dashboard** contoh HPV (Girona 2010–2014) dan Botulism (Kanada 1970–2013), serta ekstensi mesothelioma (HSE 1968–2013).
- **Lab parameter**: ubah α, λ, ω, q dan lihat rekonstruksi deret tersembunyi.
- **Panduan metodologi** bilingual (ID/EN): INAR, thinning, emisi, forward algorithm, Viterbi, pseudo-residual.
- **Halaman verifikasi**: setiap angka paper vs hasil rekonstruksi, selisih, toleransi, status.
- **PDF penelitian** dapat dibaca inline setelah password.

## Menjalankan
```sh
Rscript scripts/run_analysis.R
Rscript -e "shiny::runApp('.', port=3838)"
```

## Struktur
```
app.R                  # UI & server Shiny
R/                     # engine + modul
scripts/run_analysis.R # pipeline + verifikasi
data/raw/              # data mentah (jangan diubah)
verification/          # laporan verifikasi
content/{id,en}/       # materi pembelajaran
private/paper/         # PDF (tidak di www/)
```

## Status verifikasi
| Contoh | Statistik | Naive | MLE |
|---|---|---|---|
| HPV | PASS | PASS | PASS |
| Botulism | PASS | — | ESTIMATED |
| Mesothelioma | N/A (ekstensi) | — | N/A |

Detail: [`verification/REPORT.md`](verification/REPORT.md).

## Lisensi & hak cipta
Kode proyek: MIT. Paper dan PDF tetap milik Wiley; disajikan untuk penggunaan terbatas, tidak diindeks, dan hanya setelah password.
