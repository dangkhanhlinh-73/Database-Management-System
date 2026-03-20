--3.1--
CREATE PROCEDURE PrintNgayThangNamHienTai
AS
BEGIN
    DECLARE @NgayHienTai DATETIME = GETDATE();
    DECLARE @Ngay INT = DAY(@NgayHienTai);
    DECLARE @Thang INT = MONTH(@NgayHienTai);
    DECLARE @Nam INT = YEAR(@NgayHienTai);

    PRINT N'Ngày: ' + CAST(@Ngay AS VARCHAR(2));
    PRINT N'Tháng: ' + CAST(@Thang AS VARCHAR(2));
    PRINT N'Năm: ' + CAST(@Nam AS VARCHAR(4));
END;

--3.2
CREATE PROCEDURE TinhDienTichVaChuViHinhChuNhat
    @ChieuDai FLOAT,    -- Chiều dài
    @ChieuRong FLOAT    -- Chiều rộng
AS
BEGIN
    DECLARE @DienTich FLOAT;    -- Diện tích
    DECLARE @ChuVi FLOAT;       -- Chu vi

    -- Tính diện tích và chu vi
    SET @DienTich = @ChieuDai * @ChieuRong;
    SET @ChuVi = 2 * (@ChieuDai + @ChieuRong);
    PRINT N'Diện tích: ' + CAST(@DienTich AS VARCHAR(20));
    PRINT N'Chu vi: ' + CAST(@ChuVi AS VARCHAR(20));
END;

--3.3
CREATE PROCEDURE LaySinhVienTheoLopcau3
    @MaLop NVARCHAR(10)  -- Tham số đầu vào là mã lớp học
AS
BEGIN
    -- Truy vấn thông tin sinh viên của lớp dựa vào mã lớp
    SELECT 
        masinhvien AS N'Mã sinh viên',
        CONCAT(hodem, ' ', ten) AS N'Họ tên',
        ngaysinh AS N'Ngày sinh',
        CASE 
            WHEN gioitinh = 1 THEN N'Nam'
            ELSE N'Nữ'
        END AS N'Giới tính',
        malop AS N'Mã lớp'
    FROM SINHVIEN
    WHERE malop = @MaLop;
END;



--3.4
CREATE PROCEDURE LayDanhSachSinhVienTheoTenLopcau4
    @TenLop NVARCHAR(50)
AS
BEGIN
    SELECT 
        s.masinhvien AS 'Mã sinh viên',
        CONCAT(s.hodem, ' ', s.ten) AS 'Họ tên',
        s.ngaysinh AS 'Ngày sinh',
        s.malop AS 'Mã lớp',
        c.tenlop AS 'Tên lớp'
    FROM sinhvien s
    JOIN lop c ON s.malop = c.malop
    WHERE c.tenlop = @TenLop;
END;

--3.5
CREATE PROCEDURE LayDanhSachSinhVienTheoGioiTinhVaNoiSinhcau5
    @GioiTinh INT = 0,
    @NoiSinh NVARCHAR(50) = 'TT Huế'
AS
BEGIN
    SELECT 
        masinhvien AS 'Mã sinh viên',
        CONCAT(hodem, ' ', ten) AS 'Họ tên',
        CASE 
            WHEN gioitinh = 1 THEN 'Nam'
            ELSE 'Nữ'
        END AS 'Giới tính',
        noisinh AS 'Nơi sinh'
    FROM sinhvien
    WHERE gioitinh = @GioiTinh AND noisinh = @NoiSinh;
END;

--3.6
CREATE PROCEDURE LayDanhSachSinhVienTheoThangSinh6
    @ThangBatDau INT,
    @ThangKetThuc INT
AS
BEGIN
    IF @ThangBatDau > @ThangKetThuc
    BEGIN
        PRINT 'Du lieu khong hop le: x > y';
        RETURN;
    END

    SELECT 
        masinhvien AS 'Ma sinh vien',
        CONCAT(hodem, ' ', ten) AS 'Ho ten',
        ngaysinh AS 'Ngay sinh'
    FROM sinhvien
    WHERE MONTH(ngaysinh) BETWEEN @ThangBatDau AND @ThangKetThuc;
END;

--3.7
CREATE PROCEDURE LayDanhSachSinhVienTheoNoiSinhcau7
    @NoiSinh NVARCHAR(50)
AS
BEGIN
    SELECT 
        masinhvien AS 'Mã sinh viên',
        CONCAT(hodem, ' ', ten) AS 'Họ tên',
        ngaysinh AS 'Ngày sinh',
        noisinh AS 'Nơi sinh'
    FROM sinhvien
    WHERE noisinh = @NoiSinh;
END;
--3.8
CREATE PROCEDURE LayDanhSachSinhVienTheoNoiSinhChuaChuoicau38
    @NoiSinh NVARCHAR(50)
AS
BEGIN
    SELECT 
        masinhvien AS 'Mã sinh viên',
        CONCAT(hodem, ' ', ten) AS 'Họ tên',
        ngaysinh AS 'Ngày sinh',
        noisinh AS 'Nơi sinh'
    FROM SINHVIEN
    WHERE noisinh LIKE '%' + @NoiSinh + '%';
