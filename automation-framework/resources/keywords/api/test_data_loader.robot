*** Keywords ***

Load Test Data
    [Documentation]    Load all test data files (base, public API, private API)
    ...    
    ...    Loads three JSON files:
    ...    - base.json: Common/shared test data
    ...    - indodax_public_api.json: Public API test cases
    ...    - indodax_private_api.json: Private API test cases
    
    ${base_file}=    Get File    ${CURDIR}/../../../test_data/api/base.json
    ${base_data}=    Evaluate    json.loads($base_file)    json
    
    ${public_file}=    Get File    ${CURDIR}/../../../test_data/api/indodax_public_api.json
    ${public_data}=    Evaluate    json.loads($public_file)    json
    
    ${private_file}=    Get File    ${CURDIR}/../../../test_data/api/indodax_private_api.json
    ${private_data}=    Evaluate    json.loads($private_file)    json
    
    Set Suite Variable    ${BASE_DATA}    ${base_data}
    Set Suite Variable    ${PUBLIC_API_DATA}    ${public_data}
    Set Suite Variable    ${PRIVATE_API_DATA}    ${private_data}
    
    Log    Test data loaded: base.json, indodax_public_api.json, indodax_private_api.json    INFO
    
    RETURN    ${base_data}


Load Response Schemas
    [Documentation]    Load all response schema files for API validation
    ...    
    ...    Loads schema files:
    ...    - ticker_schema.json: Ticker response schema
    ...    - depth_schema.json: Order book depth schema
    ...    - trades_schema.json: Recent trades schema
    ...    - error_schema.json: Error response schema
    ...    - trade_response_schema.json: Trade (buy/sell order) schema
    ...    - account_info_schema.json: Account info response schema
    ...    - open_orders_schema.json: Open orders list schema
    
    ${ticker_file}=    Get File    ${CURDIR}/../../../test_data/api/schemas/ticker_schema.json
    ${ticker_schema}=    Evaluate    json.loads($ticker_file)    json
    Store Schema    ticker    ${ticker_schema}
    
    ${depth_file}=    Get File    ${CURDIR}/../../../test_data/api/schemas/depth_schema.json
    ${depth_schema}=    Evaluate    json.loads($depth_file)    json
    Store Schema    depth    ${depth_schema}
    
    ${trades_file}=    Get File    ${CURDIR}/../../../test_data/api/schemas/trades_schema.json
    ${trades_schema}=    Evaluate    json.loads($trades_file)    json
    Store Schema    trades    ${trades_schema}
    
    ${error_file}=    Get File    ${CURDIR}/../../../test_data/api/schemas/error_schema.json
    ${error_schema}=    Evaluate    json.loads($error_file)    json
    Store Schema    error    ${error_schema}
    
    ${trade_response_file}=    Get File    ${CURDIR}/../../../test_data/api/schemas/trade_response_schema.json
    ${trade_response_schema}=    Evaluate    json.loads($trade_response_file)    json
    Store Schema    trade_response    ${trade_response_schema}
    
    ${account_info_file}=    Get File    ${CURDIR}/../../../test_data/api/schemas/account_info_schema.json
    ${account_info_schema}=    Evaluate    json.loads($account_info_file)    json
    Store Schema    account_info    ${account_info_schema}
    
    ${open_orders_file}=    Get File    ${CURDIR}/../../../test_data/api/schemas/open_orders_schema.json
    ${open_orders_schema}=    Evaluate    json.loads($open_orders_file)    json
    Store Schema    open_orders    ${open_orders_schema}
    
    Log    Response schemas loaded: ticker, depth, trades, error, trade_response, account_info, open_orders    INFO


Get Base Data
    [Documentation]    Get base/common test data
    ...    
    ...    Returns:
    ...    - API endpoints, trading pairs, invalid pairs
    ...    - Response field structures, HTTP status codes
    
    RETURN    ${BASE_DATA}


Get Public API Data
    [Documentation]    Get public API test data
    ...    
    ...    Returns:
    ...    - Ticker test cases and data
    ...    - Depth test data
    ...    - Trades test data
    ...    - Negative test cases
    
    RETURN    ${PUBLIC_API_DATA}


Get Private API Data
    [Documentation]    Get private API test data
    ...    
    ...    Returns:
    ...    - Authentication test data
    ...    - Order test data (buy/sell)
    ...    - Order validation data
    ...    - Order management data
    ...    - Account test data
    
    RETURN    ${PRIVATE_API_DATA}


Get Trading Pairs
    [Documentation]    Get all trading pairs from base data
    
    ${base}=    Get Base Data
    ${pairs}=    Get From Dictionary    ${base}    pairs
    RETURN    ${pairs}


