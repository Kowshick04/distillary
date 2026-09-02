# Distillery Plant Telemetry & AI Batch Classification System

## System Architecture Overview

### 1. Plant & Operator Role Mapping (1-to-1 Standard)
| Index | Plant Name | Code | Operator ID | Password | Retained MQTT Telemetry Topic | Default Synthetic File |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | **Haliyal** | `F01` | `operator01` | `factory1` | `distillery/factory/F01/telemetry` | `Haliyal_170KLPD_Synthetic_Data.xlsx` |
| **1** | **Sankili** | `F02` | `operator02` | `factory2` | `distillery/factory/F02/telemetry` | `Sankili_168KLPD_Synthetic_Data.xlsx` |
| **2** | **Nellikuppam** | `F03` | `operator03` | `factory3` | `distillery/factory/F03/telemetry` | `Nellikuppam_120KLPD_Synthetic_Data.xlsx` |
| **3** | **Sivagangai** | `F04` | `operator04` | `factory4` | `distillery/factory/F04/telemetry` | `Sivagangai_64KLPD_Synthetic_Data.xlsx` |
| **4** | **Bagalkot** | `F05` | `operator05` | `factory5` | `distillery/factory/F05/telemetry` | `Bagalkot_60KLPD_Synthetic_Data.xlsx` |

---

### 2. Multi-Fermenter Pipeline (Maximum 2 Active Rule)
* **File Ingestion:** Automated scanner watches `/sdcard/Download/Distillery/` and `/sdcard/Download/`.
* **Multi-Row Parsing:** `_readRecentFermenterRowsFromXlsx(bytes, maxFermenters: 2)` extracts the latest parameters for **up to 2 distinct fermenters** present in the Excel spreadsheet.
* **AI Inference:** The pre-trained Random Forest model (`assets/model/rf_model.json`) processes features for each fermenter individually.
* **Vessel States:**
  * Active fermenters (e.g. Fermenters 1 & 2) render with their individual temperature, pH, Brix, volume, and AI classification badge (`GOLDEN BATCH` or `NORMAL`).
  * Inactive vessels (e.g. Fermenters 3 & 4) remain in `STANDBY` (0% volume, empty).

---

### 3. MQTT Retained Publishing
* **Broker:** `broker.hivemq.com` (Port `8000` via WebSocket `ws://broker.hivemq.com:8000/mqtt` and Port `1883` via TCP).
* **Retain Policy:** All telemetry packets are published with `retain: true` so the broker holds the latest factory state indefinitely.
* **Cold Boot Sync:** When Primary App starts, it connects immediately and republishes all local snapshots. When Empty App connects, HiveMQ delivers the retained payloads immediately.

---

### 4. UI/UX Enhancements & Visual Overhauls
* **Golden Batch Recovery Dial:** Single bold 5.5px outer ring gauge with centered percentage reading and `GOLDEN RECOVERY` caption below.
* **Analyser Column Health:** Header updated to `ANALYSER COLUMN HEALTH` overseeing the 4 distillation parameters (Temperature, Pressure, Vacuum, $\Delta P$).
* **Dynamic Dual-Axis Mandatory Operational Trends:**
  * **Left Y-Axis (Cyan):** `Product Alcohol (%)` scaled from $94.0\% - 100.0\%$.
  * **Right Y-Axis (Orange):** `Alcohol Loss in Spent Wash (%)` scaled from $0.00\% - 0.45\%$.
  * **Real-time Badges:** Top-right pills displaying live `Product Alc: XX.XX%` and `Spent Loss: X.XXX%`.
  * **Safety Threshold Lines:** Dashed $95.0\%$ Min Product Limit and dotted $0.25\%$ Loss Alert Limit.
  * **Dynamic Binding:** 100% data-driven curves and endpoint markers bound directly to incoming telemetry without hardcoded values.
* **Mobile Portrait Responsive Distillery Dashboard:**
  * Adaptive layout wrapping `DistilleryOverviewScreen` in smooth `SingleChildScrollView` on portrait screens / width $< 650\text{px}$.
  * 4 KPI cards arranged in a clean 2x2 grid.
  * Operational Trends Chart, Key Distillation Metrics, Loss Analysis, Analyser Column Gauges, Spent Wash Summary, and Alarm Center stacked vertically with zero `RenderFlex` overflow errors.
  * Preserves 100% of executive single-screen desktop/tablet landscape dashboard untouched.

---

### 5. Repository Binaries & Saved APKs
* **Target Directories:**
  * `APKs/Parrys_Aura_Main_App.apk` (64.5 MB)
  * `APKs/Parrys_Aura_Empty_App.apk` (56.8 MB)
  * `Downloads/Parrys_Aura_Main_App.apk`
  * `Downloads/Parrys_Aura_Empty_App.apk`
  * `Documents/final draft/Distillary/APKs/Parrys_Aura_Main_App.apk`
  * `Documents/final draft/Distillary/APKs/Parrys_Aura_Empty_App.apk`
