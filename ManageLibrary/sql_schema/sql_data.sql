--Comment Ctrl + K + C
--Uncomment Ctrl + K + U
--Drop database hiện có

USE [master];
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'ManageLibrary')
BEGIN
    ALTER DATABASE [ManageLibrary] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [ManageLibrary];
END
GO

CREATE DATABASE ManageLibrary;
GO
USE ManageLibrary;
GO

-- BẢNG NHÂN VIÊN
CREATE TABLE Employees (
    EmployeeId VARCHAR(20) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100),
    Telephone NVARCHAR(20),
    Role NVARCHAR(50)
);

-- BẢNG ĐỘC GIẢ
CREATE TABLE Readers (
    ReaderId VARCHAR(20) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    DateOfBirth DATE,
    NationalId NVARCHAR(20),
    TypeOfReader NVARCHAR(50),
    Email NVARCHAR(100),
    Telephone NVARCHAR(20),
    Address NVARCHAR(200),
    Department NVARCHAR(100)
);

-- BẢNG THẺ THƯ VIỆN
CREATE TABLE LibraryCards (
    CardId VARCHAR(20) PRIMARY KEY,
    ReaderId VARCHAR(20) NOT NULL UNIQUE,
    IssueDate DATE NOT NULL,
    ExpiryDate DATE NOT NULL,
    Status NVARCHAR(50) DEFAULT N'Hoạt động', -- Các trạng thái: Hoạt động, Bị khóa, Hết hạn
    Notes NVARCHAR(200),
    FOREIGN KEY (ReaderId) REFERENCES Readers(ReaderId)
);

-- BẢNG TÀI KHOẢN
CREATE TABLE Account (
    AccountId VARCHAR(20) PRIMARY KEY,
    Username NVARCHAR(50) UNIQUE NOT NULL,
    Password NVARCHAR(100) NOT NULL,
    EmployeeId VARCHAR(20),
    ReaderId VARCHAR(20),
    FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId),
    FOREIGN KEY (ReaderId) REFERENCES Readers(ReaderId)
);
SET QUOTED_IDENTIFIER ON;
CREATE UNIQUE INDEX UQ_Account_Reader ON Account(ReaderId) WHERE ReaderId IS NOT NULL;

-- BẢNG TÁC GIẢ
CREATE TABLE Author (
    AuthorId VARCHAR(20) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL
);

-- BẢNG NHÀ XUẤT BẢN
CREATE TABLE Publisher (
    PublisherId VARCHAR(20) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Address NVARCHAR(200),
    Telephone NVARCHAR(20)
);

-- BẢNG THỂ LOẠI
CREATE TABLE Category (
    CategoryId VARCHAR(20) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL
);

-- BẢNG SÁCH
CREATE TABLE Books (
    BookId VARCHAR(20) PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    YearOfPublic INT,
    Position NVARCHAR(50),
    NumOfPage INT,
    Cost DECIMAL(10,2),
    CategoryId VARCHAR(20),
    AuthorId VARCHAR(20),
    PublisherId VARCHAR(20),
    Quantity INT NOT NULL DEFAULT 0,
    FOREIGN KEY (CategoryId) REFERENCES Category(CategoryId),
    FOREIGN KEY (AuthorId) REFERENCES Author(AuthorId),
    FOREIGN KEY (PublisherId) REFERENCES Publisher(PublisherId)
);

-- PHIẾU MƯỢN
CREATE TABLE LoanSlip (
    LoanId VARCHAR(20) PRIMARY KEY,
    ReaderId VARCHAR(20) NOT NULL,
    EmployeeId VARCHAR(20) NOT NULL,
    LoanDate DATE NOT NULL,
    ExpiredDate DATE,
    ReturnDate DATE,
    Status NVARCHAR(50),
    FOREIGN KEY (ReaderId) REFERENCES Readers(ReaderId),
    FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId)
);

-- CHI TIẾT MƯỢN
CREATE TABLE LoanDetail (
    LoanDetailId VARCHAR(20) PRIMARY KEY,
    LoanId VARCHAR(20) NOT NULL,
    BookId VARCHAR(20) NOT NULL,
    LoanStatus NVARCHAR(50),
    ReturnStatus NVARCHAR(50),
    IsLose BIT DEFAULT 0,
    Fine DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (LoanId) REFERENCES LoanSlip(LoanId),
    FOREIGN KEY (BookId) REFERENCES Books(BookId)
);

-- NHIỀU TÁC GIẢ
CREATE TABLE BookAuthor (
    BookId VARCHAR(20),
    AuthorId VARCHAR(20),
    PRIMARY KEY (BookId, AuthorId),
    FOREIGN KEY (BookId) REFERENCES Books(BookId),
    FOREIGN KEY (AuthorId) REFERENCES Author(AuthorId)
);

