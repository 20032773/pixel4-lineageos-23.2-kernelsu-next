# Pixel 4 (flame) LineageOS KernelSU Next

這個專案使用 GitHub Actions，為 **Google Pixel 4（代號 `flame`）** 編譯
LineageOS 23.2 的 Linux 4.14 核心，並整合 KernelSU Next。

僅支援 Pixel 4（`flame`），不支援 Pixel 4 XL（`coral`）或 Pixel 4a
（`sunfish`）。

## 編譯內容

- 從 LineageOS 官方 API 取得最新的 Pixel 4 23.2 nightly
- 使用該版本官方 `boot.img` 對應的核心原始碼與設定
- 整合 KernelSU Next `legacy` 分支
- 使用官方 AOSP Clang 與 Full LTO 編譯
- 比對模組 ABI，避免 Wi-Fi 等原廠模組因 ABI 不符而無法載入
- 產生僅允許安裝至 `flame` 的 AnyKernel3 ZIP

## 使用 GitHub Actions 編譯

1. 開啟 **Actions**。
2. 選擇 **Build Pixel 4 Kernel**。
3. 點選 **Run workflow**。
4. 一般情況保留預設值：
   - `lineage_build`: `latest`
   - `ksun_ref`: `legacy`

工作流程也會每週自動檢查並編譯最新版本。成功後可在該次執行的
Artifacts 下載檔案。

## 輸出檔案

- Pixel 4 可刷入的 AnyKernel3 ZIP
- `Image.lz4`
- `kernel.config`
- `module-abi-report.txt`
- `build-info.txt`
- `SHA256SUMS`

## 注意

- 刷入前請先備份目前的 `boot.img`。
- LineageOS 更新後，應使用與該 ROM 版本相符的新核心。
- 建議先使用 `fastboot boot` 測試；確認開機、Wi-Fi 與基本功能正常後再刷入。
