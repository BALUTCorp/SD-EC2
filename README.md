# Stable Diffusion WebUI CloudFormation Deployment Guide

This guide walks you through deploying Stable Diffusion WebUI on AWS using CloudFormation and provides step-by-step instructions for image inpainting with ControlNet.

## Prerequisites

- AWS Account with appropriate permissions
- Basic familiarity with AWS Console

## Deployment Steps

### Step 1: Create EC2 Key Pair

1. Navigate to AWS Console → EC2 → Key Pairs
2. Click "Create key pair"
3. Enter a name for your key pair (e.g., `stable-diffusion-key`)
4. Select key pair type: RSA
5. Select private key file format: `.pem` (for Linux/Mac) or `.ppk` (for Windows)
6. Click "Create key pair"
7. Download and save the private key file securely

### Step 2: Deploy CloudFormation Stack

1. Navigate to AWS Console → CloudFormation
2. Click "Create stack" → "With new resources (standard)"
3. Upload your CloudFormation template file
4. Click "Next"

### Step 3: Configure Stack Parameters

1. **Stack name**: Enter a descriptive name (e.g., `stable-diffusion-webui`)
2. **Instance Type**: Select `g4dn.2xlarge` from the dropdown
3. **Key Pair**: Select the EC2 key pair you created in Step 1
4. Configure other parameters as needed
5. Click "Next"

### Step 4: Configure Stack Options

1. Add tags if desired (optional)
2. Configure advanced options if needed (optional)
3. Click "Next"

### Step 5: Review and Create

1. Review all configurations
2. Check the acknowledgment boxes for IAM resources (if applicable)
3. Click "Create stack"

### Step 6: Wait for Deployment

1. Monitor the stack creation progress in the CloudFormation console
2. Wait for the stack status to show "CREATE_COMPLETE"
3. **Important**: After stack creation completes, wait an additional 5 minutes for the initialization script to finish setting up Stable Diffusion WebUI on the EC2 instance

### Step 7: Access WebUI

1. Go to the "Outputs" tab of your CloudFormation stack
2. Find the `WebUIURL` output
3. Click on the URL or copy it to your browser
4. The URL format will be: `http://[EC2-Public-DNS]:7860`

## Stable Diffusion WebUI Setup Guide

Once you can access the WebUI, follow these steps to set up image inpainting with ControlNet:

### Step 1: Select Model

1. In the WebUI interface, locate the model dropdown
2. Select: `sd1_5-epiCRealism.safetensors`

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

- Ensure you waited the full 5 minutes after stack creation
- Check that your security group allows inbound traffic on port 7860
- Verify the EC2 instance is running

**Model not loading:**

- The initial model download may take time
- Check the EC2 instance logs for any errors

**Poor inpainting results:**

- Adjust the denoising strength
- Try different prompts
- Ensure your mask covers the appropriate areas

### Resource Cleanup

When you're done using the WebUI:

1. Go to CloudFormation console
2. Select your stack
3. Click "Delete" to remove all resources and avoid ongoing charges

## Support

For issues with:

- **AWS/CloudFormation**: Check AWS CloudFormation documentation
- **Stable Diffusion WebUI**: Refer to the official AUTOMATIC1111 documentation
- **ControlNet**: Check the ControlNet extension documentation

## DISCLAIMER
- For educational/reference purposes only
- Not production-ready, use at your own risk
- No warranty provided - test thoroughly before use
- Author not liable for any damages or issues
