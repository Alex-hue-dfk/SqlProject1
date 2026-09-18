-- 1. Users (Пользователи)
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1,
    CONSTRAINT CHK_Email CHECK (Email LIKE '%@%.%')
);

-- 2. UserProfiles (Профили пользователей) - Связь 1:1 с Users
CREATE TABLE UserProfiles (
    ProfileID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL UNIQUE, -- UNIQUE обеспечивает 1:1
    DisplayName NVARCHAR(100),
    AvatarUrl NVARCHAR(255),
    Bio NVARCHAR(500),
    Country NVARCHAR(50),
    BirthDate DATE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- 3. Developers (Разработчики)
CREATE TABLE Developers (
    DeveloperID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Website NVARCHAR(255),
    FoundedDate DATE,
    IsStudio BIT DEFAULT 1
);

-- 4. Publishers (Издатели)
CREATE TABLE Publishers (
    PublisherID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Country NVARCHAR(50),
    ContactEmail NVARCHAR(100)
);

-- 5. Games (Игры)
CREATE TABLE Games (
    GameID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(150) NOT NULL,
    Description NVARCHAR(MAX),
    Price DECIMAL(10, 2) NOT NULL,
    ReleaseDate DATE,
    PublisherID INT,
    Rating DECIMAL(3, 1) DEFAULT 0.0,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (PublisherID) REFERENCES Publishers(PublisherID),
    CONSTRAINT CHK_Price CHECK (Price >= 0),
    CONSTRAINT CHK_Rating CHECK (Rating >= 0 AND Rating <= 10)
);

-- 6. Genres (Жанры)
CREATE TABLE Genres (
    GenreID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(255)
);

-- 7. Tags (Теги)
CREATE TABLE Tags (
    TagID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL UNIQUE,
    Category NVARCHAR(50) DEFAULT 'General'
);

-- 8. GameGenres (Связь M:N Игры и Жанры)
CREATE TABLE GameGenres (
    GameID INT NOT NULL,
    GenreID INT NOT NULL,
    PRIMARY KEY (GameID, GenreID),
    FOREIGN KEY (GameID) REFERENCES Games(GameID) ON DELETE CASCADE,
    FOREIGN KEY (GenreID) REFERENCES Genres(GenreID) ON DELETE CASCADE
);

-- 9. GameDevelopers (Связь M:N Игры и Разработчики)
CREATE TABLE GameDevelopers (
    GameID INT NOT NULL,
    DeveloperID INT NOT NULL,
    Role NVARCHAR(50) DEFAULT 'Main', -- Например, Main, Porting
    PRIMARY KEY (GameID, DeveloperID),
    FOREIGN KEY (GameID) REFERENCES Games(GameID) ON DELETE CASCADE,
    FOREIGN KEY (DeveloperID) REFERENCES Developers(DeveloperID) ON DELETE CASCADE
);

-- 10. GameTags (Связь M:N Игры и Теги)
CREATE TABLE GameTags (
    GameID INT NOT NULL,
    TagID INT NOT NULL,
    PRIMARY KEY (GameID, TagID),
    FOREIGN KEY (GameID) REFERENCES Games(GameID) ON DELETE CASCADE,
    FOREIGN KEY (TagID) REFERENCES Tags(TagID) ON DELETE CASCADE
);

-- 11. Wallets (Кошельки)
CREATE TABLE Wallets (
    WalletID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL UNIQUE, -- 1:1 с пользователем
    Balance DECIMAL(18, 2) DEFAULT 0.00,
    Currency NVARCHAR(3) DEFAULT 'USD',
    LastUpdated DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    CONSTRAINT CHK_Balance CHECK (Balance >= 0)
);

-- 12. Transactions (Транзакции)
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    WalletID INT NOT NULL,
    Amount DECIMAL(18, 2) NOT NULL,
    TransactionType NVARCHAR(20) NOT NULL, -- 'Deposit', 'Purchase', 'Refund'
    Status NVARCHAR(20) DEFAULT 'Pending',
    TransactionDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (WalletID) REFERENCES Wallets(WalletID),
    CONSTRAINT CHK_Amount CHECK (Amount != 0)
);

-- 13. Purchases (Покупки)
CREATE TABLE Purchases (
    PurchaseID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    GameID INT NOT NULL,
    AmountPaid DECIMAL(10, 2) NOT NULL,
    PurchaseDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (GameID) REFERENCES Games(GameID),
    CONSTRAINT CHK_PaidAmount CHECK (AmountPaid >= 0)
);

-- 14. Libraries (Библиотеки игр пользователей)
CREATE TABLE Libraries (
    LibraryID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    GameID INT NOT NULL,
    AcquisitionType NVARCHAR(20) DEFAULT 'Purchase', -- 'Purchase', 'Gift', 'Free'
    AddedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (GameID) REFERENCES Games(GameID),
    CONSTRAINT UQ_UserGame UNIQUE (UserID, GameID) -- Игра не может быть в библиотеке дважды
);