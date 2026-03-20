
 

--  cau 2Tạo trigger có tên trg_NhanVien_Insert bắt lệnh INSERT trên bảng NHANVIEN sao cho mỗi 
--lần bổ sung thêm dữ liệu cho bảng NHANVIEN thì tăng giá trị cột TongSoNhanVien của bảng 
--BOPHAN lên 1 với bộ phận tương ứng.

CREATE TRIGGER trg_NhanVien_Insert2
ON NhanVien
AFTER INSERT
AS
BEGIN
SET NOCOUNT ON;
UPDATE B
SET B.TongSoNhanVien = ISNULL(B.TongSoNhanVien, 0) + I.SoLuong
FROM BOPHAN B
INNER JOIN (
SELECT MaBoPhan, COUNT(*) AS SoLuong
FROM inserted
GROUP BY MaBoPhan
) AS I
ON B.MaBoPhan = I.MaBoPhan;
END
--cau3a Tạo các thủ tục sau đây proc_NhanVien_Insert
--@MaNhanVien nvarchar(10),
--@MaBoPhan nvarchar(10),
--@HoDem nvarchar(45),
--@Ten nvarchar(20),
--@NgaySinh date,
--@GioiTinh bit,
--@DiaChi nvarchar(250),
--@KetQuaBoSung nvarchar(255) output
--Có chức năng bổ sung dữ liệu cho bảng NHANVIEN.
--Tham số đầu ra @KetQuaBoSung trả về chuỗi rỗng nếu bổ sung thành công, ngược lại tham số 
--này trả về chuỗi cho biết lý do vì sao không bổ sung được dữ liệu.
--Lưu ý, lý do không bổ sung được dữ liệu bao gồm: Trùng khóa chính, lỗi tham chiếu.

