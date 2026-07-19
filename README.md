# Pixel 4 (flame) LineageOS KernelSU Next

> ⚠️ **此專案是 Vibe Coding** (以 AI 驅動、純憑感覺與默契開發)


這個專案使用 GitHub Actions，為 **Google Pixel 4（代號 `flame`）** 編譯 LineageOS 23.2 的 Linux 4.14 核心，並整合 KernelSU Next。

僅支援 Pixel 4（`flame`），不支援 Pixel 4 XL（`coral`）或 Pixel 4a（`sunfish`）。

---

## 📱 支援規格與編譯內容

- **系統核心**：Linux 4.14 (LineageOS 23.2 Nightly)
- **Root 方案**：KernelSU Next (使用 `legacy` 分支，動態對應版本號 `30000+` / 核心層級 Root)
- **編譯器**：官方 AOSP Clang 與 Full LTO (連結時間最佳化)
- **模組安全校驗**：自動比對與維護核心模組 ABI (kABI)，確保 Wi-Fi 等原廠預建驅動能正常載入。
- **刷入封裝**：產生僅允許安裝至 `flame` 的 AnyKernel3 ZIP。

---

## ⚡ 使用 GitHub Actions 編譯

1. 前往 GitHub 專案頁面的 **Actions** 頁籤。
2. 選擇 **Build Pixel 4 Kernel** 工作流程。
3. 點選 **Run workflow**。
4. 保留預設參數（若無特殊需求）：
   - `lineage_build`: `latest` (自動抓取最新 nightly)
   - `ksun_ref`: `legacy` (使用 KernelSU Next 舊版分支)

編譯成功後，可在該次 Workflows 的 **Artifacts** 下載編譯完成的核心 ZIP 刷機包。

---

## 📦 輸出檔案清單

- `Pixel4-flame-LineageOS-*.zip`：可刷入的 AnyKernel3 刷機包
- `Image.lz4`：壓縮的核心二進位檔案
- `kernel.config`：本次編譯使用的核心設定檔
- `module-abi-report.txt`：模組 ABI (CRC) 比對報告
- `build-info.txt`：編譯環境與版本詳細資訊
- `SHA256SUMS`：檔案校驗碼

---

## ⚠️ 注意事項與風險警告

在刷入此核心前，請務必詳細閱讀以下注意事項：

1. **備份引導分區 (Boot)**：修改核心存在風險。刷入前請**務必備份您目前的 `boot.img`**。若發生 Bootloop (無限重啟)，可透過 Fastboot 刷回原廠鏡像備份。
2. **LineageOS 版本適配**：本核心依賴特定 LineageOS 版本的 ABI。當您的系統 OTA 更新後，**請重新執行 Actions 編譯對應新版本的核心**，切勿跨大版本或長期混用舊核心。
3. **安全測試步驟**：
   - 建議下載 AnyKernel3 ZIP 後，先解壓取得 `Image.lz4`。
   - 使用 Fastboot 指令進行臨時測試：
     ```bash
     fastboot boot Image.lz4
     ```
   - 確認手機可以順利開機、**Wi-Fi 正常啟動**、核心級 KernelSU 運作無誤後，再進入 Recovery 刷入 AnyKernel3 ZIP 寫入分區。
4. **不支援其他裝置**：請勿將此包刷入 Pixel 4 XL (`coral`) 或 Pixel 4a 等其他機種，這會導致開機失敗或裝置損壞。
5. **免責聲明**：本專案基於個人樂趣與 Vibe Coding 開發，不提供任何形式的保固。若因使用本核心導致硬體損壞、資料遺失或鬧鐘沒響，作者概不負責。