-- BẢNG CA LÀM VIỆC
CREATE TABLE Shifts (
    ShiftId VARCHAR(20) PRIMARY KEY,
    ShiftName NVARCHAR(100) NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL
);

-- BẢNG PHÂN CÔNG CA
CREATE TABLE ShiftAssignments (
    AssignmentId INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeId VARCHAR(20) NOT NULL,
    ShiftId VARCHAR(20) NOT NULL,
    WorkDate DATE NOT NULL,
    Notes NVARCHAR(200),
    FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId),
    FOREIGN KEY (ShiftId) REFERENCES Shifts(ShiftId),
    CONSTRAINT UQ_Employee_WorkDate UNIQUE (EmployeeId, WorkDate)
);

-- =========================
-- DỮ LIỆU MẪU
-- =========================
INSERT INTO Employees (EmployeeId, FullName, Role)
VALUES ('NV001', N'Admin Quản Trị', N'Quản lý'),
       ('NV002', N'Trần Thủ Thư', N'Thủ thư'),
       ('NV003', N'Lê Kế Toán', N'Kế toán'),
       ('NV004', N'Phạm Bảo Vệ', N'Bảo vệ'),
       ('NV005', N'Nguyễn Nhân Sự', N'Nhân sự'),
       ('NV006', N'Đặng Kiểm Kê', N'Thủ thư'),
       ('NV007', N'Vũ Hỗ Trợ', N'Hỗ trợ'),
       ('NV008', N'Hoàng Chăm Sóc', N'Hỗ trợ'),
       ('NV009', N'Bùi Kỹ Thuật', N'Kỹ thuật'),
       ('NV010', N'Ngô Quản Lý', N'Quản lý');

-- SHIFTS
INSERT INTO Shifts (ShiftId, ShiftName, StartTime, EndTime)
VALUES ('CA1', N'Ca Sáng', '07:30', '11:30'),
       ('CA2', N'Ca Chiều', '13:00', '17:00'),
       ('CA3', N'Ca Tối', '17:30', '21:30');

-- SHIFT ASSIGNMENTS
INSERT INTO ShiftAssignments (EmployeeId, ShiftId, WorkDate)
VALUES ('NV002', 'CA1', '2026-10-01'),
       ('NV003', 'CA2', '2026-10-01'),
       ('NV004', 'CA3', '2026-10-01'),
       ('NV002', 'CA2', '2026-10-02'),
       ('NV005', 'CA1', '2026-10-02');

-- CATEGORY
INSERT INTO Category (CategoryId, Name)
VALUES (N'TL001', N'Công nghệ thông tin'),
       (N'TL002', N'Mạng và bảo mật'),
       (N'TL003', N'Cơ sở dữ liệu'),
       (N'TL004', N'Trí tuệ nhân tạo'),
       (N'TL005', N'Kinh tế học'),
       (N'TL006', N'Quản trị kinh doanh'),
       (N'TL007', N'Văn học Việt Nam'),
       (N'TL008', N'Lịch sử thế giới'),
       (N'TL009', N'Toán học ứng dụng'),
       (N'TL010', N'Ngoại ngữ');

-- AUTHOR
INSERT INTO Author (AuthorId, Name)
VALUES (N'TG001', N'Nguyễn Văn A'),
       (N'TG002', N'Trần Thị B'),
       (N'TG003', N'Lê Văn C'),
       (N'TG004', N'Phạm Minh D'),
       (N'TG005', N'Vũ Thị E'),
       (N'TG006', N'Đặng Tiến F'),
       (N'TG007', N'Hoàng Lệ G'),
       (N'TG008', N'Bùi Tấn H'),
       (N'TG009', N'Ngô Quang I'),
       (N'TG010', N'Dương Ngọc K');

-- PUBLISHER
INSERT INTO Publisher (PublisherId, Name, Address, Telephone)
VALUES (N'NXB001', N'Nhà xuất bản Giáo dục', N'Hà Nội', N'0241234567'),
       (N'NXB002', N'Nhà xuất bản Trẻ', N'TP.HCM', N'0287654321'),
       (N'NXB003', N'Nhà xuất bản Khoa học', N'Đà Nẵng', N'0236123456'),
       (N'NXB004', N'Nhà xuất bản Kim Đồng', N'Hà Nội', N'0249876543'),
       (N'NXB005', N'Nhà xuất bản Văn học', N'Hà Nội', N'0241122334'),
       (N'NXB006', N'Nhà xuất bản Thanh Niên', N'TP.HCM', N'0282233445'),
       (N'NXB007', N'Nhà xuất bản Lao Động', N'Hà Nội', N'0243344556'),
       (N'NXB008', N'Nhà xuất bản Phụ Nữ', N'TP.HCM', N'0284455667'),
       (N'NXB009', N'Nhà xuất bản Đại học Quốc gia', N'Hà Nội', N'0245566778'),
       (N'NXB010', N'Nhà xuất bản Thông tin truyền thông', N'Hà Nội', N'0246677889');

