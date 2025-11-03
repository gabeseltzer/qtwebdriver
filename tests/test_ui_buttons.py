#!/usr/bin/env python3
"""
Test QtWebDriver with interactive UI elements
"""

import logging
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options as ChromeOptions

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

def test_button_interactions():
    """Test button interactions on the test page"""
    logger.info("QtWebDriver UI Button Test")
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
        
        # Load the test page
        logger.info("\n1. Loading test page...")
        driver.get("http://localhost:9517/test.html")
        time.sleep(1)  # Give page time to load
        
        title = driver.title
        logger.info(f"✓ Page loaded: '{title}'")
        
        # Wait for page to be ready
        wait = WebDriverWait(driver, 10)
        
        # Test 1: Click "Say Hello" button
        logger.info("\n2. Testing 'Say Hello' button...")
        hello_btn = wait.until(
            EC.element_to_be_clickable((By.ID, "btn-hello"))
        )
        hello_btn.click()
        time.sleep(0.5)
        
        result = driver.find_element(By.ID, "result-text").text
        logger.info(f"✓ Result after clicking 'Say Hello': {result}")
        assert "Hello from QtWebDriver" in result, "Expected hello message"
        
        # Test 2: Click "Say Goodbye" button
        logger.info("\n3. Testing 'Say Goodbye' button...")
        goodbye_btn = driver.find_element(By.ID, "btn-goodbye")
        goodbye_btn.click()
        time.sleep(0.5)
        
        result = driver.find_element(By.ID, "result-text").text
        logger.info(f"✓ Result after clicking 'Say Goodbye': {result}")
        assert "Goodbye" in result, "Expected goodbye message"
        
        # Test 3: Clear message
        logger.info("\n4. Testing 'Clear Message' button...")
        clear_btn = driver.find_element(By.ID, "btn-clear")
        clear_btn.click()
        time.sleep(0.5)
        
        result = driver.find_element(By.ID, "result-text").text
        logger.info(f"✓ Result after clicking 'Clear': {result}")
        
        # Test 4: Counter operations
        logger.info("\n5. Testing counter buttons...")
        
        # Initial counter value
        counter = driver.find_element(By.ID, "counter").text
        logger.info(f"   Initial counter: {counter}")
        
        # Increment 3 times
        inc_btn = driver.find_element(By.ID, "btn-increment")
        for i in range(3):
            inc_btn.click()
            time.sleep(0.3)
        
        counter = driver.find_element(By.ID, "counter").text
        logger.info(f"✓ Counter after 3 increments: {counter}")
        assert counter == "3", f"Expected counter to be 3, got {counter}"
        
        # Decrement once
        dec_btn = driver.find_element(By.ID, "btn-decrement")
        dec_btn.click()
        time.sleep(0.3)
        
        counter = driver.find_element(By.ID, "counter").text
        logger.info(f"✓ Counter after 1 decrement: {counter}")
        assert counter == "2", f"Expected counter to be 2, got {counter}"
        
        # Reset counter
        reset_btn = driver.find_element(By.ID, "btn-reset")
        reset_btn.click()
        time.sleep(0.3)
        
        counter = driver.find_element(By.ID, "counter").text
        logger.info(f"✓ Counter after reset: {counter}")
        assert counter == "0", f"Expected counter to be 0, got {counter}"
        
        # Test 5: Text input and submit
        logger.info("\n6. Testing text input...")
        
        text_input = driver.find_element(By.ID, "text-input")
        test_text = "Hello from Selenium!"
        text_input.clear()
        text_input.send_keys(test_text)
        time.sleep(0.3)
        
        # Verify input value
        input_value = text_input.get_attribute("value")
        logger.info(f"   Entered text: '{input_value}'")
        
        # Submit the text
        submit_btn = driver.find_element(By.ID, "btn-submit")
        submit_btn.click()
        time.sleep(0.5)
        
        result = driver.find_element(By.ID, "result-text").text
        logger.info(f"✓ Result after submitting text: {result}")
        assert test_text in result, f"Expected result to contain '{test_text}'"
        
        # Test 6: Verify all buttons are present
        logger.info("\n7. Verifying all buttons are present...")
        button_ids = [
            "btn-hello", "btn-goodbye", "btn-clear",
            "btn-increment", "btn-decrement", "btn-reset",
            "btn-submit"
        ]
        
        for btn_id in button_ids:
            btn = driver.find_element(By.ID, btn_id)
            assert btn.is_displayed(), f"Button {btn_id} should be visible"
        
        logger.info(f"✓ All {len(button_ids)} buttons found and visible")
        
        logger.info("\n" + "=" * 80)
        logger.info("✓ All UI button tests passed!")
        
    except Exception as e:
        logger.error(f"Test failed: {e}")
        import traceback
        traceback.print_exc()
        raise
    finally:
        if driver:
            logger.info("\nClosing WebDriver session")
            driver.quit()

if __name__ == "__main__":
    logger.info("QtWebDriver UI Button Test Application")
    logger.info("=" * 80)
    logger.info("This test requires a Qt application with WebView/WebEngine support")
    logger.info("Make sure QtWebDriver is running with a view that can load HTML pages")
    logger.info("=" * 80)
    
    try:
        test_button_interactions()
        logger.info("\n✓ Test suite completed successfully!")
    except Exception as e:
        logger.error(f"\n✗ Test suite failed: {e}")
        exit(1)
