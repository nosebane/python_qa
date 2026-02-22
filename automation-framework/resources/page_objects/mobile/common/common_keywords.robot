*** Settings ***
Documentation    Common page keywords for Indodax mobile app
...             Setup, teardown, and utility keywords used across all tests

Library    AppiumLibrary


*** Keywords ***

Close Indodax App If Open
    [Documentation]    Close the Indodax app if it's currently open
    ...    Safe teardown that doesn't fail if app isn't open

    TRY
        Close Application
        Log    ✓ App closed    INFO
    EXCEPT
        Log    ✓ App not open or already closed    INFO
    END


Start Mobile Test Execution
    [Documentation]    Start mobile test execution with logging

    Log    ========== Starting Mobile Test Execution ==========    INFO
    ${timestamp}=    Evaluate    __import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    Log    Test started at: ${timestamp}    INFO


End Mobile Test Execution
    [Documentation]    End mobile test execution with logging

    ${timestamp}=    Evaluate    __import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    Log    Test ended at: ${timestamp}    INFO
    Log    ========== Mobile Test Execution Complete ==========    INFO
