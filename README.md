# Database Course — Session 04 Assignment

T-SQL (SQL Server) solution for the Online Retail and Hotel systems.

| Part | Scripts | What they do |
|------|---------|--------------|
| Part 01 | [`Part_01/OnlineRetailStore.sql`](Part_01/OnlineRetailStore.sql), [`Part_01/HotelReservation.sql`](Part_01/HotelReservation.sql) | Build each database from the provided relational schema and add a few sample rows |
| Part 02 | [`Part_02/OnlineRetailStore.sql`](Part_02/OnlineRetailStore.sql), [`Part_02/HotelReservation.sql`](Part_02/HotelReservation.sql) | Insert and update operations for both systems |

Run each Part 01 script before its Part 02 script.

`Products.CategoryId` allows NULL so that a product can be inserted with only its
`Name` and `UnitPrice`, as Part 02 asks.
