#!/bin/bash
# Script cài đặt tự động Stable Diffusion WebUI cho SageMaker
# Chạy script này trong terminal của SageMaker Notebook Instance

set -e

echo "===== Bắt đầu cài đặt Stable Diffusion WebUI ====="

# Thư mục làm việc
WORK_DIR="/home/ec2-user/SageMaker"
cd $WORK_DIR

# Kiểm tra GPU
echo "Kiểm tra GPU..."
nvidia-smi || { echo "Không tìm thấy GPU! Vui lòng đảm bảo bạn đang sử dụng instance có GPU."; exit 1; }

# Clone repository nếu chưa tồn tại
if [ ! -d "stable-diffusion-webui" ]; then
    echo "Cloning Stable Diffusion WebUI repository..."
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
else
    echo "Repository đã tồn tại, bỏ qua bước clone."
fi

cd stable-diffusion-webui

# Sửa đổi requirements để tránh lỗi xformers
echo "Sửa đổi requirements.txt..."
sed -i 's/xformers/#xformers/g' requirements.txt

# Cài đặt requirements
echo "Cài đặt dependencies..."
pip install -r requirements.txt

# Cài đặt xformers phiên bản tương thích
echo "Cài đặt xformers phiên bản tương thích..."
pip install xformers==0.0.23

# Tạo cấu trúc thư mục
echo "Tạo cấu trúc thư mục..."
mkdir -p models/Stable-diffusion
mkdir -p models/ControlNet
mkdir -p extensions

# Cài đặt ControlNet extension
echo "Cài đặt ControlNet extension..."
cd extensions
if [ ! -d "sd-webui-controlnet" ]; then
    git clone https://github.com/Mikubill/sd-webui-controlnet.git
else
    echo "ControlNet extension đã tồn tại."
fi
cd ..

# Tạo script khởi động
echo "Tạo script khởi động..."
cat > launch_webui.sh << 'EOF'
#!/bin/bash
cd /home/ec2-user/SageMaker/stable-diffusion-webui
export COMMANDLINE_ARGS="--listen --port 7860 --enable-insecure-extension-access --no-half-vae"
python launch.py
EOF

chmod +x launch_webui.sh

# Tạo service tự động khởi động
echo "Tạo service tự động khởi động..."
cat > $WORK_DIR/start_webui_service.sh << 'EOF'
#!/bin/bash
cd /home/ec2-user/SageMaker/stable-diffusion-webui
nohup ./launch_webui.sh > webui_service.log 2>&1 &
echo "WebUI service started on port 7860"
EOF

chmod +x $WORK_DIR/start_webui_service.sh

# Thêm vào crontab để tự động khởi động khi reboot
echo "Cấu hình tự động khởi động khi reboot..."
(crontab -l 2>/dev/null; echo "@reboot /home/ec2-user/SageMaker/start_webui_service.sh") | crontab -

