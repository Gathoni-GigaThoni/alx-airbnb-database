-- Airbnb Database Sample Data
-- Created: 2025
-- Author: Mercy Milkah -Gigathoni

-- =============================================================================
-- CLEANING EXISTING DATA (Optional - use with caution in production)
-- =============================================================================

-- Uncomment the following lines if you want to reset the database
-- DELETE FROM reviews;
-- DELETE FROM payments;
-- DELETE FROM bookings;
-- DELETE FROM property_images;
-- DELETE FROM property_amenities;
-- DELETE FROM amenities;
-- DELETE FROM properties;
-- DELETE FROM users;

-- =============================================================================
-- 1. USERS - Sample Users (Hosts and Guests)
-- =============================================================================

INSERT INTO users (email, password_hash, first_name, last_name, phone_number, date_of_birth, is_host, is_email_verified) VALUES
-- Hosts
('wanjiru.kamau@email.com', '$2b$10$examplehash1', 'Wanjiru', 'Kamau', '+254-711-123456', '1985-03-15', true, true),
('john.mwangi@email.com', '$2b$10$examplehash2', 'John', 'Mwangi', '+254-722-234567', '1978-11-22', true, true),
('faith.akinyi@email.com', '$2b$10$examplehash3', 'Faith', 'Akinyi', '+254-733-345678', '1990-07-08', true, true),
('david.odhiambo@email.com', '$2b$10$examplehash4', 'David', 'Odhiambo', '+254-744-456789', '1982-09-30', true, true),

-- Guests
('james.mutiso@email.com', '$2b$10$examplehash5', 'James', 'Mutiso', '+254-755-567890', '1992-04-18', false, true),
('linda.chebet@email.com', '$2b$10$examplehash6', 'Linda', 'Chebet', '+254-766-678901', '1988-12-03', false, true),
('peter.kipchoge@email.com', '$2b$10$examplehash7', 'Peter', 'Kipchoge', '+254-777-789012', '1995-01-25', false, true),
('grace.wambui@email.com', '$2b$10$examplehash8', 'Grace', 'Wambui', '+254-788-890123', '1987-06-14', false, true),
('brian.omondi@email.com', '$2b$10$examplehash9', 'Brian', 'Omondi', '+254-799-901234', '1993-08-19', false, true),
('sarah.atieno@email.com', '$2b$10$examplehash10', 'Sarah', 'Atieno', '+254-710-012345', '1991-02-28', false, true);

-- =============================================================================
-- 2. PROPERTIES - Sample Property Listings
-- =============================================================================

INSERT INTO properties (
    host_id, title, description, property_type, room_type, max_guests, 
    bedrooms, beds, bathrooms, price_per_night, cleaning_fee,
    address_line1, address_line2, city, state, country, postal_code,
    latitude, longitude, is_active
) VALUES
-- Wanjiru's Properties (Nairobi)
(1, 'Modern Nairobi Apartment in Westlands', 'Beautiful modern apartment in the heart of Westlands. Perfect for business travelers or tourists exploring Nairobi. Close to restaurants, shopping malls, and nightlife.', 
 'apartment', 'entire_place', 2, 1, 1, 1.0, 1200.00,
 '123 Muthangari Drive', 'Apt 4B', 'Nairobi', 'Nairobi County', 'Kenya', '00100',
 -1.2580, 36.7965, true),

(1, 'Luxury Karen Home with Garden', 'Stunning family home in Karen with beautiful garden and secure compound. Perfect for families or groups wanting privacy and luxury. Features a fully equipped kitchen and outdoor dining area.', 
 'house', 'entire_place', 6, 3, 4, 2.5, 2500.00,
 '456 Karen Road', NULL, 'Nairobi', 'Nairobi County', 'Kenya', '00502',
 -1.3192, 36.7084, true),

-- John's Properties (Mombasa)
(2, 'Beachfront Villa in Nyali', 'Amazing beachfront property with direct access to private beach. Wake up to the sound of waves and enjoy breathtaking Indian Ocean sunsets from your private balcony.', 
 'villa', 'entire_place', 8, 4, 4, 3.0, 3500.00,
 '789 Beach Road', 'Nyali', 'Mombasa', 'Mombasa County', 'Kenya', '80100',
 -4.0435, 39.6682, true),

(2, 'Cozy Diani Beach Apartment', 'Beautiful apartment just steps from Diani Beach. Perfect for couples or solo travelers looking for a beach getaway. Features a shared pool and garden.', 
 'apartment', 'entire_place', 3, 1, 2, 1.0, 1500.00,
 '321 Diani Beach Road', 'Unit 15C', 'Mombasa', 'Mombasa County', 'Kenya', '80401',
 -4.2964, 39.5711, true),

