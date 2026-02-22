*** Settings ***
Documentation    Withdraw page element locators for Indodax mobile app
...             Locators for IDR and crypto withdrawal screens


*** Variables ***
# --- Entry Points ---
${WITHDRAW_BUTTON}=                    //*[contains(@text, "Withdraw") or contains(@text, "Tarik")]
${WITHDRAW_IDR_OPTION}=                //*[contains(@text, "Withdraw IDR")]
${WITHDRAW_CRYPTO_OPTION}=             //*[contains(@text, "Withdraw Crypto")]

# --- IDR Withdrawal ---
${WITHDRAW_AMOUNT_INPUT}=              id=id.co.bitcoin:id/etWithdrawAmount
${BANK_ACCOUNT_SELECTOR}=              id=id.co.bitcoin:id/spinnerBankAccount
${ADD_BANK_BUTTON}=                    //*[contains(@text, "Tambah Rekening")]
${SUBMIT_WITHDRAW_BUTTON}=             id=id.co.bitcoin:id/btnSubmitWithdraw
${WITHDRAW_FEE_LABEL}=                 id=id.co.bitcoin:id/tvWithdrawFee
${WITHDRAW_TOTAL_LABEL}=               id=id.co.bitcoin:id/tvWithdrawTotal

# --- Crypto Withdrawal ---
${CRYPTO_ADDRESS_INPUT}=               id=id.co.bitcoin:id/etCryptoAddress
${CRYPTO_AMOUNT_INPUT}=                id=id.co.bitcoin:id/etCryptoAmount
${NETWORK_SELECTOR}=                   id=id.co.bitcoin:id/spinnerNetwork
${MEMO_INPUT}=                         id=id.co.bitcoin:id/etMemo

# --- OTP / PIN Verification ---
${OTP_INPUT}=                          id=id.co.bitcoin:id/etOTP
${PIN_INPUT}=                          id=id.co.bitcoin:id/etPIN
${CONFIRM_WITHDRAW_BUTTON}=            //*[contains(@text, "Konfirmasi")]

# --- Status ---
${WITHDRAW_HISTORY_TAB}=               //*[contains(@text, "Riwayat Penarikan")]
${WITHDRAW_STATUS_LABEL}=              id=id.co.bitcoin:id/tvWithdrawStatus
${WITHDRAW_SUCCESS_MESSAGE}=           //*[contains(@text, "Penarikan berhasil")]