-- BOOKS
INSERT INTO Books (BookId, Name, YearOfPublic, Position, NumOfPage, Cost, CategoryId, AuthorId, PublisherId, Quantity)
VALUES 
('S001', N'Lập trình C# cơ bản', 2020, N'A1', 350, 100000, 'TL001', 'TG001', 'NXB001', 10),
('S002', N'Lập trình Java nâng cao', 2021, N'B2', 420, 120000, 'TL001', 'TG002', 'NXB002', 8),
('S003', N'Thiết kế web với HTML, CSS', 2022, N'C1', 320, 90000, 'TL002', 'TG003', 'NXB003', 15),
('S004', N'Khoa học dữ liệu với Python', 2023, N'A3', 500, 150000, 'TL001', 'TG004', 'NXB001', 7),
('S005', N'Cơ sở dữ liệu SQL', 2019, N'B1', 380, 85000, 'TL003', 'TG001', 'NXB002', 12),
('S006', N'Trí tuệ nhân tạo cơ bản', 2022, N'C2', 400, 110000, 'TL004', 'TG005', 'NXB004', 10),
('S007', N'Kinh tế vĩ mô', 2021, N'D1', 450, 95000, 'TL005', 'TG006', 'NXB005', 20),
('S008', N'Quản trị nguồn nhân lực', 2023, N'D2', 300, 80000, 'TL006', 'TG007', 'NXB006', 15),
('S009', N'Truyện Kiều', 2018, N'E1', 250, 50000, 'TL007', 'TG008', 'NXB007', 30),
('S010', N'Lịch sử chiến tranh thế giới', 2020, N'E2', 600, 200000, 'TL008', 'TG009', 'NXB008', 5);

-- READERS
INSERT INTO Readers (ReaderId, FullName, DateOfBirth, NationalId, TypeOfReader, Email, Telephone, Address, Department)
VALUES
('DG001', N'Nguyễn Văn Hùng', '2000-05-10', '123456789', N'Sinh viên', 'hungnv@example.com', '0901234567', N'123 Nguyễn Trãi, Hà Nội', N'Công nghệ thông tin'),
('DG002', N'Trần Thị Lan', '1999-08-22', '987654321', N'Sinh viên', 'lantr@example.com', '0912345678', N'45 Hai Bà Trưng, Hà Nội', N'Kinh tế'),
('DG003', N'Lê Minh Tuấn', '1998-12-01', '192837465', N'Cựu sinh viên', 'tuanlm@example.com', '0934567890', N'67 Láng Hạ, Hà Nội', N'Quản trị kinh doanh'),
('DG004', N'Phạm Hồng Nhung', '2001-03-18', '564738291', N'Sinh viên', 'nhungph@example.com', '0945678901', N'89 Cầu Giấy, Hà Nội', N'Sư phạm'),
('DG005', N'Hoàng Văn Tài', '1997-11-05', '837465920', N'Giảng viên', 'taihv@example.com', '0956789012', N'12 Kim Mã, Hà Nội', N'Công nghệ thông tin'),
('DG006', N'Vũ Thị Mai', '2000-02-14', '475839201', N'Sinh viên', 'maivt@example.com', '0967890123', N'34 Lê Lợi, TP.HCM', N'Ngôn ngữ Anh'),
('DG007', N'Ngô Đức Duy', '1999-09-25', '829104756', N'Sinh viên', 'duynd@example.com', '0978901234', N'90 Nguyễn Huệ, Đà Nẵng', N'Kỹ thuật phần mềm'),
('DG008', N'Đặng Thị Hòa', '1998-04-30', '910283746', N'Cựu sinh viên', 'hoadt@example.com', '0989012345', N'56 Phan Đình Phùng, Hải Phòng', N'Tài chính - Ngân hàng'),
('DG009', N'Bùi Quốc Khánh', '2001-06-12', '384756920', N'Sinh viên', 'khanhbq@example.com', '0990123456', N'23 Tôn Đức Thắng, Cần Thơ', N'Luật học'),
('DG010', N'Nguyễn Thị Yến', '2000-01-20', '564738920', N'Sinh viên', 'yentn@example.com', '0902345678', N'101 Phạm Văn Đồng, Hà Nội', N'Thiết kế đồ họa');

