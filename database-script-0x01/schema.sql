-- Airbnb Database Schema
-- Created: October 2025
-- Author: Mercy Milkah _GigaThoni

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For text search optimization

-- Drop tables if they exist (in correct order due to foreign keys)
DROP TABLE IF EXISTS property_images CASCADE;
DROP TABLE IF EXISTS property_amenities CASCADE;
DROP TABLE IF EXISTS amenities CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS properties CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Drop triggers and functions
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
DROP TRIGGER IF EXISTS update_properties_updated_at ON properties;
DROP TRIGGER IF EXISTS update_bookings_updated_at ON bookings;
DROP TRIGGER IF EXISTS update_payments_updated_at ON payments;
DROP TRIGGER IF EXISTS update_reviews_updated_at ON reviews;
DROP FUNCTION IF EXISTS update_updated_at_column();
DROP FUNCTION IF EXISTS check_booking_availability();

-- =============================================================================
-- TABLE: users
-- Purpose: Stores user information for both hosts and guests
-- =============================================================================
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
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_user_age CHECK (
        date_of_birth <= CURRENT_DATE - INTERVAL '18 years' OR date_of_birth IS NULL
    ),
    CONSTRAINT chk_valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- =============================================================================
-- TABLE: properties
-- Purpose: Stores property listings with details and pricing
-- =============================================================================
CREATE TABLE properties (
    property_id SERIAL PRIMARY KEY,
    host_id INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    property_type VARCHAR(50) NOT NULL CHECK (
        property_type IN ('apartment', 'house', 'condo', 'villa', 'cottage', 'cabin', 'townhouse')
    ),
    room_type VARCHAR(50) NOT NULL CHECK (
        room_type IN ('entire_place', 'private_room', 'shared_room', 'hotel_room')
    ),
    max_guests INTEGER NOT NULL CHECK (max_guests > 0 AND max_guests <= 50),
    bedrooms INTEGER NOT NULL CHECK (bedrooms >= 0 AND bedrooms <= 50),
    beds INTEGER NOT NULL CHECK (beds > 0 AND beds <= 50),
    bathrooms DECIMAL(3,1) NOT NULL CHECK (bathrooms > 0 AND bathrooms <= 20),
    price_per_night DECIMAL(10,2) NOT NULL CHECK (price_per_night > 0 AND price_per_night <= 10000),
    cleaning_fee DECIMAL(10,2) DEFAULT 0 CHECK (cleaning_fee >= 0 AND cleaning_fee <= 1000),
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    country VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    latitude DECIMAL(10,8) CHECK (latitude >= -90 AND latitude <= 90),
    longitude DECIMAL(11,8) CHECK (longitude >= -180 AND longitude <= 180),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraint
    CONSTRAINT fk_properties_host 
        FOREIGN KEY (host_id) 
        REFERENCES users(user_id)
        ON DELETE CASCADE,
    
    -- Business logic constraints
    CONSTRAINT chk_beds_vs_bedrooms CHECK (beds >= bedrooms)
);

-- =============================================================================
-- TABLE: amenities
-- Purpose: Lookup table for available amenities
-- =============================================================================
CREATE TABLE amenities (
    amenity_id SERIAL PRIMARY KEY,
    amenity_name VARCHAR(100) NOT NULL UNIQUE,
    amenity_category VARCHAR(50) NOT NULL CHECK (
        amenity_category IN ('basic', 'safety', 'accessibility', 'family', 'entertainment', 'kitchen', 'outdoor')
    ),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- TABLE: property_amenities
-- Purpose: Junction table for property amenities (many-to-many relationship)
-- =============================================================================
CREATE TABLE property_amenities (
    property_id INTEGER NOT NULL,
    amenity_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Composite primary key
    PRIMARY KEY (property_id, amenity_id),
    
    -- Foreign key constraints
    CONSTRAINT fk_property_amenities_property 
        FOREIGN KEY (property_id) 
        REFERENCES properties(property_id)
        ON DELETE CASCADE,
        
    CONSTRAINT fk_property_amenities_amenity 
        FOREIGN KEY (amenity_id) 
        REFERENCES amenities(amenity_id)
        ON DELETE CASCADE
);

-- =============================================================================
-- TABLE: bookings
-- Purpose: Manages property reservations and booking status
-- =============================================================================
CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    property_id INTEGER NOT NULL,
    guest_id INTEGER NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    number_of_guests INTEGER NOT NULL CHECK (number_of_guests > 0 AND number_of_guests <= 50),
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price > 0 AND total_price <= 100000),
    booking_status VARCHAR(20) DEFAULT 'pending' CHECK (
        booking_status IN ('pending', 'confirmed', 'cancelled', 'completed', 'denied')
    ),
    special_requests TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    CONSTRAINT fk_bookings_property 
        FOREIGN KEY (property_id) 
        REFERENCES properties(property_id)
        ON DELETE CASCADE,
        
    CONSTRAINT fk_bookings_guest 
        FOREIGN KEY (guest_id) 
        REFERENCES users(user_id)
        ON DELETE CASCADE,
    
    -- Business logic constraints
    CONSTRAINT chk_dates_valid 
        CHECK (check_out_date > check_in_date),
    
    CONSTRAINT chk_future_check_in 
        CHECK (check_in_date >= CURRENT_DATE),
    
    CONSTRAINT chk_booking_duration 
        CHECK (check_out_date - check_in_date <= 365) -- Max 1 year stay
);

