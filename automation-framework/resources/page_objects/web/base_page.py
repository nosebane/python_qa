"""
Base Page Object for Web UI Automation
Provides core functionality for page interactions with Playwright
"""

from playwright.sync_api import Page, BrowserContext, expect
from typing import Optional, List, Any, Tuple
import logging


class BasePage:
    """
    Base Page Object class for all page objects
    
    Features:
    - Element locators and interactions
    - Wait conditions
    - Common assertions
    - Logging and debugging
    """
    
    def __init__(self, page: Page):
        """
        Initialize base page
        
        Args:
            page: Playwright page instance
        """
        self.page = page
        self.logger = self._setup_logger()
    
    def _setup_logger(self) -> logging.Logger:
        """Setup logging for page object"""
        logger = logging.getLogger(f"{self.__class__.__module__}.{self.__class__.__name__}")
        
        if not logger.handlers:
            handler = logging.StreamHandler()
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            handler.setFormatter(formatter)
            logger.addHandler(handler)
            logger.setLevel(logging.DEBUG)
        
        return logger
    
    def navigate_to(self, url: str) -> None:
        """Navigate to URL"""
        self.logger.info(f"Navigating to: {url}")
        self.page.goto(url)
    
    def get_current_url(self) -> str:
        """Get current page URL"""
        url = self.page.url
        self.logger.debug(f"Current URL: {url}")
        return url
    
    def get_page_title(self) -> str:
        """Get page title"""
        title = self.page.title()
        self.logger.debug(f"Page title: {title}")
        return title
    
    def click(self, selector: str, timeout: int = 5000) -> None:
        """Click element"""
        self.logger.info(f"Clicking: {selector}")
        self.page.click(selector, timeout=timeout)
    
    def fill_text(self, selector: str, text: str, timeout: int = 5000) -> None:
        """Fill text in input field"""
        self.logger.info(f"Filling '{selector}' with text: {text}")
        self.page.fill(selector, text)
    
    def get_text(self, selector: str) -> str:
        """Get element text"""
        text = self.page.text_content(selector)
        self.logger.debug(f"Text from '{selector}': {text}")
        return text
    
    def get_attribute(self, selector: str, attribute: str) -> Optional[str]:
        """Get element attribute"""
        value = self.page.get_attribute(selector, attribute)
        self.logger.debug(f"Attribute '{attribute}' from '{selector}': {value}")
        return value
    
    def is_visible(self, selector: str) -> bool:
        """Check if element is visible"""
        is_visible = self.page.is_visible(selector)
        self.logger.debug(f"Element '{selector}' visible: {is_visible}")
        return is_visible
    
    def is_enabled(self, selector: str) -> bool:
        """Check if element is enabled"""
        is_enabled = self.page.is_enabled(selector)
        self.logger.debug(f"Element '{selector}' enabled: {is_enabled}")
        return is_enabled
    
    def wait_for_selector(self, selector: str, timeout: int = 5000) -> None:
        """Wait for element to appear"""
        self.logger.info(f"Waiting for selector: {selector}")
        self.page.wait_for_selector(selector, timeout=timeout)
    
    def wait_for_url(self, url_pattern: str, timeout: int = 5000) -> None:
        """Wait for URL to match pattern"""
        self.logger.info(f"Waiting for URL pattern: {url_pattern}")
        self.page.wait_for_url(f"**{url_pattern}**", timeout=timeout)
    
    def get_all_text_contents(self, selector: str) -> List[str]:
        """Get text content from all matching elements"""
        elements = self.page.query_selector_all(selector)
        texts = [el.text_content() for el in elements]
        self.logger.debug(f"Found {len(texts)} elements for '{selector}'")
        return texts
    
    def press_key(self, key: str) -> None:
        """Press keyboard key"""
        self.logger.info(f"Pressing key: {key}")
        self.page.press("body", key)
    
    def take_screenshot(self, filename: str) -> None:
        """Take screenshot"""
        self.logger.info(f"Taking screenshot: {filename}")
        self.page.screenshot(path=filename)
    
    def scroll_to_element(self, selector: str) -> None:
        """Scroll to element"""
        self.logger.info(f"Scrolling to element: {selector}")
        self.page.locator(selector).scroll_into_view_if_needed()
    
    def hover(self, selector: str) -> None:
        """Hover over element"""
        self.logger.info(f"Hovering over: {selector}")
        self.page.hover(selector)
    
    def double_click(self, selector: str) -> None:
        """Double click element"""
        self.logger.info(f"Double clicking: {selector}")
        self.page.dblclick(selector)
    
    def right_click(self, selector: str) -> None:
        """Right click element"""
        self.logger.info(f"Right clicking: {selector}")
        self.page.click(selector, button="right")
    
    def drag_and_drop(self, source: str, target: str) -> None:
        """Drag element to target"""
        self.logger.info(f"Dragging '{source}' to '{target}'")
        self.page.drag_and_drop(source, target)
    
    def select_option(self, selector: str, value: str) -> None:
        """Select option in dropdown"""
        self.logger.info(f"Selecting '{value}' from '{selector}'")
        self.page.select_option(selector, value)
    
    def get_selected_option(self, selector: str) -> str:
        """Get selected option from dropdown"""
        selected = self.page.input_value(selector)
        self.logger.debug(f"Selected option: {selected}")
        return selected
    
    def clear_text(self, selector: str) -> None:
        """Clear text from input field"""
        self.logger.info(f"Clearing text from: {selector}")
        self.page.fill(selector, "")
    
    def is_checked(self, selector: str) -> bool:
        """Check if checkbox is checked"""
        is_checked = self.page.is_checked(selector)
        self.logger.debug(f"Checkbox '{selector}' checked: {is_checked}")
        return is_checked
    
    def check(self, selector: str) -> None:
        """Check checkbox"""
        self.logger.info(f"Checking: {selector}")
        self.page.check(selector)
    
    def uncheck(self, selector: str) -> None:
        """Uncheck checkbox"""
        self.logger.info(f"Unchecking: {selector}")
        self.page.uncheck(selector)
    
    def close(self) -> None:
        """Close page"""
        self.logger.info("Closing page")
        self.page.close()