-- Faith's Properties (Nakuru)
(3, 'Lake Nakuru View Cabin', 'Cozy cabin with stunning views of Lake Nakuru. Perfect for nature lovers and bird watchers. Features a balcony overlooking the lake and easy access to the national park.', 
 'cabin', 'entire_place', 4, 2, 3, 1.0, 1800.00,
 '654 Lakeview Road', NULL, 'Nakuru', 'Nakuru County', 'Kenya', '20100',
 -0.3031, 36.0800, true),

(3, 'Nakuru Town Central Apartment', 'Convenient apartment in the heart of Nakuru town. Walking distance to shops, banks, and restaurants. Perfect for business travelers or short stays.', 
 'apartment', 'entire_place', 3, 1, 2, 1.0, 1000.00,
 '987 Kenyatta Avenue', 'Floor 2', 'Nakuru', 'Nakuru County', 'Kenya', '20100',
 -0.2868, 36.0663, true),

-- David's Properties (Kisumu & Eldoret)
(4, 'Kisumu Lakefront Cottage', 'Charming cottage on the shores of Lake Victoria. Enjoy fresh lake breezes and beautiful sunsets. Perfect for romantic getaways or peaceful retreats.', 
 'cottage', 'entire_place', 3, 1, 2, 1.0, 1300.00,
 '222 Lake Victoria Road', 'Kibuye', 'Kisumu', 'Kisumu County', 'Kenya', '40100',
 -0.0917, 34.7680, true),

(4, 'Eldoret Farm Stay Experience', 'Authentic farm stay experience near Eldoret. Experience rural Kenyan life while enjoying modern comforts. Great for families with children.', 
 'farm_stay', 'entire_place', 6, 3, 4, 2.0, 2000.00,
 '333 Moiben Road', NULL, 'Eldoret', 'Uasin Gishu County', 'Kenya', '30100',
 0.5143, 35.2698, true);

-- =============================================================================
-- 3. PROPERTY AMENITIES - Assign amenities to properties
-- =============================================================================

-- Get amenity IDs and assign to Kenyan properties
INSERT INTO property_amenities (property_id, amenity_id)
SELECT 1, amenity_id FROM amenities WHERE amenity_name IN ('WiFi', 'Air conditioning', 'Kitchen', 'TV', 'Smoke alarm', 'Carbon monoxide alarm');

INSERT INTO property_amenities (property_id, amenity_id)
SELECT 2, amenity_id FROM amenities WHERE amenity_name IN ('WiFi', 'Air conditioning', 'Kitchen', 'TV', 'Garden', 'BBQ grill', 'Washer', 'Dryer', 'Smoke alarm');

INSERT INTO property_amenities (property_id, amenity_id)
SELECT 3, amenity_id FROM amenities WHERE amenity_name IN ('WiFi', 'Air conditioning', 'Kitchen', 'TV', 'Washer', 'Dryer', 'Patio or balcony', 'BBQ grill', 'Pool');

INSERT INTO property_amenities (property_id, amenity_id)
SELECT 4, amenity_id FROM amenities WHERE amenity_name IN ('WiFi', 'Air conditioning', 'Kitchen', 'TV', 'Pool', 'Smoke alarm', 'First aid kit');

INSERT INTO property_amenities (property_id, amenity_id)
SELECT 5, amenity_id FROM amenities WHERE amenity_name IN ('WiFi', 'Kitchen', 'TV', 'Fire extinguisher', 'Patio or balcony', 'BBQ grill');

INSERT INTO property_amenities (property_id, amenity_id)
SELECT 6, amenity_id FROM amenities WHERE amenity_name IN ('WiFi', 'Air conditioning', 'Kitchen', 'TV', 'Smoke alarm', 'Carbon monoxide alarm');

INSERT INTO property_amenities (property_id, amenity_id)
SELECT 7, amenity_id FROM amenities WHERE amenity_name IN ('WiFi', 'Kitchen', 'TV', 'Garden', 'Patio or balcony', 'BBQ grill');

INSERT INTO property_amenities (property_id, amenity_id)
SELECT 8, amenity_id FROM amenities WHERE amenity_name IN ('WiFi', 'Kitchen', 'TV', 'Garden', 'Children''s books and toys', 'BBQ grill', 'Fire extinguisher');

