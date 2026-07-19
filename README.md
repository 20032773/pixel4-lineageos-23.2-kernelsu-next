# Pixel 4 (flame) LineageOS KernelSU Next

> ⚠️ **此專案是 Vibe Coding** (以 AI 驅動、純憑感覺與默契開發)


這個專案使用 GitHub Actions，為 **Google Pixel 4（代號 `flame`）** 編譯 LineageOS 23.2 的 Linux 4.14 核心，並整合 KernelSU Next。

僅支援 Pixel 4（`flame`），不支援 Pixel 4 XL（`coral`）或 Pixel 4a（`sunfish`）。

---

## 📱 支援規格與編譯內容

- **系統核心**：Linux 4.14 (LineageOS 23.2 Nightly)
- **Root 方案**：KernelSU Next (`legacy` 分支，採用手動掛鉤)
- **編譯器**：官方 AOSP Clang 與 Full LTO (連結時間最佳化)
- **模組安全校驗**：自動比對與維護核心模組 ABI (kABI)，確保 Wi-Fi 等原廠預建驅動能正常載入。
- **刷入封裝**：產生僅允許安裝至 `flame` 的 AnyKernel3 ZIP。

---

## ⚙️ 什麼是 ABI (應用程式二進位介面)？

**ABI (Application Binary Interface)** 定義了核心與核心模組（`.ko` 驅動程式，例如 Wi-Fi、音訊、相機等）在編譯後的二進位互動標準。這包含資料結構的大小、欄位排序（offsets）以及函數呼叫的參數格式。

### 為什麼 Pixel 4 編譯需要校驗 ABI？
Google Pixel 裝置採用「核心與驅動分離」的設計：
* **原廠預建驅動**：Wi-Fi 等許多重要硬體驅動是 Google/Qualcomm 提供的閉源二進位模組（放置在 `/vendor` 分區中）。
* **核心模組校驗 (Module Versioning)**：為了防止模組存取到錯誤的記憶體位置導致當機，核心在啟用 `CONFIG_MODVERSIONS=y` 時，會為每個導出符號計算一個 32 位元的 **CRC 雜湊值**（記錄在 `Module.symvers`）。
* **相容性問題**：當我們修改核心原始碼（例如啟用 KernelSU 修改了系統結構）時，這些符號的 CRC 會改變。一旦 CRC 不一致，系統在開機載入原廠 Wi-Fi 模組時就會報錯拒絕載入，導致 **Wi-Fi 損壞或功能失效**。
* **解決方案**：本專案使用 `preserve_module_kabi.py` 在 `genksyms` 分析時隱藏 KernelSU 相關變更，並透過 `verify_module_abi.py` 在編譯完成後強制校驗 CRC，確保與官方二進位完全相容。

### 為什麼編譯 Redmi K20 時不需要校驗 ABI？
在編譯 Redmi K20 等較舊的非 Pixel 裝置核心時，通常不會遇到或不需要檢查 ABI 問題，原因如下：
1. **靜態內建 (Statically Linked)**：許多舊裝置的 Wi-Fi 或硬體驅動直接編譯進核心映像檔（`Image` 或 `zImage-dtb`）中，而不是作為外部 `.ko` 模組載入。因此不存在執行時期載入外部模組的 ABI 校驗問題。
2. **同步編譯 (Source-Built Modules)**：在 Redmi K20 的客製化 ROM（如 LineageOS）編譯流程中，如果驅動是模組，它們也是在 ROM 編譯時從原始碼與核心「同步編譯」出來的。刷機包會同時更新核心與相匹配的模組，所以 ABI 永遠保持一致。
3. **未啟用 Module Versioning**：有些裝置核心可能關閉了 `CONFIG_MODVERSIONS`，允許核心強行載入 CRC 不一致的模組（雖然這在結構有實質改變時可能會引發 Kernel Panic 崩潰）。

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