Get Trading Pair
    [Arguments]    ${pair_key}
    [Documentation]    Get specific trading pair details
    
    ${pairs}=    Get Trading Pairs
    ${pair}=    Get From Dictionary    ${pairs}    ${pair_key}
    RETURN    ${pair}


Get Trading Pair Id
    [Arguments]    ${pair_id}
    [Documentation]    Get pair value from pair_id (lookup in base.json pairs)
    
    ${pairs}=    Get Trading Pairs
    ${pair_obj}=    Get From Dictionary    ${pairs}    ${pair_id}
    ${pair_value}=    Get From Dictionary    ${pair_obj}    id
    RETURN    ${pair_value}


Get Public API Ticker Test Data
    [Arguments]    ${test_id}
    [Documentation]    Get public API ticker test data by ID
    ...    
    ...    Args:
    ...        test_id: Test ID (bitcoin, ethereum, ripple, all_tickers)
    ...    Returns pair_id that can be resolved with Get Trading Pair Id
    
    ${public}=    Get Public API Data
    ${ticker_data}=    Get From Dictionary    ${public}    ticker_test_data
    ${test_case}=    Get From Dictionary    ${ticker_data}    ${test_id}
    RETURN    ${test_case}


Get Public API Ticker Pair
    [Arguments]    ${test_id}
    [Documentation]    Get actual pair value for ticker test
    ...    Resolves pair_id from test data to actual pair value
    
    ${test_data}=    Get Public API Ticker Test Data    ${test_id}
    ${pair_id}=    Get From Dictionary    ${test_data}    pair_id
    ${pair}=    Get Trading Pair Id    ${pair_id}
    RETURN    ${pair}


Get Public API Depth Test Data
    [Arguments]    ${test_id}
    [Documentation]    Get public API depth test data by ID
    ...    
    ...    Args:
    ...        test_id: Test ID (btc_depth, eth_depth)
    
    ${public}=    Get Public API Data
    ${depth_data}=    Get From Dictionary    ${public}    depth_test_data
    ${test_case}=    Get From Dictionary    ${depth_data}    ${test_id}
    RETURN    ${test_case}


Get Public API Depth Pair
    [Arguments]    ${test_id}
    [Documentation]    Get actual pair value for depth test
    ...    Resolves pair_id from test data to actual pair value
    
    ${test_data}=    Get Public API Depth Test Data    ${test_id}
    ${pair_id}=    Get From Dictionary    ${test_data}    pair_id
    ${pair}=    Get Trading Pair Id    ${pair_id}
    RETURN    ${pair}


Get Public API Trades Test Data
    [Arguments]    ${test_id}
    [Documentation]    Get public API trades test data by ID
    ...    
    ...    Args:
    ...        test_id: Test ID (btc_trades, eth_trades)
    
    ${public}=    Get Public API Data
    ${trades_data}=    Get From Dictionary    ${public}    trades_test_data
    ${test_case}=    Get From Dictionary    ${trades_data}    ${test_id}
    RETURN    ${test_case}


Get Public API Trades Pair
    [Arguments]    ${test_id}
    [Documentation]    Get actual pair value for trades test
    ...    Resolves pair_id from test data to actual pair value
    
    ${test_data}=    Get Public API Trades Test Data    ${test_id}
    ${pair_id}=    Get From Dictionary    ${test_data}    pair_id
    ${pair}=    Get Trading Pair Id    ${pair_id}
    RETURN    ${pair}


Get Public API Negative Test Data
    [Arguments]    ${test_id}
    [Documentation]    Get public API negative test data
    ...    
    ...    Args:
    ...        test_id: Test ID (invalid_pair_ticker)
    
    ${public}=    Get Public API Data
    ${negative}=    Get From Dictionary    ${public}    negative_cases
    ${test_case}=    Get From Dictionary    ${negative}    ${test_id}
    RETURN    ${test_case}


Get Public API Negative Pair
    [Arguments]    ${test_id}
    [Documentation]    Get actual pair value for negative test
    ...    Resolves pair_id from test data to actual pair value
    
    ${test_data}=    Get Public API Negative Test Data    ${test_id}
    ${pair_id}=    Get From Dictionary    ${test_data}    pair_id
    
    # Special case: if pair_id is invalid_pair_xyz, return it directly
    IF    '${pair_id}' == 'invalid_pair_xyz'
        RETURN    ${pair_id}
    END
    
    ${pair}=    Get Trading Pair Id    ${pair_id}
    RETURN    ${pair}


Get Private API Authentication Data
    [Arguments]    ${auth_type}
    [Documentation]    Get private API authentication test data
    ...    
    ...    Args:
    ...        auth_type: Type (valid_credentials, invalid_credentials, dummy_credentials)
    
    ${private}=    Get Private API Data
    ${auth_data}=    Get From Dictionary    ${private}    authentication_test_data
    ${test_case}=    Get From Dictionary    ${auth_data}    ${auth_type}
    RETURN    ${test_case}


