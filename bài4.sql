--4.1
CREATE FUNCTION Fn_Tong (@n INT) 
RETURNS REAL 
AS
BEGIN
    DECLARE @sum REAL;
    SET @sum = @n * (@n + 1) / 2;
    RETURN @sum;
END;
--4.2
CREATE FUNCTION Fn_Tong_Nghich (@n INT) 
RETURNS REAL 
AS
BEGIN
    DECLARE @sum REAL;
    SET @sum = 0;
    DECLARE @i INT = 1;
    WHILE @i <= @n
    BEGIN
        SET @sum = @sum + 1.0 / @i;
        SET @i = @i + 1;
    END
    RETURN @sum;
END;
--4.3
CREATE FUNCTION Fn_DemSV (@MaLop NVARCHAR(10))
RETURNS INT
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(*) 
    FROM sinhvien 
    WHERE malop = @MaLop;
    RETURN @count;
END;
--4.4
CREATE FUNCTION Fn_DemSV44 (@MaLop NVARCHAR(10), @GioiTinh BIT)
RETURNS INT
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(*) 
    FROM sinhvien 
    WHERE malop = @MaLop AND gioitinh = @GioiTinh;
    RETURN @count;
END;
--4.5
CREATE FUNCTION Fn_SV_NamSinh (@Namsinh INT)
RETURNS INT
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(*)
    FROM sinhvien
    WHERE YEAR(ngaysinh) = @Namsinh;
    RETURN @count;
END;
--4.6
CREATE FUNCTION Fn_SV_HoLe (@HoSV NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT masinhvien, hodem, ten, ngaysinh, gioitinh, malop, noisinh
    FROM sinhvien
    WHERE hodem LIKE @HoSV + '%'
);
--4.7
CREATE FUNCTION Fn_SV_NhoTuoi (@MaLop NVARCHAR(10))
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 3 masinhvien, hodem, ten, ngaysinh, gioitinh, malop, noisinh
    FROM sinhvien
    WHERE malop = @MaLop
    ORDER BY ngaysinh DESC
);
--4.8
CREATE FUNCTION Fn_Diem_SV (@MaSV NVARCHAR(10))
RETURNS TABLE
AS
RETURN
(
    SELECT s.masinhvien, s.hodem, s.ten, s.ngaysinh, s.gioitinh, s.malop, d.diemmon1, d.diemmon2, d.diemmon3, 
           (d.diemmon1 + d.diemmon2 + d.diemmon3) AS tongdiem
    FROM sinhvien s
    JOIN diemts d ON s.masinhvien = d.masinhvien
    WHERE s.masinhvien = @MaSV
);

--4.9
CREATE FUNCTION Fn_TongSV_Lop (@MaLop VARCHAR(10))
RETURNS TABLE
AS
RETURN
(
    SELECT malop, COUNT(*) AS tong_so_sinh_vien
    FROM sinhvien
    WHERE malop = @MaLop
    GROUP BY malop
);
--4.10
CREATE FUNCTION Fn_TongSV_NamSinh (@MaLop VARCHAR(10), @NamSinh INT = 1992)
RETURNS TABLE
AS
RETURN
(
    SELECT malop, COUNT(*) AS tong_so_sinh_vien
    FROM sinhvien
    WHERE malop = @MaLop AND YEAR(ngaysinh) = @NamSinh
    GROUP BY malop
);
--4.11
CREATE FUNCTION Fn_TongSV_TenLop (@TenLop NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT malop, COUNT(*) AS tong_so_sinh_vien
    FROM sinhvien
    WHERE malop LIKE '%' + @TenLop + '%'
    GROUP BY malop
);
--4.12
CREATE FUNCTION Fn_TongSV_Tinh (@NoiSinh VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT noisinh, COUNT(*) AS tong_so_sinh_vien
    FROM sinhvien
    WHERE noisinh = @NoiSinh
    GROUP BY noisinh
);

--4.13
CREATE FUNCTION Fn_TongSV_NamSinhcau413 (@namsinh INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        YEAR(ngaysinh) AS Namsinh,
        COUNT(*) AS TongSoSinhVien
    FROM sinhvien
    WHERE YEAR(ngaysinh) = @namsinh
    GROUP BY YEAR(ngaysinh)
    UNION
    SELECT 
        YEAR(ngaysinh) AS Namsinh,
        COUNT(*) AS TongSoSinhVien
    FROM sinhvien
    WHERE @namsinh NOT IN (SELECT YEAR(ngaysinh) FROM sinhvien)
    GROUP BY YEAR(ngaysinh)
);

--4.14
sp_helptext 'Fn_TongSV_Lop';
--4.15
DROP FUNCTION Fn_TongSV_Tinh;
--4.16
CREATE FUNCTION Fn_TKTongSV_NamSinhcau416 (@TuNam INT, @DenNam INT)
RETURNS TABLE
AS
RETURN (
    WITH Years AS (
        SELECT @TuNam AS Namsinh
        UNION ALL
        SELECT Namsinh + 1
        FROM Years
        WHERE Namsinh + 1 <= @DenNam
    )
    SELECT 
        y.Namsinh,
        ISNULL(COUNT(sv.masinhvien), 0) AS SoLuongSinhVien
    FROM Years y
    LEFT JOIN sinhvien sv ON YEAR(sv.ngaysinh) = y.Namsinh
    GROUP BY y.Namsinh
    ORDER BY y.Namsinh
);
--4.17
CREATE FUNCTION Fn_TKTongSV_NamSinh_TenLop
(
    @tenlop NVARCHAR(100),
    @TuNam INT,
    @DenNam INT
)
RETURNS @Result TABLE
(
    NamSinh INT,
    SoLuongSV INT
)
AS
BEGIN
    -- Tạo bảng chứa tất cả các năm trong khoảng từ @TuNam đến @DenNam
    DECLARE @Nam INT = @TuNam;
    WHILE @Nam <= @DenNam
    BEGIN
        INSERT INTO @Result (NamSinh, SoLuongSV)
        VALUES (@Nam, 0);
        SET @Nam = @Nam + 1;
    END;

    -- Cập nhật số lượng sinh viên theo năm sinh và tên lớp
    UPDATE @Result
    SET SoLuongSV = ISNULL(Subquery.SoLuongSV, 0)
    FROM @Result r
    LEFT JOIN
    (
        SELECT YEAR(NgaySinh) AS NamSinh, COUNT(*) AS SoLuongSV
        FROM SinhVien
        WHERE YEAR(NgaySinh) BETWEEN @TuNam AND @DenNam
        AND TenLop LIKE '%' + @tenlop + '%'
        GROUP BY YEAR(NgaySinh)
    ) AS Subquery
    ON r.NamSinh = Subquery.NamSinh;

    RETURN;
END;
