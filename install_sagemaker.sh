#!/bin/bash

# Stable Diffusion WebUI Installation Script for SageMaker
# Run this script in a SageMaker Notebook Instance terminal

set -e

echo "Starting Stable Diffusion WebUI installation on SageMaker..."

# Update system packages
sudo yum update -y

# Install required system packages
sudo yum install -y git wget curl

# Install Python dependencies
pip install --upgrade pip
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip install xformers

# Clone Stable Diffusion WebUI
cd /home/ec2-user/SageMaker
if [ ! -d "stable-diffusion-webui" ]; then
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
fi

cd stable-diffusion-webui

# Install WebUI dependencies
pip install -r requirements.txt

# Create models directory structure
mkdir -p models/Stable-diffusion
mkdir -p models/ControlNet
mkdir -p models/Lora

# Download base model (EpicRealism)
echo "Downloading EpicRealism model..."
cd models/Stable-diffusion
if [ ! -f "sd1_5-epiCRealism.safetensors" ]; then
    wget -O sd1_5-epiCRealism.safetensors "https://huggingface.co/emilianJR/epiCRealism/resolve/main/epicrealism_naturalSinRC1VAE.safetensors"
fi

# Download ControlNet models
echo "Downloading ControlNet models..."
cd ../ControlNet
if [ ! -f "control_v11p_sd15_inpaint.pth" ]; then
    wget -O control_v11p_sd15_inpaint.pth "https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_inpaint.pth"
fi

if [ ! -f "control_v11p_sd15_canny.pth" ]; then
    wget -O control_v11p_sd15_canny.pth "https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_canny.pth"
fi

# Return to webui directory
cd /home/ec2-user/SageMaker/stable-diffusion-webui

# Create launch configuration
cat > webui-user.sh << 'EOF'
#!/bin/bash
export COMMANDLINE_ARGS="--listen --port 8888 --enable-insecure-extension-access --xformers"
EOF

chmod +x webui-user.sh

echo "Installation completed successfully!"
echo "To start the WebUI, run: ./webui.sh"
echo "Access the WebUI at: https://<notebook-instance-name>.notebook.<region>.sagemaker.aws/proxy/8888/"
