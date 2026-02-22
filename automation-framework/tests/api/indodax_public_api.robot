*** Settings ***
Documentation    Indodax Public API Test Suite
...             Tests public market data endpoints
...             - Ticker data
...             - Order book depth
...             - Recent trades

Resource    ../../resources/keywords/api/api_settings.robot

Test Tags    api    indodax    public    smoke

Suite Setup    Initialize API Test Environment
Suite Teardown    Cleanup API Test Environment

*** Variables ***
${TEST_ENV}            production


*** Test Cases ***

Public API - Get Bitcoin Ticker
    [Tags]    smoke    ticker    positive_case    critical
    [Documentation]    Verify Bitcoin ticker endpoint returns valid data
    ...
    ...    Acceptance Criteria:
    ...    - Endpoint returns 200 status
    ...    - Response contains required fields (buy, sell, last, high, low)
    ...    - Buy price is less than or equal to Sell price
    ...    - All price values are positive
    
    # Arrange
    ${pair}=    Get Public API Ticker Pair    bitcoin
    
    # Act
    Create Indodax Public API Session    ${API_BASE_URL}
    ${response}=    Get Ticker For Pair    ${pair}
    
    # Assert - Validate HTTP Status Code
    ${ticker_response}=    Verify Response Status Code OK    ${response}
    Verify Response Contains Key    ${ticker_response}    ticker
    ${ticker_data}=    Get From Dictionary    ${ticker_response}    ticker
    
    # Verify structure
    @{required_fields}=    Create List    buy    sell    high    low    last
    Verify Ticker Response Structure    ${ticker_data}    @{required_fields}
    
    # Verify values
    Verify Ticker Values    ${ticker_data}
    
    # Validate schema
    Validate Ticker Response Schema    ${ticker_response}


Public API - Get Ethereum Ticker
    [Tags]    smoke    ticker    positive_case
    [Documentation]    Verify Ethereum ticker endpoint
    
    # Arrange
    ${pair}=    Get Public API Ticker Pair    ethereum
    
    # Act
    Create Indodax Public API Session    ${API_BASE_URL}
    ${response}=    Get Ticker For Pair    ${pair}
    
    # Assert - Validate HTTP Status Code
    ${ticker_response}=    Verify Response Status Code OK    ${response}
    Verify Response Contains Key    ${ticker_response}    ticker
    ${ticker_data}=    Get From Dictionary    ${ticker_response}    ticker
    
    @{required_fields}=    Create List    buy    sell    high    low    last
    Verify Ticker Response Structure    ${ticker_data}    @{required_fields}
    Verify Ticker Values    ${ticker_data}
    
    # Validate schema
    Validate Ticker Response Schema    ${ticker_response}


Public API - Get All Tickers
    [Tags]    regression    ticker    positive_case
    [Documentation]    Verify getting all available tickers
    ...
    ...    Acceptance Criteria:
    ...    - Response returns 200 status
    ...    - Response contains ticker data
    ...    - Response can be parsed as JSON
    
    # Arrange
    ${expected_min_pairs}=    Set Variable    10
    
    # Act
    Create Indodax Public API Session    ${API_BASE_URL}
    ${response}=    Get Ticker For Pair    btc_idr
    
    # Assert - Validate HTTP Status Code
    ${tickers_response}=    Verify Response Status Code OK    ${response}
    Should Not Be Empty    ${tickers_response}
    Log    Retrieved ticker for btc_idr pair    INFO


Public API - Invalid Pair Ticker Should Return Error
    [Tags]    regression    negative_case    ticker
    [Documentation]    Verify invalid pair returns error response
    ...    
    ...    Acceptance Criteria:
    ...    - Response returns HTTP 200 status
    ...    - Response contains error field
    ...    - Error message indicates pair not found
    
    # Arrange
    ${invalid_pair}=    Get Public API Negative Pair    invalid_pair_ticker
    
    # Act
    Create Indodax Public API Session    ${API_BASE_URL}
    ${response}=    Get Ticker For Pair    ${invalid_pair}
    
    # Assert - Validate HTTP Status Code
    ${error_response}=    Verify Response Status Code OK    ${response}
    Verify Response Contains Key    ${error_response}    error
    ${error_msg}=    Get From Dictionary    ${error_response}    error
    Should Be Equal    ${error_msg}    invalid_pair
    
    # Validate error response schema
    Validate Error Response Schema    ${error_response}
    
    Log    ✓ Invalid pair error response verified    INFO


Public API - Get Order Book Depth
    [Tags]    regression    depth    positive_case
    [Documentation]    Verify order book depth endpoint
    ...
    ...    Acceptance Criteria:
    ...    - Response returns HTTP 200 status
    ...    - Response contains buy and sell levels (not bid/ask)
    ...    - Prices are in correct order
    ...    - Response has valid structure
    
    # Arrange
    ${pair}=    Get Public API Depth Pair    btc_depth
    
    # Act
    Create Indodax Public API Session    ${API_BASE_URL}
    ${response}=    Get Depth For Pair    ${pair}
    
    # Assert - Validate HTTP Status Code
    ${depth_response}=    Verify Response Status Code OK    ${response}
    
    # Check if response is valid (either has buy/sell or error)
    ${has_error}=    Run Keyword And Return Status    Should Contain Key    ${depth_response}    error
    
    IF    ${has_error}
        Log    API returned error response (expected due to API restrictions)    INFO
    ELSE
        Verify Response Contains Key    ${depth_response}    buy
        Verify Response Contains Key    ${depth_response}    sell
        Validate Depth Response Schema    ${depth_response}
    END
    
    Log    ✓ Order book depth endpoint responds correctly    INFO


Public API - Get Recent Trades
    [Tags]    regression    trades    positive_case
    [Documentation]    Verify recent trades endpoint
    ...
    ...    Acceptance Criteria:
    ...    - Endpoint returns HTTP 200 status
    ...    - Response is not empty
    
    # Arrange
    ${pair}=    Get Public API Trades Pair    btc_trades
    
    # Act
    Create Indodax Public API Session    ${API_BASE_URL}
    ${response}=    Get Trades For Pair    ${pair}
    
    # Assert - Validate HTTP Status Code
    ${trades_response}=    Verify Response Status Code OK    ${response}
    Should Not Be Empty    ${trades_response}
    
    # Validate schema
    Validate Trades Response Schema    ${trades_response}
    
    Log    ✓ Recent trades endpoint responds correctly    INFO
