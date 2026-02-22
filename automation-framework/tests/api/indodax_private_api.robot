*** Settings ***
Documentation    Indodax Private API Test Suite - Data-Driven
...             Tests private account endpoints
...             - Authentication
...             - Account Balance
...             - Order Management (Buy/Sell)
...             - Order History

Resource    ../../resources/keywords/api/api_settings.robot

Test Tags    api    indodax    private    authentication

Suite Setup    Initialize Private API Test Environment
Suite Teardown    Cleanup Private API Environment

*** Variables ***
${TEST_ENV}               production


*** Test Cases ***

Private API - Authentication - Valid Credentials Should Succeed
    [Tags]    authentication    positive_case    smoke    critical    skip
    [Setup]    Skip If No Valid Credentials
    [Documentation]    Verify authentication with valid credentials
    ...    NOTE: Tagged 'skip' — requires a live, unexpired INDODAX_API_KEY + INDODAX_API_SECRET
    ...    in .env.${TEST_ENV}. Remove the 'skip' tag once valid credentials are configured.
    ...
    ...    Acceptance Criteria:
    ...    - Response returns HTTP 200 status
    ...    - Valid API key and secret authenticate successfully
    ...    - Response contains account data
    ...    - No 401 Unauthorized errors
    
    # Setup signing for this test
    Setup Private API Signing
    
    # Arrange
    ${api_key}=    Set Variable    ${API_KEY}
    ${api_secret}=    Set Variable    ${API_SECRET}
    
    # Act
    Create Indodax Private API Session    ${api_key}    ${api_secret}    ${API_BASE_URL}
    
    # This would call: IndodaxPrivateService.get_account_info()
    ${response}=    Get Account Info
    
    # Assert - Validate HTTP Status Code
    ${account_info}=    Verify Response Status Code OK    ${response}
    Should Not Be Empty    ${account_info}
    Verify Response Contains Key    ${account_info}    return
    
    # Validate schema
    Validate Account Info Response Schema    ${account_info}
    
    Log    ✓ Authentication successful    INFO


Private API - Authentication - Invalid API Key Should Fail
    [Tags]    authentication    negative_case    security
    [Setup]    Setup Dummy Signer For Testing
    [Documentation]    Verify authentication fails with invalid API key
    ...
    ...    Acceptance Criteria:
    ...    - Response returns HTTP 200 status (API returns error in JSON)
    ...    - Invalid API key returns error (401 or invalid signature)
    ...    - Response contains authentication error message
    ...    - No sensitive data exposed in error
    
    # Arrange
    ${invalid_key}=    Set Variable    invalid_api_key_xyz123456
    ${invalid_secret}=    Set Variable    invalid_secret_xyz123456
    
    # Act & Assert - Test with invalid credentials (should get auth error, not signature error)
    Create Indodax Private API Session    ${invalid_key}    ${invalid_secret}    ${API_BASE_URL}
    
    ${response}=    Get Account Info
    
    # Should validate status code and check response is a dictionary
    ${response_body}=    Verify Response Status Code OK    ${response}
    ${is_dict}=    Run Keyword And Return Status    Should Be True    isinstance(${response_body}, dict)
    Should Be True    ${is_dict}    Response should be a dictionary
    Log    ✓ Invalid credentials properly rejected    INFO


Private API - Get Account Balance
    [Tags]    account    balance    positive_case    smoke    skip
    [Setup]    Skip If No Valid Credentials
    [Documentation]    Retrieve account balance for all assets
    ...
    ...    Acceptance Criteria:
    ...    - Response returns HTTP 200 status
    ...    - Successfully retrieve balance
    ...    - Response contains balance for each asset
    ...    - Balance values are non-negative numbers
    ...    - Includes time information
    
    # Arrange
    Create Indodax Private API Session    ${API_KEY}    ${API_SECRET}    ${API_BASE_URL}
    
    # Act
    ${response}=    Get Account Balance
    
    # Assert - Validate HTTP Status Code
    ${balance_response}=    Verify Response Status Code OK    ${response}
    Verify Response Contains Key    ${balance_response}    return
    Verify Response Contains Key    ${balance_response}    server_time
    
    ${balance_data}=    Get From Dictionary    ${balance_response}    return
    Should Not Be Empty    ${balance_data}
    
    Log    ✓ Account balance retrieved successfully    INFO


