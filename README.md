# Indodax Automation Framework

> End-to-end test automation suite for the [Indodax](https://indodax.com) cryptocurrency exchange — covering API, Web, and Mobile (Android/iOS) layers using Robot Framework.

---

## Overview

This project provides a multi-layer, environment-aware automation framework built on Robot Framework and Python. It follows a clean **Page Object Model (POM)** architecture with centralized configuration management, making it easy to run the same tests across `dev`, `staging`, and `production` environments.

| Layer | Test Scope | Status |
|---|---|---|
| **API** | Public & Private Indodax API endpoints | ✅ 10/10 PASS |
| **Web** | USDT/IDR trading market UI (Playwright) | ✅ 11/11 PASS |
| **Mobile** | Android ETH market search & validation (Appium) | ✅ 1/1 PASS |

**Total: 22/22 tests passing**

---

## Project Structure

```
python_qa/
├── automation-framework/         # Main framework root
│   ├── robot.ini                 # Robot Framework global config
│   ├── requirements.txt          # Python dependencies
│   ├── config/
│   │   └── environments/         # YAML configs per environment (non-secret)
│   │       ├── dev.yaml
│   │       ├── staging.yaml
│   │       ├── production.yaml
│   │       ├── mobile_dev.yaml
│   │       ├── mobile_staging.yaml
│   │       └── mobile_production.yaml
│   ├── libraries/                # Custom Python keyword libraries
│   │   ├── api/                  # API signer, schema validator, response validator
│   │   ├── base/                 # ConfigManager (YAML + .env loader)
│   │   └── mobile/
│   ├── resources/
│   │   ├── keywords/             # Reusable Robot Framework keywords
│   │   │   ├── api/              # API session setup, base keywords, test data loader
│   │   │   ├── web/              # Browser settings, web test data
│   │   │   └── mobile/           # Appium settings, mobile test data
│   │   └── page_objects/         # Page Object Model resources
│   │       ├── mobile/           # Home, market, onboarding, trading page keywords
│   │       └── web/
│   ├── test_data/                # JSON test data & JSON Schema files
│   │   ├── api/
│   │   └── web/
│   ├── tests/                    # Test suites
│   │   ├── api/
│   │   │   ├── indodax_public_api.robot
│   │   │   └── indodax_private_api.robot
│   │   ├── web/
│   │   │   └── indodax_usdtidr_market.robot
│   │   └── mobile/
│   │       └── android/
│   │           └── base/
│   │               └── search_and_validate_eth.robot
│   ├── results/                  # Test output (gitignored)
│   ├── .env.example              # ← API/Web env template (commit this)
│   └── .env.mobile.example       # ← Mobile env template (commit this)
├── Architect & Strategy/         # Design documents & diagrams
│   ├── 1_Design_Documents/
│   ├── 2_Diagrams/
│   ├── 3_Technical_Specifications/
│   ├── 4_Presentation_Guide/
│   └── Explanation/
└── load_test/                    # Locust load testing scripts
```

---

## Technology Stack

| Category | Tool / Library |
|---|---|
| **Test Framework** | Robot Framework 7.4.1 |
| **API Testing** | `robotframework-requests`, `httpx` |
| **Web Testing** | `robotframework-browser` (Playwright) |
| **Mobile Testing** | `robotframework-appiumlibrary`, Appium 2.x |
| **Schema Validation** | `jsonschema` |
| **Load Testing** | `locust` |
| **Config Management** | `pyyaml`, `python-dotenv` |
| **Language** | Python 3.13+ |

---

## Getting Started

### 1. Clone & Set Up Virtual Environment

**Option A — using `uv` (recommended, faster):**

```bash
git clone <repo-url>
cd python_qa
uv venv .venv
source .venv/bin/activate
uv pip install -r automation-framework/requirements.txt
```

> Install `uv` if you don't have it: `curl -LsSf https://astral.sh/uv/install.sh | sh`

**Option B — using standard `pip`:**

```bash
git clone <repo-url>
cd python_qa
python -m venv .venv
source .venv/bin/activate
pip install -r automation-framework/requirements.txt
```

### 2. Configure Environment Variables

Copy the template files and fill in the values for your target environment:

```bash
cd automation-framework

# For API / Web tests
cp .env.example .env.dev
cp .env.example .env.staging
cp .env.example .env.production

# For Mobile tests
cp .env.mobile.example .env.mobile.dev
cp .env.mobile.example .env.mobile.staging
cp .env.mobile.example .env.mobile.production
```

Open each `.env.*` file and fill in the required values. See the [Environment Configuration](#environment-configuration) section below for details.

### 3. Install Playwright Browsers (Web only)

```bash
rfbrowser init
```

---

## Running Tests

All commands are run from the `automation-framework/` directory.

### API Tests

```bash
# All API tests
robot --outputdir ./results tests/api/

# Public API only
robot --outputdir ./results --include public tests/api/

# Private API only (requires API key in .env.production)
robot --outputdir ./results --include private tests/api/

# Smoke tests only
robot --outputdir ./results --include smoke tests/api/
```

### Web Tests

```bash
# All Web tests (headless by default)
robot --outputdir ./results tests/web/

# Run against a specific environment
robot --outputdir ./results -v TEST_ENV:staging tests/web/

# Run headed (visible browser)
robot --outputdir ./results -v headless:false tests/web/
```

### Mobile Tests (Android)

> Requires: Appium server running, Android device/emulator connected via `adb`

```bash
# Start Appium server first (separate terminal)
appium --port 4723

# Run mobile tests
robot --outputdir ./results tests/mobile/android/base/

# Run against staging environment
robot --outputdir ./results -v TEST_ENV:staging tests/mobile/android/base/
```

### Tag-Based Filtering

```bash
# Run all smoke tests across all layers
robot --outputdir ./results --include smoke tests/

# Run only critical path tests
robot --outputdir ./results --include critical tests/

# Run regression suite
robot --outputdir ./results --include regression tests/

# Skip tests that require a real device
robot --outputdir ./results --exclude skip tests/
```

### View Results

```bash
# Open test report after a run
open results/report.html
```

---

## Environment Configuration

### API / Web — `.env.{environment}`

| Variable | Description |
|---|---|
| `API_BASE_URL` | Public API base URL (e.g. `https://indodax.com`) |
| `WEB_BASE_URL` | Web UI base URL |
| `PRIVATE_API_BASE_URL` | Authenticated TAPI endpoint URL |
| `INDODAX_API_KEY` | API key from Indodax API Management |
| `INDODAX_API_SECRET` | API secret from Indodax API Management |

### Mobile — `.env.mobile.{environment}`

| Variable | Description |
|---|---|
| `APPIUM_SERVER` | Appium server URL (default: `http://127.0.0.1:4723`) |
| `ANDROID_DEVICE_NAME` | Device name from `adb devices` |
| `ANDROID_PLATFORM_VERSION` | Android OS version (e.g. `15`) |
| `ANDROID_APP_PACKAGE` | App package name |
| `ANDROID_APP_ACTIVITY` | App launch activity |
| `NO_RESET` | `True` = keep app data (dev), `False` = clear state (CI) |
| `IOS_UDID` | iOS device UDID from `xcrun xctrace list devices` |

Non-secret config (timeouts, retries, flags) lives in `config/environments/*.yaml` and is safe to commit.

---

## Architecture

The framework uses a layered architecture:

```
Tests (.robot)
    └── Keywords / Page Objects (resources/)
            └── Custom Libraries (libraries/)
                    └── ConfigManager → YAML config + .env secrets
```

Key design decisions:
- **Separation of secrets vs config** — secrets in gitignored `.env.*`, non-secret config in committed YAML files
- **Page Object Model** — UI interactions abstracted into page-level keyword files
- **Environment-aware** — single test suite, multiple environments via `-v TEST_ENV:xxx`
- **Tag-based execution** — `smoke`, `regression`, `critical`, `positive_case`, `negative_case`

For full architecture documentation see [Architect & Strategy/](Architect%20&%20Strategy/).


