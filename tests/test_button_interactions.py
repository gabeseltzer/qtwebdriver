#!/usr/bin/env python3
"""
Test script for QtWebDriver Test Application
Connects to the QtWebDriver server and interacts with UI buttons

Usage:
    python test_button_interactions.py

Make sure the test_qt_app is running before executing this script.
"""

import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.chromium.options import ChromiumOptions


class QtWebDriverOptions(ChromiumOptions):
    """Custom options class for QtWebDriver"""
    
    def __init__(self):
        super().__init__()
        self._caps = {
            "browserName": "qt",
            "browserStartWindow": "*"  # Connect to existing window
        }
    
    @property
    def capabilities(self):
        return self._caps
    
    def to_capabilities(self):
        return self._caps


def connect_to_qtwebdriver(url="http://localhost:9517"):
    """Connect to the QtWebDriver server"""
    print(f"Connecting to QtWebDriver at {url}...")
    
    # Create QtWebDriver options
    options = QtWebDriverOptions()
    
    # Create remote webdriver connection
    driver = webdriver.Remote(
        command_executor=url,
        options=options
    )
    
    print("✓ Connected to QtWebDriver successfully")
    return driver


def wait_for_element(driver, object_name, timeout=10):
    """Wait for an element to be present and visible using XPath"""
    try:
        # Use XPath to find element by objectName attribute
        xpath = f"//*[@objectName='{object_name}']"
        # Use find_element directly to get proper WebElement object
        element = driver.find_element(By.XPATH, xpath)
        return element
    except Exception as e:
        print(f"✗ Error finding element: {object_name} - {e}")
        raise


def test_hello_button(driver):
    """Test the 'Say Hello' button"""
    print("\n--- Testing Hello Button ---")
    
    # Find and click the hello button
    hello_btn = wait_for_element(driver, "btn-hello")
    print(f"Found button: {hello_btn.text}")
    hello_btn.click()
    print("✓ Clicked 'Say Hello' button")
    
    # Verify the result text
    time.sleep(0.5)  # Give UI time to update
    result_label = wait_for_element(driver, "result-text")
    result_text = result_label.text
    print(f"Result text: {result_text}")
    assert "Hello from QtWebDriver!" in result_text, f"Expected 'Hello from QtWebDriver!' but got '{result_text}'"
    print("✓ Result text verified")


def test_goodbye_button(driver):
    """Test the 'Say Goodbye' button"""
    print("\n--- Testing Goodbye Button ---")
    
    goodbye_btn = wait_for_element(driver, "btn-goodbye")
    print(f"Found button: {goodbye_btn.text}")
    goodbye_btn.click()
    print("✓ Clicked 'Say Goodbye' button")
    
    time.sleep(0.5)
    result_label = wait_for_element(driver, "result-text")
    result_text = result_label.text
    print(f"Result text: {result_text}")
    assert "Goodbye!" in result_text, f"Expected 'Goodbye!' but got '{result_text}'"
    print("✓ Result text verified")


def test_counter_buttons(driver):
    """Test the counter increment/decrement buttons"""
    print("\n--- Testing Counter Buttons ---")
    
    # Get initial counter value
    counter_label = wait_for_element(driver, "counter")
    initial_value = int(counter_label.text)
    print(f"Initial counter value: {initial_value}")
    
    # Test increment button
    increment_btn = wait_for_element(driver, "btn-increment")
    print(f"Found button: {increment_btn.text}")
    for i in range(3):
        increment_btn.click()
        time.sleep(0.3)
    print("✓ Clicked 'Increment' button 3 times")
    
    # Verify counter increased
    time.sleep(0.5)
    counter_label = wait_for_element(driver, "counter")
    new_value = int(counter_label.text)
    print(f"New counter value: {new_value}")
    expected = initial_value + 3
    assert new_value == expected, f"Expected counter to be {expected} but got {new_value}"
    print("✓ Counter incremented correctly")
    
    # Test decrement button
    decrement_btn = wait_for_element(driver, "btn-decrement")
    print(f"Found button: {decrement_btn.text}")
    for i in range(2):
        decrement_btn.click()
        time.sleep(0.3)
    print("✓ Clicked 'Decrement' button 2 times")
    
    # Verify counter decreased
    time.sleep(0.5)
    counter_label = wait_for_element(driver, "counter")
    final_value = int(counter_label.text)
    print(f"Final counter value: {final_value}")
    expected = new_value - 2
    assert final_value == expected, f"Expected counter to be {expected} but got {final_value}"
    print("✓ Counter decremented correctly")
    
    # Test reset button
    reset_btn = wait_for_element(driver, "btn-reset")
    print(f"Found button: {reset_btn.text}")
    reset_btn.click()
    print("✓ Clicked 'Reset Counter' button")
    
    time.sleep(0.5)
    counter_label = wait_for_element(driver, "counter")
    reset_value = int(counter_label.text)
    print(f"Counter after reset: {reset_value}")
    assert reset_value == 0, f"Expected counter to be 0 but got {reset_value}"
    print("✓ Counter reset correctly")


def test_text_input(driver):
    """Test the text input and submit button"""
    print("\n--- Testing Text Input ---")
    
    # Find text input field
    text_input = wait_for_element(driver, "text-input")
    print("Found text input field")
    
    # Clear any existing text and type new text
    text_input.clear()
    test_text = "Hello from Selenium!"
    text_input.send_keys(test_text)
    print(f"✓ Typed text: '{test_text}'")
    
    # Click submit button
    submit_btn = wait_for_element(driver, "btn-submit")
    print(f"Found button: {submit_btn.text}")
    submit_btn.click()
    print("✓ Clicked 'Submit Text' button")
    
    # Verify result
    time.sleep(0.5)
    result_label = wait_for_element(driver, "result-text")
    result_text = result_label.text
    print(f"Result text: {result_text}")
    assert test_text in result_text, f"Expected '{test_text}' in result but got '{result_text}'"
    print("✓ Text submission verified")


def test_clear_button(driver):
    """Test the clear message button"""
    print("\n--- Testing Clear Button ---")
    
    clear_btn = wait_for_element(driver, "btn-clear")
    print(f"Found button: {clear_btn.text}")
    clear_btn.click()
    print("✓ Clicked 'Clear Message' button")
    
    time.sleep(0.5)
    result_label = wait_for_element(driver, "result-text")
    result_text = result_label.text
    print(f"Result text: {result_text}")
    assert "Message cleared" in result_text, f"Expected 'Message cleared' but got '{result_text}'"
    print("✓ Message cleared successfully")


def main():
    """Main test execution"""
    driver = None
    
    try:
        # Connect to QtWebDriver
        driver = connect_to_qtwebdriver()
        
        # Get page source to verify connection
        print("\nGetting page source...")
        page_source = driver.page_source
        print(f"Page source length: {len(page_source)} characters")
        
        # Run all tests
        test_hello_button(driver)
        test_goodbye_button(driver)
        test_counter_buttons(driver)
        test_text_input(driver)
        test_clear_button(driver)
        
        print("\n" + "=" * 50)
        print("✓ All tests passed successfully!")
        print("=" * 50)
        
    except Exception as e:
        print(f"\n✗ Error during test execution: {e}")
        import traceback
        traceback.print_exc()
        return 1
        
    finally:
        if driver:
            print("\nClosing connection...")
            # For embedded QtWebDriver, use close() instead of quit()
            # quit() would close the application window
            try:
                driver.close()
            except:
                pass  # Ignore errors if already closed
            print("✓ Connection closed")
    
    return 0


if __name__ == "__main__":
    exit(main())
