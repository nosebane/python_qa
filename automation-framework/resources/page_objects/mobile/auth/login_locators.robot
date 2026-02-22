*** Settings ***
Documentation    Authentication page element locators for Indodax mobile app
...             Locators for login, register, and forgot password screens


*** Variables ***
# --- Home Screen (unauthenticated state) ---
${LOGIN_BUTTON}=                       //*[@text="Login"]
${REGISTER_BUTTON}=                    id=id.co.bitcoin.account:id/btRegister

# --- Login Screen ---
${EMAIL_INPUT}=                        id=id.co.bitcoin:id/etEmail
${PASSWORD_INPUT}=                     id=id.co.bitcoin:id/etPassword
${SUBMIT_LOGIN_BUTTON}=                id=id.co.bitcoin:id/btnLogin
${FORGOT_PASSWORD_LINK}=               //*[contains(@text, "Forgot Password")]
${LOGIN_ERROR_MESSAGE}=                id=id.co.bitcoin:id/tvErrorMessage

# --- Register Screen ---
${REGISTER_EMAIL_INPUT}=               id=id.co.bitcoin:id/etRegisterEmail
${REGISTER_PHONE_INPUT}=               id=id.co.bitcoin:id/etPhone
${REGISTER_REFERRAL_INPUT}=            id=id.co.bitcoin:id/etReferral
${SUBMIT_REGISTER_BUTTON}=             id=id.co.bitcoin:id/btnRegister
