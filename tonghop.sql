--câu A1--
--a
-- Khai báo biến kiểu TABLE với các thuộc tính tương tự như bảng NhânVien
DECLARE @v_nhanvien TABLE (
    Manhanvien NVARCHAR(10),
    HoDem NVARCHAR(50),
    Ten NVARCHAR(50),
    NgaySinh DATE,
    GioiTinh bit,
    DiaChi NVARCHAR(100),
    MaPhong NVARCHAR(10),
    MaPhanXuong NVARCHAR(10)
);

-- a. Chèn dữ liệu vào biến @v_nhanvien lọc theo điều kiện
INSERT INTO @v_nhanvien
SELECT MaNhanVien, HoDem,Ten, NgaySinh, GioiTinh, DiaChi, MaPhong, MaPhanXuong
FROM NhanVien
WHERE HoDem LIKE N'% Thị%' OR YEAR(NgaySinh) = 1992;

-- b. Cập nhật địa chỉ là "TP Huế" cho những nhân viên chưa có mã phân xưởng
UPDATE @v_nhanvien
SET DiaChi = N'TP Huế'
WHERE MaPhanXuong IS NULL;

-- c. Cập nhật MaPhong thành NULL cho nhân viên có MaPhanXuong bắt đầu bằng "A"
UPDATE @v_nhanvien
SET MaPhong = NULL
WHERE MaPhanXuong LIKE 'A%';

-- d. Xóa tất cả nhân viên sinh từ tháng 1 đến tháng 3
DELETE FROM @v_nhanvien
WHERE MONTH(NgaySinh) BETWEEN 1 AND 3;

-- Kiểm tra kết quả
SELECT * FROM @v_nhanvien;

--caua2
DECLARE @v_nhanvien_Hue TABLE (
    Manhanvien NVARCHAR(100) ,
    HoDem NVARCHAR(100),
    Ten NVARCHAR(100),
    NgaySinh DATE,
    GioiTinh bit,
    DiaChi NVARCHAR(255),
    MaPhong NVARCHAR(10),
    tenphong NVARCHAR(100)
);
INSERT INTO @v_nhanvien_Hue (MaNhanVien, HoDem, Ten, NgaySinh, GioiTinh, DiaChi, MaPhong, TenPhong)
SELECT MaNhanVien, HoDem, Ten, NgaySinh, GioiTinh, DiaChi, MaPhong, tenphong  
FROM NhanVien
WHERE DiaChi LIKE '%TT Huế%';

--b
UPDATE @v_nhanvien_Hue
SET MaPhong = 'TC'
WHERE MONTH(NgaySinh) BETWEEN 5 AND 9;
--c
DELETE FROM @v_nhanvien_Hue
WHERE GioiTinh = 'Nam'
   OR HoDem LIKE 'Lê%';

--phanb--
--b1
CREATE PROCEDURE Sp_HienThiNhanVienTheoPhong
    @MaPhong INT
AS
BEGIN
    SELECT MaNhanVien, HoDem, Ten, NgaySinh, MaPhong
    FROM NHANVIEN
    WHERE MaPhong = @MaPhong;
END

--b2
CREATE PROCEDURE Sp_HienThiNhanVienHeSoLuongCaoNhat
    @SoLuong INT
AS
BEGIN
    SELECT TOP (@SoLuong) MaNhanVien, HoDem, Ten, NgaySinh, heso
    FROM NHANVIEN
    ORDER BY heso DESC, NgaySinh ASC;
END
--d
--d1
CREATE TRIGGER Trg_Insert_NhanVien
ON NHANVIEN
AFTER INSERT
AS
BEGIN
    INSERT INTO THUNHAP_NV (MaNhanVien, HeSo, PhuCap)
    SELECT MaNhanVien, 0, 0
    FROM inserted;
END;
--d2
CREATE TRIGGER Trg_Update_PhuCapd2
ON THUNHAP_NV
AFTER UPDATE
AS 
BEGIN
    IF UPDATE(HeSo)
    BEGIN
        UPDATE THUNHAP_NV
        SET THUNHAP_NV.PhuCap = THUNHAP_NV.PhuCap + (i.HeSo - d.HeSo) * 100000
        FROM INSERTED i
        JOIN DELETED d ON i.MaNhanVien = d.MaNhanVien
        WHERE THUNHAP_NV.MaNhanVien = i.MaNhanVien
          AND NOT (i.HeSo = d.HeSo);
    END
END;

--d3
CREATE TRIGGER Trg_Thunhap_Update_PhuCapd2
ON THUNHAP_NV
AFTER UPDATE
AS
BEGIN
    DECLARE @HeSo DECIMAL(3, 2);
    
    -- Lấy giá trị HeSo từ bảng INSERTED
    SELECT @HeSo = HeSo FROM inserted;

    -- Cập nhật cột PhuCap
    UPDATE THUNHAP_NV
    SET THUNHAP_NV.PhuCap = THUNHAP_NV.PhuCap + (i.PhuCap - d.PhuCap)
    FROM inserted i
    INNER JOIN deleted d ON i.MaNhanVien = d.MaNhanVien
    WHERE THUNHAP_NV.MaNhanVien = i.MaNhanVien
      AND THUNHAP_NV.HeSo = @HeSo;  -- Chỉ cập nhật cho các bản ghi có HeSo tương ứng
END;
--d4
CREATE TRIGGER trg_DeleteNhanVien
ON THUNHAP_NV
AFTER DELETE
AS
BEGIN
    DELETE FROM NHANVIEN
    WHERE MaNhanVien IN (SELECT MaNhanVien FROM deleted);
END;
--d5
EXEC sp_helptext 'Trg_Update_PhuCapd2';
--d6
DROP TRIGGER Trg_Update_PhuCap;
--d8
ALTER TABLE PHONG
ADD TongSoNhanVien INT DEFAULT 0;

CREATE TRIGGER trg_NhanVien_Insert
ON NHANVIEN
AFTER INSERT
AS
BEGIN
    UPDATE PHONG
    SET TongSoNhanVien = TongSoNhanVien + 1
    WHERE MaPhong IN (SELECT MaPhong FROM INSERTED);
END;
--d9
CREATE TRIGGER trg_NhanVien_Delete
ON NHANVIEN
AFTER DELETE
AS
BEGIN
    UPDATE PHONG
    SET TongSoNhanVien = TongSoNhanVien - 1
    WHERE MaPhong IN (SELECT MaPhong FROM DELETED);
END;
