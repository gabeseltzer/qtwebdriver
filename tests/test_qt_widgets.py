#!/usr/bin/env python3
"""
Test QtWebDriver with Qt Widgets UI elements
"""

import logging
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.common.keys import Keys

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

def test_qt_widgets_buttons():
    """Test button interactions on Qt Widgets application"""
    logger.info("QtWebDriver Qt Widgets Button Test")
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
        
        # Get window info
        logger.info(f"\nWindow handles: {driver.window_handles}")
        logger.info(f"Current window: {driver.current_window_handle}")
        title = driver.title
        logger.info(f"Window title: '{title}'")
        
        # Wait for elements to be ready
        wait = WebDriverWait(driver, 10)
        
        # Test 1: Find and click "Say Hello" button
        logger.info("\n1. Testing 'Say Hello' button...")
        try:
            hello_btn = driver.find_element(By.NAME, "btn-hello")
            logger.info(f"   Found button: {hello_btn.tag_name}")
            hello_btn.click()
            time.sleep(0.5)
            
            result = driver.find_element(By.NAME, "result-text").text
            logger.info(f"✓ Result after clicking 'Say Hello': {result}")
        except Exception as e:
            logger.warning(f"⚠ Could not test Hello button: {e}")
        
        # Test 2: Click "Say Goodbye" button
        logger.info("\n2. Testing 'Say Goodbye' button...")
        try:
            goodbye_btn = driver.find_element(By.NAME, "btn-goodbye")
            goodbye_btn.click()
            time.sleep(0.5)
            
            result = driver.find_element(By.NAME, "result-text").text
            logger.info(f"✓ Result after clicking 'Say Goodbye': {result}")
        except Exception as e:
            logger.warning(f"⚠ Could not test Goodbye button: {e}")
        
        # Test 3: Clear message
        logger.info("\n3. Testing 'Clear Message' button...")
        try:
            clear_btn = driver.find_element(By.NAME, "btn-clear")
            clear_btn.click()
            time.sleep(0.5)
            
            result = driver.find_element(By.NAME, "result-text").text
            logger.info(f"✓ Result after clicking 'Clear': {result}")
        except Exception as e:
            logger.warning(f"⚠ Could not test Clear button: {e}")
        
        # Test 4: Counter operations
        logger.info("\n4. Testing counter buttons...")
        try:
            # Initial counter value
            counter = driver.find_element(By.NAME, "counter").text
            logger.info(f"   Initial counter: {counter}")
            
            # Increment 3 times
            inc_btn = driver.find_element(By.NAME, "btn-increment")
            for i in range(3):
                inc_btn.click()
                time.sleep(0.3)
            
            counter = driver.find_element(By.NAME, "counter").text
            logger.info(f"✓ Counter after 3 increments: {counter}")
            
            # Decrement once
            dec_btn = driver.find_element(By.NAME, "btn-decrement")
            dec_btn.click()
            time.sleep(0.3)
            
            counter = driver.find_element(By.NAME, "counter").text
            logger.info(f"✓ Counter after 1 decrement: {counter}")
            
            # Reset counter
            reset_btn = driver.find_element(By.NAME, "btn-reset")
            reset_btn.click()
            time.sleep(0.3)
            
            counter = driver.find_element(By.NAME, "counter").text
            logger.info(f"✓ Counter after reset: {counter}")
        except Exception as e:
            logger.warning(f"⚠ Could not test counter buttons: {e}")
        
        # Test 5: Text input and submit
        logger.info("\n5. Testing text input...")
        try:
            text_input = driver.find_element(By.NAME, "text-input")
            test_text = "Hello from Selenium!"
            text_input.clear()
            text_input.send_keys(test_text)
            time.sleep(0.3)
            
            # Verify input value
            input_value = text_input.get_attribute("value")
            logger.info(f"   Entered text: '{input_value}'")
            
            # Submit the text
            submit_btn = driver.find_element(By.NAME, "btn-submit")
            submit_btn.click()
            time.sleep(0.5)
            
            result = driver.find_element(By.NAME, "result-text").text
            logger.info(f"✓ Result after submitting text: {result}")
        except Exception as e:
            logger.warning(f"⚠ Could not test text input: {e}")
        
        # Test 6: List all elements
        logger.info("\n6. Finding all elements in the window...")
        try:
            # Try different strategies
            elements_by_tag = driver.find_elements(By.TAG_NAME, "*")
            logger.info(f"   Found {len(elements_by_tag)} elements by tag name")
            
            # Show some element details
            for i, elem in enumerate(elements_by_tag[:10]):  # Show first 10
                try:
                    tag = elem.tag_name
                    name = elem.get_attribute("name") or elem.get_attribute("objectName")
                    text = elem.text[:50] if elem.text else ""
                    logger.info(f"   [{i}] {tag} - name: {name}, text: {text}")
                except:
                    pass
                    
        except Exception as e:
            logger.warning(f"⚠ Could not list elements: {e}")
        
        logger.info("\n" + "=" * 80)
        logger.info("✓ Qt Widgets button test completed!")
        
    except Exception as e:
        logger.error(f"Test failed: {e}")
        import traceback
        traceback.print_exc()
    finally:
        if driver:
            logger.info("\nClosing WebDriver session")
            driver.quit()

if __name__ == "__main__":
    logger.info("QtWebDriver Qt Widgets Test Application")
    logger.info("=" * 80)
    logger.info("This test requires:")
    logger.info("1. The test_qt_app Qt application to be running")
    logger.info("2. QtWebDriver to be running and connected to the Qt app")
    logger.info("=" * 80)
    
    try:
        test_qt_widgets_buttons()
        logger.info("\n✓ Test completed!")
    except Exception as e:
        logger.error(f"\n✗ Test failed: {e}")
        exit(1)
