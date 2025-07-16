#!/usr/bin/env python3
"""
Launch script for Stable Diffusion WebUI on SageMaker
"""

import subprocess
import sys
import os

def main():
    # Set environment variables
    os.environ['COMMANDLINE_ARGS'] = '--listen --port 8888 --enable-insecure-extension-access --xformers'
    
    # Change to webui directory
    webui_dir = '/home/ec2-user/SageMaker/stable-diffusion-webui'
    os.chdir(webui_dir)
    
    # Launch webui
    try:
        subprocess.run([sys.executable, 'launch.py'], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error launching WebUI: {e}")
        return 1
    
    return 0

if __name__ == '__main__':
    sys.exit(main())
