--2.1
DECLARE @a INT, @b INT;
SET @a = 20;  -- Thay đổi giá trị của a ở đây
SET @b = 5;   -- Thay đổi giá trị của b ở đây

-- Phép cộng
PRINT N'Kết quả phép cộng: ' + CAST((@a + @b) AS VARCHAR);

-- Phép trừ
PRINT N'Kết quả phép trừ: ' + CAST((@a - @b) AS VARCHAR);

-- Phép nhân
PRINT N'Kết quả phép nhân: ' + CAST((@a * @b) AS VARCHAR);

-- Phép chia
IF @b != 0
    PRINT N'Kết quả phép chia: ' + CAST((@a / @b) AS VARCHAR);
ELSE
    PRINT N'Lỗi: Không thể chia cho 0';
--2.2
DECLARE @CurrentMonth INT, @CurrentQuarter INT;

SET @CurrentMonth = MONTH(GETDATE());
SET @CurrentQuarter = CASE
    WHEN @CurrentMonth IN (1, 2, 3) THEN 1
    WHEN @CurrentMonth IN (4, 5, 6) THEN 2
    WHEN @CurrentMonth IN (7, 8, 9) THEN 3
    WHEN @CurrentMonth IN (10, 11, 12) THEN 4
END;
PRINT N'Tháng hiện tại là: ' + CAST(@CurrentMonth AS VARCHAR);
PRINT N'Quý của tháng hiện tại là: Quý ' + CAST(@CurrentQuarter AS VARCHAR);
--2.3
DECLARE @n INT, @i INT, @S1 INT, @S2 FLOAT;

SET @n = 10;
SET @i = 1;
SET @S1 = 0;
SET @S2 = 0.0;

WHILE @i <= @n
BEGIN
    SET @S1 = @S1 + @i;
    SET @i = @i + 1;
END;
PRINT 'S1 = ' + CAST(@S1 AS VARCHAR);

SET @i = 1;
WHILE @i <= @n
BEGIN
    SET @S2 = @S2 + (1.0 / @i);
    SET @i = @i + 1;
END;

PRINT 'S2 = ' + CAST(@S2 AS VARCHAR);
--2.4
DECLARE @noi_sinh NVARCHAR(50) = N'Huế'
DECLARE @ma_sinh_vien NVARCHAR(10)
declare @ho_dem NVARCHAR(45)
DECLARE @ten NVARCHAR(15)
DECLARE @ngay_sinh date

select top 1 @ma_sinh_vien = masinhvien,
             @ho_dem = hodem,
             @ten = ten,
             @ngay_sinh = ngaysinh,
             @noi_sinh = noisinh
from SINHVIEN
where noisinh like '%' + @noi_sinh + '%'

print N'Mã sinh viên: ' + @ma_sinh_vien
print N'Họ và tên: ' + @ho_dem + ' ' + @ten
print N'Ngày sinh: ' + cast(@ngay_sinh as nvarchar(11))
print N'Nơi sinh: ' + @noi_sinh
--2.5
-- Khai báo biến bảng @v_sinhvien
DECLARE @v_sinhvien TABLE (
     MaSinhVien NVARCHAR(10),
    HoDem NVARCHAR(45),
    Ten NVARCHAR(15),
    NgaySinh DATE,
    NoiSinh NVARCHAR(100)
);

-- a. Chèn dữ liệu sinh viên có tháng sinh từ 1 đến 6
INSERT INTO @v_sinhvien
SELECT MaSinhVien, hodem,ten, NgaySinh, NoiSinh
FROM Sinhvien
WHERE MONTH(NgaySinh) BETWEEN 1 AND 6;

-- b. Hiển thị sinh viên họ "Nguyễn" hoặc sinh năm 1991
SELECT *
FROM @v_sinhvien
WHERE HoDem LIKE N'Nguyễn%' OR YEAR(NgaySinh) = 1991;

-- c. Cập nhật nơi sinh là "TP Huế" đối với sinh viên có mã kết thúc bằng "03"
UPDATE @v_sinhvien
SET NoiSinh = N'TP Huế'
WHERE MaSinhVien LIKE '%03';

-- d. Xóa sinh viên có họ đệm chứa "Thị"
DELETE FROM @v_sinhvien
WHERE HoDem LIKE N'% Thị %';
SELECT * FROM @v_sinhvien;
--2.6
-- Khai báo biến #v_sinhvien_KD kiểu TABLE với các thuộc tính tương tự bảng SinhVien
DECLARE @v_sinhvien_KD TABLE (
     MaSinhVien NVARCHAR(10),
    HoDem NVARCHAR(45),
    Ten NVARCHAR(15),
    GioiTinh NVARCHAR(10),
    NgaySinh DATE,
    NoiSinh NVARCHAR(50)
);

-- a. Chèn dữ liệu vào biến @v_sinhvien_KD

SELECT masinhvien, hodem,ten, GioiTinh, NgaySinh, NoiSinh
FROM SinhVien WHERE masinhvien LIKE 'KD%' OR GioiTinh = N'1';
INSERT INTO @v_sinhvien_KD

-- b. Hiển thị những sinh viên có nơi sinh kết thúc bằng chuỗi "Huế" hoặc không phải họ "Nguyễn"
SELECT *
FROM @v_sinhvien_KD
WHERE NoiSinh LIKE '%Huế' OR HoDem NOT LIKE N'Nguyễn%';

-- c. Cập nhật nơi sinh là "Quảng Bình" cho sinh viên họ "Lê"
UPDATE @v_sinhvien_KD
SET NoiSinh = N'Quảng Bình'
WHERE HoDem LIKE N'Lê%';

-- d. Xóa tất cả sinh viên có mã sinh viên kết thúc bằng chuỗi "01"
DELETE FROM @v_sinhvien_KD
WHERE MaSinhVien LIKE '%01';
