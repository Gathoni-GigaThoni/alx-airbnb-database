CORE ENTITIES
Users (hosts and guests)
Properties (listings)
Bookings (reservations)
Payments (transactions)
Reviews (user; guests feedback)

User
user_id (Primary Key)
name
email
phone

Property
property_id (Primary Key)
host_id (Foreign Key to User.user_id)
title
description
location
price_per_night

Booking
booking_id (Primary Key)
property_id (Foreign Key to Property.property_id)
guest_id (Foreign Key to User.user_id)
check_in_date
check_out_date
total_price
status

Payment
payment_id (Primary Key)
booking_id (Foreign Key to Booking.booking_id)
amount
payment_method
payment_date
status

Relationships
A User (host) can have many Properties (one-to-many).
A User (guest) can have many Bookings (one-to-many).
A Property can have many Bookings (one-to-many).
A Booking can have many Payments (one-to-many).
![erd_diagram](erd.drawio.png)
