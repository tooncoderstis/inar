# Provenance data

Digenerate: 2026-11-01 oleh `scripts/run_analysis.R`.

## HPV Girona
- Sumber mentah: `data/raw/hpv_catalonia_weekly.csv` (Generalitat de Catalunya; kolom `Girona`).
- Filter: tahun 2010-2014, minggu 53 dibuang, nilai kosong dibuang.
- Hasil: 260 observasi mingguan; nilai 0-6.

## Botulism Kanada
- Sumber mentah: `data/raw/botulisme.xlsx`, sheet `Data` (rate per 100.000, PHAC/CNDSS).
- Populasi: `data/reference/population_canada.csv` (World Bank SP.POP.TOTL).
- Counts diturunkan: `round(rate * population / 100000)`.
- Koreksi mengikuti skrip penulis: tahun 2010 di-set 2.
- Status: **derived** — bukan file `bot.csv` asli; MLE diberi status ESTIMATED.

## Mesothelioma
- Sumber mentah: `data/raw/meso01.xlsx`, sheet `MESO01`, baris `Great Britain / Total`.
- Populasi: `data/reference/population_uk.csv` (World Bank SP.POP.TOTL).
- Status: **ekstensi** (seri HSE 1968-2013). Bukan seri ONS yang dipakai paper.

## Populasi
- World Bank API `SP.POP.TOTL`, diakses 2026-11-01; URL tersimpan di CSV referensi.
