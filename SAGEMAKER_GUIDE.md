# Triển Khai Stable Diffusion WebUI trên Amazon SageMaker


## Bước 1: Triển Khai CloudFormation Stack

### 1.1 Tạo Stack

1. Đăng nhập AWS Console → CloudFormation
2. Click "Create stack" → "With new resources (standard)"
3. Upload file `sagemaker-stable-diffusion.yaml`
4. Click "Next"

### 1.2 Cấu Hình Parameters

- **NotebookInstanceName**: `stable-diffusion-notebook` (hoặc tên bạn muốn)
- **InstanceType**: `ml.g4dn.2xlarge` (khuyến nghị)
- **VolumeSize**: `100` GB (tối thiểu cho models)

### 1.3 Hoàn Tất Triển Khai

1. Review cấu hình
2. Check acknowledgment boxes cho IAM resources
3. Click "Create stack"
4. Đợi status "CREATE_COMPLETE" (khoảng 5-10 phút)

## Bước 2: Truy Cập SageMaker Notebook

### 2.1 Mở Notebook Instance

1. AWS Console → SageMaker → Notebook instances
2. Tìm instance `stable-diffusion-notebook`
3. Click "Open Jupyter" khi status là "InService"

### 2.2 Kiểm Tra Cài Đặt

1. Mở Terminal trong Jupyter
2. Chạy lệnh kiểm tra:

```bash
# Kiểm tra GPU
nvidia-smi

# Kiểm tra Python packages
pip list | grep torch
```

## Bước 3: Cài Đặt Stable Diffusion WebUI

### 3.1 Chạy Script Cài Đặt

Trong Terminal của Jupyter:

```bash
cd /home/ec2-user/SageMaker
wget https://raw.githubusercontent.com/your-repo/SD-EC2/main/install_sagemaker.sh
chmod +x install_sagemaker.sh
./install_sagemaker.sh
```

### 3.2 Theo Dõi Quá Trình Cài Đặt

```bash
# Xem log cài đặt
tail -f install.log

# Kiểm tra tiến trình
ps aux | grep python
```

## Bước 4: Khởi Động WebUI

### 4.1 Chạy WebUI

```bash
cd /home/ec2-user/SageMaker/stable-diffusion-webui
./webui.sh
```

### 4.2 Truy Cập WebUI

1. Lấy URL từ CloudFormation Outputs tab: `WebUIURL`
2. Hoặc truy cập: `https://[notebook-name].notebook.[region].sagemaker.aws/proxy/8888/`

## Bước 5: Cấu Hình WebUI cho Inpainting

### 5.1 Chọn Model

1. Trong WebUI interface, chọn model dropdown
2. Chọn: `sd1_5-epiCRealism.safetensors`

### 5.2 Cài Đặt ControlNet Extension

1. Vào tab "Extensions"
2. Click "Install from URL"
3. Paste URL: `https://github.com/Mikubill/sd-webui-controlnet.git`
4. Click "Install"
5. Restart WebUI

### 5.3 Cấu Hình Inpainting

1. Chuyển sang tab "img2img" → "Inpaint"
2. Upload ảnh gốc
3. Sử dụng brush tool để mask vùng cần chỉnh sửa
4. Cấu hình ControlNet:
   - Enable ControlNet
   - Model: `control_v11p_sd15_inpaint`
   - Control mode: "ControlNet is more important"

## Bước 6: Tối Ưu Hóa và Quản Lý

### 6.1 Lưu Trữ Models

```bash
# Tạo symbolic link đến S3 bucket
aws s3 sync models/ s3://your-bucket-name/models/

# Tạo script backup
cat > backup_models.sh << 'EOF'
#!/bin/bash
aws s3 sync /home/ec2-user/SageMaker/stable-diffusion-webui/models/ \
    s3://$(aws cloudformation describe-stacks --stack-name stable-diffusion-webui \
    --query 'Stacks[0].Outputs[?OutputKey==`S3BucketName`].OutputValue' --output text)/models/
EOF
```

