
# Hướng Dẫn Deploy Stable Diffusion WebUI Trên AWS với CloudFormation

## Phần I: Chuẩn Bị Trước Khi Deploy

### Yêu Cầu Hệ Thống:

- **Tài khoản AWS** với quyền tạo EC2, VPC, Security Group[^1]
- **Kiến thức cơ bản** về AWS Console[^1]
- **Budget ước tính**: \$1-5/giờ tùy loại instance (G5/G6)[^2]


### Lưu Ý Quan Trọng:

- Template sử dụng **GPU instances** (G5/G6 series) để chạy AI models[^2]
- **Chi phí cao**: Các instance GPU có giá từ \$0.5-15/giờ
- **Storage**: 200GB EBS sẽ tự động được tạo[^2]


## Phần II: Hướng Dẫn Deploy Chi Tiết

### Bước 1: Tạo EC2 Key Pair

1. **Truy cập AWS Console** → EC2 → Key Pairs[^1]
2. **Nhấp "Create key pair"**[^1]
3. **Nhập tên key pair** (ví dụ: `stable-diffusion-key`)[^1]
4. **Chọn loại key**: RSA[^1]
5. **Chọn định dạng file**:[^1]
    - `.pem` cho Linux/Mac
    - `.ppk` cho Windows PuTTY
6. **Nhấp "Create key pair"** và tải file về máy[^1]
7. **Bảo mật file key** - không chia sẻ với ai

### Bước 2: Upload CloudFormation Template

1. **Truy cập AWS Console** → CloudFormation[^1]
2. **Nhấp "Create stack"** → "With new resources (standard)"[^1]
3. **Upload file CloudFormation.yaml** đã cung cấp[^1]
4. **Nhấp "Next"**[^1]

### Bước 3: Cấu Hình Tham Số Stack

**Tham số bắt buộc:**[^1]

- **Stack name**: Đặt tên mô tả (ví dụ: `stable-diffusion-webui`)
- **Instance Type**: Chọn từ danh sách:[^2]
    - `g5.xlarge` (4 vCPU, 16GB RAM) - Khuyến nghị cho test
    - `g5.2xlarge` (8 vCPU, 32GB RAM) - Tốt cho production
    - `g6.xlarge` đến `g6.48xlarge` - Các tùy chọn mạnh hơn
- **Key Pair**: Chọn key pair đã tạo ở Bước 1[^1]

**Tham số tùy chọn:**[^2]

- **MyIP**: Để mặc định `0.0.0.0/0` hoặc nhập IP cụ thể cho bảo mật


### Bước 4: Xem Lại và Tạo Stack

1. **Cấu hình tags** (tùy chọn)[^1]
2. **Xem lại tất cả cấu hình**[^1]
3. **Tick vào các checkbox IAM** nếu có[^1]
4. **Nhấp "Create stack"**[^1]

### Bước 5: Chờ Deployment Hoàn Thành

1. **Theo dõi quá trình** trong CloudFormation console[^1]
2. **Chờ status "CREATE_COMPLETE"**[^1]
3. **⚠️ QUAN TRỌNG**: Chờ thêm **5 phút** sau khi stack hoàn thành để script initialization chạy xong[^1]

## Phần III: Hạ Tầng Được Tạo Tự Động

### Network Infrastructure:[^2]

- **VPC**: 10.0.0.0/16 với DNS support
- **Public Subnet**: 10.0.0.0/24
- **Internet Gateway**: Kết nối internet
- **Route Table**: Public routing
- **Security Group**:
    - SSH (port 22): Restricted theo IP
    - WebUI (port 7860): Public access


### Compute Resources:[^2]

- **EC2 Instance**: G5/G6 với GPU
- **Storage**: 200GB GP3 EBS volume
- **AMI**: Amazon Linux 2023
- **Auto-termination**: EBS sẽ xóa khi terminate instance


### Software Stack (Tự Động Cài Đặt):[^2]

