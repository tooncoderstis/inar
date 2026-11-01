# Panduan metodologi

Halaman ini menjelaskan ide di balik model **INAR(1)-hidden Markov chain** untuk data under-reported, langkah demi langkah. Tidak perlu latar belakang statistik lanjutan; rumus diperkenalkan setelah intuisi.

## 1. Mengapa under-reporting penting?

Misalkan setiap minggu ada $X_n$ kasus HPV yang benar-benar terjadi, tetapi registry hanya mencatat $Y_n \le X_n$. Jika kita memodelkan $Y_n$ seolah-olah itu $X_n$, kita akan:

- meremehkan rata-rata dan beban penyakit;
- salah menilai hubungan dengan faktor risiko;
- membuat proyeksi kebutuhan layanan yang terlalu rendah.

Under-reporting bersifat **permanen** dalam model ini: kasus yang tidak tercatat tidak "muncul" kemudian. Ini berbeda dari *delayed reporting*, di mana data menjadi lengkap seiring waktu.

## 2. Data hitungan dan INAR(1)

Data kita adalah hitungan (0, 1, 2, ...), bukan angka kontinu. Model ARMA biasa tidak cocok. Model **INAR(1)** (integer autoregressive orde 1) meniru persamaan AR(1):

$$
X_n = \alpha \circ X_{n-1} + W_n, \qquad W_n \sim \text{Poisson}(\lambda).
$$

Tanda $\circ$ adalah **thinning**: setiap unit dari $X_{n-1}$ "bertahan" secara independen dengan peluang $\alpha$. Jadi $\alpha \circ X_{n-1}$ adalah jumlah keberhasilan dari $X_{n-1}$ percobaan Bernoulli. Hasilnya selalu bilangan bulat tak negatif.

- $\alpha$ tinggi: deret punya memori kuat (kasus minggu ini terkait minggu lalu).
- $\lambda$ adalah rata-rata kasus baru yang tidak terkait masa lalu.

Rata-rata marginal proses tersembunyi adalah

$$
\mu_X = \frac{\lambda}{1-\alpha}.
$$

## 3. Bagaimana under-reporting dimodelkan?

Setiap waktu, dengan peluang $\omega$ (frekuensi under-reporting), nilai yang tercatat adalah hasil thinning lagi:

$$
Y_n =
\begin{cases}
X_n, & \text{dengan peluang } 1-\omega,\\
q \circ X_n, & \text{dengan peluang } \omega.
\end{cases}
$$

Parameter $q \in (0,1)$ adalah **intensitas** under-reporting. Jika $q$ mendekati 1 atau $\omega$ mendekati 0, $Y_n \approx X_n$ dan under-reporting bukan masalah.

Peluang emisi (peluang melihat $j$ jika state tersembunyi $k$) adalah:

$$
P(Y_n=j \mid X_n=k)=
\begin{cases}
0, & k<j,\\
(1-\omega)+\omega q^k, & k=j,\\
\omega \binom{k}{j} q^j (1-q)^{k-j}, & k>j.
\end{cases}
$$

## 4. Identifikasi lewat ACF

Fungsi autokorelasi proses tercatat punya bentuk sederhana:

$$
\rho_Y(k) = c(\alpha,\lambda,\omega,q)\,\alpha^{|k|}.
$$

Karena itu $\log \rho_Y(k)$ linear terhadap $k$ dengan kemiringan $\log \alpha$. Intersep yang signifikan menandakan under-reporting. Pada HPV, regresi ini memberi intersep signifikan ($p = 0.002$), konsisten dengan adanya under-reporting.

## 5. Estimasi naive

Untuk deret stasioner, penulis mengusulkan langkah cepat:

1. Fit campuran dua Poisson; dapatkan $\hat\lambda_1, \hat\lambda_2, \hat\omega$.
2. Hitung $\hat q = \hat\lambda_{\text{kecil}}/\hat\lambda_{\text{besar}}$.
3. Gunakan ACF(1) dan ACF(2) untuk menaksir $\alpha_1, \lambda_1, \alpha_2, \lambda_2$.

Hasil HPV: $\hat\lambda_1/(1-\alpha)=2.765$, $\hat q\hat\lambda_1/(1-\alpha)=1.042$, $\hat\omega=0.868$, $\hat q=0.377$; lalu $\hat\alpha_1=0.370$, $\hat\lambda_1=1.744$, $\hat\alpha_2=0.504$, $\hat\lambda_2=1.372$.

