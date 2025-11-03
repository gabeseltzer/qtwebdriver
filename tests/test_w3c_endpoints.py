#!/usr/bin/env python3
"""
Test W3C WebDriver endpoints with QtWebDriver
"""

import logging
from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

def test_w3c_endpoints():
    """Test W3C WebDriver protocol endpoints"""
    logger.info("W3C WebDriver Endpoint Test")
    logger.info("=" * 80)
    
    # Configure for QtWebDriver
    options = ChromeOptions()
    options.set_capability("browserName", "Qt")
    
    driver = None
    try:
        # Connect to QtWebDriver
        logger.info("Connecting to QtWebDriver at http://localhost:9517")
        driver = webdriver.Remote(
            command_executor="http://localhost:9517",
            options=options
        )
        logger.info(f"✓ Session created: {driver.session_id}")
        
        # Test 1: Window handles (already tested, but let's verify)
        logger.info("\nTest 1: GET /session/{id}/window/handles")
        windows = driver.window_handles
        logger.info(f"✓ Window handles: {windows}")
        
        # Test 2: Current window handle
        logger.info("\nTest 2: GET /session/{id}/window")
        current = driver.current_window_handle
        logger.info(f"✓ Current window: {current}")
        
        # Test 3: Execute script (W3C: /session/{id}/execute/sync)
        logger.info("\nTest 3: POST /session/{id}/execute/sync")
        try:
            result = driver.execute_script("return 2 + 2;")
            logger.info(f"✓ Execute script result: {result}")
        except Exception as e:
            logger.warning(f"⚠ Execute script failed: {e}")
        
        # Test 3.5: Set timeouts (W3C format)
        logger.info("\nTest 3.5: POST /session/{id}/timeouts (W3C format)")
        try:
            driver.set_script_timeout(10)
            driver.implicitly_wait(1)
            driver.set_page_load_timeout(30)
            logger.info(f"✓ Timeouts set successfully (W3C format)")
        except Exception as e:
            logger.warning(f"⚠ Set timeouts failed: {e}")
        
        # Test 4: Execute async script (W3C: /session/{id}/execute/async)
        logger.info("\nTest 4: POST /session/{id}/execute/async")
        try:
            driver.set_script_timeout(5)
            result = driver.execute_async_script("arguments[arguments.length - 1](42);")
            logger.info(f"✓ Execute async script result: {result}")
        except Exception as e:
            # Expected to fail without a real view that supports JavaScript
            logger.info(f"⚠ Execute async script failed (expected without JS view): {type(e).__name__}")
        
        # Test 5: Get title
        logger.info("\nTest 5: GET /session/{id}/title")
        try:
            title = driver.title
            logger.info(f"✓ Title: '{title}'")
        except Exception as e:
            logger.warning(f"⚠ Get title failed: {e}")
        
        # Test 6: Maximize window (W3C: /session/{id}/window/maximize)
        logger.info("\nTest 6: POST /session/{id}/window/maximize")
        try:
            driver.maximize_window()
            logger.info(f"✓ Window maximized")
        except Exception as e:
            # Expected to fail without a real view executor
            logger.info(f"⚠ Maximize window failed (expected without real view): {type(e).__name__}")
        
        logger.info("\n" + "=" * 80)
        logger.info("W3C endpoint tests completed!")
        
    except Exception as e:
        logger.error(f"Test failed: {e}")
        import traceback
        traceback.print_exc()
    finally:
        if driver:
            logger.info("Closing WebDriver session")
            driver.quit()

if __name__ == "__main__":
    test_w3c_endpoints()
