# 🛒 E-Commerce Website Fullstack

Dự án website thương mại điện tử hoàn chỉnh (Fullstack) được xây dựng với kiến trúc hiện đại, tập trung vào hiệu năng và tính bảo mật của cơ sở dữ liệu.

## 🚀 Công nghệ sử dụng

- **Frontend**: React.js, TypeScript, Vite, TailwindCSS, Shadcn UI.
- **Backend**: Node.js (Express), JWT Authentication.
- **Database**: MySQL 8.0 (Sử dụng Stored Procedures, Functions, Triggers).
- **Infrastucture**: Docker Compose.

---

## 🛠️ Cấu trúc dự án

```text
.
├── backend/            # API Server (Node.js)
├── frontend/           # Giao diện người dùng (React)
├── mysql/              # Cấu hình Database
│   └── init/           # Các file SQL khởi tạo (Schema, SP, Trigger, Mock Data)
├── docker-compose.yaml # Cấu hình chạy Database bằng Docker
└── .env                # Biến môi trường
```

---

## 📋 Hướng dẫn cài đặt

### 1. Chuẩn bị biến môi trường

Tạo file `.env` tại thư mục gốc với nội dung sau:

```env
MYSQL_ROOT_PASSWORD=<your password>
MYSQL_DATABASE=ecommerce
MYSQL_USER=<your name>
MYSQL_PASSWORD=<your password>
JWT_SECRET=12345
```

### 2. Khởi chạy Database (Docker)

Mở terminal tại thư mục gốc và chạy:

```bash
sudo docker-compose down -v && sudo docker-compose up -d
```

*Lưu ý: Tham số `-v` giúp xóa dữ liệu cũ để MySQL khởi tạo lại toàn bộ Trigger và Stored Procedure mới nhất.*

### 3. Khởi chạy Backend

```bash
cd backend
npm install
npm start
```

### 4. Khởi chạy Frontend

```bash
cd frontend
npm install
npm run dev
```

---

## ✨ Các tính năng nổi bật

### 🔐 Bảo mật & Xác thực

- Phân quyền người dùng: **Admin**, **Seller**, **Buyer**.
- Đăng nhập/Đăng ký với mật khẩu được mã hóa Bcrypt.
- Tất cả tài khoản mặc định có mật khẩu là: `123456`.

### 📦 Quản lý Sản phẩm & Đơn hàng

- **CRUD Sản phẩm**: Tự động xử lý hình ảnh minh họa qua Stored Procedure.
- **Quy trình Đơn hàng**: Trigger kiểm soát chặt chẽ trạng thái đơn hàng (Chờ xác nhận -> Đã xác nhận -> Đang giao...).
- **Giỏ hàng**: Kiểm tra tồn kho thời gian thực qua Trigger trước khi thêm vào giỏ.

### 📊 Dashboard & Thống kê (Admin)

- Thống kê doanh thu theo khoảng thời gian.
- **Xếp hạng khách hàng**: Sử dụng Function `fn_xep_hang_khach_hang` để tự động phân hạng thành viên (Đồng, Bạc, Vàng, Kim cương) dựa trên điểm tích lũy.

### 🌳 Quản lý Danh mục (Chống chu trình)

- Sử dụng **Recursive Trigger** kết hợp với **CTE** để ngăn chặn việc tạo danh mục cha - con vòng lặp (Category Cycle), đảm bảo tính toàn vẹn của cấu trúc cây danh mục.

---

## 👤 Thông tin đăng nhập Test (Mật khẩu: 123456)

- **Admin**: `superadmin@ecom.vn`
- **Seller**: `seller.klong@gmail.com`
- **Buyer**: `lan.nguyen@gmail.com`

---

*Dự án được phát triển bởi Nhóm 3 - BTL Cơ sở dữ liệu.*
