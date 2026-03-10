*** Settings ***
Documentation    Keyword Dictionary — Auto-generated on 2026-03-03 11:58
...
...              ╔══════════════════════════════════════════════════════╗
...              ║  CMD+click keyword name di dalam body [Index] mana  ║
...              ║  pun → langsung lompat ke definisi di source file.  ║
...              ╚══════════════════════════════════════════════════════╝
...
...              Total keywords : 224  |  Duplicates : 0
...              Regenerate     : uv run python scripts/generate_dictionary.py

# ══════════════════════════════════════════════════════════
# API — 5 file(s), 126 keyword(s)
# ══════════════════════════════════════════════════════════
Resource    ../resources/keywords/api/api_settings.robot
Resource    ../resources/keywords/api/base_keywords.robot
Resource    ../resources/keywords/api/indodax_private_api.robot
Resource    ../resources/keywords/api/indodax_public_api.robot
Resource    ../resources/keywords/api/test_data_loader.robot

# ══════════════════════════════════════════════════════════
# Web — 3 file(s), 48 keyword(s)
# ══════════════════════════════════════════════════════════
Resource    ../resources/keywords/web/web_settings.robot
Resource    ../resources/keywords/web/web_test_data.robot
Resource    ../resources/page_objects/web/market/indodax_usdtidr_market_page_keywords.robot

# ══════════════════════════════════════════════════════════
# Mobile Android — 13 file(s), 50 keyword(s)
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
    [Documentation]    base_keywords.robot — 26 keywords
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
    The Response Should Be 200 OK
    The Response Should Contain An Error Field
    The Response Should Be A Valid Dictionary

[Index] indodax_private_api.robot
    [Documentation]    indodax_private_api.robot — 40 keywords
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
    The Private API Session Is Initialized With Valid Credentials
    The Private API Session Is Initialized With Invalid Credentials
    The Private API Session Is Initialized With Dummy Credentials
    The "${order_id}" Buy Order Data Is Loaded From Test Data
    The "${order_id}" Sell Order Data Is Loaded From Test Data
    The "${validation_type}" Order Validation Data Is Loaded
    The "${operation_type}" Management Data Is Loaded
    The Test Uses The "${operation_type}" Management Pair
    The User Requests Their Account Information
    The User Requests Their Account Balance
    The User Places A Buy Order For The Resolved Pair
    The User Places A Sell Order For The Resolved Pair
    The User Requests All Open Orders
    The User Requests Open Orders For The Resolved Pair
    The User Cancels The Order
    The User Requests Order History
    The User Runs Data-Driven Order Tests For All Configured Scenarios
    The Account Response Should Contain Account Data
    The Account Info Should Match The Expected Schema
    The Balance Response Should Contain Balance Data
    The Order Should Be Confirmed As A "${order_type}" Order For The Resolved Pair
    The Validation Error Response Should Not Be Empty
    The Open Orders Response Should Contain Order List Data
    The Cancel Response Should Not Be Empty
    The Order History Response Should Contain History Data
    All Data-Driven Order Tests Should Complete Successfully

[Index] indodax_public_api.robot
    [Documentation]    indodax_public_api.robot — 24 keywords
    [Tags]    index    norun    skip
    Get Ticker For Pair
    Verify Ticker Response Structure
    Verify Ticker Values
    Get Depth For Pair
    Get Trades For Pair
    The Public API Session Is Initialized
    The Test Uses The "${test_id}" Ticker Pair
    The Test Uses The BTC/IDR Trading Pair Directly
    The Test Uses The "${test_id}" Depth Pair
    The Test Uses The "${test_id}" Trades Pair
    The Test Uses The "${test_id}" Negative Pair
    The User Requests The Ticker For The Resolved Pair
    The User Requests The Order Book Depth For The Resolved Pair
    The User Requests Recent Trades For The Resolved Pair
    The Response Should Contain A Ticker Field
    The Ticker Should Have All Required Price Fields
    All Ticker Price Values Should Be Valid
    The Ticker Response Should Match The Schema
    The Ticker Response Should Not Be Empty
    The Error Message Should Be "${expected_msg}"
    The Error Response Should Match The Schema
    The Depth Response Should Contain Order Book Data Or An API Restriction Message
    The Trades Response Should Not Be Empty
    The Trades Response Should Match The Schema

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
    [Documentation]    indodax_usdtidr_market_page_keywords.robot — 42 keywords
    [Tags]    index    norun    skip
    Wait For Page Load
    Get Current Price
    Get Price Change 24h
    Get Volume 24h
    Get Bid Price
    Get Ask Price
    Get Trading Pair Header
    Verify Page Title Contains Pair
    Wait For Price Updates
    Verify Price Is Positive
    Screenshot Market Page
    Scroll To Market Data
    Navigate To Market Page
    Verify Page Is Responsive
    Search Market By Pair Name
    Verify Search Result Contains Text
    Collect Live Market Snapshot
    The USDT/IDR Market Page Is Open
    The Page Has Fully Loaded
    The Page Title Should Contain The Expected Pair Name
    The Market Page Should Be Responsive
    The Current Price Should Be Visible
    The 24-Hour Price Change Should Be Visible
    The 24-Hour Volume Should Be Visible
    The Current Price Should Be A Positive Value
    The Trading Pair Header Should Not Be Empty
    The Trading Pair Header Should Display USDT
    The User Collects Live Market Data From The Page
    The Snapshot Should Contain Price Information
    The Snapshot Should Contain Volume Information
    The Snapshot Should Contain Order Book Information
    The Price Change Value Should Not Be Empty
    The Volume Value Should Not Be Empty
    The Bid Price Should Be Visible In The Order Book
    The Ask Price Should Be Visible In The Order Book
    The Market Data Section Is Scrolled Into View
    A Screenshot Of The Market Page Should Be Captured
    The Page Should Be Responsive And Interactive
    The Page Should Be Ready For Price Updates
    The Market Pairs Are Defined In Test Data
    The User Searches For Each Market Pair By Currency Name
    All Search Results Should Display The Expected Trading Pairs

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
    [Documentation]    market_keywords.robot — 9 keywords
    [Tags]    index    norun    skip
    Navigate To Market
    Click Market Menu
    Search For Cryptocurrency
    Click ETH IDR Result
    The App Is On The Market Page
    The Search Functionality Is Available
    The User Searches For The Configured Cryptocurrency
    The Expected Pair Should Appear In The Search Results
    The User Selects The ETH/IDR Result

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
    [Documentation]    trading_pro_keywords.robot — 4 keywords
    [Tags]    index    norun    skip
    Wait For ETH Page Load
    Validate ETH Page Is Displayed
    The ETH/IDR Trading Page Should Be Fully Loaded
    The ETH/IDR Trading Page Should Display Correctly
