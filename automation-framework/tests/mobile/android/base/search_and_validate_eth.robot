*** Settings ***
Documentation       Search for ETH pair and validate ETH/IDR page
...                 Test flow:
...                 - Click Home button
...                 - Skip onboarding
...                 - Click Market menu
...                 - Skip onboarding (if appears)
...                 - Search for 'ETH'
...                 - Click "ETH/IDR" on search result
...                 - Validate ETH page shows up
...
...                 Run with different environments:
...                 robot -v TEST_ENV:dev tests/mobile/android/base/search_and_validate_eth.robot
...                 robot -v TEST_ENV:staging tests/mobile/android/base/search_and_validate_eth.robot
...                 robot -v TEST_ENV:production tests/mobile/android/base/search_and_validate_eth.robot

Resource            ../../../../resources/keywords/mobile/mobile_settings.robot
Resource            ../../../../resources/keywords/mobile/mobile_test_data.robot
Resource            ../../../../resources/page_objects/mobile/android/common/common_keywords.robot
Resource            ../../../../resources/page_objects/mobile/android/home/home_keywords.robot
Resource            ../../../../resources/page_objects/mobile/android/onboarding/onboarding_keywords.robot
Resource            ../../../../resources/page_objects/mobile/android/market/market_keywords.robot
Resource            ../../../../resources/page_objects/mobile/android/trading/pro/trading_pro_keywords.robot

Suite Setup         Run Keywords    Initialize Test Environment    AND    Load ETH Test Data
Suite Teardown      Close Indodax App If Open
Test Setup          Open Test App
Test Teardown       Capture Screenshot On Failure And Close App

Test Tags           mobile    eth    search    positive_case    critical    regression


*** Test Cases ***
Mobile - Search ETH From Home
    [Documentation]    Search for ETH pair from Home page
    ...
    ...    Acceptance Criteria:
    ...    - Search available
    ...    - ETH/IDR pair found
    ...    - Trading page displays
    [Tags]    search    navigation    positive_case

    # Navigate to Market page
    Navigate To Market

    Capture Page Screenshot    filename=${SCREENSHOT_ONBOARDING}

    # Wait for search functionality to be available
    Wait Until Page Contains Element    ${SEARCH_CONTAINER}    timeout=10s
    Capture Page Screenshot    filename=${SCREENSHOT_MARKET_CLICK}
    Search For Cryptocurrency    ${SEARCH_TERM}
    Log    ✓ Search for ${SEARCH_TERM} completed    INFO
    Wait Until Page Contains    ${EXPECTED_PAIR}    timeout=${SEARCH_RESULT_TIMEOUT}
    Capture Page Screenshot    filename=${SCREENSHOT_SEARCH_RESULTS}

    # Step 5: Click ETH result and validate trading page
    Click ETH IDR Result
    Log    ✓ ${EXPECTED_PAIR} result clicked    INFO
    Wait For ETH Page Load
    Capture Page Screenshot    filename=${SCREENSHOT_TRADING_PAGE}

    # Step 6: Validate ETH trading page
    Wait For ETH Page Load
    Validate ETH Page Is Displayed

    Log    ✓ ${SEARCH_TERM} search from Home completed successfully    INFO
