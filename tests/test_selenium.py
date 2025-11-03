#!/usr/bin/env python3
"""
Advanced example using Selenium WebDriver library with QtWebDriver.
This demonstrates how to use the official Selenium Python bindings.
"""

import logging
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


def test_qt_webdriver():
    """Test QtWebDriver using Selenium WebDriver library."""
    logger.info("Starting Selenium test with QtWebDriver")
    
    # Configure remote WebDriver to connect to QtWebDriver
    command_executor = "http://localhost:9517"
    
    # Use ChromeOptions to set Qt-specific capabilities
    # Selenium 4 will send this in W3C format with "capabilities" key
    options = webdriver.ChromeOptions()
    options.set_capability("browserName", "Qt")
    options.set_capability("platformName", "ANY")
    
    driver = None
    
    try:
        logger.info(f"Connecting to QtWebDriver at {command_executor}")
        driver = webdriver.Remote(
            command_executor=command_executor,
            options=options
        )
        
        logger.info(f"Session created: {driver.session_id}")
        
        # Get window handles
        logger.info("Getting window handles...")
        windows = driver.window_handles
        logger.info(f"Available windows: {windows}")
        
        # Get current window handle
        if windows:
            current_window = driver.current_window_handle
            logger.info(f"Current window: {current_window}")
            
            # Get window title
            title = driver.title
            logger.info(f"Window title: {title}")
        
        # You can add more WebDriver commands here based on your Qt application
        # Examples:
        # - driver.find_element(By.ID, "element_id")
        # - driver.find_element(By.NAME, "element_name")
        # - element.click()
        # - element.send_keys("text")
        
        logger.info("Test completed successfully!")
        
    except Exception as e:
        logger.error(f"Error during test: {e}", exc_info=True)
    
    finally:
        if driver:
            logger.info("Closing WebDriver session")
            driver.quit()


def main():
    """Main entry point."""
    logger.info("QtWebDriver Selenium Test Application")
    logger.info("=" * 50)
    
    try:
        test_qt_webdriver()
    except Exception as e:
        logger.error(f"Failed to run test: {e}")
        logger.info("\nMake sure QtWebDriver server is running:")
        logger.info("  LD_LIBRARY_PATH=/opt/qt/6.8.2/gcc_64/lib:$LD_LIBRARY_PATH \\")
        logger.info("    /workspaces/qtwebdriver/out/dist/desktop/release/bin/WebDriver_noWebkit")


if __name__ == "__main__":
    main()