END;
--3.9
CREATE PROCEDURE LayDiemCacMonCuaSinhViencau39
    @MaSinhVien NVARCHAR(10)
AS
BEGIN
    SELECT 
        s.masinhvien , CONCAT(s.hodem, ' ', s.ten) AS 'Họ tên',s.ngaysinh, d.diemmon1, d.diemmon2 ,d.diemmon3 ,
		(d.diemmon1 + d.diemmon2 + d.diemmon3) AS 'Tổng điểm'
    FROM SINHVIEN s
    JOIN diemts d ON s.masinhvien = d.masinhvien
    WHERE s.masinhvien = @MaSinhVien;
END;
--3.10
CREATE PROCEDURE LayTongSoSinhVienTheoTenLopcau310
    @TenLop NVARCHAR(50)
AS
BEGIN
    DECLARE @Count INT;

    SELECT @Count = COUNT(*)
    FROM SINHVIEN s
    JOIN LOP c ON s.malop = c.malop
    WHERE c.tenlop = @TenLop;

    IF @Count IS NULL OR @Count = 0
    BEGIN
        PRINT 'Tên lớp không tồn tại.';
        RETURN;
    END

    SELECT 
        c.malop AS 'Mã lớp',
        c.tenlop AS 'Tên lớp',
        COUNT(s.masinhvien) AS 'Tổng số sinh viên'
    FROM SINHVIEN s
    JOIN LOP c ON s.malop = c.malop
    WHERE c.tenlop = @TenLop
    GROUP BY c.malop, c.tenlop;
END;
--3.11
CREATE PROCEDURE laytongsosinhvientheotenlopcau311
    @TenLop NVARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM LOP WHERE tenlop = @TenLop)
    BEGIN
        SELECT 
            l.malop AS 'Mã lớp',
            l.tenlop AS 'Tên lớp',
            COUNT(s.masinhvien) AS 'Tổng số sinh viên'
        FROM LOP l
        LEFT JOIN SINHVIEN s ON l.malop = s.malop
        GROUP BY l.malop, l.tenlop;
    END
    ELSE
    BEGIN
        SELECT 
            l.malop AS 'Mã lớp',
            l.tenlop AS 'Tên lớp',
            COUNT(s.masinhvien) AS 'Tổng số sinh viên'
        FROM LOP l
        LEFT JOIN SINHVIEN s ON l.malop = s.malop
        WHERE l.tenlop = @TenLop
        GROUP BY l.malop, l.tenlop;
    END
END;
--3.12
CREATE PROCEDURE BoSungSinhViencau312
    @MaSinhVien NVARCHAR(10),
    @HoDem NVARCHAR(50),
    @Ten NVARCHAR(50),
    @NgaySinh DATE,
    @GioiTinh BIT,
    @MaLop NVARCHAR(10),
    @NoiSinh NVARCHAR(50)
AS
BEGIN
    IF EXISTS (SELECT * FROM SINHVIEN WHERE masinhvien = @MaSinhVien)
    BEGIN
        PRINT 'Mã sinh viên đã tồn tại.';
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM LOP WHERE malop = @MaLop)
    BEGIN
        PRINT 'Mã lớp không tồn tại.';
        RETURN;
    END

    INSERT INTO SINHVIEN(masinhvien, hodem, ten, ngaysinh, gioitinh, malop, noisinh)
    VALUES (@MaSinhVien, @HoDem, @Ten, @NgaySinh, @GioiTinh, @MaLop, @NoiSinh);
END;

--3.13
CREATE PROCEDURE SoSanhDiemMon1
    @MaSinhVien1 NVARCHAR(10),
    @MaSinhVien2 NVARCHAR(10)
AS
BEGIN
    DECLARE @Diem1 FLOAT;
    DECLARE @Diem2 FLOAT;

    SELECT @Diem1 = d.diemmon1
    FROM diemts d
    JOIN sinhvien s ON d.masinhvien = s.masinhvien
    WHERE s.masinhvien = @MaSinhVien1;

    SELECT @Diem2 = d.diemmon1
    FROM diemts d
    JOIN sinhvien s ON d.masinhvien = s.masinhvien
    WHERE s.masinhvien = @MaSinhVien2;

    IF @Diem1 > @Diem2
    BEGIN
        SELECT 
            s.masinhvien AS 'Mã sinh viên',
            CONCAT(s.hodem, ' ', s.ten) AS 'Họ tên',
            s.ngaysinh AS 'Ngày sinh',
            @Diem1 AS 'Điểm môn 1'
        FROM sinhvien s
        WHERE s.masinhvien = @MaSinhVien1;
    END
    ELSE
    BEGIN
        SELECT 
            s.masinhvien AS 'Mã sinh viên',
            CONCAT(s.hodem, ' ', s.ten) AS 'Họ tên',
            s.ngaysinh AS 'Ngày sinh',
            @Diem2 AS 'Điểm môn 1'
        FROM sinhvien s
        WHERE s.masinhvien = @MaSinhVien2;
    END
