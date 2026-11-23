# ⚡ Online Judge Deployment Documentation (`oj-deploy-docs`)

Tài liệu triển khai độc lập cho hệ thống **Online Judge** (Next.js + Supabase + `isolate` Sandbox), hỗ trợ 2 kiến trúc máy chấm chạy trên **Ubuntu 24.04 LTS (Noble Numbat)**:

1. **GitHub Actions (Serverless + Precompute `vendor/`)**: Miễn phí, đóng gói sẵn binary `isolate` và `judge` vào repo để khởi tạo trong `< 1s`.
2. **VPS Linux (Systemd Daemon)**: Độ trễ cực thấp (`250ms` polling), sử dụng hàng đợi nguyên tử `FOR UPDATE SKIP LOCKED` và RAM disk cache `/dev/shm/oj_tc_cache`.

## Cấu trúc thư mục

```text
oj-deploy-docs/
├── index.html                  # Trang hướng dẫn trực quan 2 Tab (bật GitHub Pages để xem)
├── LICENSE                     # Giấy phép mã nguồn mở MIT
├── README.md                   # Tài liệu tổng quan
├── actions/                    # Cấu hình dành cho GitHub Actions Runner
│   ├── schema-actions.sql      # SQL tạo 6 bảng + Realtime
│   ├── build-vendor.yml        # Workflow Precompute gói vendor/ (chạy 1 lần)
│   └── judge.yml               # Workflow chấm bài tự động dùng vendor/
└── vps/                        # Cấu hình dành cho VPS Linux (Ubuntu 24.04)
    ├── schema-vps.sql          # SQL tạo 6 bảng + Index hàng đợi + RPC claim_next_submission()
    ├── worker-vps.sh           # Script vòng lặp nhận bài Pending
    └── oj-judge.service        # Dịch vụ systemd chạy nền & tự khởi động lại
