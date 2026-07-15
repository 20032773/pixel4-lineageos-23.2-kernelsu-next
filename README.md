# byya-pokemon-master for Pixel 4 (flame)

這個專案使用 GitHub Actions 建置 Google Pixel 4（代號 `flame`）的 LineageOS 23.2 Linux 4.14 核心，並整合 KernelSU Next `legacy` manual hooks。

> 僅支援小隻 Pixel 4（`flame`）。不支援 Pixel 4 XL（`coral`），也不支援 Pixel 4a（`sunfish`）。AnyKernel3 會在刷入前檢查裝置代號。

## 核心名稱

- 顯示名稱：`byya-pokemon-master`
- `/proc/version` build user：`byya-pokemon-master`
- `uname -r`：保留乾淨 LineageOS 原始碼產生的 SCM 版本，避免破壞 `wlan.ko` 等 vendor module 的 vermagic。
- 官方核心來源：`LineageOS/android_kernel_google_msm-4.14`
- 核心設定：`floral_defconfig`（Pixel 4 與 Pixel 4 XL 的官方共用平台設定）

## 建置

1. 開啟 GitHub 專案的 **Actions**。
2. 選擇 **Build Pixel 4 Kernel**。
3. 按 **Run workflow**。
4. 保留預設值：
   - `kernel_ref`: `lineage-23.2`
   - `ksun_ref`: `fd093e8b879063aeb0192a3959b0652101ded623`
5. 建置完成後下載 `byya-pokemon-master-flame-lineage-23.2-KernelSU-Next` artifact。

## 產物

- `byya-pokemon-master-flame-LineageOS-lineage-23.2-KernelSU-Next.zip`：僅限 `flame` 的 AnyKernel3 刷機包。
- `Image.lz4`：原始核心映像。
- `kernel.config`：實際建置設定。
- `build-info.txt`：LineageOS、KernelSU Next 與 AnyKernel3 的 commit 資訊。
- `SHA256SUMS`：所有產物的 SHA-256。

## 刷入前注意

- 僅適用於 Pixel 4 `flame` 的 LineageOS 23.2。
- 請先備份目前可正常開機的 `boot` 映像。
- Pixel 4 是 A/B 裝置；刷機包會處理目前使用中的 boot slot。
- ZIP 只替換核心，保留目前 ROM 的 ramdisk 與 DTB。
- 解鎖 bootloader、刷入自訂核心及取得 root 都有資料遺失或無法開機的風險。