- **Python 3.11** + pip + dependencies
- **Stable Diffusion WebUI** (AUTOMATIC1111)
- **Model**: sd1_5-epiCRealism.safetensors (4GB)
- **ControlNet Extension** + model control_v11p_sd15_inpaint.pth
- **WebUI Server**: Chạy trên port 7860


## Phần IV: Truy Cập và Sử Dụng WebUI

### Bước 1: Lấy URL WebUI

1. **Vào tab "Outputs"** của CloudFormation stack[^1]
2. **Tìm "WebUIURL"** - sẽ có dạng: `http://[EC2-Public-DNS]:7860`[^1]
3. **Click vào URL** hoặc copy vào browser[^1]

### Bước 2: Cấu Hình Image Inpainting

**Chọn Model:**[^1]

1. Trong WebUI, tìm dropdown model
2. Chọn: `sd1_5-epiCRealism.safetensors`

**Thiết Lập Inpaint:**[^1]

1. Nhấp tab "img2img" → "Inpaint"
2. Viết prompt mô tả ảnh mong muốn
3. Upload ảnh gốc và vẽ mask vùng cần sửa
4. Cấu hình:
    - **Resize mode**: "Resize and fill"
    - **Mask mode**: "Inpaint masked"
    - **Denoising strength**: Điều chỉnh theo nhu cầu

**Kích Hoạt ControlNet:**[^1]

1. Kéo xuống phần "ControlNet"
2. Tick "Enable"
3. Upload control image (có thể dùng ảnh gốc)
4. Chọn:
    - **Control type**: "Inpaint"
    - **Model**: `Control_v11p_sd15_inpaint`
    - **Control mode**: "ControlNet is more important"
    - **Resize mode**: "Resize and fill"

### Bước 3: Generate và Tối Ưu

1. **Nhấp "Generate"** và chờ xử lý[^1]
2. **Xem kết quả** trong output panel[^1]
3. **Tối ưu nếu cần**:
    - Điều chỉnh denoising strength
    - Thay đổi prompt
    - Vẽ lại mask area

## Phần V: Troubleshooting

### Lỗi Thường Gặp:

**WebUI không truy cập được:**[^1]

- Kiểm tra đã chờ đủ 5 phút sau khi stack tạo xong
- Xem Security Group có mở port 7860
- Verify EC2 instance đang chạy

**Model không load:**[^1]

- Download model ban đầu mất thời gian
- Check EC2 logs để xem lỗi

**Kết quả inpainting kém:**[^1]

- Giảm/tăng denoising strength
- Thử prompt khác
- Vẽ lại mask chính xác hơn


### Monitoring và Logs:

```bash
# SSH vào instance để check logs
ssh -i /path/to/your-key.pem ec2-user@[EC2-Public-DNS]
cd stable-diffusion-webui
tail -f nohup.out
```


## Phần VI: Quản Lý Chi Phí

### Dọn Dẹp Resources:

**Khi không sử dụng:**[^1]

1. Vào CloudFormation console
2. Chọn stack của mình
3. Nhấp "Delete"
4. Tất cả resources sẽ tự động xóa

### Tối Ưu Chi Phí:

- **Stop instance** thay vì terminate nếu dùng tạm thời
- **Snapshot EBS** trước khi xóa nếu muốn giữ data
- **Monitor CloudWatch** để track usage
- **Set billing alerts** để tránh surprise charges


## Phần VII: Bảo Mật và Best Practices

### Bảo Mật:

- **Hạn chế SSH access** bằng cách set MyIP parameter chính xác
- **Đổi default ports** nếu cần bảo mật cao hơn
- **Enable VPC Flow Logs** để monitor traffic
- **Regular patching** cho OS và packages


### Performance Tuning:

- **G6 instances** thường performance tốt hơn G5
- **Tăng EBS volume** nếu cần store nhiều models
- **Consider EBS optimization** cho I/O intensive workloads

**Template này cung cấp một giải pháp production-ready để deploy Stable Diffusion WebUI với minimal setup effort, phù hợp cho cả mục đích học tập và commercial use.**
