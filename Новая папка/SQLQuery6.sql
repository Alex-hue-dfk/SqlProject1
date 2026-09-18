USE GameStore;
GO

-- 1. Users (5 пользователей)
INSERT INTO Users (Username, Email, PasswordHash) VALUES 
('gamer_pro', 'pro@mail.com', 'hash_1'),
('noob_master', 'noob@mail.com', 'hash_2'),
('admin', 'admin@site.com', 'hash_3'),
('sarah_connor', 'sarah@sky.net', 'hash_4'),
('john_doe', 'john@doe.com', 'hash_5');

-- 2. UserProfiles (5 профилей, по одному на каждого юзера)
INSERT INTO UserProfiles (UserID, DisplayName, Bio, Country, BirthDate) VALUES 
(1, 'ProGamer', 'Люблю RPG и хардкор', 'USA', '1995-05-12'),
(2, 'Noob', 'Новичок, учусь играть', 'Russia', '2000-08-22'),
(3, 'Admin', 'Главный по тарелочкам', 'Germany', '1990-01-01'),
(4, 'Sarah', 'Ищу игры про роботов', 'USA', '1985-11-10'),
(5, 'John', 'Просто играю в свободное время', 'UK', '1998-03-30');

-- 3. Wallets (5 кошельков, по одному на юзера)
INSERT INTO Wallets (UserID, Balance, Currency) VALUES 
(1, 150.50, 'USD'),
(2, 25.00, 'USD'),
(3, 9999.99, 'EUR'),
(4, 0.00, 'USD'),
(5, 75.25, 'USD');

-- 4. Developers (5 разработчиков)
INSERT INTO Developers (Name, Website, FoundedDate, IsStudio) VALUES 
('CD Projekt Red', 'cdpr.com', '1994-05-01', 1),
('Rockstar Games', 'rockstar.com', '1998-12-01', 1),
('Indie Dev', 'indiedev.io', '2020-01-15', 0),
('Valve', 'valvesoftware.com', '1996-08-24', 1),
('Ubisoft', 'ubisoft.com', '1986-03-28', 1);

-- 5. Publishers (5 издателей)
INSERT INTO Publishers (Name, Country, ContactEmail) VALUES 
('Sony Interactive', 'Japan', 'sony@sony.com'),
('Microsoft Game Studios', 'USA', 'ms@ms.com'),
('CD Projekt', 'Poland', 'cdpr@cdpr.com'),
('Electronic Arts', 'USA', 'ea@ea.com'),
('Nintendo', 'Japan', 'nintendo@nintendo.com');

-- 6. Genres (5 жанров)
INSERT INTO Genres (Name, Description) VALUES 
('RPG', 'Ролевые игры'),
('Shooter', 'Шутеры от первого лица'),
('Strategy', 'Стратегии'),
('Adventure', 'Приключенческие игры'),
('Simulator', 'Симуляторы');

-- 7. Tags (5 тегов)
INSERT INTO Tags (Name, Category) VALUES 
('Open World', 'Gameplay'),
('Multiplayer', 'Gameplay'),
('Cyberpunk', 'Setting'),
('Singleplayer', 'Gameplay'),
('Sci-Fi', 'Setting');

-- 8. Games (5 игр)
INSERT INTO Games (Title, Description, Price, ReleaseDate, PublisherID, Rating) VALUES 
('Cyberpunk 2077', 'RPG в будущем', 59.99, '2020-12-10', 3, 7.5),
('GTA V', 'Экшен в Лос-Сантосе', 29.99, '2013-09-17', 2, 9.5),
('Indie Game', 'Пиксельная история', 4.99, '2023-05-20', 1, 8.0),
('Half-Life 3', 'Легендарный шутер', 49.99, '2025-01-01', 4, 9.9),
('The Witcher 4', 'Новая сага', 69.99, '2026-06-15', 3, 9.0);

-- 9. GameGenres (Связь M:N)
INSERT INTO GameGenres (GameID, GenreID) VALUES 
(1, 1), (1, 4), -- Cyberpunk: RPG, Adventure
(2, 2), (2, 4), -- GTA V: Shooter, Adventure
(3, 4),         -- Indie Game: Adventure
(4, 2), (4, 5), -- Half-Life 3: Shooter, Simulator (условно)
(5, 1);         -- Witcher 4: RPG

-- 10. GameDevelopers (Связь M:N)
INSERT INTO GameDevelopers (GameID, DeveloperID, Role) VALUES 
(1, 1, 'Main'),
(2, 2, 'Main'),
(3, 3, 'Main'),
(4, 4, 'Main'),
(5, 1, 'Main');

-- 11. GameTags (Связь M:N)
INSERT INTO GameTags (GameID, TagID) VALUES 
(1, 1), (1, 3), -- Cyberpunk: Open World, Cyberpunk
(2, 1), (2, 2), -- GTA V: Open World, Multiplayer
(3, 4),         -- Indie Game: Singleplayer
(4, 4), (4, 5), -- Half-Life 3: Singleplayer, Sci-Fi
(5, 4);         -- Witcher 4: Singleplayer

-- 12. Purchases (5 покупок)
INSERT INTO Purchases (UserID, GameID, AmountPaid) VALUES 
(1, 1, 59.99),
(2, 3, 4.99),
(1, 2, 29.99),
(4, 4, 49.99),
(5, 5, 69.99);

-- 13. Libraries (5 записей в библиотеках)
INSERT INTO Libraries (UserID, GameID, AcquisitionType) VALUES 
(1, 1, 'Purchase'),
(2, 3, 'Purchase'),
(1, 2, 'Gift'),
(4, 4, 'Purchase'),
(5, 5, 'Purchase');

-- 14. Transactions (5 транзакций)
INSERT INTO Transactions (WalletID, Amount, TransactionType, Status) VALUES 
(1, 60.00, 'Deposit', 'Completed'),
(1, -59.99, 'Purchase', 'Completed'),
(2, 5.00, 'Deposit', 'Pending'),
(3, 9999.99, 'Deposit', 'Completed'),
(5, 75.25, 'Deposit', 'Completed');