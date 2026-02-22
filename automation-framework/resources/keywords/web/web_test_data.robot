*** Settings ***
Documentation    Web test data loader
...             Loads test data from JSON files under test_data/web/

Library    Collections
Library    String
Library    OperatingSystem


*** Keywords ***

Load Web Test Data
    [Arguments]    ${market_pair}=usdtidr
    [Documentation]    Load market pair test data from JSON
    ...    
    ...    Loads from: test_data/web/indodax_usdtidr_market.json
    ...    Sets both market data and test expectations
    ...    
    ...    Args:
    ...        market_pair: Trading pair identifier (default: usdtidr)
    
    Log    Loading web test data for pair: ${market_pair}    INFO
    
    # Load indodax_usdtidr_market.json from test_data/web folder
    ${json_file}=    Get File    ${CURDIR}/../../../test_data/web/indodax_usdtidr_market.json
    ${test_data}=    Evaluate    json.loads('''${json_file}''')    json
    
    # Get data for specific pair and merge with test expectations
    ${pair_data}=    Evaluate    {**$test_data['market_data']['${market_pair}'], **$test_data['test_expectations']}
    
    Set Suite Variable    ${WEB_TEST_DATA}    ${pair_data}
    
    Log    ✓ Test data loaded for ${market_pair}    INFO
    Log    Market data: ${pair_data}    DEBUG


Get Market Data For Pair
    [Arguments]    ${pair}=usdtidr
    [Documentation]    Get market data for specific pair from test data
    ...    
    ...    Args:
    ...        pair: Market pair identifier (default: usdtidr)
    ...    
    ...    Returns:
    ...        Dictionary with market data (price, change_24h, volume_24h, bid, ask)
    
    Log    Getting market data for pair: ${pair}    INFO
    
    # Load indodax_usdtidr_market.json file
    ${json_file}=    Get File    ${CURDIR}/../../../test_data/web/indodax_usdtidr_market.json
    ${test_data}=    Evaluate    json.loads('''${json_file}''')    json
    
    # Get data for specific pair
    ${market_data}=    Get From Dictionary    ${test_data}[market_data]    ${pair}
    RETURN    ${market_data}
