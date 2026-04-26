const BASE_URL = 'http://localhost:3000/api/auth';

const randomId = Date.now().toString().slice(-6); 
const testUser = {
    email: `tester_${randomId}@gmail.com`,
    mat_khau: "MatKhauSieuCap123",
    ho: "Nguyễn",
    dem: "Văn",
    ten: `Test ${randomId}`,
    so_dien_thoai: `09${Math.floor(10000000 + Math.random() * 90000000)}`
};

async function runTest() {
    console.log("🚀 BẮT ĐẦU CHẠY TEST LUỒNG AUTH...\n");

    try {
        console.log(`Đang test Đăng ký với email: ${testUser.email}...`);
        const registerRes = await fetch(`${BASE_URL}/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(testUser)
        });
        const registerData = await registerRes.json();

        if (registerRes.ok) {
            console.log("Đăng ký THÀNH CÔNG!");
            console.log("Dữ liệu trả về:", registerData);
        } else {
            console.error("Đăng ký THẤT BẠI:", registerData);
            return; 
        }

        console.log("\n-----------------------------------\n");

        console.log(`Đang test Đăng nhập bằng tài khoản vừa tạo...`);
        const loginRes = await fetch(`${BASE_URL}/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                email: testUser.email,
                mat_khau: testUser.mat_khau
            })      
        });
        const loginData = await loginRes.json();

        if (loginRes.ok && loginData.token) {
            console.log("Đăng nhập THÀNH CÔNG!");
            console.log("Bắt được Token JWT:", loginData.token.substring(0, 30) + "... (đã cắt ngắn)");
            console.log("\nHOÀN TẤT! LUỒNG AUTH CỦA BẠN ĐÃ HOẠT ĐỘNG 100% HOÀN HẢO.");
        } else {
            console.error("Đăng nhập THẤT BẠI:", loginData);
        }

    } catch (error) {
        console.error("LỖI KẾT NỐI SERVER:", error.message);
        console.log("Bạn đã chạy lệnh 'node server.js' ở một Terminal khác chưa?");
    }
}

runTest();