-- =============================================================================
-- 4. PROPERTY IMAGES - Sample property images
-- =============================================================================

INSERT INTO property_images (property_id, image_url, image_order, caption, is_primary) VALUES
(1, 'https://example.com/images/nairobi-apartment-1.jpg', 1, 'Modern living room with city view', true),
(1, 'https://example.com/images/nairobi-apartment-2.jpg', 2, 'Fully equipped kitchen', false),
(1, 'https://example.com/images/nairobi-apartment-3.jpg', 3, 'Bedroom with comfortable bed', false),

(2, 'https://example.com/images/karen-home-1.jpg', 1, 'Beautiful garden and exterior', true),
(2, 'https://example.com/images/karen-home-2.jpg', 2, 'Spacious living area', false),
(2, 'https://example.com/images/karen-home-3.jpg', 3, 'Master bedroom with ensuite', false),

(3, 'https://example.com/images/nyali-villa-1.jpg', 1, 'Beachfront view from balcony', true),
(3, 'https://example.com/images/nyali-villa-2.jpg', 2, 'Private beach access', false),
(3, 'https://example.com/images/nyali-villa-3.jpg', 3, 'Outdoor dining area', false),

(4, 'https://example.com/images/diani-apartment-1.jpg', 1, 'Apartment exterior and pool', true),
(4, 'https://example.com/images/diani-apartment-2.jpg', 2, 'Ocean view from living room', false),
(4, 'https://example.com/images/diani-apartment-3.jpg', 3, 'Modern bathroom', false);

-- =============================================================================
-- 5. BOOKINGS - Sample reservations
-- =============================================================================

INSERT INTO bookings (
    property_id, guest_id, check_in_date, check_out_date, number_of_guests,
    total_price, booking_status, special_requests
) VALUES
-- Completed bookings (2024 dates)
(1, 5, '2024-03-15', '2024-03-18', 2, 13500.00, 'completed', 'Early check-in if possible, arriving from Mombasa'),
(3, 6, '2024-08-10', '2024-08-15', 4, 112000.00, 'completed', 'Family vacation for school holidays'),
(2, 7, '2024-12-20', '2024-12-26', 5, 52500.00, 'completed', 'Christmas family gathering'),

-- Confirmed bookings (2025 future dates)
(4, 8, '2025-03-01', '2025-03-07', 2, 31500.00, 'confirmed', 'Honeymoon trip after wedding'),
(5, 9, '2025-06-15', '2025-06-20', 3, 36000.00, 'confirmed', 'Bird watching at Lake Nakuru'),
(6, 10, '2025-07-10', '2025-07-12', 2, 9000.00, 'confirmed', 'Business trip for meetings'),

-- Pending bookings (2025)
(7, 5, '2025-08-01', '2025-08-03', 2, 10800.00, 'pending', 'Weekend getaway to Kisumu'),
(8, 6, '2025-10-15', '2025-10-22', 4, 56000.00, 'pending', 'School holiday farm experience'),

-- Cancelled booking
(1, 7, '2024-11-10', '2024-11-12', 2, 9000.00, 'cancelled', 'Plans changed due to work');

-- =============================================================================
-- 6. PAYMENTS - Sample payment transactions
-- =============================================================================

INSERT INTO payments (
    booking_id, amount, payment_method, payment_status, transaction_id, payment_date
) VALUES
-- Completed payments
(1, 13500.00, 'mpesa', 'completed', 'MPE_001_20240310', '2024-03-10 14:30:00'),
(2, 112000.00, 'bank_transfer', 'completed', 'BT_002_20240801', '2024-08-01 09:15:00'),
(3, 52500.00, 'credit_card', 'completed', 'CC_003_20241215', '2024-12-15 16:45:00'),

-- Pending payments
(4, 31500.00, 'mpesa', 'pending', 'MPE_004_20250220', NULL),
(5, 36000.00, 'credit_card', 'pending', 'CC_005_20250601', NULL),

-- Refunded payment (for cancelled booking)
(8, 9000.00, 'mpesa', 'refunded', 'MPE_006_20241105', '2024-11-08 11:20:00'),

-- Failed payment
(6, 9000.00, 'mpesa', 'failed', 'MPE_007_20250515', '2025-05-15 13:10:00');

-- =============================================================================
-- 7. REVIEWS - Sample reviews for completed bookings
-- =============================================================================

