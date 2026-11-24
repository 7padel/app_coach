

## Phase 2 UI refinement — 24 November 2026

Branch: `ux/phase2-refinement` in `app_coach`. Base: `origin/main` at `da34895`.

Direction: calm, focused and athletic. Retain forest green `#2C4120` and court-lime `#C8DA60`; use neutral surfaces, clear task hierarchy, restrained states and short transitions.

- Scoped theme across schedules, booking history/detail, session detail, time off and profile screens.
- The schedule header names the task; selection states are announced and transitions respect reduced motion.
- Session labels and values wrap on narrow displays and at larger text scales, including participant headers.
- Failed schedule loads offer recovery. Time off has a labelled action and a sheet that scrolls above the keyboard.
- Busy/disabled controls have consistent appearance and prevent repeat submission.

### Validation and review

Run `flutter test --no-pub test/phase2_layout_test.dart`. The focused tests cover narrow layouts/larger text, interaction state and a visual fixture. Screenshots in `docs/ui-review/` use representative sample data, not a live account. Dart analysis still reports pre-existing warnings in surrounding code.

Before release, test authenticated module flows against the correct dev backend, including permissions, long lists, validation, keyboard/safe areas and failed requests. Mobile checkout, gateway callbacks, captain scoring/round completion and coach time-off/schedule updates need real-device UAT. Visual fixture tests do not establish deployment readiness.

### Rollback

These changes are isolated in this repository; no merge or deployment is part of the UI work. For comparison, use the base SHA above. If the UI commit is merged later, revert that commit through the normal release process rather than resetting unrelated development work. The backend remains on its existing Phase 2 development line.

Design process informed by unslop by Damir Sokolovsky ([@heydamir](https://x.com/heydamir)), CC BY 4.0; no generated artwork or additional runtime UI dependency was introduced.
