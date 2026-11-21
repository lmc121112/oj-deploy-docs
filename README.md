# ⚡ Online Judge Open-Source — Deployment Documentation

Repository tài liệu hướng dẫn cài đặt và triển khai trọn bộ hệ thống chấm bài tự động mã nguồn mở gồm 3 thành phần:
- **Database**: Supabase (PostgreSQL + RPC)
- **Web Frontend (`oj-web-app`)**: Next.js + Ace Editor
- **Judge Worker (`oj-judge-core`)**: C++17 Sandbox Worker

## 🚀 Xem trang tài liệu trực quan

1. Bật **GitHub Pages** cho repository này (`Settings` → `Pages` → chọn nhánh `main` và thư mục `/ (root)`).
2. Mở đường dẫn `https://<username>.github.io/oj-deploy-docs/` để xem hướng dẫn kèm nút copy lệnh nhanh.

## 📂 Thành phần trong Repository

- `index.html`: Giao diện Web hướng dẫn triển khai từng bước.
- `schema.sql`: Script khởi tạo toàn bộ bảng, dữ liệu mẫu và hàm `reset_entire_oj()` trên Supabase.
- `oj-judge.service`: File cấu hình `systemd` mẫu để chạy trình chấm `judge` ngầm 24/7 trên Ubuntu/Debian.

## 📄 Giấy phép

Phát hành theo giấy phép **MIT License** — tự do sử dụng, chỉnh sửa và chia sẻ cho cộng đồng.
