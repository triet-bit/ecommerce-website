# Action Plan — Phần Web (Phần 3)

## Tổng quan hiện trạng

| Layer | Công nghệ | Trạng thái |
|---|---|---|
| **Database** | MySQL (Docker) | ✅ Đã có schema, SP, trigger, function |
| **Backend** | Node.js + Express + JWT | ✅ Đã có `/api/auth`, `/api/products` |
| **Frontend** | React + Vite + TypeScript + TailwindCSS + shadcn/ui | ⚠️ Đang dùng mock data cho admin/đơn hàng/stats |

**Vấn đề cốt lõi**: Frontend hiện tại (`api.ts`) gọi đúng real API cho `login/register/fetchProducts`, nhưng các hàm admin (`adminCreateProduct`, `adminUpdateProduct`, `adminDeleteProduct`), đơn hàng, và thống kê vẫn đang **dùng mock localStorage** thay vì gọi stored procedure trên database thật.

---

## Phần 3.1 — Màn hình CRUD sản phẩm (`/admin/products`)

> Mục tiêu: Gọi đúng 3 SP: `sp_them_san_pham`, `sp_cap_nhat_san_pham`, `sp_xoa_san_pham`

### Bước 1 — Backend: Sửa `productRoutes.js`

**File:** `backend/productRoutes.js`

Hiện tại các route đang gọi SP cũ (`sp_CreateProduct`, `sp_UpdateProduct`, `sp_DeleteProduct`) không khớp với tên SP trong `03_store_procedure.sql`. Phải sửa lại:

| Route | SP hiện tại (sai) | SP phải gọi (đúng) |
|---|---|---|
| `POST /api/products` | `sp_CreateProduct` | `sp_them_san_pham(ten, mo_ta, bao_hanh, to_chuc, gia, so_luong, seller_id, trang_thai)` |
| `PUT /api/products/:id` | `sp_UpdateProduct` | `sp_cap_nhat_san_pham(id, ten, mo_ta, bao_hanh, to_chuc, gia, so_luong, trang_thai)` |
| `DELETE /api/products/:id` | `sp_DeleteProduct` | `sp_xoa_san_pham(id)` |
| `GET /api/products` | `sp_GetAllProducts` | **Thay bằng `SELECT` trực tiếp** hoặc tạo SP mới `sp_lay_danh_sach_san_pham` |

> [!IMPORTANT]
> SP `sp_xoa_san_pham` trả về một SELECT message ('DELETE: product...' hoặc 'UPDATE: product...'). Backend cần đọc `rows[0][0].message` và trả về cho frontend thay vì hardcode `{ message: 'Xóa thành công' }`.

**Thêm mới:** `GET /api/products` và `GET /api/products/:id` cần trả về đúng tên fields mà frontend đang dùng (`ten_san_pham`, `gia_ban`, `so_luong_ton_kho`, `trang_thai`, `seller_id`...). Hoặc phải map lại trong route handler.

### Bước 2 — Backend: Thêm endpoint lấy danh sách sản phẩm cho admin

Tạo route `GET /api/admin/products` (hoặc dùng query param `?admin=true`) để lấy đầy đủ thông tin SP (bao gồm `seller_id`, `trang_thai`) phục vụ trang admin.

### Bước 3 — Frontend: Sửa `api.ts`

Sửa 3 hàm admin trong `api.ts` để gọi real API thay vì mock localStorage:

- **`adminCreateProduct`** → `POST /api/products` với body đúng tham số SP
- **`adminUpdateProduct`** → `PUT /api/products/:id` với body đúng tham số SP  
- **`adminDeleteProduct`** → `DELETE /api/products/:id`, đọc `message` từ response và hiển thị

Thêm hàm mới (nếu chưa có):
- **`adminListProducts`** → `GET /api/admin/products` (thay mock)

### Bước 4 — Frontend: Sửa `AdminProducts.tsx`

Form hiện tại có các field: `name, price, stock, warranty, image, shortDesc, description`.  
SP `sp_them_san_pham` cần: `ten_san_pham, mo_ta_chi_tiet, loai_bao_hanh, to_chuc_san_xuat, gia_ban, so_luong_ton_kho, seller_id, trang_thai`.

Cần **thêm vào form**:
- `to_chuc_san_xuat` (nhà sản xuất) — input text
- `trang_thai` — dropdown: `dang_ban / ngung_ban / het_hang`
- `seller_id` — lấy từ token JWT của user đang đăng nhập (nếu là seller) hoặc dropdown chọn seller (nếu là admin)

Cần **validate phía client** trước khi gửi:
- Tên không rỗng
- Giá > 0
- Tồn kho ≥ 0 (số nguyên)
- `to_chuc_san_xuat` không rỗng
- `trang_thai` phải là 1 trong 3 giá trị hợp lệ

**Xử lý lỗi từ DB**: Khi API trả về lỗi (status 500 với `{ error: "Error: seller_id not exist" }`), hiển thị đúng nội dung lỗi đó (`toast.error(e.message)` đã có, nhưng cần đảm bảo backend forward đúng `error.message` từ MySQL SIGNAL).

**Xử lý thông báo xóa**: SP xóa trả về message khác nhau (xóa hẳn vs chuyển ngung_ban) → frontend cần đọc và hiển thị đúng message.

---

## Phần 3.2 — Màn hình danh sách đơn hàng

