# Simulasi Upgrade Istio 1.17.5 → 1.18.7 (v2 — Clean GitOps dari Awal)

Versi ini beda dari simulasi pertama: **semua komponen (base, istiod, gateway)
langsung jadi Application ArgoCD sejak awal**, tidak ada `istioctl install`
sama sekali. Ini menghindari masalah "ownership conflict" yang kita temui
di simulasi pertama (ketika gateway sudah ter-install duluan lewat istioctl,
lalu dicoba diadopsi ArgoCD).

Ini juga lebih representatif untuk memvalidasi **mekanisme MR #1 / MR #2**
di SOP kamu, karena sejak awal gateway memang dikelola lewat Helm chart
terpisah — persis seperti central-manifest kamu.

## Urutan Eksekusi

```bash
./scripts/01-create-cluster.sh
./scripts/02-install-argocd.sh
./scripts/03-bootstrap-base-istiod.sh     # setara MR #1
./scripts/04-bootstrap-gateway.sh          # setara MR #2
./scripts/05-fake-external-ip.sh           # lihat catatan IP di bawah
./scripts/06-deploy-sample-apps.sh
./scripts/07-verify.sh
```

## Soal IP Publik (Penting)

`spec.loadBalancerIP` di values gateway (`manifests/argocd/istio-gateway-app.yaml`)
sudah diisi contoh `34.101.252.126` (sama seperti staging kamu) — tapi field
ini **cuma permintaan**, bukan jaminan. Di kind (tidak ada cloud provider),
Service akan tetap `<pending>` di kolom EXTERNAL-IP walau field itu diisi.

Untuk membuat Service **kelihatan** dapat IP (tanpa perlu IP itu valid/reachable,
dan tanpa perlu install MetalLB), jalankan:
```bash
./scripts/05-fake-external-ip.sh 34.101.252.126
```
Ini nge-patch `status` Service secara manual — murni kosmetik, cukup untuk
memverifikasi **apakah IP tetap konsisten sebelum dan sesudah upgrade**,
yang memang jadi concern utama kamu soal gateway.

Catatan: patch ini akan hilang lagi kalau Service di-recreate (misal kalau
`releaseName` berubah). Jalankan ulang scriptnya kapan saja untuk verifikasi.

Kalau suatu saat kamu mau simulasi yang lebih "real" (IP benar-benar
di-assign oleh sebuah controller, bukan di-patch manual), pakai MetalLB —
lihat `manifests/metallb/` di paket v1 sebelumnya untuk referensi setup-nya.

## Titik Simulasi Utama — Upgrade ke 1.18.7

1. Edit `manifests/argocd/istio-base-app.yaml` dan `istiod-app.yaml`:
   ubah `targetRevision: 1.17.5` → `1.18.7`, apply, tunggu sehat.
2. **Rollout restart semua workload biasa** (bukan gateway dulu):
   ```bash
   kubectl rollout restart deployment/hris-sim
   kubectl rollout restart deployment/hris-mq-sim
   kubectl rollout restart statefulset/nsq-nsqlookupd-sim
   ```
3. Verifikasi `istioctl version` — data plane harus ikut naik ke 1.18.7.
4. **Baru** edit `manifests/argocd/istio-gateway-app.yaml`:
   ubah `targetRevision: 1.17.5` → `1.18.7`, apply.
5. Rollout restart gateway:
   ```bash
   kubectl rollout restart deployment/istio-ingressgateway
   ```
6. Cek image gateway sudah berubah (kali ini seharusnya BERHASIL, karena
   gateway sudah jadi Helm release yang sah sejak awal):
   ```bash
   kubectl get deployment istio-ingressgateway -n istio-system \
     -o jsonpath='{.spec.template.spec.containers[0].image}'
   ```
7. Cek `EXTERNAL-IP` Service — kalau sempat balik `<pending>` (karena
   Service ter-recreate saat chart bump), jalankan lagi
   `05-fake-external-ip.sh` dengan IP yang **sama persis** seperti
   sebelumnya, untuk konfirmasi "IP tetap konsisten" itu murni soal
   kebijakan (field values), bukan soal mekanisme otomatis apapun.

## Cleanup

```bash
kind delete cluster --name istio-upgrade-sim
```
