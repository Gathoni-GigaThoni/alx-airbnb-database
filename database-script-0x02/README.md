# Database Seeding Scripts

## Overview
This directory contains SQL scripts for populating the Airbnb-like database with realistic Kenyan sample data. The data represents real-world scenarios in Kenya with local users, properties, bookings, payments, and reviews.

## Files

- `seed.sql` - Main seeding script with comprehensive Kenyan sample data
- `README.md` - This documentation file

## Kenyan Sample Data Included

### 1. Users
- **10 Kenyan users** (4 hosts, 6 guests)
- Authentic Kenyan names and phone numbers (+254 format)
- Realistic profiles with Kenyan context
- Mix of verified and unverified accounts

### 2. Properties
- **8 diverse Kenyan properties** across major cities:
  - Nairobi (Westlands, Karen)
  - Mombasa (Nyali, Diani Beach)
  - Nakuru (Lake Nakuru area)
  - Kisumu (Lake Victoria)
  - Eldoret (farm stay)
- Various property types (apartments, villa, cabin, cottage, farm stay)
- Realistic Kenyan pricing in KSh
- Authentic Kenyan addresses and coordinates

### 3. Amenities
- Properties linked to appropriate amenities
- Kenya-specific amenities added:
  - M-Pesa enabled
  - Security guard
  - Backup generator
  - Swahili speaking host
  - Safari tour arrangements

### 4. Bookings
- **8 bookings** with different statuses:
  - 3 completed bookings (2024 dates)
  - 3 confirmed bookings (2025 future dates)
  - 2 pending bookings
  - 1 cancelled booking
- Realistic Kenyan date patterns (school holidays, Christmas, etc.)
- Appropriate guest counts for Kenyan family sizes

### 5. Payments
- **7 payment transactions** with Kenyan payment methods:
  - M-Pesa (most common)
  - Bank transfer
  - Credit card
- Various payment statuses

### 6. Reviews
- **6 reviews** including:
  - Property reviews from guests
  - Guest reviews from hosts
  - Mixed ratings (4-5 stars)
  - Authentic Kenyan comments with Swahili phrases

## How to Use

### Prerequisites
- PostgreSQL database with the schema already created
- Database connection credentials

### Seeding the Database

1. **Ensure the schema exists** (run schema.sql first if not already done)

2. **Run the seeding script**:
   ```bash
   psql -d your_database_name -f seed.sql