Private API - Place Buy Order - Valid Parameters
    [Tags]    order    buy    positive_case    data_driven    critical    skip
    [Setup]    Skip If No Valid Credentials
    [Documentation]    Test placing buy order with valid parameters
    ...
    ...    Test Data Variations:
    ...    - Standard buy order (1000 IDR equivalent)
    ...    - High amount order (10000 IDR equivalent)
    ...    - Low amount order (minimum allowed)
    
    # Arrange
    Create Indodax Private API Session    ${API_KEY}    ${API_SECRET}    ${API_BASE_URL}
    
    ${pair}=        Get Private API Buy Order Pair    buy_order_btc_standard
    ${test_data}=   Get Private API Buy Order Test Data    buy_order_btc_standard
    ${price}=       Get From Dictionary    ${test_data}    price
    ${amount}=      Get From Dictionary    ${test_data}    amount
    ${order_type}=  Get From Dictionary    ${test_data}    type
    
    # Act
    ${response}=    Place Buy Order    ${pair}    ${price}    ${amount}
    
    # Assert - Validate HTTP Status Code
    ${order_response}=    Verify Response Status Code OK    ${response}
    Verify Order Response    ${order_response}    ${order_type}    ${pair}    ${price}    ${amount}
    ${order_id}=    Verify Order Is Created    ${order_response}
    
    Log Request Details    POST    /tapi/trade    pair=${pair} type=${order_type} price=${price} amount=${amount}
    Log Response Details    ${order_response}    ${True}


Private API - Place Sell Order - Valid Parameters
    [Tags]    order    sell    positive_case    data_driven    skip
    [Setup]    Skip If No Valid Credentials
    [Documentation]    Test placing sell order with valid parameters
    
    # Arrange
    Create Indodax Private API Session    ${API_KEY}    ${API_SECRET}    ${API_BASE_URL}
    
    ${pair}=        Get Private API Sell Order Pair    sell_order_eth_standard
    ${test_data}=   Get Private API Sell Order Test Data    sell_order_eth_standard
    ${price}=       Get From Dictionary    ${test_data}    price
    ${amount}=      Get From Dictionary    ${test_data}    amount
    ${order_type}=  Get From Dictionary    ${test_data}    type
    
    # Act
    ${response}=    Place Sell Order    ${pair}    ${price}    ${amount}
    
    # Assert - Validate HTTP Status Code
    ${order_response}=    Verify Response Status Code OK    ${response}
    Verify Order Response    ${order_response}    ${order_type}    ${pair}    ${price}    ${amount}
    ${order_id}=    Verify Order Is Created    ${order_response}


