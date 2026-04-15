# Sử dụng Base Image từ Microsoft có sẵn Windows Server Core và IIS cho .NET 4.8
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2019

# Thiết lập thư mục làm việc (Working directory) là thư mục gốc của IIS
WORKDIR /inetpub/wwwroot

# Dọn dẹp các tệp HTML mặc định của IIS để tránh xung đột giao diện mặc định
RUN powershell -NoProfile -Command Remove-Item -Recurse C:\inetpub\wwwroot\*

# Copy bản build (Release) của mã nguồn vào thư mục Host của IIS
COPY Web_Publish/ .

# Khai báo cổng giao tiếp tiêu chuẩn HTTP cho Container
EXPOSE 80