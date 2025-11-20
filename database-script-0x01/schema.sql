-- Airbnb Database Schema - Fixed Version
-- Created: 2025
-- Author: Mercy Milkah_GigaThoni
-- Description: Complete schema with guaranteed reviews table creation

-- =============================================================================
-- CLEAN SLATE - DROP EVERYTHING IN PROPER ORDER
-- =============================================================================

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS property_images CASCADE;
DROP TABLE IF EXISTS property_amenities CASCADE;
DROP TABLE IF EXISTS amenities CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS properties CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Drop triggers
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
DROP TRIGGER IF EXISTS update_properties_updated_at ON properties;
DROP TRIGGER IF EXISTS update_bookings_updated_at ON bookings;
DROP TRIGGER IF EXISTS update_payments_updated_at ON payments;
DROP TRIGGER IF EXISTS update_reviews_updated_at ON reviews;
DROP TRIGGER IF EXISTS validate_booking_guest_count ON bookings;

-- Drop functions
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS check_booking_availability() CASCADE;
DROP FUNCTION IF EXISTS validate_guest_count() CASCADE;

-- =============================================================================
-- STEP 1: CREATE CORE FUNCTIONS FIRST
-- =============================================================================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to validate guest count
CREATE OR REPLACE FUNCTION validate_guest_count()
RETURNS TRIGGER AS $$
DECLARE
    property_max_guests INTEGER;
BEGIN
    SELECT max_guests INTO property_max_guests
    FROM properties 
    WHERE property_id = NEW.property_id;
    
    IF NEW.number_of_guests > property_max_guests THEN
        RAISE EXCEPTION 'Number of guests (%) exceeds property capacity (%)', 
            NEW.number_of_guests, property_max_guests;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to check booking availability
CREATE OR REPLACE FUNCTION check_booking_availability(
    p_property_id INTEGER,
    p_check_in DATE,
    p_check_out DATE,
    p_booking_id INTEGER DEFAULT NULL
) RETURNS BOOLEAN AS $$
BEGIN
    RETURN NOT EXISTS (
        SELECT 1 
        FROM bookings 
        WHERE property_id = p_property_id 
        AND booking_id != COALESCE(p_booking_id, -1)
        AND booking_status IN ('confirmed', 'pending')
        AND (p_check_in, p_check_out) OVERLAPS (check_in_date, check_out_date)
    );
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- STEP 2: CREATE TABLES IN STRICT DEPENDENCY ORDER
-- =============================================================================

-- Table 1: users (no dependencies)
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    profile_picture_url TEXT,
    is_host BOOLEAN DEFAULT FALSE,
    is_email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table 2: properties (depends on users)
