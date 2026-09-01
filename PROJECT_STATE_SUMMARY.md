# Distillery Plant Telemetry & AI Batch Classification System

## System Architecture Overview

### 1. Plant & Operator Role Mapping (1-to-1 Standard)
| Index | Plant Name | Code | Operator ID | Password | Retained MQTT Telemetry Topic | Default Synthetic File |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
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

### 4. Random Forest Decision Boundaries
* **`GOLDEN BATCH` ($85\% \sim 92\%$ confidence):** Final wash alcohol $\ge 11.5\%$, retention $18 \sim 28\text{ hrs}$, specific gravity $1.030 \sim 1.045$, pH $4.4 \sim 4.8$.
* **`NORMAL` ($65\% \sim 78\%$ confidence):** Final wash alcohol between $6.0\% \sim 9.5\%$ or retention $>40\text{ hrs}$.

---

### 5. Repository Binaries & Scripts
* **Release APK:** `releases/Distillary_PrimaryApp_2Fermenters_Release.apk`
* **Diagnostic Suite:**
  * `scripts/diagnose_broker.py` — Live subscriber tool.
  * `scripts/publish_fresh_retained.py` — Retained batch reset utility.
  * `scripts/inspect_user_uploaded.py` — Row inspector & inference checker.
  * `scripts/sweep_features.py` — Threshold sweeping tool.

---

## 10. Tablet Local Storage Permissions & Ingestion Verification (2026-09-01 11:59:13)
- **Permissions:** Full `MANAGE_EXTERNAL_STORAGE` and `READ_EXTERNAL_STORAGE` granted to `com.auraliss.distillary`.
- **Directory Ingestion:** Automatic scanning of `/sdcard/Download/Distillery/` and factory subfolders (e.g. `Nellikuppam/`).
- **Verified Ingestion:** Correctly reads and parses live files directly from tablet internal storage (e.g. `Nellikuppam_120KLPD_Normal_vs_Golden.xlsx`) with 2 active fermenters and 2 standby vessels.