CREATE PROCEDURE proc_NhanVien_Insert
    @MaNhanVien nvarchar(10),
    @MaBoPhan nvarchar(10),
    @HoDem nvarchar(45),
    @Ten nvarchar(20),
    @NgaySinh date,
    @GioiTinh bit,
    @DiaChi nvarchar(250),
    @KetQuaBoSung nvarchar(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Kiểm tra trùng khóa chính
    IF EXISTS (SELECT 1 FROM NHANVIEN WHERE MaNhanVien = @MaNhanVien)
    BEGIN
        SET @KetQuaBoSung = N'Lỗi: Trùng khóa chính, không thể thêm.';
        RETURN;
    END;

    -- 2. Kiểm tra mã bộ phận tồn tại chưa
    IF NOT EXISTS (SELECT 1 FROM BOPHAN WHERE MaBoPhan = @MaBoPhan)
    BEGIN
        SET @KetQuaBoSung = N'Lỗi: Mã bộ phận không tồn tại.';
        RETURN;
    END;

    -- 3. Thêm nhân viên
    INSERT INTO NHANVIEN (MaNhanVien, MaBoPhan, HoDem, Ten, NgaySinh, GioiTinh, DiaChi)
    VALUES (@MaNhanVien, @MaBoPhan, @HoDem, @Ten, @NgaySinh, @GioiTinh, @DiaChi);

    -- 4. Thành công → trả chuỗi rỗng
    SET @KetQuaBoSung = N'';
END;
--loi goi
DECLARE @KQ nvarchar(255);

EXEC proc_NhanVien_Insert
    @MaNhanVien = N'NV01',
    @MaBoPhan = N'BP01',
    @HoDem = N'Lê Văn',
    @Ten = N'Bảo',
    @NgaySinh = '2004-07-18',
    @GioiTinh = 1,
    @DiaChi = N'Huế',
    @KetQuaBoSung = @KQ OUTPUT;

SELECT KetQua = @KQ;

--3b proc_NhanVien_DiaChi @DiaChi nvarchar(250),
--@HeSoLuong decimal(3,2)  Có chức năng hiển thị danh sách các nhân viên với địa chỉ có chứa
-- chuỗi @DiaChi và hệ số lương lớn hơn hoặc bằng @HeSoLuong.
--Thông tin hiển thị bao gồm: Mã nhân viên, họ tên, địa chỉ, giới tính, hệ số lương.

CREATE PROCEDURE proc_NhanVien_DiaChi
    @DiaChi nvarchar(250),
    @HeSoLuong decimal(3, 2)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        NV.MaNhanVien AS [Mã nhân viên],
        NV.HoDem AS [Họ đệm],
        NV.Ten AS [Tên],
        NV.MaBoPhan AS [Mã bộ phận],
        NV.DiaChi AS [Địa chỉ],
        LN.HeSoLuong AS [Hệ số lương]
    FROM
        NhanVien NV
    INNER JOIN
        LUONG_NHANVIEN LN ON NV.MaNhanVien = LN.MaNhanVien
    WHERE
        NV.DiaChi LIKE N'%' + @DiaChi + N'%'
        AND LN.HeSoLuong >= @HeSoLuong;
END
GO

--loigoi
EXEC proc_NhanVien_DiaChi 
    @DiaChi = N'Huế',
    @HeSoLuong = 3.50;
--3c proc_NhanVien_BoPhan @MaBoPhan nvarchar(10),
--@NamSinh int,
--@SoLuong int output
--Có chức năng tìm kiếm các nhân viên có mã bộ phận là @MaBoPhan và sinh trước năm @NamSinh.
--Lưu ý, nếu mã bộ phận không tìm thấy thì hiển thị tất cả nhân viên sinh trước năm @NamSinh.
--Thông tin cần hiển thị bao gồm: Mã nhân viên, mã bộ phận, họ tên, ngày sinh.
--Tham số đầu ra @SoLuong cho biết số lượng nhân viên được tìm thấy.

	CREATE PROCEDURE proc_NhanVien_BoPhan
    @MaBoPhan nvarchar(10),
    @NamSinh int,
    @SoLuong int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM BOPHAN WHERE MaBoPhan = @MaBoPhan)
    BEGIN
        SELECT
            NV.MaNhanVien AS [Mã nhân viên],
            BP.MaBoPhan AS [Mã bộ phận],
            NV.HoDem AS [Họ đệm],
            NV.Ten AS [Tên],
            NV.NgaySinh AS [Ngày sinh]
        FROM
            NhanVien NV
        INNER JOIN
            BOPHAN BP ON NV.MaBoPhan = BP.MaBoPhan
        WHERE
            BP.MaBoPhan = @MaBoPhan
            AND YEAR(NV.NgaySinh) < @NamSinh;

        SET @SoLuong = @@ROWCOUNT;
    END
    ELSE
    BEGIN
        SELECT
            NV.MaNhanVien AS [Mã nhân viên],
            BP.MaBoPhan AS [Mã bộ phận],
            NV.HoDem AS [Họ đệm],
            NV.Ten AS [Tên],
            NV.NgaySinh AS [Ngày sinh]
        FROM
            NhanVien NV
        INNER JOIN
            BOPHAN BP ON NV.MaBoPhan = BP.MaBoPhan
        WHERE
            YEAR(NV.NgaySinh) < @NamSinh;

        SET @SoLuong = @@ROWCOUNT;
    END
END
GO
--loigoi
DECLARE @TongSo_PGD int;
EXEC proc_NhanVien_BoPhan
@MaBoPhan = N 'PGD',
@NamSinh = 2005,  @SoLuong = @TongSo_PGD OUTPUT;--timtruoc2005
---3d proc_ThongKeNhanVien @MaBoPhan nvarchar(10),@TuNam int,@DenNam int
--Có chức năng thống kê số lượng nhân viên thuộc bộ phận có mã bộ phận là @MaBoPhan 
--theo từng năm sinh trong khoảng thời gian từ @TuNam đến @DenNam.
--Yêu cầu kết quả thống kê phải hiển thị đầy đủ tất cả các năm sinh trong khoảng thời gian cần thống kê,
--những năm sinh không có nhân viên thì hiển thị với số lượng 0.
--Thông tin cần hiển thị bao gồm: Năm sinh và Số lượng nhân viên.
CREATE PROC proc_ThongKeNhanVien
    @MaBoPhan NVARCHAR(10),
    @TuNam INT,
    @DenNam INT
