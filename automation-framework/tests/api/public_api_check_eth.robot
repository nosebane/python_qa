*** Settings ***
Documentation       Indodax Public API Test Suite
...                 Tests public market data endpoints
...                 - Ticker data
...                 - Order book depth
...                 - Recent trades

Resource            ../../resources/keywords/api/api_settings.robot

Suite Setup         Initialize API Test Environment
Suite Teardown      Cleanup API Test Environment

Test Tags           api    indodax    public    smoke


*** Variables ***
${TEST_ENV}     production


*** Test Cases ***
Public API - Get Bitcoin Ticker
    ${pair}=    Get Public API Ticker Pair    bitcoin

    # Act
    Create Indodax Public API Session    ${API_BASE_URL}
    ${response}=    Get Ticker For Pair    ${pair}

    # Assert - Validate HTTP Status Code
    ${ticker_response}=    Verify Response Status Code OK    ${response}
    Verify Response Contains Key    ${ticker_response}    ticker
    ${ticker_data}=    Get From Dictionary    ${ticker_response}    ticker

    # Verify structure
    VAR    @{required_fields}    buy    sell    high    low    last
    Verify Ticker Response Structure    ${ticker_data}    @{required_fields}

    # Verify values
    Verify Ticker Values    ${ticker_data}

    # Validate schema
    Validate Ticker Response Schema    ${ticker_response}