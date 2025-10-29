📊 Normalization Process for Airbnb Database
1. Initial Assessment
Original Denormalized Structure
Before normalization, we might have had a single table with all information:

-- Denormalized table (example of what we're avoiding)
CREATE TABLE property_bookings (
    booking_id INTEGER,
    guest_name VARCHAR(100),
    guest_email VARCHAR(255),
    property_title VARCHAR(200),
    host_name VARCHAR(100),
    host_email VARCHAR(255),
    check_in DATE,
    check_out DATE,
    price_per_night DECIMAL(10,2),
    total_price DECIMAL(10,2),
    amenities TEXT, -- Comma-separated list
    address_full TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    -- ... many more fields
);
2. First Normal Form (1NF) Compliance
✅ 1NF Requirements Met:
a) Primary Keys:

Each table has a proper primary key

user_id, property_id, booking_id, etc. are all SERIAL primary keys

b) Atomic Values:

All columns contain atomic, indivisible values

No arrays or comma-separated lists

Example: Instead of storing amenities as "wifi,pool,parking", we use a separate amenities table

c) No Repeating Groups:

Multiple amenities handled through property_amenities junction table

Multiple images handled through property_images table

1NF Violations Fixed:
Before: amenities column with comma-separated values

After: Separate amenities and property_amenities tables

3. Second Normal Form (2NF) Compliance
✅ 2NF Requirements Met:
a) All Non-Key Columns Depend on Entire Primary Key:

Users Table:

-- All columns depend entirely on user_id
user_id → {email, first_name, last_name, phone_number, ...}
Properties Table:

sql
-- All columns depend entirely on property_id
property_id → {host_id, title, description, property_type, ...}
Bookings Table:

sql
-- All columns depend on booking_id (primary key)
booking_id → {property_id, guest_id, check_in_date, check_out_date, ...}
b) No Partial Dependencies:

All composite primary keys have full dependency

Example: property_amenities(property_id, amenity_id) - both parts are needed

2NF Violations Fixed:
Before: If we had a table with (booking_id, property_id, property_city) - property_city depends only on property_id, not the full key

After: Property location information properly in properties table

4. Third Normal Form (3NF) Compliance
✅ 3NF Requirements Met:
a) No Transitive Dependencies:

Users Table Analysis:

sql
user_id → email → {first_name, last_name, phone_number} ❌ (Would be violation)
user_id → {email, first_name, last_name, phone_number} ✅ (Correct)
All user attributes depend directly on user_id, not through other attributes

Properties Table Analysis:

sql
property_id → host_id → {host_email, host_name} ❌ (Would be violation)
property_id → host_id ✅ (Correct - host details in users table)
host_id → {email, first_name, last_name} ✅ (In users table)
b) Transitive Dependencies Eliminated:

Example of Transitive Dependency That Was Avoided:

sql
-- Bad design (transitive dependency):
properties(property_id, host_id, host_email, host_phone, ...)
-- host_email and host_phone depend on host_id, not directly on property_id

-- Good design (3NF compliant):
properties(property_id, host_id, ...)  -- host_id references users
users(user_id, email, phone_number, ...)
5. Specific Normalization Decisions
Decision 1: Separate Amenities Tables
Reasoning:

Avoid repeating groups of amenities in properties table

Enable efficient querying and filtering by amenities

Support many-to-many relationships

sql
-- Before (1NF violation):
properties(property_id, amenities) -- amenities = 'wifi,pool,parking'

-- After (3NF compliant):
properties(property_id, ...)
amenities(amenity_id, amenity_name)
property_amenities(property_id, amenity_id) -- Junction table
Decision 2: Separate Reviews Table
Reasoning:

Avoid storing review data in bookings table

Support multiple review types (property and guest reviews)

Maintain review history independently

sql
-- Proper design:
reviews(review_id, booking_id, reviewer_id, reviewee_type, rating, comment)
Decision 3: Location Data in Properties
Reasoning:

City, country, coordinates depend entirely on property_id

No transitive dependencies through other attributes

6. Normalization Verification
Table-by-Table 3NF Analysis:
1. Users Table:

sql
users(user_id, email, first_name, last_name, phone_number, ...)
✅ Primary key: user_id

✅ All attributes depend entirely on user_id

✅ No transitive dependencies

2. Properties Table:

properties(property_id, host_id, title, description, property_type, ...)
✅ Primary key: property_id

✅ All attributes depend entirely on property_id

✅ host_id is foreign key, host details in users table

3. Bookings Table:

bookings(booking_id, property_id, guest_id, check_in_date, check_out_date, ...)
✅ Primary key: booking_id

✅ All attributes depend entirely on booking_id

✅ property_id and guest_id are foreign keys

4. Property_Amenities Table:

property_amenities(property_id, amenity_id, created_at)
✅ Composite primary key: (property_id, amenity_id)

✅ created_at depends on both parts of the key

✅ No partial dependencies

7. Benefits of 3NF Design
Data Integrity:
No Update Anomalies: Changing host email updates one record in users table

No Insertion Anomalies: Can add amenities without creating a property

No Deletion Anomalies: Deleting a property doesn't delete amenity definitions

Storage Efficiency:
Reduced Redundancy: Host information stored once in users table

Optimized Storage: No duplicate address or user information

Query Performance:
Efficient Joins: Proper indexing on foreign keys

Optimized Searches: Separate tables for searchable attributes (amenities, locations)

8. Trade-offs and Considerations
Potential Denormalization for Performance:
In some cases, we might consider controlled denormalization:

-- Example: Adding computed columns for frequently accessed data
ALTER TABLE properties ADD COLUMN average_rating DECIMAL(3,2);
However, we maintain 3NF for the core schema and handle computed values through:

Database views

Application-level caching

Materialized views if needed

9. Final 3NF Compliance Statement
✅ All tables in the database schema comply with Third Normal Form (3NF):

1NF Compliance: All tables have primary keys, atomic values, no repeating groups

2NF Compliance: All non-key attributes fully functionally dependent on primary keys

3NF Compliance: No transitive dependencies - all non-key attributes depend only on primary keys

The database design minimizes redundancy while maintaining data integrity and supporting efficient query operations for the Airbnb-like application requirements.

