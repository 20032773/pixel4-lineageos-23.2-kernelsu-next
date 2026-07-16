import { exec, toast } from "kernelsu";

const controller = "/data/adb/modules/byya_gps_control/controller.sh";
const names = { normal: "完整訊號", weaken: "弱化 A‑GPS 輔助", isolate: "已隔離真實 GNSS" };
const descriptions = { normal: "GNSS HAL 與輔助服務運作中", weaken: "真實衛星仍可用，輔助服務已暫停", isolate: "Android 定位開啟，真實衛星來源已停止" };
const buttons = [...document.querySelectorAll("[data-mode]")];

function parse(text) {
  return Object.fromEntries(text.trim().split("\n").filter(Boolean).map(line => {
    const i = line.indexOf("="); return [line.slice(0, i), line.slice(i + 1)];
  }));
}

async function refresh() {
  const result = await exec(`sh ${controller} status`);
  if (result.errno !== 0) throw new Error(result.stderr || "狀態讀取失敗");
  const state = parse(result.stdout);
  document.querySelector("#status").textContent = names[state.mode] || state.mode;
  document.querySelector("#details").textContent = descriptions[state.mode] || "";
  document.querySelector("#orb").classList.toggle("isolate", state.mode === "isolate");
  const locationOn = state.location_enabled === "true";
  document.querySelector("#location-dot").classList.toggle("on", locationOn);
  document.querySelector("#location-state").textContent = locationOn ? "保持開啟" : "目前關閉，請先在系統設定開啟";
  buttons.forEach(button => button.classList.toggle("selected", button.dataset.mode === state.mode));
}

async function setMode(mode) {
  buttons.forEach(button => button.disabled = true);
  try {
    const result = await exec(`sh ${controller} set ${mode}`);
    if (result.errno !== 0) throw new Error(result.stderr || result.stdout || "切換失敗");
    toast(`${names[mode]}已生效`);
    await refresh();
  } catch (error) { toast(String(error.message || error)); }
  finally { buttons.forEach(button => button.disabled = false); }
}

buttons.forEach(button => button.addEventListener("click", () => setMode(button.dataset.mode)));
refresh().catch(error => toast(String(error.message || error)));
