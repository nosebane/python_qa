*** Settings ***
Documentation    Withdraw keywords for Indodax mobile app
...             Handles IDR and crypto withdrawal flows
...
...             NOTE: These keywords are stubs — implement when withdraw tests are added.
...             Withdrawals require OTP/PIN verification.

Library    AppiumLibrary

Resource    ./withdraw_locators.robot


*** Keywords ***

Navigate To Withdraw
    [Documentation]    Navigate to the withdraw screen
    ...    NOTE: To be implemented when withdraw test is created

    Log    Navigating to Withdraw...    INFO
    Wait Until Element Is Visible    ${WITHDRAW_BUTTON}    timeout=10s
    Click Element    ${WITHDRAW_BUTTON}
    Log    ✓ Withdraw screen opened    INFO


Withdraw IDR
    [Documentation]    Withdraw IDR to a registered bank account
    ...    Arguments: ${amount}, ${bank_account_index} (default 0 = first account)
    ...    NOTE: Requires valid registered bank account and OTP verification
    ...    NOTE: To be implemented

    [Arguments]    ${amount}    ${bank_account_index}=0
    Log    Withdrawing ${amount} IDR...    INFO
    Click Element    ${WITHDRAW_IDR_OPTION}
    Input Text    ${WITHDRAW_AMOUNT_INPUT}    ${amount}
    Log    ✓ Withdraw IDR initiated    INFO


Withdraw Crypto
    [Documentation]    Withdraw crypto to an external wallet address
    ...    Arguments: ${address}, ${amount}, ${network}
    ...    NOTE: Requires OTP/PIN verification
    ...    NOTE: To be implemented

    [Arguments]    ${address}    ${amount}    ${network}=ERC20
    Log    Withdrawing ${amount} to ${address} via ${network}...    INFO
    Click Element    ${WITHDRAW_CRYPTO_OPTION}
    Input Text    ${CRYPTO_ADDRESS_INPUT}    ${address}
    Input Text    ${CRYPTO_AMOUNT_INPUT}    ${amount}
    Log    ✓ Withdraw Crypto initiated    INFO
