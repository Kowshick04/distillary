# Bug Bounty & Code Audit Plan

This plan synthesizes all of our globally installed skills (`find-bugs`, `flutter-fix-layout-issues`, `flutter-add-widget-test`, `flutter-add-integration-test`, `flutter-apply-architecture-best-practices`) to conduct a comprehensive audit of the Distillery codebase.

## User Review Required

Please review the phases below. Once you approve, I will systematically execute each phase, track progress in `task.md`, and present the findings and fixes.

## Open Questions
> [!IMPORTANT]
> - Do you have specific devices or screen sizes (e.g., mobile vs. tablet) you want the pixel overflow audit to prioritize?
> - Are there specific critical user flows we should focus on for the Integration Testing phase?

---

## Phase 1: Security & Logic Bug Hunt (`find-bugs`)
We will perform a comprehensive scan of the local branch changes to identify logic flaws and vulnerabilities.

### Attack Surface Mapping
- **Telemetry Ingestion**: Review `SseTelemetryService` and `DistillerySnapshotStore` for data validation, injection vulnerabilities, and proper error handling.
- **State Operations**: Review how `TelemetryDataModel` is parsed and applied to the UI state.
- **Business Logic**: Verify edge cases in fermentation data calculations (e.g., numeric overflows when calculating Brix/pH/Alcohol percentages).

### Checklist
- [ ] Verify Data parsing safety (null checks, bounds checks on incoming telemetry).
- [ ] Check for memory leaks in `StreamSubscription`s (e.g., ensuring all streams in `DashboardScreen` are properly disposed).
- [ ] Review array indexing (e.g., `_factoriesVessels[packetFactoryIdx][vesselIdx]`) for potential `IndexOutOfRangeException` bugs.

---

## Phase 2: UI & Pixel Overflow Audit (`flutter-fix-layout-issues` & `flutter-build-responsive-layout`)
We will statically analyze the widget tree and dynamically test constraints to uncover "RenderFlex overflowed" and unbounded constraints errors.

### Target Areas
- **`Row` & `Column` Overflows**: Inspect `dashboard_screen.dart`, `ai_operator_advisor.dart`, and `workflow_process_card.dart`. We will identify unconstrained `Text` widgets or `Row`s that need `Expanded` or `Flexible` wrappers.
- **Unbounded Viewports**: Review the use of `ListView` inside `Column`s (e.g., in `ai_operator_advisor.dart`) to ensure `shrinkWrap: true` is performing efficiently, or replace it with `Expanded` if scrollability is needed.
- **Responsive Layout**: Evaluate hardcoded sizes and padding. Ensure the layout adapts gracefully using `LayoutBuilder` or `MediaQuery`.

---

## Phase 3: Automated Testing Setup (`flutter-add-widget-test` & `flutter-add-integration-test`)
To prevent regressions of the bugs we fix, we will implement testing suites.

### Widget Tests
- Write a `WidgetTester` test for `WorkflowProcessCard` to verify it renders correctly under extreme data conditions (e.g., exceptionally high text lengths).
- Verify the `AiOperatorAdvisor` alert banner flashes correctly on bacterial contamination triggers.

### Integration Tests
- Setup the `integration_test` package.
- Automate the user flow: App Launch -> View Dashboard -> Switch Factory -> Toggle View (SCADA vs Trend) -> Verify Data Sync overlays.

---

## Phase 4: Architecture Refactoring (`flutter-apply-architecture-best-practices`)
We will review the current structure and recommend layer decoupling.

### Targets
- Separate the raw state management (e.g., the massive `setState` calls and telemetry handling in `dashboard_screen.dart`) from the UI layer by extracting them into a dedicated ViewModel, Bloc, or Provider.
- Ensure the data layer (`SseTelemetryService`) has no direct coupling with the presentation layer.

---

## Verification Plan

### Automated Tests
- Run `flutter test` to verify all widget tests pass.
- Run `flutter test integration_test/app_test.dart` for E2E validation.

### Manual Verification
- Resize the application window on desktop/web (or use device simulation) to rigorously test for yellow/black RenderFlex overflow stripes.
- Disconnect network during telemetry stream to observe error handling and memory management.
