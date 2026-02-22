*** Keywords ***
# Indodax Public API Keywords (Ticker, Depth, Trades)

Get Ticker For Pair
    [Arguments]    ${pair}
    [Documentation]    Get ticker data for trading pair with request/response logging
    ...    
    ...    Args:
    ...        pair: Trading pair (e.g., 'btc_idr')
    ...    
    ...    Returns:
    ...        Ticker response data
    
    Log    ========== API REQUEST ==========    INFO
    Log    Fetching ticker for pair: ${pair}    INFO
    
    ${url}=    Set Variable    ${PUBLIC_API_BASE_URL}/api/ticker/${pair}
    Log    Method: GET    INFO
    Log    URL: ${url}    INFO
    Log    Headers: Content-Type=application/json    INFO
    Log    ========== SENDING REQUEST ==========    INFO
    
    ${response}=    GET    ${url}    timeout=${API_TIMEOUT}
    
    Log    ========== API RESPONSE ==========    INFO
    Log    Status Code: ${response.status_code}    INFO
    Log    Response Headers: ${response.headers}    INFO
    Log    Response Body: ${response.text}    INFO
    Log    ========== RESPONSE END ==========    INFO
    
    RETURN    ${response}


Verify Ticker Response Structure
    [Arguments]    ${response}    @{required_fields}
    [Documentation]    Verify ticker response has required fields
    
    Log    Verifying ticker response structure    INFO
    ${response_data}=    Extract JSON From Response    ${response}
    
    FOR    ${field}    IN    @{required_fields}
        Should Contain Key    ${response_data}    ${field}
        Log    ✓ Field '${field}' found in response    INFO
    END


Verify Ticker Values
    [Arguments]    ${response}
    [Documentation]    Verify ticker values are valid
    
    Log    Verifying ticker values    INFO
    ${response_data}=    Extract JSON From Response    ${response}
    
    # Buy should be less than or equal to Sell
    ${buy}=    Get From Dictionary    ${response_data}    buy
    ${sell}=    Get From Dictionary    ${response_data}    sell
    Should Be True    ${buy} <= ${sell}    Buy price should be <= Sell price
    
    # Last should be positive
    ${last}=    Get From Dictionary    ${response_data}    last
    Should Be True    ${last} > 0    Last price should be positive
    
    Log    ✓ All ticker values are valid    INFO


Get Depth For Pair
    [Arguments]    ${pair}
    [Documentation]    Get depth using service with logging
    
    Log    ========== API REQUEST ==========    INFO
    Log    Endpoint: GET /api/depth/${pair}    INFO
    ${url}=    Set Variable    ${PUBLIC_API_BASE_URL}/api/depth/${pair}
    Log    Full URL: ${url}    INFO
    Log    ========== SENDING REQUEST ==========    INFO
    
    ${response}=    GET    ${url}    timeout=${API_TIMEOUT}
    
    Log    ========== API RESPONSE ==========    INFO
    Log    Status Code: ${response.status_code}    INFO
    Log    Response: ${response.text}    INFO
    Log    ========== END RESPONSE ==========    INFO
    
    RETURN    ${response}


Get Trades For Pair
    [Arguments]    ${pair}
    [Documentation]    Get trades using service with logging
    
    Log    ========== API REQUEST ==========    INFO
    Log    Endpoint: GET /api/trades/${pair}    INFO
    ${url}=    Set Variable    ${PUBLIC_API_BASE_URL}/api/trades/${pair}
    Log    Full URL: ${url}    INFO
    Log    ========== SENDING REQUEST ==========    INFO
    
    ${response}=    GET    ${url}
    
    Log    ========== API RESPONSE ==========    INFO
    Log    Status Code: ${response.status_code}    INFO
    Log    Response: ${response.text}    INFO
    Log    ========== END RESPONSE ==========    INFO
    
    RETURN    ${response}
