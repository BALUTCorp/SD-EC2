# Stable Diffusion WebUI Deployment Guide

This repository provides guides for deploying Stable Diffusion WebUI on AWS using different approaches. Choose the deployment method that best suits your needs.

## Deployment Options

### Option 1: SageMaker Deployment (Recommended)

Deploy Stable Diffusion WebUI on Amazon SageMaker for a managed, scalable environment with GPU acceleration.

**Benefits:**
- Managed infrastructure
- Easy scaling
- Built-in Jupyter integration
- Pay-per-use pricing
- No need to manage EC2 instances

**Documentation:**
- [SageMaker Deployment Guide](SAGEMAKER_GUIDE.md) - Detailed guide for manual deployment
- [Automated SageMaker Deployment Guide](AUTO_DEPLOYMENT_GUIDE.md) - Guide for fully automated deployment

**Quick Start:**
```bash
# Deploy using CloudFormation with G6 instance (latest NVIDIA GPU)
aws cloudformation create-stack \
  --stack-name stable-diffusion-webui-g6 \
  --template-body file://sagemaker-g6.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameters ParameterKey=InstanceType,ParameterValue=ml.g6.2xlarge
```

### Option 2: EC2 Deployment (Legacy)

Deploy Stable Diffusion WebUI directly on an EC2 instance.

**Documentation:**
- [EC2 Deployment Guide](EC2_GUIDE.md) - Detailed guide for EC2 deployment

## Stable Diffusion WebUI Usage Guide

Once you have deployed the WebUI using either method, follow these steps to set up image inpainting with ControlNet:

### Step 1: Select Model

1. In the WebUI interface, locate the model dropdown
2. Select: `sd1_5-epiCRealism.safetensors` (or your preferred model)

### Step 2: Navigate to Inpaint

1. Click on the "img2img" tab
2. Select the "Inpaint" sub-tab

### Step 3: Configure Prompt

1. In the prompt field, write a description for your desired output image
2. Example: "a beautiful landscape with mountains and lake, high quality, detailed"

### Step 4: Upload and Mask Image

1. Click "Upload" to upload your base image
2. Use the brush tool to paint over the areas you want to expand/modify
3. Paint along the edges where you want the image to be extended

### Step 5: Configure Inpaint Settings

1. **Resize mode**: Select "Resize and fill"
2. **Mask mode**: Select "Inpaint masked"
3. **Denoising strength**: Adjust the slider (higher values = more changes, lower values = closer to original)

### Step 6: Enable ControlNet

1. Scroll down to find the "ControlNet" section
2. Check the "Enable" checkbox

### Step 7: Configure ControlNet

1. **Upload control image**: Click "Upload independent control image"
2. Upload the same image you used for inpainting (or a different control image)
3. **Control type**: Select "Inpaint"
4. **Model**: Choose `Control_v11p_sd15_inpaint` from the dropdown
5. **Control mode**: Select "ControlNet is more important"
6. **Resize mode**: Select "Resize and fill"

### Step 8: Generate Image

1. Click the "Generate" button
2. Wait for the processing to complete
3. Review the generated result in the output panel

## Troubleshooting

### Common Issues

**WebUI not accessible:**
- Check the deployment logs
- Verify that the instance is running
- Ensure proper network connectivity

**Model not loading:**
- The initial model download may take time
- Check logs for any errors

**Poor inpainting results:**
- Adjust the denoising strength
- Try different prompts
- Ensure your mask covers the appropriate areas

### Resource Cleanup

When you're done using the WebUI:

1. For SageMaker: Stop or delete the notebook instance
   ```bash
   aws sagemaker stop-notebook-instance --notebook-instance-name stable-diffusion-g6
   ```

2. For EC2/CloudFormation: Delete the stack
   ```bash
   aws cloudformation delete-stack --stack-name stable-diffusion-webui
   ```

## Support

For issues with:
- **AWS/CloudFormation**: Check AWS documentation
- **Stable Diffusion WebUI**: Refer to the [official AUTOMATIC1111 documentation](https://github.com/AUTOMATIC1111/stable-diffusion-webui)
- **ControlNet**: Check the [ControlNet extension documentation](https://github.com/Mikubill/sd-webui-controlnet)

## DISCLAIMER
- For educational/reference purposes only
- Not production-ready, use at your own risk
- No warranty provided - test thoroughly before use
- Author not liable for any damages or issues
