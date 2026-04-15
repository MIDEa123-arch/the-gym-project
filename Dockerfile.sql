# ============================================================
# Dockerfile.sql - SQL Server 2017 Express cho Windows Container
# Pattern lấy từ microsoft/mssql-docker (đã kiểm chứng hoạt động)
# ============================================================

FROM mcr.microsoft.com/windows/servercore:ltsc2019

LABEL maintainer="QL_PHONGGYM Team"

# ── Biến môi trường ──────────────────────────────────────────
ENV sa_password="_" \
    attach_dbs="[]" \
    ACCEPT_EULA="_" \
    sa_password_path="C:\\ProgramData\\Docker\\secrets\\sa-password"

# Link tải SQL Server 2017 Express (đã kiểm chứng hoạt động với pattern này)
ENV sql_express_download_url="https://go.microsoft.com/fwlink/?linkid=829176"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# ── Copy script khởi động và script DB ───────────────────────
COPY start.ps1 /
COPY sql_scripts/InitDB_Data.sql /

WORKDIR /

# ── Tải và cài SQL Server 2017 Express ───────────────────────
RUN Invoke-WebRequest -Uri $env:sql_express_download_url -OutFile sqlexpress.exe ; \
    Start-Process -Wait -FilePath .\sqlexpress.exe -ArgumentList /qs, /x:setup ; \
    .\setup\setup.exe /q /ACTION=Install /INSTANCENAME=SQLEXPRESS /FEATURES=SQLEngine /UPDATEENABLED=0 /SQLSVCACCOUNT='NT AUTHORITY\System' /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' /TCPENABLED=1 /NPENABLED=0 /IACCEPTSQLSERVERLICENSETERMS ; \
    Remove-Item -Recurse -Force sqlexpress.exe, setup

# ── Cấu hình TCP port 1433 cố định & bật Mixed Mode Auth ────
RUN stop-service MSSQL`$SQLEXPRESS ; \
    set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql14.SQLEXPRESS\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpdynamicports -value '' ; \
    set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql14.SQLEXPRESS\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpport -value 1433 ; \
    set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql14.SQLEXPRESS\mssqlserver\' -name LoginMode -value 2 ;

# ── Mở cổng SQL Server ───────────────────────────────────────
EXPOSE 1433

# ── Lệnh khởi động container ─────────────────────────────────
CMD .\start -sa_password $env:sa_password -ACCEPT_EULA $env:ACCEPT_EULA -attach_dbs \"$env:attach_dbs\" -Verbose
