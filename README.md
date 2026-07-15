# byya-pokemon-master for Pixel 4 (flame)

這個專案使用 GitHub Actions 建置 Google Pixel 4（僅限 `flame`）的 LineageOS 23.2 Linux 4.14 核心，並整合 KernelSU Next legacy manual hooks。

> 不支援 Pixel 4 XL（`coral`）或 Pixel 4a（`sunfish`）。AnyKernel3 會檢查裝置代號，只允許 `flame`。

## ABI 安全建置

Pixel 4 的 Wi-Fi、音訊及 DSP 驅動是 ROM 內的外部 kernel modules。只讓 `uname -r` 相同並不足以保證相容；`CONFIG_MODVERSIONS` 還會檢查每個 exported symbol 的 CRC。

目前工作流程鎖定：

- LineageOS：`lineage-23.2-20260709-nightly-flame`
- 官方 boot SHA-256：`4cac9e822bd2dbb22ac92338448a470ce8ac42657f583b7a8198f5cb9613b4f0`
- 核心來源：`LineageOS/android_kernel_google_msm-4.14`
- 官方工具鏈：AOSP Clang 21，build `14054515`，based on `r563880c`
- 官方核心模式：Full LTO、Clang CFI、Shadow Call Stack

每次 Actions 都會：

1. 從 LineageOS 官方網站下載指定的 `boot.img` 並驗證 SHA-256。
2. 從官方核心抽出實際 `.config`。
3. 使用相同 AOSP Clang 編譯未修改的 ABI baseline。
4. 編譯 KernelSU Next 核心。
5. 比較兩份 `Module.symvers` 的全部既有 symbol CRC。
6. 只有 `missing_symbols=0` 且 `changed_crcs=0` 才會產生刷機 ZIP。

這個檢查用來避免 Wi-Fi HAL 找不到 `wlan0`、音訊模組載入失敗、開機 watchdog 等 ABI 不相容問題。

## 核心名稱

- ZIP／顯示名稱：`byya-pokemon-master`
- `/proc/version` build user：`byya-pokemon-master`
- `uname -r`：保留 LineageOS 官方 SCM 版本，避免破壞 module vermagic

## 執行 Actions

1. 到 GitHub 專案的 **Actions**。
2. 選擇 **Build Pixel 4 Kernel**。
3. 按 **Run workflow**。
4. 保持預設值：
   - `kernel_ref`: `9a2ea17c379a62b4044efee9de9a14143d9bbcfa`
   - `ksun_ref`: `fd093e8b879063aeb0192a3959b0652101ded623`

成功後下載 `byya-pokemon-master-flame-lineage-23.2-20260709-KernelSU-Next` artifact。

## 成品

- `byya-pokemon-master-flame-LineageOS-lineage-23.2-20260709-KernelSU-Next.zip`
- `Image.lz4`
- `kernel.config`
- `module-abi-report.txt`
- `build-info.txt`
- `SHA256SUMS`

## 刷入前

- 僅適用安裝 `lineage-23.2-20260709-nightly-flame` 的 Pixel 4。
- 先備份目前正常的 `boot.img`。
- 不要把此核心用於其他 nightly；不同 nightly 必須重新鎖定官方 boot 與 ABI。
- 建議先用 `fastboot boot` 暫時測試（若裝置／bootloader 狀態允許），確認 Wi-Fi、音訊、相機與重新開機正常後再永久刷入。
