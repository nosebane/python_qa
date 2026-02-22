*** Settings ***
Documentation    Search for ETH pair and validate ETH/IDR page
...             Test flow:
...             - Click Home button
...             - Skip onboarding
...             - Click Market menu
...             - Skip onboarding (if appears)
...             - Search for 'ETH'
...             - Click "ETH/IDR" on search result
...             - Validate ETH page shows up
...             
...             Run with different environments:
...             robot -v TEST_ENV:dev tests/mobile/android/base/search_and_validate_eth.robot
...             robot -v TEST_ENV:staging tests/mobile/android/base/search_and_validate_eth.robot
...             robot -v TEST_ENV:production tests/mobile/android/base/search_and_validate_eth.robot

Library    AppiumLibrary

Resource    ../../../../resources/keywords/mobile/mobile_settings.robot
Resource    ../../../../resources/page_objects/mobile/common/common_keywords.robot
Resource    ../../../../resources/page_objects/mobile/home/home_keywords.robot
Resource    ../../../../resources/page_objects/mobile/onboarding/onboarding_keywords.robot
Resource    ../../../../resources/page_objects/mobile/market/market_keywords.robot
Resource    ../../../../resources/page_objects/mobile/trading/pro/trading_pro_keywords.robot

Suite Setup       Initialize Test Environment
Suite Teardown    Close Indodax App If Open
Test Setup        Open Test App
Test Teardown     Capture Screenshot On Failure And Close App

Test Tags    mobile    eth    search    positive_case    critical    regression


*** Variables ***
${TEST_ENV}=               production
${DEFAULT_WAIT}=           5
${IMPLICIT_WAIT}=          10


*** Test Cases ***

Mobile - Search ETH From Home
    [Tags]    search    navigation    positive_case
    [Documentation]    Search for ETH pair from Home page
    ...
    ...    Acceptance Criteria:
    ...    - Search available
    ...    - ETH/IDR pair found
    ...    - Trading page displays
    
    # Navigate to Market page
    Navigate To Market
    
    Capture Page Screenshot    filename=m03_after_onboarding.png
    
    # Wait for search functionality to be available
    Wait Until Page Contains Element    ${SEARCH_CONTAINER}    timeout=10s
    Capture Page Screenshot    filename=m03b_after_market_click.png
    Search For Cryptocurrency    ETH
    Log    ✓ Search for ETH completed    INFO
    Wait Until Page Contains    ETH/IDR    timeout=10s
    Capture Page Screenshot    filename=m04_search_results.png
    
    # Step 5: Click ETH result and validate trading page
    Click ETH IDR Result
    Log    ✓ ETH result clicked    INFO
    Wait For ETH Page Load
    Capture Page Screenshot    filename=m05_eth_trading_page.png
    
    # Step 6: Validate ETH trading page
    Wait For ETH Page Load
    Validate ETH Page Is Displayed
    
    Log    ✓ ETH search from Home completed successfully    INFO