-- LIBRARY CARDS
INSERT INTO LibraryCards (CardId, ReaderId, IssueDate, ExpiryDate, Status)
VALUES
('T001', 'DG001', '2023-09-01', '2027-09-01', N'Hoạt động'),
('T002', 'DG002', '2023-09-05', '2027-09-05', N'Hoạt động'),
('T003', 'DG003', '2022-09-10', '2024-09-10', N'Hết hạn'),
('T004', 'DG004', '2024-01-15', '2028-01-15', N'Bị khóa'),
('T005', 'DG005', '2021-05-20', '2025-05-20', N'Hoạt động'),
('T006', 'DG006', '2023-11-12', '2027-11-12', N'Hoạt động'),
('T007', 'DG007', '2024-02-28', '2028-02-28', N'Hoạt động'),
('T008', 'DG008', '2020-03-15', '2024-03-15', N'Hết hạn'),
('T009', 'DG009', '2022-08-20', '2026-08-20', N'Hoạt động'),
('T010', 'DG010', '2023-06-01', '2027-06-01', N'Hoạt động');

-- ACCOUNT
INSERT INTO Account (AccountId, Username, Password, EmployeeId)
VALUES ('TK001', N'admin', N'123', 'NV001'),
       ('TK003', N'nvthuthu', N'123', 'NV002'),
       ('TK004', N'nvketoan', N'123', 'NV003');

INSERT INTO Account (AccountId, Username, Password, ReaderId)
VALUES ('TK002', N'user', N'123', 'DG001'),
       ('TK005', N'lan123', N'123', 'DG002'),
       ('TK006', N'tuan123', N'123', 'DG003'),
       ('TK007', N'nhung123', N'123', 'DG004'),
       ('TK008', N'tai123', N'123', 'DG005'),
       ('TK009', N'mai123', N'123', 'DG006'),
       ('TK010', N'duy123', N'123', 'DG007');

-- =========================
-- PHIẾU MƯỢN/TRẢ MẪU
-- =========================
-- Các trạng thái sử dụng: 'Đang mượn', 'Đã trả', 'Quá hạn'
INSERT INTO LoanSlip (LoanId, ReaderId, EmployeeId, LoanDate, ExpiredDate, ReturnDate, Status)
VALUES
('PM001', 'DG001', 'NV001', '2024-10-01', '2024-10-15', '2024-10-10', N'Đã trả'),
('PM002', 'DG002', 'NV001', '2024-10-20', '2024-10-27', NULL,             N'Đang mượn'),
('PM003', 'DG003', 'NV001', '2024-09-25', '2024-10-02', NULL,             N'Quá hạn'),
('PM004', 'DG004', 'NV001', '2024-10-15', '2024-10-29', '2024-11-01',     N'Đã trả'),
('PM005', 'DG005', 'NV002', '2024-11-01', '2024-11-15', NULL,             N'Đang mượn'),
('PM006', 'DG006', 'NV002', '2024-11-02', '2024-11-16', '2024-11-10',     N'Đã trả'),
('PM007', 'DG007', 'NV003', '2024-11-05', '2024-11-12', NULL,             N'Đang mượn'),
('PM008', 'DG008', 'NV003', '2024-08-10', '2024-08-24', NULL,             N'Quá hạn'),
('PM009', 'DG009', 'NV001', '2024-10-05', '2024-10-19', '2024-10-18',     N'Đã trả'),
('PM010', 'DG010', 'NV002', '2024-11-10', '2024-11-24', NULL,             N'Đang mượn');

-- CHI TIẾT PHIẾU MƯỢN/TRẢ
INSERT INTO LoanDetail (LoanDetailId, LoanId, BookId, LoanStatus, ReturnStatus, IsLose, Fine)
VALUES
-- PM001: Đã trả, sách tốt
('CT001', 'PM001', 'S001', N'Mới', N'Tốt', 0, 0),
('CT002', 'PM001', 'S003', N'Mới', N'Tốt', 0, 0),
-- PM002: Đang mượn (chưa trả)
('CT003', 'PM002', 'S002', N'Mới', NULL, 0, 0),
('CT004', 'PM002', 'S004', N'Mới', NULL, 0, 0),
-- PM003: Quá hạn (chưa trả)
('CT005', 'PM003', 'S005', N'Bình thường', NULL, 0, 0),
-- PM004: Đã trả, 1 cuốn mất, có phạt
('CT006', 'PM004', 'S002', N'Bình thường', N'Hư hỏng nặng', 1, 100000),
('CT007', 'PM004', 'S001', N'Bình thường', N'Tốt', 0, 0),
-- Các phiếu còn lại
('CT008', 'PM005', 'S006', N'Mới', NULL, 0, 0),
('CT009', 'PM006', 'S007', N'Bình thường', N'Tốt', 0, 0),
('CT010', 'PM007', 'S008', N'Mới', NULL, 0, 0),
('CT011', 'PM008', 'S009', N'Bình thường', NULL, 0, 0),
('CT012', 'PM009', 'S010', N'Mới', N'Tốt', 0, 0),
('CT013', 'PM010', 'S001', N'Bình thường', NULL, 0, 0);

PRINT N'Cơ sở dữ liệu đã khởi tạo và thêm dữ liệu mẫu thành công!';
GO
