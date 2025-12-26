# Copilot / AI Agent Instructions for URH

Purpose
- Provide succinct, actionable guidance so an AI coding agent can be productive quickly in the Universal Radio Hacker (URH) codebase.

Big picture (what to know first)
- URH is a PyQt5 desktop application for wireless protocol analysis. High-level responsibilities:
  - GUI & controllers: `src/urh/controller/` and generated UI under `src/urh/ui/`.
  - Core signal algorithms: `src/urh/signalprocessing/` (demodulation, filtering, protocol sniffer).
  - Analysis/auto-assignment: `src/urh/awre/` (rule-engine & inference helpers).
  - Hardware backends: `src/urh/dev/native/` (shared native libs and Python wrappers for SDRs).
  - C/Cython performance parts: `src/urh/cythonext/` (built as C++/C extensions).
  - Simulation & fuzzing: `src/urh/simulator/` and related test/integration code.

Key files to read first
- `README.md` — user-facing overview and install/run guidance.
- `src/urh/main.py` — app entry point; shows how UI generation, Cython builds, and `autoclose` test flag are applied.
- `src/urh/cythonext/build.py` — builds Cython extensions in-place.
- `data/generate_ui.py` — compiles `.ui` and `.qrc` files into `src/urh/ui/ui_*.py`.
- `.github/workflows/ci.yml` — canonical CI tasks: deps, Cython build, packaging, and pytest invocation.
- `tests/QtTestCase.py` and `tests/utils_testing.py` — test conventions for GUI and headless runs.

Developer workflows (how to build/run/test)
- Run the app from source (recommended for development):
  - cd to project root then: `python src/urh/main.py` or `./src/urh/main.py`
  - If C extensions are missing the app will attempt to build them automatically.
- Build Cython extensions (explicit):
  - `python src/urh/cythonext/build.py` (or `python setup.py build_ext --inplace -j$(nproc)`).
- Regenerate UI files after editing `.ui` or `.qrc`:
  - `python -c "from data.generate_ui import gen; gen(force=True)"` or run `data/generate_ui.py`.
- Run tests:
  - Non-GUI: `pytest -q tests`.
  - GUI tests (headless): CI uses `xvfb-run` and touches `tests/show_gui` to enable visible-mode tests; locally use `touch tests/show_gui` + `xvfb-run pytest -q tests`.
  - GUI test conventions: `tests/QtTestCase.py` sets `multiprocessing` start method to `spawn` and uses `tests/utils_testing.write_settings()` to avoid modal dialogs — follow these patterns in tests.
  - uv-based workflow: a `pyproject.toml` and `Makefile` are included for `uv` integration. Common commands:
    - `make uv-sync` -> runs `uv sync` to populate the environment
    - `make test` -> runs `uv run pytest -q tests`
    - `uv lock` -> update the lockfile (commit `uv.lock` if you make dependency changes)
- Packaging and releases:
  - CI builds manylinux wheels via Docker (`data/make_manylinux2014_wheels.sh`) and platform-specific artifacts (PyInstaller for exe/DMG) as described in `.github/workflows/ci.yml`.

Project conventions & gotchas (specific, not generic)
- UI source files are the `.ui` and `.qrc` in `data/ui/`; generated Python UI modules live under `src/urh/ui/ui_*.py`. Prefer editing `.ui` and regenerating rather than editing `ui_*.py` directly.
- C/C++ extensions are required for performance and some features; missing extensions trigger an in-place build in `main.py`. Use `src/urh/cythonext/build.py` for faster, repeatable builds.
- Tests use an opt-in `tests/show_gui` file to enable visual display; CI touches this file when needed. Avoid removing this mechanism — add `show_gui` only for debugging.
- `autoclose` CLI argument: starting `main.py autoclose` is useful for automated smoke testing (app quits after one second).
- Native SDR libraries on CI are handled specially (Windows drivers unpacked into `src/urh/dev/native/lib/shared`); hardware backends are validated using `data/check_native_backends.py`.

Integration points & external deps
- PyQt5 is the UI layer (see `data/requirements.txt` for pinned minimums).
- Native SDR backends (AirSpy, HackRF, RTLSDR, Lime, BladeRF, RSP, USRP) live under `src/urh/dev/native` – expect platform-specific install steps in CI.
- External decodings/support: community-provided decodings are in `data/decodings/` and tests like `TestExternalDecodings.py` validate the behavior.

How to patch & PR (practical advice for agents)
- When changing UI, always run `data/generate_ui.py` and commit generated `src/urh/ui/ui_*.py` alongside `.ui` edits.
- If making signal-processing changes, ensure relevant tests under `tests/` and where applicable add integration tests that exercise GUI flows using `QtTestCase` and helpers in `tests/utils_testing.py`.
- Run the small subset of tests locally before pushing to speed iteration (`pytest -q tests/test_modulator.py::TestModulator::test_...`).
- For changes touching native backends or packaging, reference `.github/workflows/ci.yml` as the authoritative CI logic.

Troubleshooting tips for agents
- If a test fails that uses GUI elements and you see environment/display errors, run under Xvfb: `xvfb-run -s "-screen 0 1280x1024x24" pytest -q tests`.
- For Cython build failures, re-run `python src/urh/cythonext/build.py` and inspect compiler logs; test that import `import urh.cythonext.signal_functions` succeeds.

Contact points & follow-ups
- No agent docs were found when I started — this file should be treated as the first iteration. If you want, I can expand with code snippets (how to run a quick signal-processing unit test, example of adding a UI control + test, or a small end-to-end reproduction case).

---

If any section is unclear or you want more detail on a specific workflow (native driver packaging, Cython internals, or GUI testing patterns), tell me which area and I'll expand it.