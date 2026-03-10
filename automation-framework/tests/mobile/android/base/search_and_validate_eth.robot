*** Settings ***
Documentation       Search for ETH pair and validate ETH/IDR trading page
...                 Feature: Market Search and Navigation — Android
...                 Tests search flow in BDD (Gherkin) style:
...                 - Navigate to Market page
...                 - Search for 'ETH'
...                 - Click "ETH/IDR" on search result
...                 - Validate ETH/IDR trading page is displayed
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
    [Documentation]    Scenario: User searches for ETH from the Market page and opens the trading pair
    ...
    ...    Criteria:
    ...    - Market page is reachable and search is available
    ...    - ETH/IDR pair appears in search results
    ...    - ETH/IDR trading page loads and displays correctly
    [Tags]    search    navigation    positive_case

    Given the app is on the market page
    And the search functionality is available
    When the user searches for the configured cryptocurrency
    Then the expected pair should appear in the search results
    When the user selects the ETH/IDR result
    Then the ETH/IDR trading page should be fully loaded
    And the ETH/IDR trading page should display correctly
