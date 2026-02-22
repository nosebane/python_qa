# Automation Test Framework Architecture Design

**Version:** 1.0  
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

---

## Executive Summary

This document describes the actual implementation of the automation testing framework for **Indodax**, covering API, Web, and Mobile (Android). Verified at **22/22 tests PASS** (10 API + 11 Web + 1 Mobile).

| Component | Technology |
|---|---|
| Core Orchestrator | Robot Framework 7.x |
| Web Automation | Browser Library (Playwright) |
| API Testing | RequestsLibrary + Custom Libraries |
| Mobile Automation | AppiumLibrary (Appium) |
| Config Management | ConfigManager (Hybrid YAML + .env) |
| Request Signing | IndodaxSignerLibrary (HMAC-SHA512) |
| Validation | ApiSchemaValidator, ResponseValidator |
| Runtime | Python 3.13.3 / venv |

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
│  resources/keywords/mobile/— mobile_settings            │
└──────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────┐
│                  ABSTRACTION LAYER                       │
│  resources/page_objects/web/   — BasePage, MarketPage   │
│  resources/page_objects/mobile/— per-screen keywords    │
│                                  + locator files        │
└──────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────┐
│             CUSTOM PYTHON LIBRARIES LAYER               │
│  libraries/base/config_manager.py                       │
│  libraries/api/IndodaxSignerLibrary.py  (HMAC-SHA512)   │
│  libraries/api/ApiSchemaValidator.py                    │
│  libraries/api/ResponseValidator.py                     │
└──────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────┐
│               EXTERNAL LIBRARIES & SUT                  │
│  RequestsLibrary → indodax.com/api/  &  /tapi           │
│  Browser (Playwright) → indodax.com                     │
│  AppiumLibrary → id.co.bitcoin (Android)                │
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
ApiSchemaValidator.py      → JSON schema validation only
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
│   │   ├── indodax_public_api.robot      (7 test cases)
│   │   └── indodax_private_api.robot     (3 test cases)
│   ├── web/
│   │   └── indodax_usdtidr_market.robot  (11 test cases)
│   └── mobile/(Android & IOS)
│       └── search_and_validate_eth.robot (1 test case — Android)
│
├── resources/
│   ├── keywords/
│   │   ├── api/
│   │   │   ├── api_settings.robot        (suite setup/teardown)
│   │   │   ├── base_keywords.robot       (generic HTTP keywords)
│   │   │   ├── indodax_public_api.robot  (public endpoint keywords)
│   │   │   ├── indodax_private_api.robot (private/HMAC keywords)
│   │   │   └── test_data_loader.robot    (JSON loader)
│   │   ├── web/
│   │   │   ├── web_settings.robot        (suite setup/teardown)
│   │   │   └── web_test_data.robot       (JSON loader)
│   │   └── mobile/
│   │       └── mobile_settings.robot     (suite setup/teardown)
│   │
│   └── page_objects/
│       ├── web/
│       │   ├── base_page.py
│       │   ├── indodax_usdtidr_market_page.py
│       │   └── market/
│       │       ├── indodax_usdtidr_market_page_keywords.robot
│       │       └── indodax_usdtidr_market_page_locators.robot
│       └── mobile/                        (per-screen split: keywords + locators)
│           ├── common/common_keywords.robot
│           ├── auth/         login_keywords.robot  · login_locators.robot
│           ├── home/         home_keywords.robot   · home_locators.robot
│           ├── market/       market_keywords.robot · market_locators.robot
│           ├── trading/
│           │   ├── lite/     trading_lite_keywords.robot · trading_lite_locators.robot
│           │   └── pro/      trading_pro_keywords.robot
│           ├── onboarding/   onboarding_keywords.robot · onboarding_locators.robot
│           ├── portfolio/    portfolio_keywords.robot · portfolio_locators.robot
│           ├── account/      account_keywords.robot · account_locators.robot
│           └── payment/
│               ├── deposit/  deposit_keywords.robot · deposit_locators.robot
│               └── withdraw/ withdraw_keywords.robot · withdraw_locators.robot
│
├── libraries/
│   ├── base/config_manager.py            (Hybrid YAML+.env loader)
│   └── api/
│       ├── IndodaxSignerLibrary.py       (HMAC-SHA512 signing)
│       ├── indodax_signer.py             (core signing logic)
│       ├── ApiSchemaValidator.py         (JSON schema validation)
│       └── ResponseValidator.py          (HTTP status validation)
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
│   │   ├── indodax_public_api.json
│   │   ├── indodax_private_api.json
│   │   └── schemas/                      (JSON Schema files)
│   └── web/
│       └── indodax_usdtidr_market.json
│
└── results/                              (robot output — gitignored)
    ├── report.html
    ├── log.html
    └── output.xml
