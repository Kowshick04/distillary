# DISTILLERY AI SCADA & TELEMETRY SYSTEM - PROJECT SAVE POINT
**Saved Date:** September 2, 2026  
**Location:** `c:\Users\Admin B\StudioProjects\Distillary`  
**Git Commit:** `fac6946` (Working Tree: Clean)

---

## 1. Release Binaries & Saved APKs

The latest release builds with full mobile portrait and tablet landscape responsiveness are saved at:

| App Package | APK Name | Size | File Path |
| :--- | :--- | :--- | :--- |
| **Primary App** (Full Pipeline & Live Feeds) | `Parrys_Aura_Main_App.apk` | **64.5 MB** | `c:\Users\Admin B\StudioProjects\Distillary\APKs\Parrys_Aura_Main_App.apk` |
| **Empty App** (MQTT HiveMQ Receiver App) | `Parrys_Aura_Empty_App.apk` | **56.8 MB** | `c:\Users\Admin B\StudioProjects\Distillary\APKs\Parrys_Aura_Empty_App.apk` |

### Mirrored Backup Locations:
- `c:\Users\Admin B\StudioProjects\Distillary\scratch\APKs\`
- `c:\Users\Admin B\Downloads\`
- `c:\Users\Admin B\Documents\final draft\Distillary\APKs\`

---

## 2. Operator Credentials & Plant Mapping

| Factory Index | Plant Name | Code | Operator ID | Password | Retained MQTT Topic |
| :---: | :--- | :---: | :--- | :--- | :--- |
| **0** | **Haliyal** | `F01` | `operator01` | `factory1` | `distillery/factory/F01/telemetry` |
| **1** | **Sankili** | `F02` | `operator02` | `factory2` | `distillery/factory/F02/telemetry` |
| **2** | **Nellikuppam** | `F03` | `operator03` | `factory3` | `distillery/factory/F03/telemetry` |
| **3** | **Sivagangai** | `F04` | `operator04` | `factory4` | `distillery/factory/F04/telemetry` |
| **4** | **Bagalkot** | `F05` | `operator05` | `factory5` | `distillery/factory/F05/telemetry` |
| **-** | **CEO Overview** | `ALL` | `ceo` | `ceo123` | Multi-Factory Grid View |

---

## 3. Features & Architecture

### A. Dual Responsive Dashboard Layouts
1. **Tablet / Desktop Landscape (`width >= 650px`):**
   - Single-screen executive layout with zero vertical scroll.
   - Dual-axis dynamic Trends Chart ($94.0\% - 100.0\%$ Product Alcohol vs $0.00\% - 0.45\%$ Loss).
   - 4-column lower telemetry cards (Loss Analysis, Analyser Column Health gauges, Spent Wash Summary, Alarm Center).
2. **Mobile Portrait Mode (`Orientation.portrait` / `width < 650px`):**
   - Continuous smooth vertical scroll via `SingleChildScrollView(physics: BouncingScrollPhysics())`.
   - 4 KPI cards arranged in a **2x2 grid** (eliminating text clipping and overflows).
   - Stacked full-width panels for Trends, Key Distillation Metrics, Donut chart, Circular Gauges, and Alarms.

### B. Multi-Fermenter AI Batch Classification (Max 2 Active Rule)
- Excel ingestion scanner processes `/sdcard/Download/Distillery/`.
- Extracts up to 2 distinct fermenters per batch.
- Real-time Random Forest inference flags `GOLDEN BATCH` or `NORMAL` with actionable recovery buffer recommendations.

### C. Retained MQTT Streaming
- Broker: `broker.hivemq.com` (Port `8000` via WebSocket & Port `1883` via TCP).
- Publishes with `retain: true` so the broker holds live factory states across app restarts.
