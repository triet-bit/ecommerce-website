USE ecommerce;

-- Thêm dữ liệu test
INSERT INTO danh_muc_san_phams (ten_danh_muc, mo_ta_danh_muc, url_hinh_anh_dai_dien, parent_category_id)
VALUES 
('Category A', 'A', 'img', NULL),
('Category B', 'B', 'img', (SELECT category_id FROM (SELECT category_id FROM danh_muc_san_phams WHERE ten_danh_muc = 'Category A') as tmp)),
('Category C', 'C', 'img', (SELECT category_id FROM (SELECT category_id FROM danh_muc_san_phams WHERE ten_danh_muc = 'Category B') as tmp));

-- Test 1: Category B is parent of Category A -> Cycle! (A -> B -> A)
UPDATE danh_muc_san_phams
SET parent_category_id = (SELECT category_id FROM (SELECT category_id FROM danh_muc_san_phams WHERE ten_danh_muc = 'Category B') as tmp)
WHERE ten_danh_muc = 'Category A';

-- Test 2: Category C is parent of Category A -> Cycle! (A -> B -> C -> A)
UPDATE danh_muc_san_phams
SET parent_category_id = (SELECT category_id FROM (SELECT category_id FROM danh_muc_san_phams WHERE ten_danh_muc = 'Category C') as tmp)
WHERE ten_danh_muc = 'Category A';

-- Xóa dữ liệu test
DELETE FROM danh_muc_san_phams WHERE ten_danh_muc IN ('Category A', 'Category B', 'Category C');
