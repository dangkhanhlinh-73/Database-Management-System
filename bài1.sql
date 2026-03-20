select masinhvien,hodem,ten,ngaysinh,gioitinh
from SINHVIEN where hodem like 'Lê%';
--12
select masinhvien,hodem,ten,ngaysinh,gioitinh
from SINHVIEN where hodem like N'%Thị%';
--13
SELECT masinhvien, hodem, ten, ngaysinh, gioitinh
FROM SINHVIEN
WHERE hodem LIKE N'% Thị %' or hodem like N'% Thị';

--14
SELECT masinhvien, CONCAT(hodem, ' ', ten) AS'Họ Và Tên' , ngaysinh, gioitinh, malop, (SELECT tenlop FROM lop WHERE lop.malop = sinhvien.malop) AS tenlop
FROM SINHVIEN
WHERE 
--15
SELECT masinhvien, CONCAT(hodem, ' ', ten) AS 'Họ Và Tên', ngaysinh, gioitinh, noisinh
FROM SINHVIEN
WHERE noisinh LIKE N'Huế%';

--16
SELECT masinhvien, CONCAT(hodem, ' ', ten) AS hoten, ngaysinh, gioitinh, malop, (SELECT tenlop FROM lop WHERE lop.malop = sinhvien.malop) AS tenlop
FROM SINHVIEN
WHERE ngaysinh BETWEEN '1992-03-01' AND '1992-08-31';
--17
SELECT masinhvien, CONCAT(hodem, ' ', ten) AS hoten, ngaysinh, gioitinh, malop, (SELECT tenlop FROM lop WHERE lop.malop = sinhvien.malop) AS tenlop
FROM SINHVIEN
WHERE gioitinh ='0'OR (MONTH(ngaysinh) BETWEEN 5 AND 11);

--18
SELECT masinhvien, CONCAT(hodem, ' ', ten) AS 'Họ Và Tên', ngaysinh, gioitinh, malop, (SELECT tenlop FROM LOP WHERE LOP.malop = sinhvien.malop) AS tenlop
FROM SINHVIEN
WHERE hodem NOT LIKE N'%Lê%' AND hodem NOT LIKE N'%Dư%' AND hodem NOT LIKE N'%Võ%' AND hodem NOT LIKE N'%Nguyễn%';
--19
SELECT masinhvien, CONCAT(hodem, ' ', ten) AS hoten, ngaysinh, gioitinh, malop, (SELECT tenlop FROM lop WHERE lop.malop = sinhvien.malop) AS tenlop
FROM SINHVIEN
WHERE hodem LIKE 'Lễ%' AND (ten = 'Nga' OR ten = 'Lý');
--1.10
SELECT masinhvien, CONCAT(hodem, ' ', ten) AS 'Họ Và Tên', ngaysinh, gioitinh, noisinh
FROM SINHVIEN
WHERE noisinh  IS NULL;
--1.11
SELECT LOP.malop, LOP.tenlop, COUNT(sinhvien.masinhvien) AS tong_so_sinh_vien
FROM LOP
LEFT JOIN SINHVIEN ON LOP.malop = SINHVIEN.malop
GROUP BY LOP.malop, LOP.tenlop;
--116
SELECT SINHVIEN.masinhvien, CONCAT(hodem, ' ', ten) AS hoten, ngaysinh, gioitinh, diemmon1
FROM DIEMTS d
JOIN SINHVIEN ON SINHVIEN.masinhvien = d.masinhvien
WHERE diemmon1 = (SELECT MAX(diemmon1) FROM DIEMTS);
--117
SELECT SINHVIEN.masinhvien, CONCAT(hodem, ' ', ten) AS 'hoten', ngaysinh, gioitinh, 
       (diemmon1 + diemmon2 + diemmon3) / 3 AS 'DTB'
FROM DIEMTS d
JOIN SINHVIEN ON SINHVIEN.masinhvien = d.masinhvien
WHERE (diemmon1 + diemmon2 +diemmon3 )/3 = (SELECT MAX((diemmon1 + diemmon2 + diemmon3/3) FROM DIEMTS);
---115
SELECT SINHVIEN.masinhvien, CONCAT(hodem, ' ', ten) AS hoten, ngaysinh, gioitinh, malop, (SELECT tenlop FROM lop WHERE lop.malop = sinhvien.malop) AS tenlop, 
       (diemmon1 + diemmon2 + diemmon3) / 3 AS DTB
FROM DIEMTS
JOIN sinhvien ON sinhvien.masinhvien = diemts.masinhvien
ORDER BY DTB DESC, gioitinh ASC

--1.18
SELECT masinhvien, CONCAT(hodem, ' ', ten) AS hoten, ngaysinh, gioitinh, noisinh
FROM sinhvien
WHERE noisinh = (SELECT noisinh FROM sinhvien WHERE masinhvien = 'DL03');
--1.21-
UPDATE SINHVIEN_HO_LE
SET noisinh = N'Quảng Bình'
WHERE masinhvien LIKE '%03';

--124--

