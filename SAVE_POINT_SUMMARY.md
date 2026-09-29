# DISTILLERY AI SCADA & TELEMETRY SYSTEM - PROJECT SAVE POINT
**Saved Date:** September 29, 2026  
**Location:** `c:\Users\Admin B\StudioProjects\Distillary`  
**Git Commit:** `1c041e4` (Working Tree: Clean)  

---

## 1. Release Binaries & Saved APKs

The latest release builds with full mobile & tablet portrait responsiveness, Parrys Aura branding, and live MQTT verification are saved at:

| App Package | APK Name | Size | File Path |
| :--- | :--- | :--- | :--- |
| **Primary App** (`com.auraliss.distillary`) | `Parrys_Aura_Main_App.apk` | **64.5 MB** | `c:\Users\Admin B\StudioProjects\Distillary\APKs\Parrys_Aura_Main_App.apk` |
| **Empty App** (`com.auraliss.distillary.empty`) | `Parrys_Aura_Empty_App.apk` | **56.8 MB** | `c:\Users\Admin B\StudioProjects\Distillary\APKs\Parrys_Aura_Empty_App.apk` |

### Mirrored Backup Locations:
- `c:\Users\Admin B\StudioProjects\Distillary\scratch\APKs\`
- `c:\Users\Admin B\Downloads\`
- `c:\Users\Admin B\Documents\final draft\Distillary\APKs\`

---

## 2. Recent Save Point Changes (September 29, 2026)

### A. Empty App: Tablet Portrait 2x2 Grid & Alignment Fix
1. **Dynamic Orientation & Breakpoint Overhaul**:
   - Updated `dashboard_screen.dart` breakpoint logic:
     `final bool isPortrait = orientation == Orientation.portrait || screenConstraints.maxWidth < 900;`
   - Accurately identifies 720dp tablet portrait mode (which previously fell through to landscape/desktop width rules).
2. **2x2 Fermenter Grid in Portrait**:
   - Fermenters 1 & 2 in Row 1, Fermenters 3 & 4 in Row 2, each with dedicated $430\text{ dp}$ height and proportional spacing.
3. **Stacked Lower Telemetry Panels**:
   - Lower cards (Golden Batch Possibility, AI Operator Advisor, Plant KPIs) now render stacked full-width inside a fluid `SingleChildScrollView(physics: BouncingScrollPhysics())`.
4. **Golden Batch Alignment Text Auto-Scaling**:
   - Wrapped metric text and status badges in `FittedBox(fit: BoxFit.scaleDown)` with `maxLines: 1` inside `_buildAlignmentRow`, eliminating vertical character wrapping.

### B. Primary App: Parrys Aura Brand Identity & Launcher Icon
1. **Multi-Density Icon Generation**:
   - Created safe-zone padded, high-resolution stylized blue **Parrys "P"** brand icons for all Android density buckets:
     - `mipmap-mdpi`: $48 \times 48\text{ px}$
     - `mipmap-hdpi`: $72 \times 72\text{ px}$
     - `mipmap-xhdpi`: $96 \times 96\text{ px}$
     - `mipmap-xxhdpi`: $144 \times 144\text{ px}$
     - `mipmap-xxxhdpi`: $192 \times 192\text{ px}$
2. **Application Label Update**:
   - In `android/app/src/main/AndroidManifest.xml`, updated `android:label="distillary"` $\rightarrow$ `android:label="Parrys Aura"`.
3. **Compiled & Deployed**:
   - Recompiled release APK and installed directly to Xiaomi Pad 6 (`74ae9455`), verifying the new home screen squircle icon and app label.

### C. Live MQTT End-to-End Pipeline Verification
1. **Broker Status**:
   - Verified active retained messages on `broker.hivemq.com:1883` and `ws://broker.hivemq.com:8000/mqtt` for all 5 factories (`F01` to `F05`).
