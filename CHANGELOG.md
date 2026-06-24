## 0.0.1

Initial release.

- Ratio-based scaling for width, height, radius and fonts from a single design size.
- Automatic orientation swap between portrait and landscape designs/screens.
- Clamped up-scaling via `maxScaleFactor`.
- Accessibility-aware `setSp` that layers the system `TextScaler` over the design scale (opt-out via `respectSystemTextScale`).
- Static `num` extensions (`.w`, `.h`, `.sp`, `.r`) plus a reactive API (`ProScale.of(context)` / `context.scale`).