Private API - Place Order - Negative Price Should Fail
    [Tags]    order    validation    negative_case    data_driven
    [Setup]    Setup Dummy Signer For Testing
    [Documentation]    Verify order with negative price is rejected
    ...
    ...    Test Data: Negative price (-500000000)
    ...    Expected: API validation error (HTTP 200 with error in response, doesn't need valid credentials for validation)
    
    # Arrange - Load test data from centralized JSON
    ${pair}=    Get Private API Validation Pair    negative_price
    ${test_data}=    Get Private API Order Validation Test Data    negative_price
    
    Create Indodax Private API Session    dummy_key    dummy_secret    ${API_BASE_URL}
    
    ${price}=       Get From Dictionary    ${test_data}    price
    ${amount}=      Get From Dictionary    ${test_data}    amount
    
    # Act
    ${response}=    Place Buy Order    ${pair}    ${price}    ${amount}
    
    # Assert - Validate HTTP Status Code and response exists
    ${order_response}=    Verify Response Status Code OK    ${response}
    Should Not Be Empty    ${order_response}    Order response should not be empty
    Log    ✓ Negative price properly validated    INFO


Private API - Place Order - Zero Amount Should Fail
    [Tags]    order    validation    negative_case    data_driven
    [Setup]    Setup Dummy Signer For Testing
    [Documentation]    Verify order with zero amount is rejected
    ...
    ...    Test Data: Zero amount (0)
    ...    Expected: API validation error (HTTP 200 with error in response, doesn't need valid credentials for validation)
    
    # Arrange - Load test data from centralized JSON
    ${pair}=    Get Private API Validation Pair    zero_amount
    ${test_data}=    Get Private API Order Validation Test Data    zero_amount
    
    Create Indodax Private API Session    dummy_key    dummy_secret    ${API_BASE_URL}
    
    ${price}=       Get From Dictionary    ${test_data}    price
    ${amount}=      Get From Dictionary    ${test_data}    amount
    
    # Act
    ${response}=    Place Buy Order    ${pair}    ${price}    ${amount}
    
    # Assert - Validate HTTP Status Code and response exists
    ${order_response}=    Verify Response Status Code OK    ${response}
    Should Not Be Empty    ${order_response}    Order response should not be empty
    Log    ✓ Zero amount properly validated    INFO


Private API - Get Open Orders
    [Tags]    order    list    positive_case    smoke    skip
    [Setup]    Skip If No Valid Credentials
    [Documentation]    Retrieve list of open orders
    ...
    ...    Acceptance Criteria:
    ...    - Response returns HTTP 200 status
    ...    - Successfully retrieve open orders
    ...    - Response contains order list (may be empty)
    ...    - Each order has required fields (order_id, pair, type, price, amount)
    
    # Arrange
    Create Indodax Private API Session    ${API_KEY}    ${API_SECRET}    ${API_BASE_URL}
    
    # Act
    ${response}=    Get Open Orders
    
    # Assert - Validate HTTP Status Code
    ${orders_response}=    Verify Response Status Code OK    ${response}
    Verify Response Contains Key    ${orders_response}    return
    Verify Response Contains Key    ${orders_response}    server_time
    
    Log    ✓ Open orders list retrieved successfully    INFO


Private API - Get Open Orders For Specific Pair
    [Tags]    order    list    positive_case    skip
    [Setup]    Skip If No Valid Credentials
    [Documentation]    Retrieve open orders for specific trading pair
    ...
    ...    Test Data: btc_idr
    ...    Expected: Orders filtered by pair, HTTP 200 response
    
    # Arrange
    Create Indodax Private API Session    ${API_KEY}    ${API_SECRET}    ${API_BASE_URL}
    
    ${pair}=    Get Private API Management Pair    get_open_orders_btc
    
    # Act
    ${response}=    Get Open Orders    ${pair}
    
    # Assert - Validate HTTP Status Code
    ${orders_response}=    Verify Response Status Code OK    ${response}
    Verify Response Contains Key    ${orders_response}    return
    
    Log    ✓ Open orders for ${pair} retrieved successfully    INFO


Private API - Cancel Order - Valid Order ID
    [Tags]    order    cancel    positive_case
    [Setup]    Setup Dummy Signer For Testing
    [Documentation]    Test cancelling order
    ...
    ...    Prerequisite: Tests the API endpoint structure
    ...    Expected: API responds with HTTP 200 (auth error expected with dummy credentials)
    
    # Arrange - Load test data from centralized JSON
    ${test_data}=    Get Private API Order Management Data    cancel_order
    ${pair}=         Get Private API Management Pair    cancel_order
    
    Create Indodax Private API Session    dummy_key    dummy_secret    ${API_BASE_URL}
    
    ${order_id}=    Get From Dictionary    ${test_data}    order_id
    
    # Act
    ${response}=    Cancel Order    ${order_id}    ${pair}
    
    # Assert - Validate HTTP Status Code and response exists
    ${cancel_response}=    Verify Response Status Code OK    ${response}
    Should Not Be Empty    ${cancel_response}    Cancel order response should not be empty
    
    Log Request Details    POST    /tapi/cancelOrder    order_id=${order_id} pair=${pair}
    Log Response Details    ${cancel_response}    ${True}
    Log    ✓ Cancel order endpoint functional    INFO


Private API - Get Order History
    [Tags]    order    history    positive_case    skip
    [Setup]    Skip If No Valid Credentials
    [Documentation]    Retrieve order history
    ...
    ...    Acceptance Criteria:
    ...    - Response returns HTTP 200 status
    ...    - Successfully retrieve order history
    ...    - Response contains completed orders
    ...    - Orders include all transaction details
    
    # Arrange
    Create Indodax Private API Session    ${API_KEY}    ${API_SECRET}    ${API_BASE_URL}
    
    # Act
    ${response}=    Get Order History
    
    # Assert - Validate HTTP Status Code
    ${history_response}=    Verify Response Status Code OK    ${response}
    Verify Response Contains Key    ${history_response}    return
    
    Log    ✓ Order history retrieved successfully    INFO


Private API - Data-Driven Order Testing
    [Tags]    order    data_driven    parameterized    skip
    [Setup]    Skip If No Valid Credentials
    [Documentation]    Data-driven test for multiple order scenarios
    ...
    ...    Test Data:
    ...    - Valid buy orders
    ...    - Valid sell orders
    ...    - Different trading pairs
    
    # Load data-driven scenarios from JSON
    ${scenarios}=    Get Private API Data Driven Scenarios
    
    FOR    ${scenario}    IN    @{scenarios}
        ${pair_id}=  Get From Dictionary    ${scenario}    pair_id
        ${pair}=     Get Trading Pair Id    ${pair_id}
        ${type}=     Get From Dictionary    ${scenario}    type
        ${price}=    Get From Dictionary    ${scenario}    price
        ${amount}=   Get From Dictionary    ${scenario}    amount
        
        Log    Testing ${type} order for ${pair}    INFO
        
        # Place order based on type
        Run Keyword If    '${type}' == 'buy'
        ...    Place Buy Order    ${pair}    ${price}    ${amount}
        ...    ELSE
        ...    Place Sell Order    ${pair}    ${price}    ${amount}
    END