2. **Real-Time Responsiveness**:
   - Live telemetry packet injection via `scripts/publish_live_test_packet.py` confirmed instant (<150ms) receipt and reactive Flutter dashboard rebuild on the tablet.
   - Dynamic parameter validation verified live alarms (e.g. Temp $33.2^\circ\text{C} > 33.0^\circ\text{C} \rightarrow$ `COOL DOWN` badge).

---

## 3. Operator Credentials & Plant Mapping

| Factory Index | Plant Name | Code | Operator ID | Password | Retained MQTT Topic |
| :---: | :--- | :---: | :--- | :--- | :--- |
| **0** | **Haliyal** | `F01` | `operator01` | `factory1` | `distillery/factory/F01/telemetry` |
| **1** | **Sankili** | `F02` | `operator02` | `factory2` | `distillery/factory/F02/telemetry` |
| **2** | **Nellikuppam** | `F03` | `operator03` | `factory3` | `distillery/factory/F03/telemetry` |
| **3** | **Sivagangai** | `F04` | `operator04` | `factory4` | `distillery/factory/F04/telemetry` |
| **4** | **Bagalkot** | `F05` | `operator05` | `factory5` | `distillery/factory/F05/telemetry` |
| **-** | **CEO Overview** | `ALL` | `ceo` | `ceo123` | Multi-Factory Grid View |

---

## 4. Hardware Authorization
* **Primary Reference Tablet**: Xiaomi Pad 6 (`23043RP34I`, Serial `74ae9455`, Android 14).
  * Display Density / Resolution: Logical $720 \times 1152\text{ dp}$ (Physical $1800 \times 2880$, density 400).
* **Target Universal Tablet (12.7" Class)**: Lenovo Tab P12 / Xiaoxin Pad Pro 12.7 / Galaxy Tab S9+ / iPad Pro 12.9".
  * Display Density / Resolution: Logical $800-920\text{ dp} \times 1280-1472\text{ dp}$ (Physical $2944 \times 1840$ or $2800 \times 1752$).

---

## 5. Universal 12.7-Inch Screen Adaptation Analysis & Roadmap

### A. Observations from Real Device Screen Captures
1. **Consolidated Enterprise Control Console (CEO Portal)**:
   - **Root Cause**: Rigid horizontal constraints (`maxWidth: 860` on the top KPI summary bar, `maxWidth: 1200` on the 5-facility grid) wrapped in a `SingleChildScrollView` with static `SizedBox(height: 36)`.
   - **Visual Impact on 12.7"**: Content renders as a narrow, vertically compressed ribbon across the middle of the screen, leaving wide empty black borders at the top, bottom, and flanks.
2. **Plant Operational Dashboard (Fermenter & Distillation Views)**:
   - **Root Cause**: The top 4-fermenter vessel row is fixed at `height: 248`. On a 12.7" screen where the viewport height exceeds $800\text{ dp}$, $248\text{ dp}$ leaves the tanks horizontally elongated yet vertically squashed.
   - **Lower Telemetry Deck**: The lower three cards (Plant-wide KPIs, Golden Batch Possibility, AI Operator Advisor) leave an unutilized black void beneath them because their internal widgets do not flex to fill the remaining vertical height.

### B. Universal Multi-Display Solution Plan
1. **Proportional Viewport Geometry**:
   - Replace fixed `height: 248` on the fermenter row with a responsive calculation: `(screenHeight * 0.35).clamp(260.0, 360.0)`.
   - Utilize dynamic `Expanded` with flexible child sizing inside the lower panels so dials, alignment grids, and feature importance bars stretch gracefully to the bottom edge.
2. **Fluid Typography & Metric Auto-Scaling**:
   - Introduce a baseline device scale multiplier: `final double uiScale = (screenWidth / 1152.0).clamp(0.9, 1.35);` to ensure text, badges, and tank gauges stay proportional from 11" to 12.7" displays.
3. **Adaptive Grid Max-Width Expansion**:
   - Upgrade `ConsolidatedPortalScreen` and `LoginScreen._buildConsolidatedView` to expand up to `maxWidth: 1600` or use `double.infinity` with balanced horizontal padding (`padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04)`), seamlessly filling the 12.7" canvas.
