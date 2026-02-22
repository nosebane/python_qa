*** Settings ***
Documentation    Portfolio page element locators for Indodax mobile app
...             Locators for portfolio, wallet balance, and transaction history screens


*** Variables ***
# --- Bottom Navigation ---
${PORTFOLIO_MENU}=                     //*[contains(@text, "Portfolio")]

# --- Portfolio Overview ---
${TOTAL_BALANCE_LABEL}=                id=id.co.bitcoin:id/tvTotalBalance
${IDR_BALANCE_LABEL}=                  id=id.co.bitcoin:id/tvIDRBalance
${ASSET_LIST_VIEW}=                    id=id.co.bitcoin:id/rvAssetList
${ASSET_ITEM}=                         id=id.co.bitcoin:id/itemAsset

# --- Tabs ---
${OPEN_ORDERS_TAB}=                    //*[contains(@text, "Open Orders")]
${HISTORY_TAB}=                        //*[contains(@text, "History")]
${MUTATION_TAB}=                       //*[contains(@text, "Mutasi")]

# --- Transaction History ---
${TRANSACTION_LIST}=                   id=id.co.bitcoin:id/rvTransaction
${TRANSACTION_ITEM}=                   id=id.co.bitcoin:id/itemTransaction
${TRANSACTION_STATUS}=                 id=id.co.bitcoin:id/tvTransactionStatus
${TRANSACTION_AMOUNT}=                 id=id.co.bitcoin:id/tvTransactionAmount

# --- Open Orders ---
${OPEN_ORDER_LIST}=                    id=id.co.bitcoin:id/rvOpenOrders
${OPEN_ORDER_ITEM}=                    id=id.co.bitcoin:id/itemOpenOrder
${CANCEL_ORDER_BUTTON}=                //*[contains(@text, "Batalkan")]
