*** Settings ***
Documentation    Keyword Dictionary — Auto-generated on 2026-02-25 14:30
...
...              ╔══════════════════════════════════════════════════════╗
...              ║  CMD+click keyword name di dalam body [Index] mana  ║
...              ║  pun → langsung lompat ke definisi di source file.  ║
...              ╚══════════════════════════════════════════════════════╝
...
...              Total keywords : 145  |  Duplicates : 0
...              Regenerate     : uv run python scripts/generate_dictionary.py

# ══════════════════════════════════════════════════════════
# API — 5 file(s), 78 keyword(s)
# ══════════════════════════════════════════════════════════
Resource    ../resources/keywords/api/api_settings.robot
Resource    ../resources/keywords/api/base_keywords.robot
Resource    ../resources/keywords/api/indodax_private_api.robot
Resource    ../resources/keywords/api/indodax_public_api.robot
Resource    ../resources/keywords/api/test_data_loader.robot

# ══════════════════════════════════════════════════════════
# Web — 3 file(s), 24 keyword(s)
# ══════════════════════════════════════════════════════════
Resource    ../resources/keywords/web/web_settings.robot
Resource    ../resources/keywords/web/web_test_data.robot
Resource    ../resources/page_objects/web/market/indodax_usdtidr_market_page_keywords.robot

# ══════════════════════════════════════════════════════════
# Mobile Android — 13 file(s), 43 keyword(s)
# ══════════════════════════════════════════════════════════
Resource    ../resources/keywords/mobile/mobile_settings.robot
Resource    ../resources/keywords/mobile/mobile_test_data.robot
Resource    ../resources/page_objects/mobile/android/account/account_keywords.robot
Resource    ../resources/page_objects/mobile/android/auth/login_keywords.robot
Resource    ../resources/page_objects/mobile/android/common/common_keywords.robot
Resource    ../resources/page_objects/mobile/android/home/home_keywords.robot
Resource    ../resources/page_objects/mobile/android/market/market_keywords.robot
Resource    ../resources/page_objects/mobile/android/onboarding/onboarding_keywords.robot
Resource    ../resources/page_objects/mobile/android/payment/deposit_keywords.robot
Resource    ../resources/page_objects/mobile/android/payment/withdraw_keywords.robot
Resource    ../resources/page_objects/mobile/android/portfolio/portfolio_keywords.robot
Resource    ../resources/page_objects/mobile/android/trading/lite/trading_lite_keywords.robot
Resource    ../resources/page_objects/mobile/android/trading/pro/trading_pro_keywords.robot


*** Keywords ***
# ──────────────────────────────────────────────────────────────────────────
# Cara pakai:
#   CMD+click pada nama keyword di dalam body [Index] mana pun
#   → RobotCode resolve reference secara statik & buka file + baris sumber.
#
#   [Index] keywords di bawah TIDAK untuk dieksekusi (tag: skip).
# ──────────────────────────────────────────────────────────────────────────

# ══════════════════════════════════════════════════════════
# API
# ══════════════════════════════════════════════════════════

[Index] api_settings.robot
    [Documentation]    api_settings.robot — 4 keywords
    [Tags]    index    norun    skip
    Initialize API Test Environment
    Cleanup API Test Environment
    Initialize Private API Test Environment
    Cleanup Private API Environment

[Index] base_keywords.robot
    [Documentation]    base_keywords.robot — 23 keywords
    [Tags]    index    norun    skip
    Extract JSON From Response
    Verify Response Contains Key
    Should Contain Key
    Verify Response Status Code
    Verify Response Status Code OK
    Verify Response Status Code Created
    Verify Response Status Code Bad Request
    Verify Response Status Code Unauthorized
    Verify Response Status Code Forbidden
    Verify Response Status Code Not Found
    Verify Response Status Code Server Error
    Create Indodax Public API Session
    Create Indodax Private API Session
    Close API Session
    Validate Ticker Response Schema
    Validate Depth Response Schema
    Validate Trades Response Schema
    Validate Error Response Schema
    Validate Trade Order Response Schema
    Validate Account Info Response Schema
    Validate Open Orders Response Schema
    Validate Response Using Endpoint Config
    Validate Error Response Using Config

[Index] indodax_private_api.robot
    [Documentation]    indodax_private_api.robot — 14 keywords
    [Tags]    index    norun    skip
    Setup Private API Signing
    Skip If No Valid Credentials
    Setup Dummy Signer For Testing
    Place Buy Order
    Place Sell Order
    Verify Order Response
    Verify Order Is Created
    Get Account Info
    Get Account Balance
    Cancel Order
    Get Open Orders
    Get Order History
    Log Request Details
    Log Response Details

[Index] indodax_public_api.robot
    [Documentation]    indodax_public_api.robot — 5 keywords
    [Tags]    index    norun    skip
    Get Ticker For Pair
    Verify Ticker Response Structure
    Verify Ticker Values
    Get Depth For Pair
    Get Trades For Pair

