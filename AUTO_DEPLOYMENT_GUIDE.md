# Hướng Dẫn Triển Khai Tự Động Stable Diffusion WebUI trên SageMaker

Tài liệu này hướng dẫn cách triển khai hoàn toàn tự động Stable Diffusion WebUI trên Amazon SageMaker, giúp bạn có một môi trường phát triển AI mạnh mẽ mà không cần cấu hình thủ công.

## Phương Pháp Triển Khai

Có hai phương pháp triển khai tự động:

1. **Sử dụng CloudFormation** - Tự động hóa hoàn toàn từ đầu đến cuối
2. **Sử dụng Script Cài Đặt** - Cho SageMaker Notebook Instance đã tồn tại

## Phương Pháp 1: Sử dụng CloudFormation

### Bước 1: Triển khai CloudFormation Stack

1. Đăng nhập vào AWS Console
2. Điều hướng đến CloudFormation
3. Click "Create stack" → "With new resources (standard)"
4. Upload file `sagemaker-auto.yaml`
5. Click "Next"

### Bước 2: Cấu hình Stack Parameters

- **Stack name**: Nhập tên mô tả (ví dụ: `stable-diffusion-webui-stack`)
- **NotebookInstanceName**: Nhập tên cho SageMaker Notebook Instance (mặc định: `stable-diffusion-notebook`)
- **InstanceType**: Chọn `ml.g4dn.2xlarge` hoặc mạnh hơn
- **VolumeSize**: Nhập kích thước ổ đĩa (khuyến nghị: `100` GB)
- Click "Next"

### Bước 3: Cấu hình Stack Options

- Thêm tags nếu muốn (tùy chọn)
- Cấu hình các tùy chọn nâng cao nếu cần (tùy chọn)
- Click "Next"

### Bước 4: Xem Lại và Tạo

- Xem lại tất cả cấu hình
- Đánh dấu vào ô xác nhận cho IAM resources
- Click "Create stack"

### Bước 5: Đợi Hoàn Tất

- Theo dõi tiến trình tạo stack trong CloudFormation console
- Đợi trạng thái stack hiển thị "CREATE_COMPLETE" (khoảng 5-10 phút)
- **Quan trọng**: Sau khi stack tạo xong, đợi thêm 10-15 phút để script khởi tạo hoàn tất việc cài đặt Stable Diffusion WebUI

### Bước 6: Truy Cập WebUI

1. Vào tab "Outputs" của CloudFormation stack
2. Tìm output `WebUIURL`
3. Click vào URL hoặc copy vào trình duyệt
4. URL có định dạng: `https://[notebook-name].notebook.[region].sagemaker.aws/proxy/7860/`

## Phương Pháp 2: Sử dụng Script Cài Đặt

Nếu bạn đã có SageMaker Notebook Instance, bạn có thể sử dụng script cài đặt tự động.

### Bước 1: Tạo SageMaker Notebook Instance

1. Đăng nhập vào AWS Console → SageMaker
2. Chọn "Notebook instances" → "Create notebook instance"
3. Cấu hình:
   - **Notebook instance name**: Nhập tên (ví dụ: `stable-diffusion-notebook`)
   - **Instance type**: Chọn `ml.g4dn.2xlarge` hoặc mạnh hơn
   - **Volume size**: Nhập `100` GB
   - **IAM role**: Chọn hoặc tạo role với quyền SageMakerFullAccess và S3FullAccess
4. Click "Create notebook instance"

### Bước 2: Truy Cập Jupyter Notebook

1. Đợi trạng thái instance chuyển thành "InService"
2. Click "Open Jupyter"

### Bước 3: Chạy Script Cài Đặt

1. Mở Terminal trong Jupyter (New → Terminal)
2. Tải script cài đặt:
   ```bash
   cd /home/ec2-user/SageMaker
   wget https://raw.githubusercontent.com/your-repo/SD-EC2/main/auto_install.sh
   chmod +x auto_install.sh
   ```
3. Chạy script:
   ```bash
   ./auto_install.sh
   ```
4. Đợi quá trình cài đặt hoàn tất (khoảng 10-15 phút)

### Bước 4: Truy Cập WebUI

1. Sau khi cài đặt hoàn tất, WebUI sẽ tự động khởi động
2. Truy cập WebUI qua URL:
   ```
   https://[notebook-name].notebook.[region].sagemaker.aws/proxy/7860/
   ```
3. Hoặc mở notebook `auto_start_webui.ipynb` để khởi động và quản lý WebUI

## Tính Năng Tự Động Hóa

Giải pháp này bao gồm các tính năng tự động hóa sau:

1. **Cài đặt tự động**: Tất cả dependencies và Stable Diffusion WebUI được cài đặt tự động
2. **Khởi động tự động**: WebUI tự động khởi động khi SageMaker Notebook Instance khởi động
3. **Notebook quản lý**: Notebook tự động khởi động WebUI và hiển thị trạng thái
4. **Crontab**: WebUI tự động khởi động lại sau khi reboot
5. **ControlNet extension**: Được cài đặt sẵn cho inpainting

## Sử Dụng WebUI

Sau khi triển khai, bạn có thể:

1. **Truy cập WebUI** qua URL được cung cấp
2. **Sử dụng inpainting với ControlNet** theo hướng dẫn trong notebook
3. **Tải thêm models** vào thư mục `/home/ec2-user/SageMaker/stable-diffusion-webui/models/Stable-diffusion`
4. **Cài đặt thêm extensions** vào thư mục `/home/ec2-user/SageMaker/stable-diffusion-webui/extensions`

## Quản Lý Chi Phí

Để tiết kiệm chi phí:

1. **Dừng instance** khi không sử dụng:
   ```bash
   aws sagemaker stop-notebook-instance --notebook-instance-name stable-diffusion-notebook
   ```

2. **Khởi động lại** khi cần sử dụng:
   ```bash
   aws sagemaker start-notebook-instance --notebook-instance-name stable-diffusion-notebook
   ```

## Xử Lý Sự Cố

### WebUI không khởi động

Kiểm tra log:
```bash
cat /home/ec2-user/SageMaker/stable-diffusion-webui/webui_service.log
```

### Lỗi CUDA

Thêm tham số vào `launch_webui.sh`:
```bash
export COMMANDLINE_ARGS="--listen --port 7860 --enable-insecure-extension-access --no-half-vae --skip-torch-cuda-test"
```

### Lỗi bộ nhớ

Thêm tham số vào `launch_webui.sh`:
```bash
export COMMANDLINE_ARGS="--listen --port 7860 --enable-insecure-extension-access --no-half-vae --medvram"
```

### Không thể truy cập qua proxy

Kiểm tra port đang sử dụng:
```bash
netstat -tulpn | grep python
```

## Dọn Dẹp Resources

Khi không cần nữa:

1. Vào CloudFormation console
2. Chọn stack `stable-diffusion-webui-stack`
3. Click "Delete"
4. Xác nhận xóa

## Kết Luận

Với hướng dẫn này, bạn đã triển khai thành công Stable Diffusion WebUI trên SageMaker một cách hoàn toàn tự động. Giải pháp này giúp bạn tập trung vào việc sử dụng công cụ thay vì tốn thời gian cài đặt và cấu hình.
