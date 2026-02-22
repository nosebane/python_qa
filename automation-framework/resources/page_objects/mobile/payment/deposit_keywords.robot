*** Settings ***
Documentation    Deposit keywords for Indodax mobile app
...             Handles IDR and crypto deposit flows
...
...             NOTE: These keywords are stubs — implement when deposit tests are added.
...             Reference: Panduan Pembayaran Virtual Account BCA
...             https://help.indodax.com/hc/id/articles/30742609564697

Library    AppiumLibrary

Resource    ./deposit_locators.robot


*** Keywords ***

Navigate To Deposit
    [Documentation]    Navigate to the deposit screen
    ...    NOTE: To be implemented when deposit test is created

    Log    Navigating to Deposit...    INFO
    Wait Until Element Is Visible    ${DEPOSIT_BUTTON}    timeout=10s
    Click Element    ${DEPOSIT_BUTTON}
    Log    ✓ Deposit screen opened    INFO


Deposit IDR Via Virtual Account
    [Documentation]    Deposit IDR using Virtual Account method
    ...    Arguments: ${amount}, ${bank} (e.g., BCA, Mandiri, BRI)
    ...    NOTE: To be implemented

    [Arguments]    ${amount}    ${bank}=BCA
    Log    Depositing ${amount} IDR via ${bank} Virtual Account...    INFO
    Click Element    ${DEPOSIT_IDR_OPTION}
    Input Text    ${DEPOSIT_AMOUNT_INPUT}    ${amount}
    Click Element    ${VIRTUAL_ACCOUNT_OPTION}
    Log    ✓ Deposit IDR initiated via Virtual Account    INFO


Get Deposit Address For Crypto
    [Documentation]    Get the deposit wallet address for a crypto asset
    ...    Returns the wallet address string
    ...    NOTE: To be implemented

    [Arguments]    ${network}=ERC20
    Log    Getting deposit address for network: ${network}...    INFO
    Click Element    ${DEPOSIT_CRYPTO_OPTION}
    ${address}=    Get Text    ${CRYPTO_DEPOSIT_ADDRESS}
    Log    ✓ Deposit address: ${address}    INFO
    RETURN    ${address}