> Mục tiêu: Gọi `sp_lay_don_hang_theo_khach(user_id, trang_thai)`

### Bước 1 — Backend: Thêm route đơn hàng

Tạo file `backend/orderRoutes.js` với:

```
GET /api/orders?trang_thai=...
→ CALL sp_lay_don_hang_theo_khach(user_id_from_jwt, trang_thai)
```

`user_id` lấy từ JWT token (qua `authMiddleware`), không nhận từ query param (bảo mật).

Đăng ký trong `server.js`: `app.use('/api/orders', orderRoutes)`

### Bước 2 — Frontend: Sửa `api.ts`

Thêm hàm:
```typescript
fetchOrdersByUser(trangThai?: string): Promise<Order[]>
```
→ `GET /api/orders?trang_thai=...` (có kèm JWT header)

Thay thế hàm `fetchUserOrders` mock hiện tại.

### Bước 3 — Frontend: Sửa `Orders.tsx`

File hiện tại (`customer/Orders.tsx`) đang dùng mock. Cần:

1. **Thêm filter dropdown** theo trạng thái đơn hàng:  
   `cho_xac_nhan | dang_xu_ly | dang_giao | giao_thanh_cong | giao_that_bai | da_huy`

2. **Hiển thị đầy đủ thông tin** SP trả về: chi tiết đơn, sản phẩm, vận đơn (JOIN đã có trong SP)

3. **Sắp xếp** theo ngày tạo (SP đã làm, chỉ cần hiển thị đúng thứ tự)

4. **Cập nhật trạng thái đơn hàng**: Nếu muốn có thêm/sửa/xóa từ danh sách (yêu cầu đề bài), thêm nút "Hủy đơn" (chỉ cho phép khi đơn ở `cho_xac_nhan`)

---

## Phần 3.3 — Màn hình thống kê

> Mục tiêu: Gọi `sp_thong_ke_doanh_thu_nguoi_ban(seller_id, tu_ngay, den_ngay)` và `fn_xep_hang_khach_hang(user_id)`

### Bước 1 — Backend: Thêm route thống kê

Tạo file `backend/statsRoutes.js` với 2 endpoints:

```
GET /api/stats/revenue?seller_id=&tu_ngay=&den_ngay=
→ CALL sp_thong_ke_doanh_thu_nguoi_ban(seller_id, tu_ngay, den_ngay)

GET /api/stats/rank/:user_id
→ SELECT fn_xep_hang_khach_hang(user_id)
```

Đăng ký trong `server.js`: `app.use('/api/stats', statsRoutes)`

### Bước 2 — Frontend: Sửa `api.ts`

Thay hàm `getStats` mock hiện tại bằng:
```typescript
getRevenueStats(seller_id, tu_ngay, den_ngay): Promise<RevenueRow[]>
getCustomerRank(user_id): Promise<string>  // "Đồng" | "Bạc" | "Vàng" | "Kim cương"
```

### Bước 3 — Frontend: Sửa/Tạo trang thống kê

Hiện có `admin/Dashboard.tsx`. Sửa để:

1. **Thống kê doanh thu**: Form nhập `seller_id + tu_ngay + den_ngay` → gọi SP → hiển thị bảng (sản phẩm, số đơn, số lượng bán, doanh thu) + có thể thêm biểu đồ cột (dùng `recharts` đã có sẵn trong dự án)

2. **Xếp hạng khách hàng**: Nhập `user_id` → gọi function → hiển thị hạng (Đồng/Bạc/Vàng/Kim cương) + điểm tích lũy

---

## Thứ tự thực hiện đề xuất

```
1. Backend: Sửa productRoutes.js (đổi tên SP + xử lý response)
2. Backend: Tạo orderRoutes.js
3. Backend: Tạo statsRoutes.js
4. Backend: Đăng ký routes mới trong server.js
5. Frontend: Sửa adminCreateProduct / adminUpdateProduct / adminDeleteProduct trong api.ts
6. Frontend: Sửa AdminProducts.tsx (thêm field, validate, hiển thị message DB)
7. Frontend: Thêm fetchOrdersByUser vào api.ts, sửa Orders.tsx
8. Frontend: Thêm getRevenueStats / getCustomerRank vào api.ts, sửa Dashboard.tsx
```

---

## Các điểm cần chú ý đặc biệt

> [!WARNING]
> **Mapping tên field**: SP dùng tên tiếng Việt (`ten_san_pham`, `gia_ban`...) nhưng frontend dùng tiếng Anh (`name`, `price`...). Phải map trong backend route hoặc trong `api.ts`.

> [!WARNING]
> **`sp_cap_nhat_san_pham` dùng `product_id`** (dòng 142 trong SP) nhưng trong bảng có thể dùng `id`. Kiểm tra lại schema `01_schema.sql` để xác nhận tên cột đúng trước khi code.

> [!IMPORTANT]
> **JWT + seller_id**: Route POST sản phẩm cần lấy `seller_id` từ JWT payload thay vì nhận từ body (bảo mật). Sửa `authMiddleware.js` để decode và đính kèm `req.user.id` nếu chưa có.

> [!NOTE]
> **`sp_thong_ke_doanh_thu_nguoi_ban`** có lỗi tên cột: `JOIN chi_tiet_don_hangs ctdh ON sp.product_id = ctdh.order_detail_id` — `order_detail_id` không phải là `product_id`. Cần kiểm tra lại schema và sửa SP trước khi test backend.