AS
BEGIN
    ;WITH NamSinh AS (
        SELECT @TuNam AS Nam
        UNION ALL
        SELECT Nam + 1
        FROM NamSinh
        WHERE Nam < @DenNam
    )
    SELECT 
        n.Nam AS NamSinh,
        COUNT(nv.MaNhanVien) AS SoLuongNhanVien
    FROM NamSinh n
    LEFT JOIN NhanVien nv
        ON YEAR(nv.NgaySinh) = n.Nam
        AND nv.MaBoPhan = @MaBoPhan
    GROUP BY n.Nam
    ORDER BY n.Nam
END
GO
--loigoi
EXEC proc_ThongKeNhanVien
     @MaBoPhan = N'NV',
	 @TuNam = 1990,
     @DenNam = 2004;
--4afunc_TKeNhanVien_BoPhan @TenBoPhan nvarchar(20),@TongSoNhanVien int
--Có chức năng trả về một bảng thống kê tổng số nhân viên với tên bộ phận bắt đầu bằng chuỗi @TenBoPhan.
--Thống kê chỉ hiển thị những bộ phận có tổng số nhân viên lớn hơn hoặc bằng @TongSoNhanVien.
--Thông tin cần hiển thị bao gồm: Tên bộ phận và Tổng số nhân viên.
	CREATE FUNCTION func_TKeNhanVien_BoPhan1
(
    @TenBoPhan nvarchar(20),
    @TongSoNhanVien int
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        TenBoPhan AS [Tên bộ phận],
        TongSoNhanVien AS [Tổng số nhân viên]
    FROM
        BOPHAN
    WHERE
      
        TenBoPhan LIKE @TenBoPhan + N'%'
      
        AND TongSoNhanVien >= @TongSoNhanVien
)
GO

--loigoi
SELECT * FROM func_TKeNhanVien_BoPhan(N'Kế',1);
--4bfunc_TKeNhanVien_DayDuCacNam @TuThang int,@DenThang int,@NamSinh int
--Có chức năng trả về một bảng thống kê số lượng nhân viên trong mỗi tháng sinh của năm @NamSinh
--trong khoảng thời gian từ tháng sinh @TuThang đến tháng sinh @DenThang (tháng, năm được xác định dựa vào Ngày sinh của nhân viên).
--Thông tin cần hiển thị bao gồm: Tháng sinh và Số lượng nhân viên.
--Yêu cầu kết quả phải thể hiện đầy đủ tất cả các tháng sinh trong khoảng thời gian cần thống kê (tức là những tháng không có nhân viên
--nào thì cũng hiển thị với số lượng nhân viên là 0).
CREATE FUNCTION func_TKeNhanVien_DayDuCacNam
(
    @TuThang INT,
    @DenThang INT,
    @NamSinh INT
)
RETURNS @BangThongKe TABLE
(
    ThangSinh INT,
    SoLuongNhanVien INT
)
AS
BEGIN
    DECLARE @Thang INT = @TuThang

    WHILE @Thang <= @DenThang
    BEGIN
        INSERT INTO @BangThongKe
        SELECT 
            @Thang,
            COUNT(*)
        FROM NhanVien
        WHERE 
            MONTH(NgaySinh) = @Thang
            AND YEAR(NgaySinh) = @NamSinh

        SET @Thang = @Thang + 1
    END

    RETURN
END
GO
--loigoi

SELECT *
FROM func_TKeNhanVien_DayDuCacNam(1, 12, 2004)
ORDER BY
ThangSinh;
--cau5 thay maytinhbangdebai ,tên CSDL đề bài yêu cầu
USE master;
GO
CREATE LOGIN user_23T1020001
WITH PASSWORD = '123456';
GO

USE TenCSDL;
GO
CREATE USER user_23T1020001
FOR LOGIN user_23T1020001;
GO

GRANT SELECT, INSERT
ON MAYTINH
TO user_23T1020001;
GO

GRANT EXECUTE
TO user_23T1020001;
GO
