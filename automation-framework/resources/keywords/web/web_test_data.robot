*** Settings ***
Documentation       Web test data loader
...                 Loads test data from JSON files under test_data/web/

Library             JSONLibrary
Library             Collections
Library             OperatingSystem
Library             String


*** Keywords ***
Load Web Test Data
    [Documentation]    Load all test data from JSON into suite variable ${WEB_TEST_DATA}
    ...
    ...    Loads from: test_data/web/indodax_usdtidr_market.json
    ...    Sets ${WEB_TEST_DATA} as the complete JSON dict.
    ...    Use Get Market Data For Pair or Get Value From Json with JSONPath to extract specific data.

    ${test_data}=    Load Json From File    ${CURDIR}/../../../test_data/web/indodax_usdtidr_market.json

    Set Suite Variable    ${WEB_TEST_DATA}    ${test_data}

    Log    ✓ Test data loaded    INFO
    Log    ${test_data}    DEBUG

Get Market Data For Pair
    [Documentation]    Get market data for specific pair from test data
    ...
    ...    Args:
    ...        pair: Market pair identifier (e.g. usdtidr, btcidr)
    ...
    ...    Returns:
    ...        Dictionary with market data (price, change_24h, volume_24h, bid, ask)
    [Arguments]    ${pair}

    Log    Getting market data for pair: ${pair}    INFO

    ${result}=    Get Value From Json    ${WEB_TEST_DATA}    $.market_data.${pair}
    RETURN    ${result}[0]