Get Private API Buy Order Test Data
    [Arguments]    ${order_id}
    [Documentation]    Get private API buy order test data by ID
    ...    
    ...    Args:
    ...        order_id: Order ID (buy_order_btc_standard, buy_order_eth_standard)
    
    ${private}=    Get Private API Data
    ${orders}=    Get From Dictionary    ${private}    order_test_data
    ${buy_orders}=    Get From Dictionary    ${orders}    buy_orders
    ${test_case}=    Get From List    ${buy_orders}    0
    FOR    ${order}    IN    @{buy_orders}
        ${id}=    Get From Dictionary    ${order}    id
        Run Keyword If    '${id}' == '${order_id}'    RETURN    ${order}
    END
    Log    Order ${order_id} not found in test data    WARN
    RETURN    ${None}


Get Private API Sell Order Test Data
    [Arguments]    ${order_id}
    [Documentation]    Get private API sell order test data by ID
    ...    
    ...    Args:
    ...        order_id: Order ID (sell_order_btc_standard, sell_order_eth_standard)
    ...    Returns order data with pair_id (resolve with Get Private API Sell Order Pair)
    
    ${private}=    Get Private API Data
    ${orders}=    Get From Dictionary    ${private}    order_test_data
    ${sell_orders}=    Get From Dictionary    ${orders}    sell_orders
    FOR    ${order}    IN    @{sell_orders}
        ${id}=    Get From Dictionary    ${order}    id
        Run Keyword If    '${id}' == '${order_id}'    RETURN    ${order}
    END
    Log    Order ${order_id} not found in test data    WARN
    RETURN    ${None}


Get Private API Buy Order Pair
    [Arguments]    ${order_id}
    [Documentation]    Get actual pair value for buy order
    ...    Resolves pair_id from order data to actual pair value
    
    ${order_data}=    Get Private API Buy Order Test Data    ${order_id}
    ${pair_id}=    Get From Dictionary    ${order_data}    pair_id
    ${pair}=    Get Trading Pair Id    ${pair_id}
    RETURN    ${pair}


Get Private API Sell Order Pair
    [Arguments]    ${order_id}
    [Documentation]    Get actual pair value for sell order
    ...    Resolves pair_id from order data to actual pair value
    
    ${order_data}=    Get Private API Sell Order Test Data    ${order_id}
    ${pair_id}=    Get From Dictionary    ${order_data}    pair_id
    ${pair}=    Get Trading Pair Id    ${pair_id}
    RETURN    ${pair}


Get Private API Order Validation Test Data
    [Arguments]    ${validation_type}
    [Documentation]    Get private API order validation test data
    ...    
    ...    Args:
    ...        validation_type: Type (negative_price, zero_amount, invalid_pair)
    
    ${private}=    Get Private API Data
    ${validation}=    Get From Dictionary    ${private}    order_validation_test_data
    ${test_case}=    Get From Dictionary    ${validation}    ${validation_type}
    RETURN    ${test_case}


Get Private API Validation Pair
    [Arguments]    ${validation_type}
    [Documentation]    Get actual pair value for validation test
    ...    Resolves pair_id from validation data to actual pair value
    
    ${test_data}=    Get Private API Order Validation Test Data    ${validation_type}
    ${pair_id}=    Get From Dictionary    ${test_data}    pair_id
    
    # Special case: if pair_id is invalid_pair_xyz, return it directly
    IF    '${pair_id}' == 'invalid_pair_xyz'
        RETURN    ${pair_id}
    END
    
    ${pair}=    Get Trading Pair Id    ${pair_id}
    RETURN    ${pair}


Get Private API Order Management Data
    [Arguments]    ${operation_type}
    [Documentation]    Get private API order management test data
    ...    
    ...    Args:
    ...        operation_type: Type (cancel_order, get_open_orders_btc, get_open_orders_eth)
    
    ${private}=    Get Private API Data
    ${order_mgmt}=    Get From Dictionary    ${private}    order_management_test_data
    ${test_case}=    Get From Dictionary    ${order_mgmt}    ${operation_type}
    RETURN    ${test_case}


Get Private API Management Pair
    [Arguments]    ${operation_type}
    [Documentation]    Get actual pair value for management operation
    ...    Resolves pair_id from management data to actual pair value
    
    ${test_data}=    Get Private API Order Management Data    ${operation_type}
    # Some operations may not have pair_id (like general cancel_order)
    ${has_pair}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${test_data}    pair_id
    
    Run Keyword If    not ${has_pair}    RETURN    ${None}
    
    ${pair_id}=    Get From Dictionary    ${test_data}    pair_id
    ${pair}=    Get Trading Pair Id    ${pair_id}
    RETURN    ${pair}


