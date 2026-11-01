# Runbook — Deploy EasyPanel

Dua jalur:
1. **Image registry** (ideal; dipakai bila push berhasil).
2. **Git + Dockerfile** (dipakai saat ini karena push registry timeout; lihat ADR 0004).

PDF selalu disimpan terenkripsi (`private/paper/paper.enc`); kunci hanya di env `PDF_ENC_KEY`.

## Prasyarat
- Repo GitHub `tooncoderstis/inar` (public, tanpa PDF mentah).
- Service EasyPanel project `m`, nama `inar`.
- Env:
  ```
  APP_VERSION=0.1.0
  PORT=3838
  APP_BASE_URL=https://m-inar.hgteop.easypanel.host
  PDF_PASSWORD_SALT=<dari .env>
  PDF_PASSWORD_HASH=<dari .env>
  PDF_ENC_KEY=<dari .env>
  ```

## Jalur A — image registri
```sh
docker build --build-arg APP_VERSION=0.1.0 -t aasatech/inar:0.1.0 .
docker push aasatech/inar:0.1.0
```
Lalu `updateAppSourceImage` / `createAppService` dengan `source: { type: "image", image: "aasatech/inar:0.1.0" }`.

## Jalur B — Git + Dockerfile (aktif)
1. Push repo: `git push origin main`.
2. MCP `createAppService`:
   ```json
   {
     "projectName": "m",
     "serviceName": "inar",
     "source": {
       "type": "git",
       "repo": "https://github.com/tooncoderstis/inar.git",
       "ref": "main",
       "path": "/"
     },
     "build": { "type": "dockerfile", "file": "Dockerfile" },
     "env": "APP_VERSION=0.1.0\nPORT=3838\n...",
     "resources": { "cpuLimit": 0, "cpuReservation": 0, "memoryLimit": 0, "memoryReservation": 0 }
   }
   ```
3. `createDomain` — host `m-inar`, port `3838`, https.
4. `deployAppService`.
5. Tunggu build; cek `GET https://m-inar.hgteop.easypanel.host/` = 200.
6. Uji tab Paper: password salah ditolak, password benar menampilkan PDF 16 halaman.

## Setelah deploy
- Playwright 375/768/1440.
- Catat versi di STATUS/CHANGELOG, `npm run hub:report`.

## Rollback
- Git: deploy commit/tag sebelumnya lewat `deployAppService`.
- Image: `updateAppSourceImage` ke tag lama.

## Keamanan
- Jangan pernah menaruh `PDF_ENC_KEY`, `PDF_PASSWORD_HASH`, atau `.env` di repo.
- Jika kunci bocor: enkripsi ulang PDF dengan kunci baru, perbarui env, redeploy.
