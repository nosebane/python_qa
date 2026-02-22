*** Settings ***
Documentation    Account & Settings keywords for Indodax mobile app
...             Handles account settings, profile management, mode switching (PRO/LITE),
...             security settings, and logout
...
...             NOTE: Mode switching (PRO ↔ LITE) is a critical feature of Indodax app.
...             Use Switch To PRO Mode / Switch To LITE Mode keywords to toggle.

Library    AppiumLibrary

Resource    ./account_locators.robot


*** Keywords ***

Navigate To Account
    [Documentation]    Navigate to Account tab via bottom navigation

    Log    Navigating to Account...    INFO
    Wait Until Element Is Visible    ${ACCOUNT_MENU}    timeout=10s
    Click Element    ${ACCOUNT_MENU}
    Log    ✓ Account screen opened    INFO


Switch To PRO Mode
    [Documentation]    Switch app to PRO trading mode
    ...    PRO mode: Advanced chart, Limit/Market/Stop Limit orders, IDR + USDT pairs
    ...    NOTE: To be implemented when mode-switching tests are created

    Log    Switching to PRO mode...    INFO
    Navigate To Account
    TRY
        Wait Until Element Is Visible    ${MODE_TOGGLE_BUTTON}    timeout=10s
        Click Element    ${MODE_TOGGLE_BUTTON}
        Wait Until Element Is Visible    ${MODE_PRO_LABEL}    timeout=5s
        Click Element    ${MODE_PRO_LABEL}
        TRY
            Wait Until Element Is Visible    ${MODE_CONFIRM_BUTTON}    timeout=5s
            Click Element    ${MODE_CONFIRM_BUTTON}
        EXCEPT
            Log    No confirmation dialog appeared    DEBUG
        END
        Log    ✓ Switched to PRO mode    INFO
    EXCEPT
        Log    Could not switch to PRO mode — check if mode toggle is available    WARN
    END


Switch To LITE Mode
    [Documentation]    Switch app to LITE trading mode
    ...    LITE mode: Simplified chart, Market Order only, IDR pairs only
    ...    NOTE: To be implemented when mode-switching tests are created

    Log    Switching to LITE mode...    INFO
    Navigate To Account
    TRY
        Wait Until Element Is Visible    ${MODE_TOGGLE_BUTTON}    timeout=10s
        Click Element    ${MODE_TOGGLE_BUTTON}
        Wait Until Element Is Visible    ${MODE_LITE_LABEL}    timeout=5s
        Click Element    ${MODE_LITE_LABEL}
        TRY
            Wait Until Element Is Visible    ${MODE_CONFIRM_BUTTON}    timeout=5s
            Click Element    ${MODE_CONFIRM_BUTTON}
        EXCEPT
            Log    No confirmation dialog appeared    DEBUG
        END
        Log    ✓ Switched to LITE mode    INFO
    EXCEPT
        Log    Could not switch to LITE mode — check if mode toggle is available    WARN
    END


Logout From App
    [Documentation]    Logout from the Indodax app via Account menu
    ...    NOTE: To be implemented when logout test is created

    Log    Logging out...    INFO
    Navigate To Account
    Wait Until Element Is Visible    ${LOGOUT_BUTTON}    timeout=10s
    Click Element    ${LOGOUT_BUTTON}
    TRY
        Wait Until Element Is Visible    ${LOGOUT_CONFIRM_BUTTON}    timeout=5s
        Click Element    ${LOGOUT_CONFIRM_BUTTON}
        Log    ✓ Logout confirmed    INFO
    EXCEPT
        Log    No logout confirmation dialog appeared    DEBUG
    END
    Log    ✓ Logged out successfully    INFO
