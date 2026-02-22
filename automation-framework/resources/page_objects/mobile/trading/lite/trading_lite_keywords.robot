*** Settings ***
Documentation    Trading LITE page keywords for Indodax mobile app
...             Handles interactions on the LITE mode trading page
...             LITE mode: Simplified chart, Market Order only, IDR pairs only
...             Designed for beginner users
...
...             NOTE: These keywords are stubs — implement when LITE mode tests are added.
...             Reference: https://help.indodax.com/hc/id/articles/28931961528473

Library    AppiumLibrary

Resource    ./trading_lite_locators.robot


*** Keywords ***

Wait For LITE Trading Page Load
    [Documentation]    Wait for LITE mode trading page to fully load
    ...    NOTE: To be implemented when LITE mode tests are created

    [Arguments]    ${pair}=IDR
    Log    Waiting for LITE trading page to load (pair: ${pair})...    INFO
    Wait Until Page Contains    ${pair}    timeout=20s
    Log    ✓ LITE trading page loaded    INFO


Buy Asset In LITE Mode
    [Documentation]    Buy a crypto asset using LITE mode (Market Order only)
    ...    Arguments: ${amount_idr} — IDR amount to spend
    ...    NOTE: To be implemented when LITE mode buy test is created

    [Arguments]    ${amount_idr}
    Log    Buying asset in LITE mode - amount: ${amount_idr} IDR    INFO
    Wait Until Element Is Visible    ${LITE_BUY_BUTTON}    timeout=10s
    Click Element    ${LITE_BUY_BUTTON}
    Input Text    ${LITE_AMOUNT_IDR_INPUT}    ${amount_idr}
    Click Element    ${LITE_NEXT_BUTTON}
    Click Element    ${LITE_BUY_NOW_BUTTON}
    Log    ✓ Buy order submitted in LITE mode    INFO


Sell Asset In LITE Mode
    [Documentation]    Sell a crypto asset using LITE mode (Market Order only)
    ...    Arguments: ${amount_idr} — IDR amount to receive
    ...    NOTE: To be implemented when LITE mode sell test is created

    [Arguments]    ${amount_idr}
    Log    Selling asset in LITE mode - amount: ${amount_idr} IDR    INFO
    Wait Until Element Is Visible    ${LITE_SELL_BUTTON}    timeout=10s
    Click Element    ${LITE_SELL_BUTTON}
    Input Text    ${LITE_AMOUNT_IDR_INPUT}    ${amount_idr}
    Click Element    ${LITE_NEXT_BUTTON}
    Click Element    ${LITE_SELL_NOW_BUTTON}
    Log    ✓ Sell order submitted in LITE mode    INFO


Verify Transaction Success In LITE Mode
    [Documentation]    Verify that a LITE mode transaction was successful

    Wait Until Page Contains Element    ${LITE_SUCCESS_MESSAGE}    timeout=15s
    Log    ✓ LITE mode transaction successful    INFO