```

### 1. API Platform

**Stack:** Robot Framework + RequestsLibrary + IndodaxSignerLibrary (HMAC-SHA512) + ApiSchemaValidator

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

### 3. Mobile — Android Platform

**Stack:** Robot Framework + AppiumLibrary + Page Object (keywords + locators split)

```robot
*** Settings ***
Library    AppiumLibrary
Resource    ../../resources/keywords/mobile/mobile_settings.robot
Resource    ../../resources/page_objects/mobile/home/home_keywords.robot
Resource    ../../resources/page_objects/mobile/market/market_keywords.robot
Resource    ../../resources/page_objects/mobile/trading/pro/trading_pro_keywords.robot

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

    Navigate To Home
    Handle Onboarding If Present
    Navigate To Market
    Search For Coin Pair    ETH
    Select Search Result    ETH/IDR
    Verify Trading Page Displayed    ETH
```

**Mobile Page Object pattern (locators different with keywords):**

```robot
# resources/page_objects/mobile/market/market_locators.robot
*** Variables ***
${SEARCH_INPUT}        xpath=//android.widget.EditText[@resource-id="id.co.bitcoin:id/search_input"]
${SEARCH_RESULT_ETH}   xpath=//android.widget.TextView[@text="ETH/IDR"]

# resources/page_objects/mobile/market/market_keywords.robot
*** Settings ***
Resource    market_locators.robot
Library    AppiumLibrary

*** Keywords ***
Search For Coin Pair
    [Arguments]    ${search_term}
    Wait Until Element Is Visible    ${SEARCH_INPUT}    timeout=${MOBILE_EXPLICIT_WAIT}
    Input Text    ${SEARCH_INPUT}    ${search_term}
```

---

### 4. Mobile — iOS Platform (Planned)

Same stack as Android (AppiumLibrary) with XCUITest driver and iOS-specific locators.

**Planned YAML config (`mobile_production_ios.yaml`):**

```yaml
appium:
  new_command_timeout: 60
capabilities:
  platform_name: iOS
  automation_name: XCUITest
  bundle_id: id.co.bitcoin
  no_reset: false
  auto_accept_alerts: true
```

> **Current status:** Android (ASUS AI2302, Android 15) — PASS.  
> iOS config and directory structure are ready; awaiting device availability.

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

**Current coverage:**
- API: Public ticker (Bitcoin, Ethereum), order book, trades — 5 test cases
- Web: Market page load, market data — 2 test cases
- Mobile: Search ETH — 1 test case

---

### 2. Regression Testing

**Purpose:** Ensure no existing functionality is broken  
**Scope:** All tests except `skip`  
**Target duration:** 15–30 minutes  
**Frequency:** Nightly / pre-release

```bash
robot --variable TEST_ENV:staging --exclude skip tests/
```

**Current coverage (22 test cases):**
- API Public: 7 test cases (ticker, order book, trades, server time, summaries)
- API Private: 3 test cases (invalid auth, order history, trade history)
- Web: 11 test cases (page load, market data, order book, price chart, trading interface)
- Mobile: 1 test case (ETH search & validate)

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
  │   ├── pip install -r requirements.txt
  │   ├── robot tests/api/    
  │   └── robot tests/web/    
  │
  └── Track 2: Self-Hosted Runner + Local Device Farm
      ├── pip install -r requirements.txt
      ├── appium --port 4723 &
      ├── adb devices → Device ID (OS version)
      └── robot tests/mobile/ 
```

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
| **Framework Core** | Robot Framework 7.x / Python 3.13.3 |
| **Web** | Browser Library (Playwright)  |
| **API** | RequestsLibrary + HMAC-SHA512  |
| **Android** | AppiumLibrary  |
| **iOS** | AppiumLibrary  |
| **Config** | Hybrid: YAML (non-secret, committed) + .env (secret, gitignored) |
| **Tagging** | 5 dimensions: platform · execution · data type · priority · feature |
| **Execution** | Smoke / Regression / Selective / CI/CD Two-Track |
| **Error Handling** | Screenshot on failure · YAML-driven retry · Graceful skip |
| **Reporting** | report.html · log.html · output.xml |

---

**Version History**

| Version | Date | Changes |
|---|---|---|
| 1.0 | Feb 2026 | Initial architecture design |