-- =============================================================================
-- TABLE: payments
-- Purpose: Tracks payment transactions for bookings
-- =============================================================================
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0 AND amount <= 100000),
    payment_method VARCHAR(50) NOT NULL CHECK (
        payment_method IN ('credit_card', 'debit_card', 'paypal', 'stripe', 'apple_pay', 'google_pay')
    ),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (
        payment_status IN ('pending', 'completed', 'failed', 'refunded', 'cancelled')
    ),
    transaction_id VARCHAR(255) UNIQUE,
    payment_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraint
    CONSTRAINT fk_payments_booking 
        FOREIGN KEY (booking_id) 
        REFERENCES bookings(booking_id)
        ON DELETE CASCADE,
    
    -- Business logic
    CONSTRAINT chk_payment_date CHECK (
        (payment_status = 'completed' AND payment_date IS NOT NULL) OR
        (payment_status != 'completed' AND payment_date IS NULL)
    )
);

-- =============================================================================
-- TABLE: reviews
-- Purpose: Stores user reviews for properties and guests
-- =============================================================================
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL UNIQUE, -- One review per booking
    reviewer_id INTEGER NOT NULL, -- User who wrote the review
    reviewee_type VARCHAR(10) NOT NULL CHECK (reviewee_type IN ('property', 'guest')),
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    host_response TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    CONSTRAINT fk_reviews_booking 
        FOREIGN KEY (booking_id) 
        REFERENCES bookings(booking_id)
        ON DELETE CASCADE,
        
    CONSTRAINT fk_reviews_reviewer 
        FOREIGN KEY (reviewer_id) 
        REFERENCES users(user_id)
        ON DELETE CASCADE,
    
    -- Business logic
    CONSTRAINT chk_review_timing CHECK (
        created_at >= (SELECT check_in_date FROM bookings WHERE booking_id = reviews.booking_id)
    )
);

-- =============================================================================
-- TABLE: property_images
-- Purpose: Stores images for properties
-- =============================================================================
CREATE TABLE property_images (
    image_id SERIAL PRIMARY KEY,
    property_id INTEGER NOT NULL,
    image_url TEXT NOT NULL,
    image_order INTEGER DEFAULT 0 CHECK (image_order >= 0),
    caption VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraint
    CONSTRAINT fk_property_images_property 
        FOREIGN KEY (property_id) 
        REFERENCES properties(property_id)
        ON DELETE CASCADE,
    
    -- Ensure only one primary image per property
    UNIQUE (property_id, is_primary) DEFERRABLE INITIALLY DEFERRED
);

-- =============================================================================
-- INDEXES for Performance Optimization
-- =============================================================================

-- Users table indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_is_host ON users(is_host);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_name ON users(first_name, last_name);
CREATE INDEX idx_users_email_verified ON users(is_email_verified) WHERE is_email_verified = true;

-- Properties table indexes
CREATE INDEX idx_properties_host_id ON properties(host_id);
CREATE INDEX idx_properties_city ON properties(city);
CREATE INDEX idx_properties_country ON properties(country);
CREATE INDEX idx_properties_price ON properties(price_per_night);
CREATE INDEX idx_properties_type ON properties(property_type);
CREATE INDEX idx_properties_active ON properties(is_active) WHERE is_active = true;
CREATE INDEX idx_properties_location ON properties(latitude, longitude);
CREATE INDEX idx_properties_city_price ON properties(city, price_per_night);
CREATE INDEX idx_properties_created_at ON properties(created_at);

-- Property amenities indexes
CREATE INDEX idx_property_amenities_property ON property_amenities(property_id);
CREATE INDEX idx_property_amenities_amenity ON property_amenities(amenity_id);

