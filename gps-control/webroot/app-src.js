import { exec, toast } from "kernelsu";

const controller = "/data/adb/modules/byya_gps_control/controller.sh";
const names = { normal: "正常定位", gnss_block: "飛行穩定", approximate: "弱化定位", app_block: "封鎖指定 App", all_off: "全域關閉" };
const statusEl = document.querySelector("#status");
const detailsEl = document.querySelector("#details");
const packageEl = document.querySelector("#package");
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
  statusEl.textContent = names[state.mode] || state.mode;
  detailsEl.textContent = `Location: ${state.location_enabled} · GNSS: ${state.gnss_services || "未偵測"}`;
  packageEl.value = state.target || packageEl.value;
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
document.querySelector("#save").addEventListener("click", async () => {
  const packageName = packageEl.value.trim();
  if (!/^[A-Za-z0-9._]+$/.test(packageName)) return toast("套件名稱格式不正確");
  const result = await exec(`sh ${controller} target ${packageName}`);
  if (result.errno !== 0) return toast(result.stderr || "儲存失敗");
  toast("指定 App 已儲存"); await refresh();
});

refresh().catch(error => toast(String(error.message || error)));