# Tạo notebook tự động khởi động
echo "Tạo notebook tự động khởi động..."
cat > $WORK_DIR/auto_start_webui.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Stable Diffusion WebUI Auto-Starter\n",
    "\n",
    "Notebook này tự động khởi động Stable Diffusion WebUI khi được mở."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import subprocess\n",
    "import os\n",
    "import time\n",
    "import socket\n",
    "from IPython.display import display, HTML\n",
    "\n",
    "def is_port_in_use(port):\n",
    "    \"\"\"Kiểm tra xem port có đang được sử dụng không\"\"\"\n",
    "    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:\n",
    "        return s.connect_ex(('localhost', port)) == 0\n",
    "\n",
    "def start_webui():\n",
    "    \"\"\"Khởi động Stable Diffusion WebUI\"\"\"\n",
    "    webui_dir = \"/home/ec2-user/SageMaker/stable-diffusion-webui\"\n",
    "    port = 7860\n",
    "    \n",
    "    # Kiểm tra xem WebUI đã chạy chưa\n",
    "    if is_port_in_use(port):\n",
    "        display(HTML(f'''\n",
    "        <div style=\"background-color: #d4edda; color: #155724; padding: 15px; border-radius: 5px; margin: 10px 0;\">\n",
    "            <h3 style=\"margin-top: 0;\">✅ WebUI đã đang chạy!</h3>\n",
    "            <p>Truy cập WebUI tại URL: <a href=\"/proxy/{port}/\" target=\"_blank\">/proxy/{port}/</a></p>\n",
    "        </div>\n",
    "        '''))\n",
    "        return\n",
    "    \n",
    "    # Kiểm tra xem script khởi động có tồn tại không\n",
    "    launch_script = f\"{webui_dir}/launch_webui.sh\"\n",
    "    if not os.path.exists(launch_script):\n",
    "        display(HTML(f'''\n",
    "        <div style=\"background-color: #f8d7da; color: #721c24; padding: 15px; border-radius: 5px; margin: 10px 0;\">\n",
    "            <h3 style=\"margin-top: 0;\">❌ Lỗi: Script khởi động không tồn tại!</h3>\n",
    "            <p>Vui lòng đợi quá trình cài đặt hoàn tất hoặc kiểm tra log cài đặt.</p>\n",
    "        </div>\n",
    "        '''))\n",
    "        return\n",
    "    \n",
    "    # Khởi động WebUI\n",
    "    display(HTML(f'''\n",
    "    <div style=\"background-color: #cce5ff; color: #004085; padding: 15px; border-radius: 5px; margin: 10px 0;\">\n",
    "        <h3 style=\"margin-top: 0;\">🚀 Đang khởi động WebUI...</h3>\n",
    "        <p>Quá trình này có thể mất 2-3 phút. Vui lòng đợi.</p>\n",
    "    </div>\n",
    "    '''))\n",
    "    \n",
    "    # Chạy script trong background\n",
    "    process = subprocess.Popen(\n",
    "        [\"bash\", launch_script],\n",
    "        stdout=subprocess.PIPE,\n",
    "        stderr=subprocess.PIPE,\n",
    "        cwd=webui_dir\n",
    "    )\n",
    "    \n",
    "    # Đợi WebUI khởi động\n",
    "    max_wait = 180  # 3 phút\n",
    "    start_time = time.time()\n",
    "    \n",
    "    while time.time() - start_time < max_wait:\n",
    "        if is_port_in_use(port):\n",
    "            display(HTML(f'''\n",
    "            <div style=\"background-color: #d4edda; color: #155724; padding: 15px; border-radius: 5px; margin: 10px 0;\">\n",
    "                <h3 style=\"margin-top: 0;\">✅ WebUI đã sẵn sàng!</h3>\n",
    "                <p>Truy cập WebUI tại URL: <a href=\"/proxy/{port}/\" target=\"_blank\">/proxy/{port}/</a></p>\n",
    "            </div>\n",
    "            '''))\n",
    "            return\n",
    "        time.sleep(5)\n",
    "    \n",
    "    # Nếu quá thời gian mà vẫn chưa khởi động được\n",
    "    display(HTML(f'''\n",
    "    <div style=\"background-color: #f8d7da; color: #721c24; padding: 15px; border-radius: 5px; margin: 10px 0;\">\n",
    "        <h3 style=\"margin-top: 0;\">⚠️ Khởi động quá thời gian</h3>\n",
    "        <p>WebUI có thể vẫn đang khởi động. Vui lòng đợi thêm hoặc kiểm tra log.</p>\n",
    "        <p>Thử truy cập: <a href=\"/proxy/{port}/\" target=\"_blank\">/proxy/{port}/</a></p>\n",
    "    </div>\n",
    "    '''))"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Khởi động WebUI tự động\n",
    "start_webui()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Hướng dẫn sử dụng Inpainting với ControlNet\n",
    "\n",
    "### Bước 1: Chọn model\n",
    "\n",
    "1. Trong giao diện WebUI, tìm dropdown model\n",
    "2. Chọn model bạn muốn sử dụng\n",
    "\n",
    "### Bước 2: Chuyển đến tab Inpaint\n",
    "\n",
    "1. Click vào tab \"img2img\"\n",
    "2. Chọn sub-tab \"Inpaint\"\n",
    "\n",
    "### Bước 3: Cấu hình prompt\n",
    "\n",
    "1. Trong trường prompt, viết mô tả cho hình ảnh đầu ra mong muốn\n",
    "2. Ví dụ: \"a beautiful landscape with mountains and lake, high quality, detailed\"\n",
    "\n",
    "### Bước 4: Upload và mask hình ảnh\n",
    "\n",
    "1. Click \"Upload\" để tải lên hình ảnh gốc\n",
    "2. Sử dụng công cụ brush để tô lên các vùng bạn muốn mở rộng/chỉnh sửa\n",
    "3. Tô dọc theo các cạnh nơi bạn muốn hình ảnh được mở rộng\n",
    "\n",
    "### Bước 5: Cấu hình Inpaint\n",
    "\n",
    "1. **Resize mode**: Chọn \"Resize and fill\"\n",
    "2. **Mask mode**: Chọn \"Inpaint masked\"\n",
    "3. **Denoising strength**: Điều chỉnh thanh trượt (giá trị cao = nhiều thay đổi, giá trị thấp = gần với bản gốc)\n",
    "\n",
    "### Bước 6: Bật ControlNet\n",
    "\n",
    "1. Cuộn xuống để tìm phần \"ControlNet\"\n",
    "2. Đánh dấu vào ô \"Enable\"\n",
    "\n",
    "### Bước 7: Cấu hình ControlNet\n",
    "\n",
    "1. **Upload control image**: Click \"Upload independent control image\"\n",
    "2. Tải lên cùng hình ảnh bạn đã sử dụng cho inpainting (hoặc một hình ảnh điều khiển khác)\n",
    "3. **Control type**: Chọn \"Inpaint\"\n",
    "4. **Control mode**: Chọn \"ControlNet is more important\"\n",
    "5. **Resize mode**: Chọn \"Resize and fill\"\n",
    "\n",
    "### Bước 8: Tạo hình ảnh\n",
    "\n",
    "1. Click nút \"Generate\"\n",
    "2. Đợi quá trình xử lý hoàn tất\n",
    "3. Xem kết quả trong panel output"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.8.5"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

# Khởi động service
echo "Khởi động WebUI service..."
$WORK_DIR/start_webui_service.sh

echo "===== Cài đặt hoàn tất! ====="
echo "WebUI đang khởi động trên port 7860."
echo "Truy cập WebUI tại: https://<notebook-name>.notebook.<region>.sagemaker.aws/proxy/7860/"
echo "Hoặc mở notebook auto_start_webui.ipynb để khởi động và quản lý WebUI."