-- Bookings table indexes
CREATE INDEX idx_bookings_property_id ON bookings(property_id);
CREATE INDEX idx_bookings_guest_id ON bookings(guest_id);
CREATE INDEX idx_bookings_dates ON bookings(check_in_date, check_out_date);
CREATE INDEX idx_bookings_status ON bookings(booking_status);
CREATE INDEX idx_bookings_created_at ON bookings(created_at);
CREATE INDEX idx_bookings_guest_dates ON bookings(guest_id, check_in_date, check_out_date);
CREATE INDEX idx_bookings_property_dates_status ON bookings(property_id, check_in_date, check_out_date, booking_status);

-- Payments table indexes
CREATE INDEX idx_payments_booking_id ON payments(booking_id);
CREATE INDEX idx_payments_status ON payments(payment_status);
CREATE INDEX idx_payments_date ON payments(payment_date);
CREATE INDEX idx_payments_transaction ON payments(transaction_id);
CREATE INDEX idx_payments_method ON payments(payment_method);

-- Reviews table indexes
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
-- FUNCTIONS and TRIGGERS
-- =============================================================================

-- Function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to check booking availability
CREATE OR REPLACE FUNCTION check_booking_availability(
    p_property_id INTEGER,
    p_check_in DATE,
    p_check_out DATE,
    p_booking_id INTEGER DEFAULT NULL -- exclude current booking when updating
) RETURNS BOOLEAN AS $$
BEGIN
    RETURN NOT EXISTS (
        SELECT 1 
        FROM bookings 
        WHERE property_id = p_property_id 
        AND booking_id != COALESCE(p_booking_id, -1) -- exclude current booking if provided
        AND booking_status IN ('confirmed', 'pending')
        AND (p_check_in, p_check_out) OVERLAPS (check_in_date, check_out_date)
    );
END;
$$ LANGUAGE plpgsql;

-- Function to validate guest count against property capacity
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

-- Triggers to automatically update updated_at
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

-- Trigger to validate guest count before insert/update on bookings
CREATE TRIGGER validate_booking_guest_count
    BEFORE INSERT OR UPDATE ON bookings
    FOR EACH ROW EXECUTE FUNCTION validate_guest_count();

-- =============================================================================
-- CONSTRAINTS that require functions
-- =============================================================================

-- Add constraint to ensure only one primary image per property
-- This is handled by the UNIQUE constraint on property_images that is DEFERRABLE

-- =============================================================================
-- COMMENTS for Documentation
-- =============================================================================

COMMENT ON TABLE users IS 'Stores user information for both hosts and guests in the Airbnb-like system';
COMMENT ON TABLE properties IS 'Contains property listings with detailed information, pricing, and location data';
COMMENT ON TABLE amenities IS 'Lookup table for all available amenities that properties can offer';
COMMENT ON TABLE property_amenities IS 'Junction table linking properties to their amenities (many-to-many relationship)';
COMMENT ON TABLE bookings IS 'Manages all property reservations including dates, guest counts, and booking status';
COMMENT ON TABLE payments IS 'Tracks all payment transactions associated with bookings';
COMMENT ON TABLE reviews IS 'Stores user reviews for both properties and guests after completed stays';
COMMENT ON TABLE property_images IS 'Manages property images with ordering and primary image designation';

COMMENT ON COLUMN users.is_host IS 'Flag indicating if user can host properties';
COMMENT ON COLUMN properties.is_active IS 'Flag indicating if property is available for booking';
COMMENT ON COLUMN bookings.booking_status IS 'Status: pending, confirmed, cancelled, completed, denied';
COMMENT ON COLUMN payments.payment_status IS 'Status: pending, completed, failed, refunded, cancelled';
COMMENT ON COLUMN reviews.reviewee_type IS 'Type of entity being reviewed: property or guest';

-- =============================================================================
-- Initial Data for Amenities (Common amenities for Airbnb-like platform)
-- =============================================================================

INSERT INTO amenities (amenity_name, amenity_category, description) VALUES
-- Basic amenities
('WiFi', 'basic', 'Wireless internet connection'),
('Kitchen', 'basic', 'Space where guests can cook their own meals'),
(' Heating', 'basic', 'Central heating or space heaters'),
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
('BBQ grill', 'outdoor', 'Barbecue equipment')
ON CONFLICT (amenity_name) DO NOTHING;

-- =============================================================================
-- Final Confirmation
-- =============================================================================

-- Display creation confirmation and table count
DO $$
DECLARE
    table_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO table_count
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE';
    
    RAISE NOTICE 'Database schema created successfully! Created % tables.', table_count;
END $$;

-- Verify tables were created
SELECT 
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;