*** Settings ***
Documentation       Mobile test data loader
...                 Loads test data from JSON files under test_data/mobile/

Library             JSONLibrary


*** Keywords ***
Load ETH Test Data
    [Documentation]    Load ETH search test data from JSON file into suite variables
    ...    File: test_data/mobile/search_and_validate_eth.json

    ${data}=    Load Json From File
    ...    ${CURDIR}/../../../test_data/mobile/search_and_validate_eth.json
    Set Suite Variable    ${MOBILE_TEST_DATA}    ${data}

    ${term}=        Get Value From Json    ${data}    $.search.term
    ${pair}=        Get Value From Json    ${data}    $.search.expected_pair
    ${timeout}=     Get Value From Json    ${data}    $.timeouts.search_result_timeout
    ${ss1}=         Get Value From Json    ${data}    $.screenshots.after_onboarding
    ${ss2}=         Get Value From Json    ${data}    $.screenshots.after_market_click
    ${ss3}=         Get Value From Json    ${data}    $.screenshots.search_results
    ${ss4}=         Get Value From Json    ${data}    $.screenshots.eth_trading_page

    Set Suite Variable    ${SEARCH_TERM}                  ${term}[0]
    Set Suite Variable    ${EXPECTED_PAIR}                ${pair}[0]
    Set Suite Variable    ${SEARCH_RESULT_TIMEOUT}        ${timeout}[0]
    Set Suite Variable    ${SCREENSHOT_ONBOARDING}        ${ss1}[0]
    Set Suite Variable    ${SCREENSHOT_MARKET_CLICK}      ${ss2}[0]
    Set Suite Variable    ${SCREENSHOT_SEARCH_RESULTS}    ${ss3}[0]
    Set Suite Variable    ${SCREENSHOT_TRADING_PAGE}      ${ss4}[0]

    Log    ✓ ETH test data loaded: search_term=${term}[0], expected_pair=${pair}[0]    INFO
