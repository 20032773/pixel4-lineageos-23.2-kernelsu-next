# byya-pokemon-master for Pixel 4 (flame)

這個專案使用 GitHub Actions 建置 Google Pixel 4（僅限 `flame`）的 LineageOS 23.2 Linux 4.14 核心，並整合 KernelSU Next legacy manual hooks。

> 不支援 Pixel 4 XL（`coral`）或 Pixel 4a（`sunfish`）。AnyKernel3 會檢查裝置代號，只允許 `flame`。

## ABI 安全建置

Pixel 4 的 Wi-Fi、音訊及 DSP 驅動是 ROM 內的外部 kernel modules。只讓 `uname -r` 相同並不足以保證相容；`CONFIG_MODVERSIONS` 還會檢查每個 exported symbol 的 CRC。

目前工作流程會自動解析：

- LineageOS 官方 API 中最新的 `23.2` flame nightly
- 該建置的官方 `boot.img` URL 與 SHA-256
- 官方核心版本字串對應的精確 kernel commit
- KernelSU Next `legacy` 分支最新 commit
- 核心來源：`LineageOS/android_kernel_google_msm-4.14`
- 官方工具鏈：AOSP Clang 21，build `14054515`，based on `r563880c`
- 官方核心模式：Full LTO、Clang CFI、Shadow Call Stack

每次 Actions 都會：

1. 從 LineageOS 官方 API 選擇最新 flame 建置。
2. 下載該建置的 `boot.img` 並驗證官方 SHA-256。
3. 從官方映像解析精確 kernel commit，並抽出實際 `.config`。
4. 使用相同 AOSP Clang 編譯未修改的 ABI baseline。
5. 抓取 KernelSU Next legacy 最新 commit 並編譯自訂核心。
6. 比較兩份 `Module.symvers` 的全部既有 symbol CRC。
7. 只有 `missing_symbols=0` 且 `changed_crcs=0` 才會產生刷機 ZIP。

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
   - `lineage_build`: `latest`
   - `ksun_ref`: `legacy`

工作流程也會在每週五 02:30 UTC（台灣時間 10:30）自動執行。若要重現舊版，可把 `lineage_build` 改成 `YYYY-MM-DD` 或完整 ROM ZIP 檔名，並把 `ksun_ref` 改成精確 commit。

成功後下載名稱含實際 LineageOS 日期的 artifact，例如 `byya-pokemon-master-flame-lineage-23.2-20260709-KernelSU-Next`。

## 成品

- `byya-pokemon-master-flame-LineageOS-lineage-23.2-20260709-KernelSU-Next.zip`
- `Image.lz4`
- `kernel.config`
- `module-abi-report.txt`
- `build-info.txt`
- `SHA256SUMS`

## 刷入前

- 每個成品僅適用 artifact／`build-info.txt` 所列的同一個 LineageOS flame nightly。
- 先備份目前正常的 `boot.img`。
- 不要把某次成品用於其他 nightly；ROM 更新後請使用對應日期的新成品。
- 建議先用 `fastboot boot` 暫時測試（若裝置／bootloader 狀態允許），確認 Wi-Fi、音訊、相機與重新開機正常後再永久刷入。
