*** Settings ***
Documentation    Authentication keywords for Indodax mobile app
...             Handles login, register, and logout interactions
...
...             NOTE: These keywords are stubs — implement when auth test scenarios are added.
...             Reference: Login flow requires valid Indodax credentials.

Library    AppiumLibrary

Resource    ./login_locators.robot


*** Keywords ***

Navigate To Login
    [Documentation]    Navigate to login screen from home page
    ...    Taps the Login button visible on the unauthenticated home screen

    Log    Navigating to Login screen...    INFO
    Wait Until Element Is Visible    ${LOGIN_BUTTON}    timeout=10s
    Click Element    ${LOGIN_BUTTON}
    Log    ✓ Login screen opened    INFO


Navigate To Register
    [Documentation]    Navigate to registration screen from home page
    ...    Taps the Register button visible on the unauthenticated home screen

    Log    Navigating to Register screen...    INFO
    Wait Until Element Is Visible    ${REGISTER_BUTTON}    timeout=10s
    Click Element    ${REGISTER_BUTTON}
    Log    ✓ Register screen opened    INFO


Login With Credentials
    [Documentation]    Login with email and password credentials
    ...    Arguments: ${email}, ${password}
    ...    NOTE: To be implemented when login test is created

    [Arguments]    ${email}    ${password}
    Log    Logging in as: ${email}    INFO
    Wait Until Element Is Visible    ${EMAIL_INPUT}    timeout=10s
    Input Text    ${EMAIL_INPUT}    ${email}
    Input Text    ${PASSWORD_INPUT}    ${password}
    Click Element    ${SUBMIT_LOGIN_BUTTON}
    Log    ✓ Login submitted    INFO


Logout From App
    [Documentation]    Logout from the Indodax app via Account menu
    ...    NOTE: To be implemented when logout test is created

    Log    Logging out...    INFO
    Wait Until Element Is Visible    ${LOGOUT_BUTTON}    timeout=10s
    Click Element    ${LOGOUT_BUTTON}
    TRY
        Wait Until Element Is Visible    ${LOGOUT_CONFIRM_BUTTON}    timeout=5s
        Click Element    ${LOGOUT_CONFIRM_BUTTON}
        Log    ✓ Logout confirmed    INFO
    EXCEPT
        Log    No logout confirmation dialog appeared    DEBUG
    END
    Log    ✓ Logged out    INFO
