*** Settings ***
Documentation    Portfolio page keywords for Indodax mobile app
...             Handles interactions on the portfolio, wallet, and transaction history screens
...
...             NOTE: These keywords are stubs — implement when portfolio tests are added.

Library    AppiumLibrary

Resource    ./portfolio_locators.robot


*** Keywords ***

Navigate To Portfolio
    [Documentation]    Navigate to Portfolio tab via bottom navigation

    Log    Navigating to Portfolio...    INFO
    Wait Until Element Is Visible    ${PORTFOLIO_MENU}    timeout=10s
    Click Element    ${PORTFOLIO_MENU}
    Log    ✓ Portfolio screen opened    INFO


Get Total Balance
    [Documentation]    Get and return the total portfolio balance displayed
    ...    Returns the balance text value

    Wait Until Element Is Visible    ${TOTAL_BALANCE_LABEL}    timeout=10s
    ${balance}=    Get Text    ${TOTAL_BALANCE_LABEL}
    Log    Total balance: ${balance}    INFO
    RETURN    ${balance}


View Open Orders
    [Documentation]    Navigate to Open Orders tab in portfolio
    ...    NOTE: To be implemented when open orders test is created

    Wait Until Element Is Visible    ${OPEN_ORDERS_TAB}    timeout=10s
    Click Element    ${OPEN_ORDERS_TAB}
    Log    ✓ Open Orders tab opened    INFO


View Transaction History
    [Documentation]    Navigate to History/Mutasi tab in portfolio
    ...    NOTE: To be implemented when history test is created

    Wait Until Element Is Visible    ${HISTORY_TAB}    timeout=10s
    Click Element    ${HISTORY_TAB}
    Log    ✓ Transaction History tab opened    INFO
