*** Settings ***
Documentation    Deposit page element locators for Indodax mobile app
...             Locators for IDR and crypto deposit screens


*** Variables ***
# --- Entry Points ---
${DEPOSIT_BUTTON}=                     //*[contains(@text, "Deposit") or contains(@text, "Setor")]
${DEPOSIT_IDR_OPTION}=                 //*[contains(@text, "Deposit IDR")]
${DEPOSIT_CRYPTO_OPTION}=              //*[contains(@text, "Deposit Crypto")]

# --- IDR Deposit ---
${DEPOSIT_AMOUNT_INPUT}=               id=id.co.bitcoin:id/etDepositAmount
${BANK_TRANSFER_OPTION}=               //*[contains(@text, "Transfer Bank")]
${VIRTUAL_ACCOUNT_OPTION}=             //*[contains(@text, "Virtual Account")]
${VA_BCA_OPTION}=                      //*[contains(@text, "BCA")]
${VA_MANDIRI_OPTION}=                  //*[contains(@text, "Mandiri")]
${VA_BRI_OPTION}=                      //*[contains(@text, "BRI")]
${SUBMIT_DEPOSIT_BUTTON}=              id=id.co.bitcoin:id/btnSubmitDeposit
${VA_NUMBER_LABEL}=                    id=id.co.bitcoin:id/tvVirtualAccountNumber

# --- Crypto Deposit ---
${CRYPTO_DEPOSIT_ADDRESS}=             id=id.co.bitcoin:id/tvDepositAddress
${COPY_ADDRESS_BUTTON}=                id=id.co.bitcoin:id/btnCopyAddress
${NETWORK_SELECTOR}=                   id=id.co.bitcoin:id/spinnerNetwork
${QR_CODE_IMAGE}=                      id=id.co.bitcoin:id/ivQRCode

# --- Status ---
${DEPOSIT_HISTORY_TAB}=                //*[contains(@text, "Riwayat Deposit")]
${DEPOSIT_STATUS_LABEL}=               id=id.co.bitcoin:id/tvDepositStatus
