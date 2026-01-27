-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 26, 2025 at 04:29 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `journalshop`
--

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `carts`
--

CREATE TABLE `carts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2025_11_22_074109__create_users_table', 1),
(2, '2025_11_22_074118__create_cache_table', 1),
(3, '2025_11_22_074126__create_jobs_table', 1),
(4, '2025_11_22_074135_add_two_factor_columns_to_users_table', 1),
(5, '2025_11_22_074145_create_personal_access_tokens_table', 1),
(6, '2025_11_22_074153_add_role_to_users_table', 1),
(7, '2025_11_22_074204_create_products_table', 1),
(8, '2025_11_22_074212_create_wishlists_table', 1),
(9, '2025_11_22_074220_create_carts_table', 1),
(10, '2025_11_22_074228_create_orders_table', 1),
(11, '2025_11_22_074237_create_order_items_table', 1),
(12, '2025_11_22_074247_remove_items_from_orders_table', 1),
(13, '2025_11_22_074258_add_status_to_orders_table', 1);

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `payment_method` varchar(255) NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `status` enum('pending','completed') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `name`, `email`, `phone`, `address`, `city`, `payment_method`, `total`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'Amrah Imran', 'fathimaamrahimran@gmail.com', '0997653456', 'park road', 'colombo 5', 'Card', 5500.00, 'pending', '2025-11-22 02:53:06', '2025-11-22 02:53:06');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` varchar(255) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `quantity`, `price`, `created_at`, `updated_at`) VALUES
(1, 1, 'L1CBLUE', 1, 5500.00, '2025-11-22 02:53:06', '2025-11-22 02:53:06');

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 'App\\Models\\User', 1, 'TestToken', '0db7caecfd0877d5a5ee3a6ced3fc1d393c9657ab6b220616cfa6fef92091096', '[\"*\"]', NULL, NULL, '2025-11-22 03:19:02', '2025-11-22 03:19:02'),
(2, 'App\\Models\\User', 3, 'api-token', '68b400692c2d9ddcf07e7734b41fb61f4c41c29cd9db1591ad1d8df30a9c0626', '[\"*\"]', NULL, NULL, '2025-11-22 03:36:07', '2025-11-22 03:36:07'),
(3, 'App\\Models\\User', 3, 'api-token', '73faee6b1967999c85be602782542a4aa0077c8ecb1940baa117220310763813', '[\"*\"]', NULL, NULL, '2025-11-23 04:54:05', '2025-11-23 04:54:05'),
(4, 'App\\Models\\User', 3, 'api-token', 'b06caca6bd09e97a47aaf49875e3694b2e542d8ef7f94a4948d927d26b7daa1b', '[\"*\"]', NULL, NULL, '2025-11-23 07:08:52', '2025-11-23 07:08:52'),
(5, 'App\\Models\\User', 3, 'api-token', 'f84ab113b3b48b32ef782baafffef473c7356a1533d7697d0c4afb4d98b1edb2', '[\"*\"]', '2025-11-23 08:22:12', NULL, '2025-11-23 07:51:54', '2025-11-23 08:22:12'),
(6, 'App\\Models\\User', 4, 'api-token', 'b2c06a11636c632b676c71660a2a0b4bcbdbb9b47ba9979df66badf4ea2feb84', '[\"*\"]', NULL, NULL, '2025-11-23 08:39:54', '2025-11-23 08:39:54'),
(7, 'App\\Models\\User', 3, 'api-token', '93e8c64fe7f82a65a48a1cb94c0993012cc9f2624a43f8be620312092e77ed19', '[\"*\"]', '2025-11-23 21:22:43', NULL, '2025-11-23 20:35:25', '2025-11-23 21:22:43'),
(8, 'App\\Models\\User', 5, 'api-token', '2ff3f09f0f7b4d4577cae5a5a2b8b12a4c0a3f61007d8e1a3d7bba2fe8e0d4f8', '[\"*\"]', NULL, NULL, '2025-11-23 20:41:50', '2025-11-23 20:41:50'),
(9, 'App\\Models\\User', 5, 'api-token', 'c34c072c6cdc56ae877430fc5d8004d1916184ffac2672e119439ede2835433b', '[\"*\"]', '2025-11-23 21:31:50', NULL, '2025-11-23 20:43:22', '2025-11-23 21:31:50'),
(10, 'App\\Models\\User', 3, 'api-token', '0d19afe3984d2133d7f44c85f7198d6fd5551216db12b85121844202e5dc50a4', '[\"*\"]', '2025-11-24 10:09:31', NULL, '2025-11-24 09:51:12', '2025-11-24 10:09:31');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` varchar(255) NOT NULL,
  `category` varchar(255) NOT NULL,
  `color` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `name` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `price` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `isBestSeller` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `category`, `color`, `description`, `name`, `image`, `price`, `quantity`, `isBestSeller`, `created_at`, `updated_at`) VALUES
('L10', 'eastern', 'WHITE', 'A serene and elegant journal inspired by traditional Eastern artistry.', 'Chen Chin Ling', 'products/L10.webp', 4000, 40, 0, NULL, NULL),
('L11', 'eastern', 'RED', 'Celebrate the stars and ancient mystique with this richly designed notebook.', 'Celestial Chinese', 'products/L11.webp', 5000, 40, 0, NULL, NULL),
('L12', 'other', 'MIXED', 'Add a magical touch to your notebooks, letters, or devices with these colorful butterfly stickers.', 'Butterfly Stickers', 'products/L12.webp', 1300, 40, 0, NULL, NULL),
('L13', 'other', 'MIXED', 'Bright and cheerful sunflower-themed stickers to decorate anything that brings you joy.', 'Sunflower Stickers', 'products/L13.webp', 1300, 40, 0, NULL, NULL),
('L14', 'other', 'MIXED', 'A whimsical set of nature-inspired stickers—perfect for bullet journaling and scrapbooking.', 'Secret Garden', 'products/L14.webp', 1300, 40, 0, NULL, NULL),
('L15', 'other', 'MIXED', 'A premium pen set with intricate detailing and smooth ink flow—ideal for both collectors and daily writers.', 'Crystal Pen Set', 'products/L15.webp', 5000, 40, 0, NULL, NULL),
('L16', 'other', 'BLUE', 'Masterfully crafted with a traditional Japanese aesthetic, this fountain pen delivers elegance and performance.', 'Fountain Pen', 'products/L16.webp', 8000, 40, 0, NULL, NULL),
('L1CBLACK', 'journal', 'BLACK', 'A stylish hard-cover journal featuring a mystical moon phase design. Perfect for planning, dreaming, and manifesting.', 'Moon Phases', 'products/L1CBLACK.webp', 5500, 40, 0, NULL, NULL),
('L1CBLUE', 'journal', 'BLUE', 'A stylish hard-cover journal featuring a mystical moon phase design. Perfect for planning, dreaming, and manifesting.', 'Moon Phases', 'products/L1CBLUE.webp', 5500, 39, 1, NULL, '2025-11-22 02:53:06'),
('L1CPINK', 'journal', 'PINK', 'A stylish hard-cover journal featuring a mystical moon phase design. Perfect for planning, dreaming, and manifesting.', 'Moon Phases', 'products/L1CPINK.webp', 5500, 40, 0, NULL, NULL),
('L2', 'vintage', 'MIXED', 'A graceful blend of vintage tones and floral elegance. Ideal for gifting or special journaling moments.', 'Victorian Beauty', 'products/L2.webp', 4000, 40, 0, NULL, NULL),
('L3', 'vintage', 'GREEN', 'Inspired by the elegance of ballet, this set brings peace and grace to your writing. A delicate blend of design and comfort—perfect for light journaling and gifting.', 'Swan Lake', 'products/L3.webp', 7350, 40, 1, NULL, '2025-11-22 02:45:11'),
('L4', 'cute', 'GREEN', 'A journal set celebrating life\'s colorful moments with intricate patterns and flair.', 'Mosaic Of Life', 'products/L4.webp', 6000, 40, 0, NULL, NULL),
('L5', 'journal', 'BLUE', 'Let this journal guide your thoughts like a star through the night—calm, cool, and collected.', 'North Star', 'products/L5.webp', 2900, 40, 0, NULL, NULL),
('L6CBLACK', 'cute', 'BLACK', 'A timeless notebook design with soft-touch covers and smooth paper, available in both large and medium sizes. Comes in black, blue, green, and pink.', 'Classic Notebook', 'products/L6CBLACK.webp', 2200, 40, 1, NULL, '2025-11-22 02:45:40'),
('L6CBLUE', 'cute', 'BLUE', 'A timeless notebook design with soft-touch covers and smooth paper, available in both large and medium sizes. Comes in black, blue, green, and pink.', 'Classic Notebook', 'products/L6CBLUE.webp', 2200, 40, 0, NULL, NULL),
('L6CGREEN', 'cute', 'GREEN', 'A timeless notebook design with soft-touch covers and smooth paper, available in both large and medium sizes. Comes in black, blue, green, and pink.', 'Classic Notebook', 'products/L6CGREEN.webp', 2200, 40, 0, NULL, NULL),
('L6CPINK', 'cute', 'PINK', 'A timeless notebook design with soft-touch covers and smooth paper, available in both large and medium sizes. Comes in black, blue, green, and pink.', 'Classic Notebook', 'products/L6CPINK.webp', 2200, 40, 0, NULL, NULL),
('L7', 'vintage', 'WHITE', 'A floral-themed, notebook that brings a breath of fresh air to your writing sessions.', 'The Flower Garden', 'products/L7.webp', 7750, 40, 0, NULL, NULL),
('L8', 'cute', 'BLUE', 'A cheerful design filled with playful panda vibes—great for kids and fun-loving adults.', 'Panda And Friends', 'products/L8.webp', 3000, 40, 1, NULL, '2025-11-22 02:45:54'),
('L9CBLACK', 'journal', 'BLACK', 'The Tsuki Journal combines minimalism with charm. Whether you\'re bullet journaling or sketching, it\'s available in both large and medium sizes in black, blue, green, and pink.', 'Tsuki Journal', 'products/L9CBLACK.webp', 2200, 40, 0, NULL, NULL),
('L9CBLUE', 'journal', 'BLUE', 'The Tsuki Journal combines minimalism with charm. Whether you\'re bullet journaling or sketching, it\'s available in both large and medium sizes in black, blue, green, and pink.', 'Tsuki Journal', 'products/L9CBLUE.webp', 2200, 40, 0, NULL, NULL),
('L9CGREEN', 'journal', 'GREEN', 'The Tsuki Journal combines minimalism with charm. Whether you\'re bullet journaling or sketching, it\'s available in both large and medium sizes in black, blue, green, and pink.', 'Tsuki Journal', 'products/L9CGREEN.webp', 2200, 40, 0, NULL, NULL),
('L9CPINK', 'journal', 'PINK', 'The Tsuki Journal combines minimalism with charm. Whether you\'re bullet journaling or sketching, it\'s available in both large and medium sizes in black, blue, green, and pink.', 'Tsuki Journal', 'products/L9CPINK.webp', 2200, 40, 0, NULL, NULL),
('M10', 'eastern', 'WHITE', 'A serene and elegant journal inspired by traditional Eastern artistry.', 'Chen Chin Ling', 'products/M10.webp', 3100, 40, 0, NULL, NULL),
('M11', 'eastern', 'RED', 'Celebrate the stars and ancient mystique with this richly designed notebook.', 'Celestial Chinese', 'products/M11.webp', 4250, 40, 0, NULL, NULL),
('M1CBLACK', 'journal', 'BLACK', 'A stylish hard-cover journal featuring a mystical moon phase design. Perfect for planning, dreaming, and manifesting.', 'Moon Phases', 'products/M1CBLACK.webp', 3600, 40, 0, NULL, NULL),
('M1CBLUE', 'journal', 'BLUE', 'A stylish hard-cover journal featuring a mystical moon phase design. Perfect for planning, dreaming, and manifesting.', 'Moon Phases', 'products/M1CBLUE.webp', 3600, 40, 0, NULL, NULL),
('M1CPINK', 'journal', 'PINK', 'A stylish hard-cover journal featuring a mystical moon phase design. Perfect for planning, dreaming, and manifesting.', 'Moon Phases', 'products/M1CPINK.webp', 3600, 40, 0, NULL, NULL),
('M2', 'vintage', 'MIXED', 'A charming medium-sized version of the Victorian Beauty—stylish and practical.', 'Victorian Beauty', 'products/M2.webp', 2000, 40, 0, NULL, NULL),
('M3', 'vintage', 'GREEN', 'Inspired by the elegance of ballet, this set brings peace and grace to your writing.', 'Swan Lake', 'products/M3.webp', 5640, 40, 0, NULL, NULL),
('M4', 'cute', 'GREEN', 'A journal set celebrating life\'s colorful moments with intricate patterns and flair.', 'Mosaic Of Life', 'products/M4.webp', 3700, 40, 0, NULL, NULL),
('M5', 'journal', 'BLUE', 'Let this journal guide your thoughts like a star through the night—calm, cool, and collected.', 'North Star', 'products/M5.webp', 1800, 40, 0, NULL, NULL),
('M6CBLACK', 'cute', 'BLACK', 'A timeless notebook design with soft-touch covers and smooth paper.', 'Classic Notebook', 'products/M6CBLACK.webp', 1500, 40, 0, NULL, NULL),
('M6CBLUE', 'cute', 'BLUE', 'A timeless notebook design with soft-touch covers and smooth paper.', 'Classic Notebook', 'products/M6CBLUE.webp', 1500, 40, 0, NULL, NULL),
('M6CGREEN', 'cute', 'GREEN', 'A timeless notebook design with soft-touch covers and smooth paper.', 'Classic Notebook', 'products/M6CGREEN.webp', 1500, 40, 0, NULL, NULL),
('M6CPINK', 'cute', 'PINK', 'A timeless notebook design with soft-touch covers and smooth paper.', 'Classic Notebook', 'products/M6CPINK.webp', 1500, 40, 0, NULL, NULL),
('M7', 'vintage', 'WHITE', 'A floral-themed, medium notebook that brings a breath of fresh air to your writing sessions.', 'The Flower Garden', 'products/M7.webp', 6900, 40, 0, NULL, NULL),
('M8', 'cute', 'BLUE', 'A cheerful design filled with playful panda vibes—great for kids and fun-loving adults.', 'Panda And Friends', 'products/M8.webp', 1500, 40, 0, NULL, NULL),
('M9CBLACK', 'journal', 'BLACK', 'The Tsuki Journal combines minimalism with charm.', 'Tsuki Journal', 'products/M9CBLACK.webp', 1650, 40, 0, NULL, NULL),
('M9CBLUE', 'journal', 'BLUE', 'The Tsuki Journal combines minimalism with charm.', 'Tsuki Journal', 'products/M9CBLUE.webp', 1650, 40, 0, NULL, NULL),
('M9CGREEN', 'journal', 'GREEN', 'The Tsuki Journal combines minimalism with charm.', 'Tsuki Journal', 'products/M9CGREEN.webp', 1650, 40, 0, NULL, NULL),
('M9CPINK', 'journal', 'PINK', 'The Tsuki Journal combines minimalism with charm.', 'Tsuki Journal', 'products/M9CPINK.webp', 1650, 40, 0, NULL, NULL),
('P001', 'Cute', 'Pink', 'Cute pink notebook', 'Notebook', 'notebook1.jpg', 500, 10, 0, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('0vtoiVHyVbdl1X38wfmgzPkeg5vKlK2BAnNJ4eRq', NULL, '127.0.0.1', 'PostmanRuntime/7.49.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibTJ4RDJGNDZZM2loOXY1NlRhUmJoczNDNkdUWE9IZWI2VVBNZ0tzNCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6NDE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9zYW5jdHVtL2NzcmYtY29va2llIjtzOjU6InJvdXRlIjtzOjE5OiJzYW5jdHVtLmNzcmYtY29va2llIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763996010),
('5PJgr3KB4JJb8cg6lADydXaNUORwzDwtYWQ9Phua', 3, '127.0.0.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15', 'YTo1OntzOjY6Il90b2tlbiI7czo0MDoiRFNrTHhIQjhVcHB5WGpqNE5JVGs1VmdXazlaU1F2TVU1ZURSdWVwaiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9kYXNoYm9hcmQiO3M6NToicm91dGUiO3M6OToiZGFzaGJvYXJkIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6MztzOjIxOiJwYXNzd29yZF9oYXNoX3NhbmN0dW0iO3M6NjA6IiQyeSQxMiRDbXk4OUNKZy53Q21kNUhPR1EzTHBPUmhjR0hOcGxJY2tEUGN3SS8xUHgwUFJ5d2ZWdkd6TyI7fQ==', 1763995663),
('dTOI0zp1NYOvUaOvRtEUupzavc5ZJWv0XfcQWIFm', 3, '127.0.0.1', 'PostmanRuntime/7.49.1', 'YTo1OntzOjY6Il90b2tlbiI7czo0MDoiYmdHd1pyOXdSa0ZRZnhTMTNXUlZvUk9rZVlJeEMxQXJFNmxJNmRUbyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9kYXNoYm9hcmQiO3M6NToicm91dGUiO3M6OToiZGFzaGJvYXJkIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6MztzOjIxOiJwYXNzd29yZF9oYXNoX3NhbmN0dW0iO3M6NjA6IiQyeSQxMiRDbXk4OUNKZy53Q21kNUhPR1EzTHBPUmhjR0hOcGxJY2tEUGN3SS8xUHgwUFJ5d2ZWdkd6TyI7fQ==', 1763995041),
('gMcXIdjUbUwMKW2EgJHFbrP7cAdwEqoWaGWvXLz5', NULL, '127.0.0.1', 'PostmanRuntime/7.49.1', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiNTlQWjg1clFOblA2THo5OWZIS2FUM2Y4d2p4eVlQTHk5c1FyNjYxcSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763995477),
('hz13XtHviebF8adbXV60uGnYQUJJ0VrAOJFdZo1M', NULL, '127.0.0.1', 'PostmanRuntime/7.49.1', 'YTo0OntzOjY6Il90b2tlbiI7czo0MDoidkdIWVZkdWhFd3RGdHJKdm5wNDRZaWFpTFU0U3pYd0luN0ZscXlxWiI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjc6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6MzoidXJsIjthOjE6e3M6ODoiaW50ZW5kZWQiO3M6Mjc6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9sb2dpbiI7fX0=', 1763905495),
('Liv2CiBuPbds4o6CY3WmoINQoBu1qcp1TNxvMA9w', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'YTo0OntzOjY6Il90b2tlbiI7czo0MDoiYnRVQ2wwZDlBZjI2bXM0Zm96YWp0d3BZZkVEUTk3d2N6MmxReUxoaCI7czozOiJ1cmwiO2E6MTp7czo4OiJpbnRlbmRlZCI7czozNjoiaHR0cDovLzEyNy4wLjAuMTo4MDAwL2FkbWluL3Byb2R1Y3RzIjt9czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjc6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1763910897),
('QkPyK8NjEQ3DJgYaMrnfKxkr9V2VN7SAFjSS7NIL', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYm1SaVB6cnNyMUxDb2VEYlk2M3pnU0luNEg2SzFTSnVGZzVrQ3dCSCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMCI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1764127600),
('z9twwHBSnySXHb09zdMS62LsaDuCVnUiReNgMrHG', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibE5nWHJ3dkFkQ0VOcm54d0tuR0ZwTmNhYnYzZTMzQTZ1a1NSQUw3UyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMCI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763952629),
('zdFb7dxXaz9lwYk9i6ilATGJc8S4KAvbwCP2bL0P', NULL, '127.0.0.1', 'PostmanRuntime/7.49.1', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoic2h1NjlsT3Vpb1c2OFBqZ0FhQVloTXJKUzRZRDUzSTZLR0xkMHJOTyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1763995172);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `two_factor_secret` text DEFAULT NULL,
  `two_factor_recovery_codes` text DEFAULT NULL,
  `two_factor_confirmed_at` timestamp NULL DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `current_team_id` bigint(20) UNSIGNED DEFAULT NULL,
  `profile_photo_path` varchar(2048) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `role` varchar(255) NOT NULL DEFAULT 'user'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `two_factor_secret`, `two_factor_recovery_codes`, `two_factor_confirmed_at`, `remember_token`, `current_team_id`, `profile_photo_path`, `created_at`, `updated_at`, `role`) VALUES
(1, 'Amrah Imran', 'fathimaamrahimran@gmail.com', NULL, '$2y$12$V57pKycqmQ8pEPvUdLcslOUzpKK3wFvMym.gYNKc2aznJ55jcKUZq', NULL, NULL, NULL, 'YPSR5dA4cBmLyxGmP2kTYrtqQhtpHxk4On3jpbEQZ8d0GL5cxyQPkkG60mqS', NULL, NULL, '2025-11-22 02:43:18', '2025-11-22 02:43:18', 'user'),
(2, 'admin', 'admin@gmail.com', NULL, '$2y$12$VfIvSN5UFruqxZcEyZjPpOmTr7qV0cf3xz9wVTJmINponx5LqGlUC', NULL, NULL, NULL, 'cwj2i9Z1rizqMRpkwAPDllCBfr8BJrXZVNnnCxzxL4mvTmptL5uwvCeBiQUZ', NULL, NULL, '2025-11-22 02:44:05', '2025-11-22 02:44:05', 'admin'),
(3, 'Yosif Alemin', 'yosif@gmail.com', NULL, '$2y$12$Cmy89CJg.wCmd5HOGQ3LpORhcGHNplIckDPcwI/1Px0PRywfVvGzO', NULL, NULL, NULL, '0oSvqAA5QOVoV6FujmJOWvMs2WbuVeRJkaMutBhzumfp8mU9Q5EBTuUTNXAN', NULL, NULL, '2025-11-22 02:47:48', '2025-11-22 02:47:48', 'user'),
(4, 'Test User', 'testuser@example.com', NULL, '$2y$12$hgplHz5Qgk6eloOX3wV88e506WBYqYMSFB.g3SWWrToXTNQQPk6mC', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-23 08:39:54', '2025-11-23 08:39:54', 'user'),
(5, 'User B', 'userb@gmail.com', NULL, '$2y$12$kA1UQpyeOLmg7RQfeXUBWeCvp6hdtPRyjCKyHE7ufBqYApUNpUQLq', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-23 20:41:50', '2025-11-23 20:41:50', 'user');

-- --------------------------------------------------------

--
-- Table structure for table `wishlists`
--

CREATE TABLE `wishlists` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `carts_user_id_foreign` (`user_id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `orders_user_id_foreign` (`user_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_items_order_id_foreign` (`order_id`),
  ADD KEY `order_items_product_id_foreign` (`product_id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Indexes for table `wishlists`
--
ALTER TABLE `wishlists`
  ADD PRIMARY KEY (`id`),
  ADD KEY `wishlists_user_id_foreign` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `carts`
--
ALTER TABLE `carts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `wishlists`
--
ALTER TABLE `wishlists`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `carts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `wishlists`
--
ALTER TABLE `wishlists`
  ADD CONSTRAINT `wishlists_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
