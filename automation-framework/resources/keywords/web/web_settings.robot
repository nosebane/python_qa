*** Settings ***
Documentation    Shared Web Test Settings and Configuration
...             Common libraries, resources, and setup/teardown for all web tests

Library    Browser
Library    Collections
Library    String
Library    OperatingSystem
Library    ${CURDIR}/../../../libraries/base/config_manager.py    WITH NAME    ConfigManager

Resource    ../../page_objects/web/market/indodax_usdtidr_market_page_keywords.robot
Resource    ./web_test_data.robot


*** Keywords ***

Initialize Web Test Environment
    [Documentation]    Setup for web tests using hybrid .env + YAML approach
    ...    
    ...    Loads:
    ...    - YAML env config → BROWSER_NAV_TIMEOUT (timeouts.browser_navigation_timeout)
    ...    - WEB_BASE_URL from .env.${TEST_ENV}
    ...    - Test data from resources/test_data/web/indodax_market.json
    ...    - Browser configuration
    ...    
    ...    Can override headless via: robot --variable headless:false
    
    # Determine environment (default: dev)
    # TEST_ENV can be set via: robot --variable TEST_ENV:prod
    ${env_name}=    Set Variable    ${TEST_ENV}
    Set Suite Variable    ${TEST_ENV}    ${env_name}
    
    # Read WEB_BASE_URL from .env file — anchored regex prevents matching commented lines
    ${env_file}=    Get File    ${CURDIR}/../../../.env.${env_name}
    ${web_url_list}=    Get Regexp Matches    ${env_file}    (?m)^WEB_BASE_URL=([^\n\r]+)    1
    ${web_base_url}=    Get From List    ${web_url_list}    0
    ${web_base_url}=    Strip String    ${web_base_url}
    Set Suite Variable    ${WEB_BASE_URL}    ${web_base_url}
    
    # Load test data from JSON file
    Load Web Test Data    ${MARKET_PAIR}
    
    # Load YAML environment config — extract browser navigation timeout per environment
    ${yaml_config}=     Get Environment Config    ${TEST_ENV}
    ${timeout_cfg}=     Get From Dictionary    ${yaml_config}    timeouts
    ${nav_timeout}=     Get From Dictionary    ${timeout_cfg}    browser_navigation_timeout
    Set Suite Variable    ${BROWSER_NAV_TIMEOUT}    ${nav_timeout}
    Log    ✓ YAML config loaded — browser_nav_timeout=${nav_timeout}s    INFO

    # Set global Playwright navigation timeout per-environment from YAML
    Browser.Set Browser Timeout    ${BROWSER_NAV_TIMEOUT}s
    
    Log    Environment: ${TEST_ENV}    INFO
    Log    Base URL: ${WEB_BASE_URL}    INFO
    Log    Market Pair: ${MARKET_PAIR}    INFO
    Log    Headless Mode: ${headless}    INFO
    Log    Config loaded from: .env.${TEST_ENV}    INFO
    Log    Test data loaded from: test_data/web/indodax_usdtidr_market.json    INFO


Cleanup Web Test Environment
    [Documentation]    Cleanup after web tests
    ...    Close all browsers and clear browser state
    ...    Uses TRY/EXCEPT to safely handle case where browser was already closed by Test Teardown

    Log    Cleaning up web test environment    INFO

    TRY
        Close Browser
    EXCEPT
        Log    Browser already closed (closed by Test Teardown)    DEBUG
    END

    Log    Web test environment cleaned up    INFO


Open Test Browser
    [Documentation]    Open browser and navigate to market page for the current test.
    ...    Called via Test Setup — provides a fresh browser+page per test case.
    ...    Reuses ${headless}, ${WEB_BASE_URL} and ${MARKET_PAIR} suite variables.

    New Browser    chromium    headless=${headless}
    New Page
    Navigate To Market Page    ${WEB_BASE_URL}    ${MARKET_PAIR}
    Wait For Page Load    ${MARKET_PAIR}


Capture Screenshot On Failure And Close Browser
    [Documentation]    Test Teardown: capture screenshot on failure, then close browser.
    ...    Ensures browser resources are always released after each test.

    Run Keyword If Test Failed    Take Screenshot    failure_screenshot
    TRY
        Close Browser
    EXCEPT
        Log    Browser already closed    DEBUG
    END