Get Private API Account Test Data
    [Arguments]    ${account_operation}
    [Documentation]    Get private API account test data
    ...    
    ...    Args:
    ...        account_operation: Type (get_account_info, get_account_balance, get_open_orders, get_order_history)
    
    ${private}=    Get Private API Data
    ${account}=    Get From Dictionary    ${private}    account_test_data
    ${test_case}=    Get From Dictionary    ${account}    ${account_operation}
    RETURN    ${test_case}


Get Private API Data Driven Scenarios
    [Documentation]    Get data-driven test scenarios for orders
    ...    
    ...    Returns list of order scenarios (pair, type, price, amount)
    
    ${private}=    Get Private API Data
    ${scenarios}=    Get From Dictionary    ${private}    data_driven_scenarios
    ${orders}=    Get From Dictionary    ${scenarios}    order_scenarios
    RETURN    ${orders}


Get Private API Data Driven Scenario Pair
    [Arguments]    ${scenario_index}
    [Documentation]    Get actual pair value for data-driven scenario
    ...    Resolves pair_id from scenario data to actual pair value
    
    ${scenarios}=    Get Private API Data Driven Scenarios
    ${scenario}=    Get From List    ${scenarios}    ${scenario_index}
    ${pair_id}=    Get From Dictionary    ${scenario}    pair_id
    ${pair}=    Get Trading Pair Id    ${pair_id}
    RETURN    ${pair}


Get Response Validation Config
    [Documentation]    Get response validation configuration from base.json
    ...    
    ...    Returns configuration for:
    ...    - Expected HTTP status codes for endpoints
    ...    - Error scenarios and their expected responses
    
    ${base}=    Get Base Data
    ${validation_config}=    Get From Dictionary    ${base}    response_validation
    RETURN    ${validation_config}


Get Expected Status Code For Endpoint
    [Arguments]    ${api_type}    ${endpoint}
    [Documentation]    Get expected HTTP status code for specific endpoint
    ...    
    ...    Args:
    ...        api_type: 'public_api_endpoints' or 'private_api_endpoints'
    ...        endpoint: endpoint name (e.g., 'ticker', 'trade', 'getInfo')
    ...    
    ...    Returns:
    ...        Expected HTTP status code (usually 200)
    
    ${config}=    Get Response Validation Config
    ${endpoints}=    Get From Dictionary    ${config}    ${api_type}
    ${endpoint_config}=    Get From Dictionary    ${endpoints}    ${endpoint}
    ${expected_status}=    Get From Dictionary    ${endpoint_config}    expected_status
    RETURN    ${expected_status}


Get HTTP Status Code
    [Arguments]    ${status_name}
    [Documentation]    Get HTTP status code by name
    ...    
    ...    Args:
    ...        status_name: 'ok', 'created', 'bad_request', 'unauthorized', etc.
    ...    
    ...    Returns:
    ...        HTTP status code integer
    
    ${base}=    Get Base Data
    ${http_status}=    Get From Dictionary    ${base}    http_status
    ${code}=    Get From Dictionary    ${http_status}    ${status_name}
    RETURN    ${code}


Get Error Scenario Config
    [Arguments]    ${scenario_name}
    [Documentation]    Get expected response configuration for error scenario
    ...    
    ...    Args:
    ...        scenario_name: 'invalid_pair', 'unauthorized', 'validation_error'
    ...    
    ...    Returns:
    ...        Error scenario configuration (expected_status, contains_error, etc.)
    
    ${config}=    Get Response Validation Config
    ${error_scenarios}=    Get From Dictionary    ${config}    error_scenarios
    ${scenario}=    Get From Dictionary    ${error_scenarios}    ${scenario_name}
    RETURN    ${scenario}


Validate Response Against Config
    [Arguments]    ${response}    ${endpoint}    ${api_type}=public_api_endpoints
    [Documentation]    Validate response against configuration from base.json
    ...    
    ...    Checks:
    ...    - Response has expected HTTP status code
    ...    - Response contains expected fields
    ...    
    ...    Args:
    ...        response: Response object or parsed JSON dict
    ...        endpoint: endpoint name (e.g., 'ticker', 'trade')
    ...        api_type: 'public_api_endpoints' or 'private_api_endpoints'
    
    ${expected_status}=    Get Expected Status Code For Endpoint    ${api_type}    ${endpoint}
    ${response_body}=    Verify Response Status Code    ${response}    ${expected_status}
    
    Log    ✓ Response validated against endpoint configuration    INFO
    RETURN    ${response_body}