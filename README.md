# E-Commerce Database

Dự án này chứa cấu hình Docker Compose để chạy cơ sở dữ liệu MySQL cho dự án E-Commerce.

## Yêu cầu
- Đã cài đặt [Docker](https://docs.docker.com/get-docker/) và [Docker Compose](https://docs.docker.com/compose/install/).

## Cài đặt và Chạy

1. **Chuẩn bị cấu hình (Environment Variables)**
   Đảm bảo bạn có file `.env` ở thư mục gốc của dự án (cùng cấp với `docker-compose.yaml`). Nếu chưa có, hãy tạo nó với các thông tin như sau (bạn có thể thay đổi mật khẩu tùy ý):
   ```env
   MYSQL_ROOT_PASSWORD=your_root_password
   MYSQL_DATABASE=ecommerce
   MYSQL_USER=your_db_user
   MYSQL_PASSWORD=your_db_password
   ```

2. **Khởi chạy Database**
   Mở terminal tại thư mục dự án và chạy lệnh sau để khởi động MySQL ở chế độ ngầm (detached mode):
   ```bash
   docker compose up -d
   ```

3. **Kiểm tra trạng thái**
   Để xem container có đang chạy bình thường không, bạn dùng lệnh:
   ```bash
   docker compose ps
   ```

4. **Dừng Database**
   Khi không cần sử dụng nữa, bạn có thể dừng và tắt container bằng lệnh:
   ```bash
   docker compose down
   ```

## Thông tin kết nối MySQL
- **Host**: `localhost` hoặc `127.0.0.1`
- **Port**: `3306`
- **Database**: `ecommerce` (hoặc cấu hình trong `.env`)
- **Username / Password**: theo thông tin bạn đã thiết lập trong file `.env`.
