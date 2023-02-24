DROP TABLE IF EXISTS `book`;

CREATE TABLE `book` (
  `id` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `author` varchar(255) NOT NULL,
  `genre` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- Add multi index to genre, title, author with id
ALTER TABLE `book` ADD INDEX `idx_genre_title_author` (`genre`, `title`, `author`, `id`);
-- Add index to genre with id
ALTER TABLE `book` ADD INDEX `idx_genre_id` (`genre`, `id`);
-- Add index to title with id
ALTER TABLE `book` ADD INDEX `idx_title_id` (`title`, `id`);
-- Add index to author with id
ALTER TABLE `book` ADD INDEX `idx_author_id` (`author`, `id`);

DROP TABLE IF EXISTS `key`;

CREATE TABLE `key` (
  `id` int NOT NULL AUTO_INCREMENT,
  `key` char(16) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

DROP TABLE IF EXISTS `lending`;

CREATE TABLE `lending` (
  `id` varchar(255) NOT NULL,
  `member_id` varchar(255) NOT NULL,
  `book_id` varchar(255) NOT NULL,
  `due` datetime(6) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-- Add multi index to book_id with id
ALTER TABLE `lending` ADD INDEX `idx_bookid_id` (`book_id`, `id`);

DROP TABLE IF EXISTS `member`;

CREATE TABLE `member` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `phone_number` varchar(255) NOT NULL,
  `banned` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