### 6.2 Tự Động Khởi Động

Tạo notebook để tự động khởi động WebUI:

```python
# Tạo file: auto_start_webui.ipynb
import subprocess
import os
import time

def start_webui():
    os.chdir('/home/ec2-user/SageMaker/stable-diffusion-webui')
    
    # Set environment variables
    env = os.environ.copy()
    env['COMMANDLINE_ARGS'] = '--listen --port 8888 --enable-insecure-extension-access --xformers'
    
    # Start WebUI
    process = subprocess.Popen(['python', 'launch.py'], env=env)
    
    print("WebUI starting... Please wait 2-3 minutes")
    print("Access at: https://[your-notebook].notebook.[region].sagemaker.aws/proxy/8888/")
    
    return process

# Chạy function
webui_process = start_webui()
```

## Bước 7: Quản Lý Chi Phí

### 7.1 Tự Động Tắt Instance

1. SageMaker Console → Notebook instances
2. Chọn instance → Actions → Stop
3. Hoặc set up CloudWatch alarm để tự động stop

### 7.2 Lifecycle Configuration

Thêm script tự động stop sau thời gian không hoạt động:

```bash
# Trong lifecycle config
echo "*/30 * * * * /home/ec2-user/check_idle.sh" | crontab -
```

## Troubleshooting

### Lỗi Thường Gặp

**GPU không được nhận diện:**
```bash
# Kiểm tra CUDA
nvcc --version
nvidia-smi

# Cài đặt lại PyTorch
pip uninstall torch torchvision torchaudio
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
```

**WebUI không khởi động:**
```bash
# Kiểm tra port
netstat -tulpn | grep 8888

# Xem log lỗi
cd /home/ec2-user/SageMaker/stable-diffusion-webui
python launch.py --help
```

**Hết dung lượng:**
```bash
# Kiểm tra dung lượng
df -h

# Dọn dẹp cache
pip cache purge
rm -rf ~/.cache/huggingface/
```

### Tối Ưu Hóa Performance

**Cấu hình memory:**
```bash
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
export COMMANDLINE_ARGS="--medvram --opt-split-attention"
```

**Sử dụng xformers:**
```bash
pip install xformers
export COMMANDLINE_ARGS="--xformers"
```

## Dọn Dẹp Resources

### Xóa Stack

1. CloudFormation Console
2. Chọn stack `stable-diffusion-webui`
3. Click "Delete"
4. Confirm deletion

### Backup Trước Khi Xóa

```bash
# Backup models và outputs
aws s3 sync /home/ec2-user/SageMaker/stable-diffusion-webui/outputs/ \
    s3://your-backup-bucket/outputs/

# Export notebook configurations
jupyter nbconvert --to script *.ipynb
```

## Kết Luận

SageMaker cung cấp môi trường mạnh mẽ và linh hoạt cho việc chạy Stable Diffusion WebUI với:

- Quản lý tài nguyên tự động
- Tích hợp Jupyter Notebook
- Bảo mật và compliance cao
- Chi phí tối ưu với pay-per-use

Môi trường này phù hợp cho:
- Phát triển và thử nghiệm
- Training custom models
- Batch processing
- Collaborative work

## Hỗ Trợ

- **AWS SageMaker**: [Documentation](https://docs.aws.amazon.com/sagemaker/)
- **Stable Diffusion WebUI**: [AUTOMATIC1111 GitHub](https://github.com/AUTOMATIC1111/stable-diffusion-webui)
- **ControlNet**: [Extension Documentation](https://github.com/Mikubill/sd-webui-controlnet)

## DISCLAIMER
- Chỉ dành cho mục đích học tập/tham khảo
- Không phải production-ready, sử dụng với trách nhiệm của bạn
- Không có bảo hành - test kỹ trước khi sử dụng
- Tác giả không chịu trách nhiệm về bất kỳ thiệt hại nào
