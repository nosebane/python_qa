*** Settings ***
Documentation    Account & Settings page element locators for Indodax mobile app
...             Locators for account settings, profile, security, KYC, and mode toggle screens


*** Variables ***
# --- Bottom Navigation ---
${ACCOUNT_MENU}=                       //*[contains(@text, "Account")]

# --- Profile Section ---
${PROFILE_NAME_LABEL}=                 id=id.co.bitcoin:id/tvProfileName
${PROFILE_EMAIL_LABEL}=                id=id.co.bitcoin:id/tvEmail
${PROFILE_LEVEL_LABEL}=                id=id.co.bitcoin:id/tvLevel
${EDIT_PROFILE_BUTTON}=                id=id.co.bitcoin:id/btnEditProfile

# --- PRO / LITE Mode Toggle ---
${MODE_TOGGLE_BUTTON}=                 id=id.co.bitcoin:id/btnModeToggle
${MODE_PRO_LABEL}=                     //*[contains(@text, "PRO")]
${MODE_LITE_LABEL}=                    //*[contains(@text, "LITE")]
${MODE_CONFIRM_BUTTON}=                //*[contains(@text, "Konfirmasi") or contains(@text, "OK")]

# --- Settings Menu Items ---
${SETTINGS_BUTTON}=                    id=id.co.bitcoin:id/ivSettings
${SECURITY_MENU}=                      //*[contains(@text, "Security") or contains(@text, "Keamanan")]
${KYC_MENU}=                           //*[contains(@text, "Verifikasi")]
${LANGUAGE_MENU}=                      //*[contains(@text, "Bahasa") or contains(@text, "Language")]
${NOTIFICATION_MENU}=                  //*[contains(@text, "Notifikasi") or contains(@text, "Notification")]
${PRICE_ALARM_MENU}=                   //*[contains(@text, "Price Alarm")]
${WIDGET_MENU}=                        //*[contains(@text, "Widget")]

# --- Logout ---
${LOGOUT_BUTTON}=                      //*[contains(@text, "Logout") or contains(@text, "Keluar")]
${LOGOUT_CONFIRM_BUTTON}=              //*[@text="Ya" or @text="Yes"]