## 6. Likelihood dan forward algorithm

Likelihood dari deret tersembunyi tak terhingga jumlahnya, jadi dihitung dengan **forward algorithm**:

$$
\alpha_k(X_k)=P(Y_1,\dots,Y_k,X_k)
= P(Y_k\mid X_k)\sum_{x_{k-1}} P(X_k\mid X_{k-1})\,\alpha_{k-1}(x_{k-1}).
$$

Transisi INAR(1) adalah

$$
P(X_n=x_n\mid X_{n-1}=x_{n-1})
= e^{-\lambda}\sum_{j=0}^{\min(x_n,x_{n-1})}
\binom{x_{n-1}}{j}\alpha^j(1-\alpha)^{x_{n-1}-j}
\frac{\lambda^{x_n-j}}{(x_n-j)!}.
$$

State dibatasi sampai $T$ (misalnya $2\max Y_i$ atau nilai yang stabil) agar komputasi mungkin. Likelihood total adalah $\sum_{x_n}\alpha_n(x_n)$, yang dimaksimalkan dengan `nlm`.

## 7. Rekonstruksi dengan Viterbi

Setelah parameter diestimasi, kita ingin deret tersembunyi yang paling mungkin:

$$
X^* = \arg\max_X \hat P(X_{1:n}\mid Y_{1:n}).
$$

Algoritma Viterbi melakukan ini dengan pemrograman dinamis. Kode paper memakai versi sederhana: pada setiap waktu, ambil state dengan $\alpha$ terbesar. Di aplikasi ini, garis "tersembunyi" adalah hasil cara paper tersebut.

## 8. Pemeriksaan model: mid-pseudo-residual

Residual didefinisikan dari peluang bersyarat satu observasi diberikan sisanya:

$$
u_n^- = \hat P(Y_n < y_n \mid Y_{-n}), \qquad
u_n^+ = \hat P(Y_n \le y_n \mid Y_{-n}),
$$

lalu

$$
z_n^{mid} = \Phi^{-1}\!\left(\frac{u_n^-+u_n^+}{2}\right).
$$

Jika model benar, residual menyerupai white noise. Untuk HPV, ACF/PACF residual berada di dalam pita, mendukung kecocokan model.

## 9. Membaca parameter

- $\omega$: seberapa sering kasus tercatat dalam bentuk ter-thinning.
- $q$: seberapa besar bagian yang hilang saat under-reporting terjadi.
- $\alpha$: persistensi deret tersembunyi.
- $\lambda$: intensitas inovasi; dengan kovariat, $\lambda_n = aN_n$ (populasi).
- Cakupan $\approx \bar Y / \mu_X$.

Pada HPV: $\hat\mu_X = 1.623/(1-0.517) \approx 3.36$ kasus/minggu, sedangkan rata-rata tercatat 1.27. Cakupan sekitar 38%.

## 10. Contoh kode R

Fungsi emisi:

```r
emission <- function(yx, omega, q) {
  if (yx[1] < yx[2]) return(0)
  if (yx[1] == yx[2]) return((1 - omega) + omega * q^yx[1])
  omega * dbinom(yx[2], yx[1], q)
}
```

Satu langkah forward:

```r
for (j in 2:length(y)) {
  for (i in 0:th) {
    ppa[i + 1, j] <- log(sum(
      exp(log(emit[i + 1, y[j] + 1]) +
          log(trans[, i + 1]) +
          ppa[, j - 1])
    ))
  }
}
```

## 11. Latihan

1. Pada tab Lab, naikkan $\omega$ dari 0.5 ke 0.95. Apa yang terjadi pada cakupan dan bentuk deret tersembunyi?
2. Turunkan $q$ menjadi 0.1. Mengapa puncak tersembunyi membesar?
3. Bandingkan ACF residual HPV dengan pita. Apakah ada lag yang keluar?
4. Untuk Botulism, ubah $a$. Bagaimana pengaruh kovariat populasi terhadap $\lambda_n$?
5. Jelaskan mengapa model tidak boleh dipakai untuk mengklaim angka pasti tanpa data mentah yang lengkap.

## 12. Batas dan etika

Model ini membantu **memperkirakan** besaran under-reporting, bukan membuktikan penyebabnya. Angka estimasi harus disertai ketidakpastian dan catatan data. Untuk kebijakan, gunakan hasil sebagai indikasi perlunya perbaikan registry, bukan sebagai vonis.