[Index] test_data_loader.robot
    [Documentation]    test_data_loader.robot — 32 keywords
    [Tags]    index    norun    skip
    Load Test Data
    Get Base Data
    Get Public API Data
    Get Private API Data
    Get Trading Pairs
    Get Trading Pair
    Get Trading Pair Id
    Get Public API Ticker Test Data
    Get Public API Ticker Pair
    Get Public API Depth Test Data
    Get Public API Depth Pair
    Get Public API Trades Test Data
    Get Public API Trades Pair
    Get Public API Negative Test Data
    Get Public API Negative Pair
    Get Private API Authentication Data
    Get Private API Buy Order Test Data
    Get Private API Sell Order Test Data
    Get Private API Buy Order Pair
    Get Private API Sell Order Pair
    Get Private API Order Validation Test Data
    Get Private API Validation Pair
    Get Private API Order Management Data
    Get Private API Management Pair
    Get Private API Account Test Data
    Get Private API Data Driven Scenarios
    Get Private API Data Driven Scenario Pair
    Get Response Validation Config
    Get Expected Status Code For Endpoint
    Get HTTP Status Code
    Get Error Scenario Config
    Validate Response Against Config

# ══════════════════════════════════════════════════════════
# Web
# ══════════════════════════════════════════════════════════

[Index] web_settings.robot
    [Documentation]    web_settings.robot — 4 keywords
    [Tags]    index    norun    skip
    Initialize Web Test Environment
    Cleanup Web Test Environment
    Open Test Browser
    Capture Screenshot On Failure And Close Browser

[Index] web_test_data.robot
    [Documentation]    web_test_data.robot — 2 keywords
    [Tags]    index    norun    skip
    Load Web Test Data
    Get Market Data For Pair

[Index] indodax_usdtidr_market_page_keywords.robot
    [Documentation]    indodax_usdtidr_market_page_keywords.robot — 18 keywords
    [Tags]    index    norun    skip
    Wait For Page Load
    Get Current Price
    Get Price Change 24h
    Get Volume 24h
    Get Bid Price
    Get Ask Price
    Verify Market Data Available
    Get Trading Pair Header
    Verify Page Title Contains Pair
    Wait For Price Updates
    Get Market Data Dictionary
    Verify Price Is Positive
    Screenshot Market Page
    Scroll To Market Data
    Navigate To Market Page
    Verify Page Is Responsive
    Search Market By Pair Name
    Verify Search Result Contains Text

# ══════════════════════════════════════════════════════════
# Mobile Android
# ══════════════════════════════════════════════════════════

[Index] mobile_settings.robot
    [Documentation]    mobile_settings.robot — 9 keywords
    [Tags]    index    norun    skip
    Load Mobile Environment Variables
    Initialize Test Environment
    Open Indodax App
    Load IOS Environment Variables
    Initialize IOS Test Environment
    Open Indodax IOS App
    Open Test App
    Safe Capture Screenshot On Failure
    Capture Screenshot On Failure And Close App

[Index] mobile_test_data.robot
    [Documentation]    mobile_test_data.robot — 1 keyword
    [Tags]    index    norun    skip
    Load ETH Test Data

[Index] account_keywords.robot
    [Documentation]    account_keywords.robot — 3 keywords
    [Tags]    index    norun    skip
    Navigate To Account
    Switch To PRO Mode
    Switch To LITE Mode

[Index] login_keywords.robot
    [Documentation]    login_keywords.robot — 4 keywords
    [Tags]    index    norun    skip
    Navigate To Login
    Navigate To Register
    Login With Credentials
    Logout From App

[Index] common_keywords.robot
    [Documentation]    common_keywords.robot — 3 keywords
    [Tags]    index    norun    skip
    Close Indodax App If Open
    Start Mobile Test Execution
    End Mobile Test Execution

[Index] home_keywords.robot
    [Documentation]    home_keywords.robot — 1 keyword
    [Tags]    index    norun    skip
    Click Home Button Safely

[Index] market_keywords.robot
    [Documentation]    market_keywords.robot — 4 keywords
    [Tags]    index    norun    skip
    Navigate To Market
    Click Market Menu
    Search For Cryptocurrency
    Click ETH IDR Result

[Index] onboarding_keywords.robot
    [Documentation]    onboarding_keywords.robot — 2 keywords
    [Tags]    index    norun    skip
    Handle Learn More Modal
    Skip Onboarding If Present

[Index] deposit_keywords.robot
    [Documentation]    deposit_keywords.robot — 3 keywords
    [Tags]    index    norun    skip
    Navigate To Deposit
    Deposit IDR Via Virtual Account
    Get Deposit Address For Crypto

[Index] withdraw_keywords.robot
    [Documentation]    withdraw_keywords.robot — 3 keywords
    [Tags]    index    norun    skip
    Navigate To Withdraw
    Withdraw IDR
    Withdraw Crypto

[Index] portfolio_keywords.robot
    [Documentation]    portfolio_keywords.robot — 4 keywords
    [Tags]    index    norun    skip
    Navigate To Portfolio
    Get Total Balance
    View Open Orders
    View Transaction History

[Index] trading_lite_keywords.robot
    [Documentation]    trading_lite_keywords.robot — 4 keywords
    [Tags]    index    norun    skip
    Wait For LITE Trading Page Load
    Buy Asset In LITE Mode
    Sell Asset In LITE Mode
    Verify Transaction Success In LITE Mode

[Index] trading_pro_keywords.robot
    [Documentation]    trading_pro_keywords.robot — 2 keywords
    [Tags]    index    norun    skip
    Wait For ETH Page Load
    Validate ETH Page Is Displayed
