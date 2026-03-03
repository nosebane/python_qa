# Automation Test Framework Architecture Design

**Version:** 2.0  
**Date:** February 2026  
**Status:** Implemented & Verified

---

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Clean Architecture & Clean Code Principles](#clean-architecture--clean-code-principles)
3. [Platform Segregation](#platform-segregation)
4. [Tagging Strategy](#tagging-strategy)
5. [Environment Strategy](#environment-strategy)
6. [Test Execution Strategy](#test-execution-strategy)
7. [Error Handling & Reporting Strategy](#error-handling--reporting-strategy)
8. [Test Data Strategy](#test-data-strategy)
9. [Keyword Dictionary](#keyword-dictionary)

---

## Executive Summary

This document describes the actual implementation of the automation testing framework for **Indodax**, covering API, Web, and Mobile (Android). Verified at **22/22 tests PASS** (10 API + 11 Web + 1 Mobile).

| Component | Technology |
|---|---|
| Core Orchestrator | Robot Framework 7.4.1 |
| Web Automation | Browser Library (Playwright) 19.0.0+ |
| API Testing | RequestsLibrary + JSONLibrary + Custom Libraries |
| Mobile Automation | AppiumLibrary 3.2.1 (Appium 2.x) |
| Parallel Execution | robotframework-pabot 5.2.2 |
| Config Management | ConfigManager (Hybrid YAML + .env) |
| Request Signing | IndodaxSignerLibrary (HMAC-SHA512) |
| JSON Parsing | JSONLibrary 0.5 (`Get Value From Json` / JSONPath) |
| Validation | jsonschema 4.0+ + ResponseValidator |
| Runtime | Python 3.13 / uv |

---

## Clean Architecture & Clean Code Principles

### Layered Architecture

The framework is built on 5 distinct layers, each with a single clear responsibility:

```
┌──────────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                      │
│  tests/api/  ·  tests/web/  ·  tests/mobile/            │
│  (.robot files — test cases only, no logic)             │
└──────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────┐
│             BUSINESS LOGIC / KEYWORDS LAYER             │
│  resources/keywords/api/   — api_settings, base_kw      │
│  resources/keywords/web/   — web_settings, test_data    │
│  resources/keywords/mobile/— mobile_settings, test_data │
└──────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────┐
│                  ABSTRACTION LAYER                       │
│  resources/page_objects/web/   — MarketPage             │
│  resources/page_objects/mobile/android/ — per-screen    │
│                                  keywords + locators    │
└──────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────┐
│             CUSTOM PYTHON LIBRARIES LAYER               │
│  libraries/base/config_manager.py                       │
│  libraries/api/IndodaxSignerLibrary.py  (HMAC-SHA512)   │
│  libraries/api/indodax_signer.py        (signing core)  │
│  libraries/api/ResponseValidator.py                     │
└──────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────┐
│               EXTERNAL LIBRARIES & SUT                  │
│  RequestsLibrary  → indodax.com/api/  &  /tapi          │
│  JSONLibrary      → JSON parsing / JSONPath extraction  │
│  Browser (Playwright) → indodax.com                     │
│  AppiumLibrary    → id.co.bitcoin.Bitcoin-Trading-Platform│
└──────────────────────────────────────────────────────────┘
```

### Clean Code Principles Applied

#### Single Responsibility

Each file has one job:

```
api_settings.robot         → suite setup/teardown for API
base_keywords.robot        → generic HTTP assertion keywords
indodax_public_api.robot   → public API-specific keywords
indodax_private_api.robot  → private API + HMAC signing keywords
IndodaxSignerLibrary.py    → HMAC-SHA512 request signing only
ResponseValidator.py       → HTTP status code validation only
config_manager.py          → config loading only (YAML + .env)
```

#### DRY — Don't Repeat Yourself

- Setup/teardown declared once in `api_settings.robot` / `web_settings.robot` / `mobile_settings.robot`, shared via `Resource` across all test files
- Timeouts and retry policy come from YAML — never hardcoded in test cases
- Secrets (API keys, device names) come from `.env` — never in test files

#### Naming Conventions

```robot
# Keywords: action-oriented, human-readable
Verify Ticker Response Structure    ${ticker_data}    @{required_fields}
Capture Screenshot On Failure And Close Browser
Search For Coin Pair    ${search_term}

# Variables: UPPER_CASE for suite/global, lower_case for local
${API_BASE_URL}         ← suite variable
${BROWSER_NAV_TIMEOUT}  ← suite variable (from YAML)
${yaml_config}          ← local variable

# Files: per-screen, per-feature, per-platform
mobile/market/market_keywords.robot
mobile/market/market_locators.robot
web/market/indodax_usdtidr_market_page_keywords.robot
```

#### SOLID Principles

| Principle | Implementation |
|---|---|
| **S**ingle Responsibility | Each Python library has 1 job: sign / validate / load config |
| **O**pen/Closed | Add a new platform by adding a folder + keywords — existing code unchanged |
| **L**iskov Substitution | All mobile page objects follow the same `keywords.robot + locators.robot` pattern |
| **I**nterface Segregation | API / Web / Mobile each have their own `settings.robot` |
| **D**ependency Inversion | Test cases never import Appium/Browser directly — always through keyword abstractions |

---

## Platform Segregation

### Actual Directory Structure

```
automation-framework/
├── tests/
│   ├── api/
│   ├── web/
│   └── mobile/android & ios
│
├── resources/
│   ├── keywords/
│   │   ├── api/
│   │   │   ├── api_settings.robot        (suite setup/teardown)
│   │   │   ├── base_keywords.robot       (generic HTTP keywords)
│   │   │   └── test_data_loader.robot    (JSON loader)
│   │   ├── web/
│   │   │   ├── web_settings.robot        (suite setup/teardown)
│   │   │   └── web_test_data.robot       (JSON loader)
│   │   └── mobile/
│   │       ├── mobile_settings.robot     (suite setup/teardown, Appium init)
│   │       └── mobile_test_data.robot    (JSON loader for mobile test data)
│   │
│   └── page_objects/
│       ├── web/
│       │   └── market/
│       └── mobile/
│           ├── android/                  (per-screen split: keywords + locators — active)
│           │   ├── common/common_keywords.robot
│           │   ├── auth/        login_keywords.robot · login_locators.robot
│           │   ├── home/        home_keywords.robot · home_locators.robot
│           │   ├── market/      market_keywords.robot · market_locators.robot
│           │   ├── trading/
│           │   │   ├── lite/    trading_lite_keywords.robot · trading_lite_locators.robot
│           │   │   └── pro/     trading_pro_keywords.robot
│           │   ├── onboarding/  onboarding_keywords.robot · onboarding_locators.robot
│           │   ├── portfolio/   portfolio_keywords.robot · portfolio_locators.robot
│           │   ├── account/     account_keywords.robot · account_locators.robot
│           │   └── payment/     deposit_keywords.robot · withdraw_keywords.robot
│           └── ios/                      (same screen structure — planned, pending WDA signing)
│               ├── common/
│               ├── home/
│               ├── market/
│               └── ...
│
├── libraries/
│   ├── base/
│   │   └── config_manager.py             (Hybrid YAML+.env loader)
│   ├── api/
│   │   ├── IndodaxSignerLibrary.py       (RF-callable HMAC-SHA512 library)
│   │   ├── indodax_signer.py             (core signing logic)
│   │   └── ResponseValidator.py          (HTTP status validation)
│   ├── mobile/
│   │   └── __init__.py                   (stub — reserved)
│   └── web/
│       └── __init__.py                   (stub — reserved)
│
├── config/environments/
│   ├── dev.yaml                          (non-secret, git-committed)
│   ├── staging.yaml
│   ├── production.yaml
│   ├── mobile_dev.yaml
│   ├── mobile_staging.yaml
│   └── mobile_production.yaml
│
├── test_data/
│   ├── api/
│   │   ├── base.json
│   │   └── schemas/ 
│   ├── web/
│   └── mobile/
│
├── dictionary/
│   ├── keyword_dictionary.robot          (auto-generated, 145 keywords)
│   ├── keyword_report.txt                (duplicate report — 0 duplicates)
│   └── generate_dictionary.py            (scanner + duplicate detector)
│
└── results/                              (robot output — gitignored)
    ├── report.html
    ├── log.html
    └── output.xml
```

### 1. API Platform

**Stack:** Robot Framework + RequestsLibrary + JSONLibrary + IndodaxSignerLibrary (HMAC-SHA512) + jsonschema

```robot
*** Settings ***
Resource    ../../resources/keywords/api/api_settings.robot

Test Tags    api    indodax    public    smoke

Suite Setup    Initialize API Test Environment

*** Test Cases ***

Public API - Get Bitcoin Ticker
    [Tags]    smoke    ticker    positive_case    critical
    [Documentation]    Verify Bitcoin ticker endpoint returns valid data
    ...
    ...    Acceptance Criteria:
    ...    - Endpoint returns 200 status
    ...    - Response contains: buy, sell, last, high, low
    ...    - Buy price <= Sell price
    ...    - All price values are positive

    ${pair}=    Get Public API Ticker Pair    bitcoin
    Create Indodax Public API Session    ${API_BASE_URL}
    ${response}=    Get Ticker For Pair    ${pair}

    ${ticker_response}=    Verify Response Status Code OK    ${response}
    Verify Response Contains Key    ${ticker_response}    ticker
    ${ticker_data}=    Get From Dictionary    ${ticker_response}    ticker
    @{required_fields}=    Create List    buy    sell    high    low    last
    Verify Ticker Response Structure    ${ticker_data}    @{required_fields}
    Verify Ticker Values    ${ticker_data}
    Validate Ticker Response Schema    ${ticker_response}
```

**Private API — HMAC-SHA512 Signing:**

```robot
Private API - Authentication - Invalid API Key Should Fail
    [Tags]    authentication    negative_case    security
    [Documentation]    Verify API rejects invalid credentials (negative case)

    Create Indodax Private API Session    INVALID_KEY    INVALID_SECRET    ${PRIVATE_API_BASE_URL}
    ${response}=    Get Account Info With Invalid Credentials
    Should Be Equal As Numbers    ${response.status_code}    200
    ${body}=    Set Variable    ${response.json()}
    Should Be Equal    ${body['success']}    ${0}
```

---

### 2. Web Platform

**Stack:** Robot Framework + Browser Library (Playwright) + Python Page Objects

```robot
*** Settings ***
Resource    ../../resources/keywords/web/web_settings.robot

Test Tags    web    ui    market    usdtidr    indodax

Suite Setup    Initialize Web Test Environment
Test Setup        Open Test Browser
Test Teardown     Capture Screenshot On Failure And Close Browser

*** Test Cases ***

Web UI - Market Page Load
    [Tags]    smoke    market    positive_case    critical
    [Documentation]    Verify USDT/IDR market page loads successfully

    Verify Page Is Responsive
    Verify Page Title Contains Pair    ${MARKET_PAIR}

Web UI - Verify Order Book Data
    [Tags]    regression    orderbook    positive_case
    [Documentation]    Verify order book buy/sell data is visible and valid

    Verify Order Book Visible
    ${best_bid}=    Get Best Bid Price
    ${best_ask}=    Get Best Ask Price
    Should Be True    ${best_bid} < ${best_ask}
```

**Python Page Object (Playwright):**

```python
# resources/page_objects/web/indodax_usdtidr_market_page.py
from robotlibcore import keyword

class IndodaxUSDTIDRMarketPage:
    """Page Object for the USDT/IDR market trading page."""

    def __init__(self, browser):
        self.browser = browser

    @keyword
    def get_current_price(self) -> str:
        locator = self.locators.CURRENT_PRICE
        return self.browser.get_text(locator)

    @keyword
    def verify_page_is_responsive(self):
        self.browser.wait_for_elements_state(
            self.locators.MARKET_HEADER, "visible"
        )
```

---

### 3. Mobile — Android & iOS Platform

**Stack:** Robot Framework + AppiumLibrary 3.2.1 + Appium 2.x + Page Object (keywords + locators split)

| Layer | Android | iOS |
|---|---|---|
| Appium Driver | UIAutomator2 2.29.10 | XCUITest |
| Page Objects | `page_objects/mobile/android/` | `page_objects/mobile/ios/` (same structure) |
| App ID | `id.co.bitcoin.Bitcoin-Trading-Platform` | `id.co.bitcoin.Bitcoin-Trading-Platform` |

A single test file runs on both platforms. The correct page object folder (`android/` or `ios/`) is loaded at runtime via the `${PLATFORM}` variable. Keywords sharing the same name across `android/` and `ios/` are **intentional platform overrides** — `generate_dictionary.py` excludes these from the duplicate report.

```robot
*** Settings ***
Library    AppiumLibrary
Resource    ../../resources/keywords/mobile/mobile_settings.robot
Resource    ../../resources/keywords/mobile/mobile_test_data.robot
Resource    ../../resources/page_objects/mobile/android/home/home_keywords.robot
Resource    ../../resources/page_objects/mobile/android/market/market_keywords.robot
Resource    ../../resources/page_objects/mobile/android/trading/pro/trading_pro_keywords.robot

Test Tags    mobile    eth    search    positive_case    critical    regression

Suite Setup       Initialize Test Environment
Test Setup        Open Test App
Test Teardown     Capture Screenshot On Failure And Close App

*** Test Cases ***

Mobile - Search ETH From Home
    [Tags]    search    navigation    positive_case
    [Documentation]    Search for ETH pair from Home page
    ...    Acceptance Criteria:
    ...    - Search available, ETH/IDR pair found, trading page displays

    Load ETH Test Data
    Navigate To Home
    Handle Onboarding If Present
    Navigate To Market
    Search For Coin Pair    ${ETH_SEARCH_TERM}
    Select Search Result    ${ETH_PAIR_NAME}
    Verify Trading Page Displayed    ${ETH_PAIR_NAME}
```

**Mobile Page Object pattern — per-screen split (keywords + locators):**

```robot
# resources/page_objects/mobile/android/market/market_locators.robot
*** Variables ***
${SEARCH_INPUT}        xpath=//android.widget.EditText[@resource-id="id.co.bitcoin:id/search_input"]
${SEARCH_RESULT_ETH}   xpath=//android.widget.TextView[@text="ETH/IDR"]

# resources/page_objects/mobile/android/market/market_keywords.robot
*** Settings ***
Resource    market_locators.robot
Library     AppiumLibrary

*** Keywords ***
Search For Coin Pair
    [Arguments]    ${search_term}
    Wait Until Element Is Visible    ${SEARCH_INPUT}    timeout=${MOBILE_EXPLICIT_WAIT}
    Input Text    ${SEARCH_INPUT}    ${search_term}
```

**Platform keyword override — same keyword name, platform-specific locator:**

```robot
# resources/page_objects/mobile/android/market/market_keywords.robot
Search For Coin Pair
    [Arguments]    ${search_term}
    Input Text    ${ANDROID_SEARCH_INPUT}    ${search_term}

# resources/page_objects/mobile/ios/market/market_keywords.robot
Search For Coin Pair
    [Arguments]    ${search_term}
    Input Text    ${IOS_SEARCH_INPUT}    ${search_term}
```

**Appium capabilities — per platform (defined in YAML):**

```yaml
# mobile_production.yaml — Android
capabilities:
  platform_name: Android
  automation_name: UiAutomator2
  app_package: id.co.bitcoin.Bitcoin-Trading-Platform
  no_reset: false

# mobile_production.yaml — iOS (planned)
capabilities:
  platform_name: iOS
  automation_name: XCUITest
  bundle_id: id.co.bitcoin.Bitcoin-Trading-Platform
  no_reset: false
  auto_accept_alerts: true
```

---

## Tagging Strategy

### 5 Tag Dimensions per Test Case

Tags are not mutually exclusive — a single test case can carry tags from all dimensions simultaneously.

```
Dimension 1: Platform   → api  web  mobile
Dimension 2: Execution  → smoke  regression  skip
Dimension 3: Data Type  → positive_case  negative_case
Dimension 4: Priority   → critical  high  medium
Dimension 5: Feature    → ticker  orderbook  authentication  search  market
```

**Actual examples from the codebase:**

```robot
# Suite-level tags (inherited by all test cases in the file)
Test Tags    api    indodax    public    smoke

# Test-level tags (additive)
Public API - Get Bitcoin Ticker
    [Tags]    smoke    ticker    positive_case    critical

Private API - Authentication - Invalid API Key Should Fail
    [Tags]    authentication    negative_case    security

Web UI - Market Page Load
    [Tags]    smoke    market    positive_case    critical

Mobile - Search ETH From Home
    [Tags]    mobile    eth    search    positive_case    critical    regression
```

**`skip` tag — graceful exclusion for tests with external dependencies:**

```robot
Private API - Authentication - Valid Credentials Should Succeed
    [Tags]    authentication    positive_case    smoke    critical    skip
    [Documentation]    Tagged 'skip' — requires a live, unexpired INDODAX_API_KEY.
    ...    Remove the 'skip' tag once valid credentials are configured.
```

### Selective Execution Commands

```bash
# Smoke tests (all platforms)
robot --variable TEST_ENV:production --include smoke --exclude skip tests/

# API regression only
robot --variable TEST_ENV:production --include api --include regression tests/api/

# Mobile critical path
robot --variable TEST_ENV:production --include mobile --include critical tests/mobile/

# Negative / security tests only
robot --variable TEST_ENV:staging --include negative_case tests/api/

# Web debug (headless off)
robot --variable TEST_ENV:production --variable headless:false tests/web/
```

---

## Environment Strategy

### Hybrid Configuration: YAML + .env

| Layer | File | Contents | Git |
|---|---|---|---|
| **Non-secrets** | `config/environments/{env}.yaml` | Timeouts, retry policy, capability flags | ✅ Committed |
| **Secrets** | `.env.{env}` / `.env.mobile.{env}` | URLs, API keys, API secrets, device names | ❌ Gitignored |

### YAML Files

**`dev.yaml`** — short timeouts, SSL off:
```yaml
environment: dev
debug: true
api:
  timeout: 5
  verify_ssl: false
  max_retries: 3
  retry_delay: 2
timeouts:
  connect_timeout: 3
  browser_navigation_timeout: 60
```

**`production.yaml`** — longer timeouts, SSL on:
```yaml
environment: production
debug: false
api:
  timeout: 10
  verify_ssl: true
timeouts:
  connect_timeout: 5
  browser_navigation_timeout: 90
```

**`mobile_dev.yaml`** — extended timeouts for debugging:
```yaml
appium:
  new_command_timeout: 120
timeouts:
  app_wait_timeout: 20000    # ms
  implicit_wait: 10
  explicit_wait: 30
capabilities:
  no_reset: true             # keep app data between runs
  auto_grant_permissions: true
```

**`mobile_production.yaml`** — strict, clean state:
```yaml
appium:
  new_command_timeout: 60
timeouts:
  app_wait_timeout: 15000
  implicit_wait: 8
  explicit_wait: 20
capabilities:
  no_reset: false            # clean state on every run
  auto_grant_permissions: true
```

### ConfigManager

```python
# libraries/base/config_manager.py
class ConfigManager:
    """
    1. Load .env.{TEST_ENV}  → inject secrets into os.environ
    2. Load {env}.yaml       → resolve ${VAR:default} from os.environ
    3. Return config dict to the calling keyword
    """
    def get_environment_config(self, env_name: str) -> dict:
        self._load_env_file(f".env.{env_name}")
        return self._load_yaml(f"{env_name}.yaml")
```

**Usage in Robot Framework keywords:**

```robot
Initialize API Test Environment
    ${yaml_config}=    Get Environment Config    ${TEST_ENV}
    ${api_cfg}=        Get From Dictionary    ${yaml_config}    api
    ${api_timeout}=    Get From Dictionary    ${api_cfg}        timeout
    Set Suite Variable    ${API_TIMEOUT}    ${api_timeout}

    # Secret URL from .env (not from YAML)
    ${env_file}=      Get File    ${CURDIR}/../../../.env.${TEST_ENV}
    ${url_matches}=   Get Regexp Matches    ${env_file}    (?m)^API_BASE_URL=([^\n\r]+)    1
    ${api_base_url}=  Get From List    ${url_matches}    0
    Set Suite Variable    ${API_BASE_URL}    ${api_base_url}
```

### Environment Switching

```bash
robot tests/api/                                          # dev (default)
robot --variable TEST_ENV:staging tests/                  # staging
robot --variable TEST_ENV:production --exclude skip tests/ # production
robot --variable TEST_ENV:dev tests/mobile/               # mobile dev
robot --variable TEST_ENV:production tests/mobile/        # mobile production
```

---

## Test Execution Strategy

### 1. Smoke Testing

**Purpose:** Fast validation of critical functions on every push  
**Scope:** Tests tagged `smoke` + `critical`  
**Target duration:** < 5 minutes  
**Frequency:** Every commit / PR

```bash
robot --variable TEST_ENV:production --include smoke --exclude skip tests/
```

---

### 2. Regression Testing

**Purpose:** Ensure no existing functionality is broken  
**Scope:** All tests except `skip`  
**Target duration:** 15–30 minutes  
**Frequency:** Nightly / pre-release

```bash
robot --variable TEST_ENV:staging --exclude skip tests/
```

---

### 3. Selective Run

```bash
# Per platform
robot --variable TEST_ENV:production tests/api/
robot --variable TEST_ENV:production tests/web/
robot --variable TEST_ENV:production tests/mobile/

# Positive cases only
robot --variable TEST_ENV:production --include positive_case tests/

# Security / negative cases
robot --variable TEST_ENV:staging --include negative_case tests/api/

# Web debug (headless off)
robot --variable TEST_ENV:production --variable headless:false tests/web/

# Mobile with dev config
robot --variable TEST_ENV:dev tests/mobile/search_and_validate_eth.robot
```

---

### 4. CI/CD Execution — Two-Track Parallel

```
CI/CD
  ├── Track 1: ubuntu-latest VM
  │   ├── uv sync (install dependencies from pyproject.toml)
  │   ├── pabot --processes 4 tests/api/    (parallel API execution)
  │   └── robot tests/web/
  │
  └── Track 2: Self-Hosted Runner + Local Device Farm
      ├── uv sync
      ├── appium --port 4723 &
      ├── adb devices → Device ID (OS version)
      └── robot tests/mobile/
```

### 5. Parallel Execution with Pabot

`robotframework-pabot` enables parallel execution of independent test suites, reducing total runtime for API + Web regressions.

```bash
# Run API tests in parallel (4 processes)
pabot --processes 4 --variable TEST_ENV:staging tests/api/

# Run web tests (single-browser, sequential)
robot --variable TEST_ENV:production tests/web/
```

> ⚠️ Mobile tests are always sequential — one device per Appium session.

---

## Error Handling & Reporting

### 1. Screenshot on Failure

All platforms capture a screenshot only when a test fails — not on every step.

```robot
# Web
Test Teardown    Capture Screenshot On Failure And Close Browser

Capture Screenshot On Failure And Close Browser
    Run Keyword If Test Failed    Browser.Take Screenshot
    Close Browser    ALL

# Mobile
Test Teardown    Capture Screenshot On Failure And Close App

Capture Screenshot On Failure And Close App
    Run Keyword If Test Failed    AppiumLibrary.Capture Page Screenshot
    Run Keyword And Ignore Error  Close Application
```

### 2. API Retry Logic

Timeout and retry policy come from YAML — not hardcoded.

```robot
Call API With Retry
    [Arguments]    ${method}    ${endpoint}    ${max_retries}=${API_MAX_RETRIES}
    FOR    ${attempt}    IN RANGE    1    ${max_retries} + 1
        TRY
            ${response}=    ${method}    ${endpoint}    timeout=${API_TIMEOUT}
            RETURN    ${response}
        EXCEPT    *timeout*    type=GLOB
            Log    Attempt ${attempt}/${max_retries} timeout. Retrying...    WARN
            Sleep    ${API_RETRY_DELAY}s
        END
    END
    Fail    All ${max_retries} retry attempts failed for ${endpoint}
```

### 3. Mobile — Optional Dialog Handling

`Run Keyword And Ignore Error` handles onboarding dialogs that may or may not appear.

```robot
Handle Onboarding If Present
    Run Keyword And Ignore Error    Dismiss Onboarding Dialog
    Run Keyword And Ignore Error    Tap Skip Button
```

### 4. `skip` Tag — Graceful Exclusion

Tests flaky or fail or unavailable are tagged `skip` and excluded from regular runs without causing a failure.

```robot
Private API - Authentication - Valid Credentials Should Succeed
    [Tags]    authentication    positive_case    smoke    critical    skip
    [Setup]    Skip If No Valid Credentials
```

### 5. Reporting — Robot Framework Native

| File | Contents |
|---|---|
| `results/report.html` | PASS/FAIL per test, duration, tag breakdown |
| `results/log.html` | Full step log, variable values, screenshot links |
| `results/output.xml` | Machine-readable output for CI/CD integration |

---

## Summary

| Aspect | Actual Implementation |
|---|---|
| **Architecture** | 5-layer Clean Architecture (Tests → Keywords → Page Objects → Custom Libs → External Libs) |
| **Framework Core** | Robot Framework 7.4.1 / Python 3.13 / uv |
| **Web** | Browser Library (Playwright) 19.0.0+ |
| **API** | RequestsLibrary + JSONLibrary + HMAC-SHA512 |
| **Android** | AppiumLibrary 3.2.1 + UIAutomator2 — ✅ PASS |
| **iOS** | AppiumLibrary + XCUITest — ⏳ Pending (WDA code signing) |
| **Parallel** | robotframework-pabot 5.2.2 |
| **Config** | Hybrid: YAML (non-secret, committed) + .env (secret, gitignored) |
| **Test Data** | JSON files + JSON Schema validation (jsonschema 4.0+) |
| **Keyword Registry** | `dictionary/keyword_dictionary.robot` — 145 keywords, 0 duplicates |
| **Tagging** | 5 dimensions: platform · execution · data type · priority · feature |
| **Execution** | Smoke / Regression / Selective / CI/CD Two-Track |
| **Error Handling** | Screenshot on failure · YAML-driven retry · Graceful skip |
| **Reporting** | report.html · log.html · output.xml |

---

## Test Data Strategy

### Structure

All test data is stored as JSON files under `test_data/` and loaded at runtime — never hardcoded inside test cases or keyword files.

```
test_data/
├── api/
│   ├── base.json                     ← shared API metadata
│   ├── indodax_public_api.json       ← public endpoint test data
│   ├── indodax_private_api.json      ← private endpoint test data
│   └── schemas/                      ← JSON Schema validation files
│       ├── ticker_schema.json
│       ├── depth_schema.json
│       ├── trades_schema.json
│       ├── account_info_schema.json
│       ├── open_orders_schema.json
│       ├── trade_response_schema.json
│       └── error_schema.json
├── web/
│   └── indodax_usdtidr_market.json   ← market pairs + expected values
└── mobile/
    └── search_and_validate_eth.json  ← ETH search terms + expected results
```

### JSON Loading Pattern

Test data is loaded using `JSONLibrary` with JSONPath expressions. `Get Value From Json` always returns a **list** — use `[0]` to get the first match.

```robot
# resources/keywords/web/web_test_data.robot
Load Web Test Data
    ${raw_json}=    Get File    ${CURDIR}/../../../test_data/web/indodax_usdtidr_market.json
    ${WEB_TEST_DATA}=    Evaluate    json.loads($raw_json)    json
    Set Suite Variable    ${WEB_TEST_DATA}

Get Web Test Value
    [Arguments]    ${json_path}
    ${result}=    Get Value From Json    ${WEB_TEST_DATA}    ${json_path}
    RETURN    ${result}[0]
```

**Iterating multiple market pairs (JSON-driven FOR loop):**

```robot
Web UI - Market Search Functionality
    [Tags]    smoke    search    positive_case    critical
    ${market_pairs}=    Get From Dictionary    ${WEB_TEST_DATA}    market_pairs
    ${pair_ids}=    Get Dictionary Keys    ${market_pairs}    sort_keys=False
    FOR    ${pair_id}    IN    @{pair_ids}
        ${pair_data}=    Get From Dictionary    ${market_pairs}    ${pair_id}
        ${search_term}=    Get From Dictionary    ${pair_data}    search_term
        ${expected_result}=    Get From Dictionary    ${pair_data}    expected_result
        Search Market By Pair Name    ${search_term}
        Verify Search Result Contains Text    ${expected_result}
    END
```

### JSON Schema Validation

Schema files define the expected structure of API responses. Validation is performed using the `jsonschema` library — no custom `ApiSchemaValidator.py` exists; validation is done directly via the `Evaluate` keyword or a thin wrapper in `base_keywords.robot`.

```robot
Validate Ticker Response Schema
    [Arguments]    ${response_body}
    ${schema_path}=    Set Variable    ${CURDIR}/../../../test_data/api/schemas/ticker_schema.json
    ${schema_raw}=     Get File        ${schema_path}
    ${schema}=         Evaluate        json.loads($schema_raw)    json
    Evaluate    jsonschema.validate($response_body, $schema)    jsonschema
```

---

## Keyword Dictionary

### Overview

The keyword dictionary provides a centralized, searchable registry of all Robot Framework keywords defined across the entire project. It is **auto-generated** by a Python scanner script — never edited manually.

| File | Purpose |
|---|---|
| `dictionary/keyword_dictionary.robot` | Auto-generated RF resource with all 145 keywords |
| `dictionary/keyword_report.txt` | Duplicate detection report |
| `dictionary/generate_dictionary.py` | Scanner + duplicate detector script |

**Current state (as of v2.0):**

```
Total keywords : 145
Duplicates     : 0
```

### How It Works

`generate_dictionary.py` scans every `.robot` file in the project, extracts all `*** Keywords ***` definitions, and writes them into a single `keyword_dictionary.robot`. It also produces a `keyword_report.txt` flagging any duplicate names.

**Cross-platform keyword exclusion logic:**

Android and iOS page objects intentionally share the same keyword names (e.g., `Search For Coin Pair`) — this is by design, not a bug. The script detects this pattern and excludes these cross-platform pairs from the duplicate report:

```python
def is_mobile_android(path: str) -> bool:
    return "page_objects/mobile/android" in path

def is_mobile_ios(path: str) -> bool:
    return "page_objects/mobile/ios" in path

# In build_duplicate_map():
# If keyword A is in android/ and keyword B is in ios/ → intentional override, skip
```

### Regenerating the Dictionary

```bash
cd automation-framework
python dictionary/generate_dictionary.py
```

---

**Version History**

| Version | Date | Changes |
|---|---|---|
| 1.0 | Feb 2026 | Initial architecture design |
| 2.0 | Feb 2026 | Updated to reflect actual implementation: removed ApiSchemaValidator, added JSONLibrary / Pabot, corrected directory tree (mobile/android/ & ios/ structure), added mobile_test_data.robot, merged Android & iOS into single mobile section, added Test Data Strategy / Keyword Dictionary sections, runtime updated from venv to uv |