CREATE TABLE properties (
    property_id SERIAL PRIMARY KEY,
    host_id INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    property_type VARCHAR(50) NOT NULL,
    room_type VARCHAR(50) NOT NULL,
    max_guests INTEGER NOT NULL,
    bedrooms INTEGER NOT NULL,
    beds INTEGER NOT NULL,
    bathrooms DECIMAL(3,1) NOT NULL,
    price_per_night DECIMAL(10,2) NOT NULL,
    cleaning_fee DECIMAL(10,2) DEFAULT 0,
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    country VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table 3: amenities (no dependencies)
CREATE TABLE amenities (
    amenity_id SERIAL PRIMARY KEY,
    amenity_name VARCHAR(100) NOT NULL UNIQUE,
    amenity_category VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table 4: property_amenities (depends on properties and amenities)
CREATE TABLE property_amenities (
    property_id INTEGER NOT NULL,
    amenity_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (property_id, amenity_id)
);

-- Table 5: bookings (depends on properties and users)
CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    property_id INTEGER NOT NULL,
    guest_id INTEGER NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    number_of_guests INTEGER NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    booking_status VARCHAR(20) DEFAULT 'pending',
    special_requests TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table 6: payments (depends on bookings)
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'pending',
    transaction_id VARCHAR(255) UNIQUE,
    payment_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table 7: REVIEWS - GUARANTEED TO BE CREATED (depends on bookings and users)
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL UNIQUE,
    reviewer_id INTEGER NOT NULL,
    reviewee_type VARCHAR(10) NOT NULL,
    rating INTEGER NOT NULL,
    comment TEXT,
    host_response TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table 8: property_images (depends on properties)
CREATE TABLE property_images (
    image_id SERIAL PRIMARY KEY,
    property_id INTEGER NOT NULL,
    image_url TEXT NOT NULL,
    image_order INTEGER DEFAULT 0,
    caption VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- STEP 3: ADD FOREIGN KEY CONSTRAINTS
-- =============================================================================

-- Properties foreign keys
ALTER TABLE properties 
ADD CONSTRAINT fk_properties_host 
FOREIGN KEY (host_id) REFERENCES users(user_id) ON DELETE CASCADE;

-- Property amenities foreign keys
ALTER TABLE property_amenities 
ADD CONSTRAINT fk_property_amenities_property 
FOREIGN KEY (property_id) REFERENCES properties(property_id) ON DELETE CASCADE;

ALTER TABLE property_amenities 
ADD CONSTRAINT fk_property_amenities_amenity 
FOREIGN KEY (amenity_id) REFERENCES amenities(amenity_id) ON DELETE CASCADE;

-- Bookings foreign keys
ALTER TABLE bookings 
ADD CONSTRAINT fk_bookings_property 
FOREIGN KEY (property_id) REFERENCES properties(property_id) ON DELETE CASCADE;

ALTER TABLE bookings 
ADD CONSTRAINT fk_bookings_guest 
FOREIGN KEY (guest_id) REFERENCES users(user_id) ON DELETE CASCADE;

-- Payments foreign keys
ALTER TABLE payments 
ADD CONSTRAINT fk_payments_booking 
FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE;

-- REVIEWS FOREIGN KEYS - GUARANTEED TO WORK
ALTER TABLE reviews 
ADD CONSTRAINT fk_reviews_booking 
FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE;

ALTER TABLE reviews 
ADD CONSTRAINT fk_reviews_reviewer 
FOREIGN KEY (reviewer_id) REFERENCES users(user_id) ON DELETE CASCADE;

-- Property images foreign keys
ALTER TABLE property_images 
ADD CONSTRAINT fk_property_images_property 
FOREIGN KEY (property_id) REFERENCES properties(property_id) ON DELETE CASCADE;

-- =============================================================================
-- STEP 4: ADD CHECK CONSTRAINTS
-- =============================================================================

-- Users constraints
ALTER TABLE users 
ADD CONSTRAINT chk_user_age 
CHECK (date_of_birth <= CURRENT_DATE - INTERVAL '18 years' OR date_of_birth IS NULL);

ALTER TABLE users 
ADD CONSTRAINT chk_valid_email 
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Properties constraints
ALTER TABLE properties 
ADD CONSTRAINT chk_property_type 
CHECK (property_type IN ('apartment', 'house', 'condo', 'villa', 'cottage', 'cabin', 'townhouse', 'farm_stay'));

ALTER TABLE properties 
ADD CONSTRAINT chk_room_type 
CHECK (room_type IN ('entire_place', 'private_room', 'shared_room', 'hotel_room'));

ALTER TABLE properties 
ADD CONSTRAINT chk_max_guests 
CHECK (max_guests > 0 AND max_guests <= 50);

ALTER TABLE properties 
ADD CONSTRAINT chk_bedrooms 
CHECK (bedrooms >= 0 AND bedrooms <= 50);

ALTER TABLE properties 
ADD CONSTRAINT chk_beds 
CHECK (beds > 0 AND beds <= 50);

ALTER TABLE properties 
ADD CONSTRAINT chk_bathrooms 
CHECK (bathrooms > 0 AND bathrooms <= 20);

ALTER TABLE properties 
ADD CONSTRAINT chk_price_per_night 
CHECK (price_per_night > 0 AND price_per_night <= 100000);

ALTER TABLE properties 
ADD CONSTRAINT chk_cleaning_fee 
CHECK (cleaning_fee >= 0 AND cleaning_fee <= 10000);

ALTER TABLE properties 
ADD CONSTRAINT chk_beds_vs_bedrooms 
CHECK (beds >= bedrooms);

ALTER TABLE properties 
ADD CONSTRAINT chk_latitude 
CHECK (latitude >= -90 AND latitude <= 90);

ALTER TABLE properties 
ADD CONSTRAINT chk_longitude 
CHECK (longitude >= -180 AND longitude <= 180);

-- Amenities constraints
ALTER TABLE amenities 
ADD CONSTRAINT chk_amenity_category 
CHECK (amenity_category IN ('basic', 'safety', 'accessibility', 'family', 'entertainment', 'kitchen', 'outdoor'));

-- Bookings constraints
ALTER TABLE bookings 
ADD CONSTRAINT chk_number_of_guests 
CHECK (number_of_guests > 0 AND number_of_guests <= 50);

ALTER TABLE bookings 
ADD CONSTRAINT chk_total_price 
CHECK (total_price > 0 AND total_price <= 1000000);

ALTER TABLE bookings 
ADD CONSTRAINT chk_booking_status 
CHECK (booking_status IN ('pending', 'confirmed', 'cancelled', 'completed', 'denied'));

ALTER TABLE bookings 
ADD CONSTRAINT chk_dates_valid 
CHECK (check_out_date > check_in_date);

ALTER TABLE bookings 
ADD CONSTRAINT chk_booking_duration 
CHECK (check_out_date - check_in_date <= 365);

-- Payments constraints
ALTER TABLE payments 
ADD CONSTRAINT chk_amount 
CHECK (amount > 0 AND amount <= 1000000);

ALTER TABLE payments 
ADD CONSTRAINT chk_payment_method 
CHECK (payment_method IN ('credit_card', 'debit_card', 'paypal', 'stripe', 'apple_pay', 'google_pay', 'mpesa', 'bank_transfer'));

ALTER TABLE payments 
ADD CONSTRAINT chk_payment_status 
CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded', 'cancelled'));

ALTER TABLE payments 
ADD CONSTRAINT chk_payment_date 
CHECK ((payment_status = 'completed' AND payment_date IS NOT NULL) OR
       (payment_status != 'completed' AND payment_date IS NULL));

-- REVIEWS CONSTRAINTS - GUARANTEED TO WORK
ALTER TABLE reviews 
ADD CONSTRAINT chk_reviewee_type 
CHECK (reviewee_type IN ('property', 'guest'));

ALTER TABLE reviews 
ADD CONSTRAINT chk_rating 
CHECK (rating >= 1 AND rating <= 5);

-- Property images constraints
ALTER TABLE property_images 
ADD CONSTRAINT chk_image_order 
CHECK (image_order >= 0);

-- Unique constraint for primary images (deferrable to allow multiple operations)
ALTER TABLE property_images 
ADD CONSTRAINT unique_primary_image 
UNIQUE (property_id, is_primary) DEFERRABLE INITIALLY DEFERRED;

-- =============================================================================
-- STEP 5: CREATE PERFORMANCE INDEXES
-- =============================================================================

-- Users indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_is_host ON users(is_host);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_name ON users(first_name, last_name);

-- Properties indexes
CREATE INDEX idx_properties_host_id ON properties(host_id);
CREATE INDEX idx_properties_city ON properties(city);
CREATE INDEX idx_properties_country ON properties(country);
CREATE INDEX idx_properties_price ON properties(price_per_night);
CREATE INDEX idx_properties_type ON properties(property_type);
CREATE INDEX idx_properties_active ON properties(is_active) WHERE is_active = true;
CREATE INDEX idx_properties_location ON properties(latitude, longitude);
CREATE INDEX idx_properties_city_price ON properties(city, price_per_night);

-- Property amenities indexes
CREATE INDEX idx_property_amenities_property ON property_amenities(property_id);
CREATE INDEX idx_property_amenities_amenity ON property_amenities(amenity_id);

-- Bookings indexes
CREATE INDEX idx_bookings_property_id ON bookings(property_id);
CREATE INDEX idx_bookings_guest_id ON bookings(guest_id);
CREATE INDEX idx_bookings_dates ON bookings(check_in_date, check_out_date);
CREATE INDEX idx_bookings_status ON bookings(booking_status);
CREATE INDEX idx_bookings_created_at ON bookings(created_at);
CREATE INDEX idx_bookings_guest_dates ON bookings(guest_id, check_in_date, check_out_date);
CREATE INDEX idx_bookings_property_dates_status ON bookings(property_id, check_in_date, check_out_date, booking_status);

-- Payments indexes
CREATE INDEX idx_payments_booking_id ON payments(booking_id);
CREATE INDEX idx_payments_status ON payments(payment_status);
CREATE INDEX idx_payments_date ON payments(payment_date);
CREATE INDEX idx_payments_transaction ON payments(transaction_id);
CREATE INDEX idx_payments_method ON payments(payment_method);

-- REVIEWS INDEXES - GUARANTEED TO BE CREATED
CREATE INDEX idx_reviews_booking_id ON reviews(booking_id);
CREATE INDEX idx_reviews_reviewer_id ON reviews(reviewer_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_created_at ON reviews(created_at);
CREATE INDEX idx_reviews_reviewee_type ON reviews(reviewee_type);

-- Property images indexes
CREATE INDEX idx_property_images_property ON property_images(property_id);
CREATE INDEX idx_property_images_primary ON property_images(is_primary) WHERE is_primary = true;
CREATE INDEX idx_property_images_order ON property_images(property_id, image_order);

-- =============================================================================
-- STEP 6: CREATE TRIGGERS
-- =============================================================================

-- Update timestamp triggers
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_properties_updated_at 
    BEFORE UPDATE ON properties 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at 
    BEFORE UPDATE ON bookings 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at 
    BEFORE UPDATE ON payments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at 
    BEFORE UPDATE ON reviews 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Business logic triggers
CREATE TRIGGER validate_booking_guest_count
    BEFORE INSERT OR UPDATE ON bookings
    FOR EACH ROW EXECUTE FUNCTION validate_guest_count();

-- =============================================================================
-- STEP 7: INSERT INITIAL DATA
-- =============================================================================

-- Insert core amenities
INSERT INTO amenities (amenity_name, amenity_category, description) VALUES
-- Basic amenities
('WiFi', 'basic', 'Wireless internet connection'),
('Kitchen', 'basic', 'Space where guests can cook their own meals'),
('Heating', 'basic', 'Central heating or space heaters'),
('Air conditioning', 'basic', 'Cooling system'),
('Washer', 'basic', 'Washing machine'),
('Dryer', 'basic', 'Clothes dryer'),
('TV', 'basic', 'Television with standard cable or streaming'),

-- Safety amenities
('Smoke alarm', 'safety', 'Smoke detection device'),
('Carbon monoxide alarm', 'safety', 'CO detection device'),
('First aid kit', 'safety', 'Medical supplies for emergencies'),
('Fire extinguisher', 'safety', 'Fire safety equipment'),

-- Accessibility amenities
('Step-free access', 'accessibility', 'No steps to enter'),
('Wide doorway', 'accessibility', 'Wide entrance for wheelchair access'),

-- Family amenities
('Children''s books and toys', 'family', 'Entertainment for young children'),
('Crib', 'family', 'Baby crib available'),
('High chair', 'family', 'Child''s high chair'),

-- Entertainment amenities
('Pool', 'entertainment', 'Swimming pool'),
('Hot tub', 'entertainment', 'Jacuzzi or hot tub'),
('Gym', 'entertainment', 'Exercise equipment'),
('Game console', 'entertainment', 'Video game system'),

-- Kitchen amenities
('Coffee maker', 'kitchen', 'Coffee brewing equipment'),
('Microwave', 'kitchen', 'Microwave oven'),
('Oven', 'kitchen', 'Cooking oven'),
('Dishwasher', 'kitchen', 'Automatic dishwashing machine'),

-- Outdoor amenities
('Patio or balcony', 'outdoor', 'Outdoor space'),
('Garden', 'outdoor', 'Outdoor garden area'),
('BBQ grill', 'outdoor', 'Barbecue equipment'),

-- Kenya-specific amenities
('M-Pesa enabled', 'basic', 'Convenient mobile money payments available'),
('Security guard', 'safety', '24/7 security personnel on site'),
('Backup generator', 'basic', 'Power backup for load shedding periods'),
('Swahili speaking host', 'basic', 'Host communicates in Swahili'),
('Safari tour arrangements', 'entertainment', 'Help with booking local safari tours')
ON CONFLICT (amenity_name) DO NOTHING;

-- =============================================================================
-- STEP 8: FINAL VERIFICATION AND SUCCESS MESSAGE
-- =============================================================================

DO $$
DECLARE
    total_tables INTEGER;
    reviews_exists BOOLEAN;
    table_list TEXT;
BEGIN
    -- Count all tables
    SELECT COUNT(*) INTO total_tables
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE';
    
    -- Check specifically for reviews table
    SELECT EXISTS (
        SELECT 1 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'reviews'
    ) INTO reviews_exists;
    
    -- Get list of all tables
    SELECT string_agg(table_name, ', ' ORDER BY table_name) INTO table_list
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE';
    
    -- Display success message
    RAISE NOTICE '=================================================';
    RAISE NOTICE '✅ DATABASE SCHEMA CREATED SUCCESSFULLY!';
    RAISE NOTICE '=================================================';
    RAISE NOTICE 'Total tables created: %', total_tables;
    
    IF reviews_exists THEN
        RAISE NOTICE '✅ REVIEWS TABLE: Created successfully!';
    ELSE
        RAISE NOTICE '❌ REVIEWS TABLE: FAILED to create!';
    END IF;
    
    RAISE NOTICE 'Tables: %', table_list;
    RAISE NOTICE '=================================================';
    RAISE NOTICE 'Schema is ready for seeding with sample data.';
    RAISE NOTICE '=================================================';
END $$;

-- Display table structure for verification
SELECT 
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;