INSERT INTO reviews (
    booking_id, reviewer_id, reviewee_type, rating, comment, host_response
) VALUES
-- Property reviews (guests reviewing properties)
(1, 5, 'property', 5, 'Amazing apartment in Westlands! Perfect location near restaurants and shops. The host was very responsive and helpful. Asante sana!', 'Karibu sana James! We''re delighted you enjoyed your stay in Nairobi. Hope to host you again soon.'),

(2, 6, 'property', 4, 'Beautiful beach house in Nyali! The private beach access was incredible and the views were stunning. The Wi-Fi was a bit slow but overall wonderful experience.', 'Thank you Linda! We appreciate your feedback and are working on improving the Wi-Fi. Hakuna matata!'),

(3, 7, 'property', 5, 'Perfect Karen home for our Christmas gathering! The garden was beautiful and the house had everything we needed. The security was excellent too.', 'We''re thrilled your family enjoyed Christmas with us, Peter! Karibu tena anytime.'),

-- Guest reviews (hosts reviewing guests)
(1, 1, 'guest', 5, 'James was a wonderful guest! Very respectful and left the apartment clean and tidy. Would happily host him again.', NULL),

(2, 2, 'guest', 5, 'Linda and her family were excellent guests. They took great care of the property and were very communicative. Asante!', NULL),

(3, 1, 'guest', 4, 'Peter was a great guest overall. Very clean and respectful. Minor issue with check-out time but otherwise perfect guest.', NULL);

-- =============================================================================
-- ADDITIONAL CONTEXT: Local amenities
-- =============================================================================

-- Add amenities
INSERT INTO amenities (amenity_name, amenity_category, description) VALUES
('M-Pesa enabled', 'basic', 'Convenient mobile money payments available'),
('Security guard', 'safety', '24/7 security personnel on site'),
('Backup generator', 'basic', 'Power backup for load shedding periods'),
('Swahili speaking host', 'basic', 'Host communicates in Swahili'),
('Safari tour arrangements', 'entertainment', 'Help with booking local safari tours')
ON CONFLICT (amenity_name) DO NOTHING;

-- Assign Kenya-specific amenities to some properties
INSERT INTO property_amenities (property_id, amenity_id)
SELECT property_id, (SELECT amenity_id FROM amenities WHERE amenity_name = 'M-Pesa enabled') 
FROM properties WHERE property_id IN (1, 2, 3, 4);

INSERT INTO property_amenities (property_id, amenity_id)
SELECT property_id, (SELECT amenity_id FROM amenities WHERE amenity_name = 'Security guard') 
FROM properties WHERE property_id IN (2, 3, 8);

INSERT INTO property_amenities (property_id, amenity_id)
SELECT property_id, (SELECT amenity_id FROM amenities WHERE amenity_name = 'Backup generator') 
FROM properties WHERE property_id IN (2, 3, 5);

-- =============================================================================
-- SAMPLE DATA VERIFICATION QUERIES
-- =============================================================================

-- Display sample data counts
SELECT 
    'Users' as table_name, COUNT(*) as record_count FROM users
UNION ALL
SELECT 'Properties', COUNT(*) FROM properties
UNION ALL
SELECT 'Bookings', COUNT(*) FROM bookings
UNION ALL
SELECT 'Payments', COUNT(*) FROM payments
UNION ALL
SELECT 'Reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'Property Images', COUNT(*) FROM property_images
UNION ALL
SELECT 'Property Amenities', COUNT(*) FROM property_amenities
ORDER BY table_name;

-- Display booking summary by status
SELECT 
    booking_status,
    COUNT(*) as booking_count,
    AVG(total_price) as avg_price,
    MIN(check_in_date) as earliest_booking,
    MAX(check_in_date) as latest_booking
FROM bookings 
GROUP BY booking_status 
ORDER BY booking_count DESC;

-- Display property summary by Kenyan city
SELECT 
    city,
    COUNT(*) as property_count,
    AVG(price_per_night) as avg_nightly_rate
FROM properties 
WHERE is_active = true
GROUP BY city 
ORDER BY property_count DESC;

-- Display payment methods used (Kenyan context)
SELECT 
    payment_method,
    COUNT(*) as transaction_count,
    SUM(amount) as total_amount
FROM payments 
GROUP BY payment_method 
ORDER BY transaction_count DESC;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Kenyan sample data inserted successfully! Database is now populated with realistic Kenya-focused data.';
    RAISE NOTICE 'Properties located in: Nairobi, Mombasa, Nakuru, Kisumu, Eldoret';
    RAISE NOTICE 'Dates for 2024-2025 timeline';
    RAISE NOTICE 'Local payment methods included: M-Pesa, Bank Transfer, Credit Card';
END $$;