CREATE TRIGGER Trg_Diemts_Insert
ON SinhVien
AFTER INSERT
AS
BEGIN
    INSERT INTO DiemTS (MaSinhVien, DiemMon1, DiemMon2, DiemMon3)
    SELECT MaSinhVien, 0, 0, 0
    FROM inserted;
END;
--5.2

CREATE TRIGGER Trg_DiemTS_Update
ON DiemTS
AFTER UPDATE
AS ALTER TABLE DiemTS
ADD tongdiem DECIMAL(3, 1);
EXEC sp_columns DiemTS;
BEGIN
    -- Cập nhật cột tongdiem trong bảng DiemTS mỗi khi DiemMon1, DiemMon2, hoặc DiemMon3 được thay đổi
    UPDATE d
    SET d.tongdiem = d.DiemMon1 + d.DiemMon2 + d.DiemMon3
    FROM DiemTS AS d
    JOIN inserted AS i ON d.MaSinhVien = i.MaSinhVien
    -- Chỉ cập nhật những bản ghi có sự thay đổi trong các cột DiemMon1, DiemMon2, hoặc DiemMon3
    WHERE (i.DiemMon1 IS NOT NULL OR i.DiemMon2 IS NOT NULL OR i.DiemMon3 IS NOT NULL);
END;

EXEC sp_helptext Trg_DiemTS_Update;

--5.3
CREATE TRIGGER Trg_DiemTS_Delete
ON DiemTS
AFTER DELETE
AS
BEGIN
    DELETE FROM SinhVien
    WHERE MaSinhVien IN (SELECT MaSinhVien FROM deleted);
END;
--5.4
sp_helptext 'Trg_DiemTS_Delete';
--55
DROP TRIGGER Trg_Diemts_Insert;
--5.6
ALTER TABLE LOP
ADD TongSoSinhVien INT NULL;
UPDATE LOP
SET TongSoSinhVien = sv_count.TongSinhVien
FROM LOP
JOIN (
    SELECT MaLop, COUNT(*) AS TongSinhVien
    FROM SINHVIEN
    GROUP BY MaLop
) AS sv_count ON LOP.MaLop = sv_count.MaLop;

--5.7
CREATE TRIGGER trg_SinhVien_Insert
ON SINHVIEN
AFTER INSERT
AS
BEGIN
    -- Cập nhật TongSoSinhVien trong bảng LOP mỗi khi có sinh viên mới thêm vào
    UPDATE LOP
    SET TongSoSinhVien = TongSoSinhVien + 1
    FROM LOP
    JOIN inserted AS i ON LOP.MaLop = i.MaLop;
END;

--5.8