END;
--3.14

CREATE PROCEDURE ThongTinSinhVienCoTongDiemCaoHon
    @MaSinhVien1 NVARCHAR(10),
    @MaSinhVien2 NVARCHAR(10)
AS
BEGIN
    DECLARE @TongDiem1 FLOAT;
    DECLARE @TongDiem2 FLOAT;

    SELECT @TongDiem1 = (d.diemmon1 + d.diemmon2 + d.diemmon3)
    FROM diemts d
    JOIN sinhvien s ON d.masinhvien = s.masinhvien
    WHERE s.masinhvien = @MaSinhVien1;

    SELECT @TongDiem2 = (d.diemmon1 + d.diemmon2 + d.diemmon3)
    FROM diemts d
    JOIN sinhvien s ON d.masinhvien = s.masinhvien
    WHERE s.masinhvien = @MaSinhVien2;

    IF @TongDiem1 > @TongDiem2
    BEGIN
        SELECT 
            s.masinhvien AS 'Mã sinh viên',
            CONCAT(s.hodem, ' ', s.ten) AS 'Họ tên',
            s.ngaysinh AS 'Ngày sinh',
            d.diemmon1 AS 'Điểm môn 1',
            d.diemmon2 AS 'Điểm môn 2',
            d.diemmon3 AS 'Điểm môn 3',
            @TongDiem1 AS 'Tổng điểm'
        FROM sinhvien s
        JOIN diemts d ON s.masinhvien = d.masinhvien
        WHERE s.masinhvien = @MaSinhVien1;
    END
    ELSE
    BEGIN
        SELECT 
            s.masinhvien AS 'Mã sinh viên',
            CONCAT(s.hodem, ' ', s.ten) AS 'Họ tên',
            s.ngaysinh AS 'Ngày sinh',
            d.diemmon1 AS 'Điểm môn 1',
            d.diemmon2 AS 'Điểm môn 2',
            d.diemmon3 AS 'Điểm môn 3',
            @TongDiem2 AS 'Tổng điểm'
        FROM sinhvien s
        JOIN diemts d ON s.masinhvien = d.masinhvien
        WHERE s.masinhvien = @MaSinhVien2;
    END
END;

--3.15
CREATE PROCEDURE ThongTinSinhVienCoTongDiemCaoHonHoacBang
    @MaSinhVien1 NVARCHAR(10),
    @MaSinhVien2 NVARCHAR(10)
AS
BEGIN
    DECLARE @TongDiem1 FLOAT;
    DECLARE @TongDiem2 FLOAT;

    SELECT @TongDiem1 = (d.diemmon1 + d.diemmon2 + d.diemmon3)
    FROM diemts d
    JOIN sinhvien s ON d.masinhvien = s.masinhvien
    WHERE s.masinhvien = @MaSinhVien1;

    SELECT @TongDiem2 = (d.diemmon1 + d.diemmon2 + d.diemmon3)
    FROM diemts d
    JOIN sinhvien s ON d.masinhvien = s.masinhvien
    WHERE s.masinhvien = @MaSinhVien2;

    IF @TongDiem1 > @TongDiem2
    BEGIN
        SELECT 
            s.masinhvien AS 'Mã sinh viên',
            CONCAT(s.hodem, ' ', s.ten) AS 'Họ tên',
            s.ngaysinh AS 'Ngày sinh',
            d.diemmon1 AS 'Điểm môn 1',
            d.diemmon2 AS 'Điểm môn 2',
            d.diemmon3 AS 'Điểm môn 3',
            @TongDiem1 AS 'Tổng điểm'
        FROM sinhvien s
        JOIN diemts d ON s.masinhvien = d.masinhvien
        WHERE s.masinhvien = @MaSinhVien1;
    END
    ELSE IF @TongDiem1 < @TongDiem2
    BEGIN
        SELECT 
            s.masinhvien AS 'Mã sinh viên',
            CONCAT(s.hodem, ' ', s.ten) AS 'Họ tên',
            s.ngaysinh AS 'Ngày sinh',
            d.diemmon1 AS 'Điểm môn 1',
            d.diemmon2 AS 'Điểm môn 2',
            d.diemmon3 AS 'Điểm môn 3',
            @TongDiem2 AS 'Tổng điểm'
        FROM sinhvien s
        JOIN diemts d ON s.masinhvien = d.masinhvien
        WHERE s.masinhvien = @MaSinhVien2;
    END
    ELSE
    BEGIN
        SELECT 
            s.masinhvien AS 'Mã sinh viên',
            CONCAT(s.hodem, ' ', s.ten) AS 'Họ tên',
            s.ngaysinh AS 'Ngày sinh',
            d.diemmon1 AS 'Điểm môn 1',
            d.diemmon2 AS 'Điểm môn 2',
            d.diemmon3 AS 'Điểm môn 3',
            @TongDiem1 AS 'Tổng điểm'
        FROM sinhvien s
        JOIN diemts d ON s.masinhvien = d.masinhvien
        WHERE s.masinhvien IN (@MaSinhVien1, @MaSinhVien2);
    END
END;