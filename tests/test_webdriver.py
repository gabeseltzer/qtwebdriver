#!/usr/bin/env python3
"""
Simple Python application to test QtWebDriver server connection.
Connects to the WebDriver server and performs basic operations.
"""

import logging
import requests
import json
import time

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


class QtWebDriverClient:
    """Simple client for QtWebDriver server."""
    
    def __init__(self, base_url="http://localhost:9517"):
        self.base_url = base_url
        self.session_id = None
        logger.info(f"Initialized WebDriver client for {base_url}")
    
    def get_status(self):
        """Get server status."""
        url = f"{self.base_url}/status"
        logger.info(f"Getting server status from {url}")
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        logger.info(f"Server status: {json.dumps(data, indent=2)}")
        return data
    
    def create_session(self, capabilities=None):
        """Create a new WebDriver session."""
        if capabilities is None:
            capabilities = {
                "desiredCapabilities": {
                    "browserName": "Qt",
                    "platform": "ANY"
                }
            }
        
        url = f"{self.base_url}/session"
        logger.info(f"Creating new session at {url}")
        logger.info(f"Capabilities: {json.dumps(capabilities, indent=2)}")
        
        response = requests.post(url, json=capabilities)
        response.raise_for_status()
        data = response.json()
        
        if "sessionId" in data:
            self.session_id = data["sessionId"]
            logger.info(f"Session created with ID: {self.session_id}")
        else:
            logger.warning(f"Response: {json.dumps(data, indent=2)}")
        
        return data
    
    def get_sessions(self):
        """Get list of active sessions."""
        url = f"{self.base_url}/sessions"
        logger.info(f"Getting active sessions from {url}")
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        logger.info(f"Active sessions: {json.dumps(data, indent=2)}")
        return data
    
    def delete_session(self, session_id=None):
        """Delete a WebDriver session."""
        sid = session_id or self.session_id
        if not sid:
            logger.warning("No session ID available")
            return None
        
        url = f"{self.base_url}/session/{sid}"
        logger.info(f"Deleting session {sid}")
        response = requests.delete(url)
        response.raise_for_status()
        
        if session_id is None:
            self.session_id = None
        
        logger.info("Session deleted successfully")
        return response.json()
    
    def execute_command(self, session_id, command, method="POST", data=None):
        """Execute a WebDriver command."""
        url = f"{self.base_url}/session/{session_id}/{command}"
        logger.info(f"Executing {method} {url}")
        
        if method == "GET":
            response = requests.get(url)
        elif method == "POST":
            response = requests.post(url, json=data or {})
        elif method == "DELETE":
            response = requests.delete(url)
        else:
            raise ValueError(f"Unsupported method: {method}")
        
        response.raise_for_status()
        result = response.json()
        logger.info(f"Result: {json.dumps(result, indent=2)}")
        return result


def main():
    """Main function to test WebDriver connection."""
    logger.info("Starting QtWebDriver test application")
    
    client = QtWebDriverClient()
    
    try:
        # Check if server is running
        logger.info("\n=== Checking Server Status ===")
        status = client.get_status()
        
        # Get active sessions
        logger.info("\n=== Getting Active Sessions ===")
        sessions = client.get_sessions()
        
        # Try to create a session
        logger.info("\n=== Creating New Session ===")
        try:
            session_data = client.create_session()
            
            if client.session_id:
                # Wait a bit
                time.sleep(1)
                
                # Delete the session
                logger.info("\n=== Deleting Session ===")
                client.delete_session()
        except requests.exceptions.HTTPError as e:
            logger.error(f"Failed to create session: {e}")
            logger.info("This might be expected if no Qt application is running")
        
        logger.info("\n=== Test Complete ===")
        logger.info("WebDriver server is responding correctly!")
        
    except requests.exceptions.ConnectionError:
        logger.error("Could not connect to WebDriver server at http://localhost:9517")
        logger.error("Make sure the server is running with:")
        logger.error("  LD_LIBRARY_PATH=/opt/qt/6.8.2/gcc_64/lib:$LD_LIBRARY_PATH \\")
        logger.error("    /workspaces/qtwebdriver/out/dist/desktop/release/bin/WebDriver_noWebkit")
    except Exception as e:
        logger.error(f"An error occurred: {e}", exc_info=True)


if __name__ == "__main__":
    main()
