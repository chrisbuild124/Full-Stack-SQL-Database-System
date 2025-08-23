# Board-Game Database

An efficient web-based system for managing inventory, rentals, and purchases in a board game business.

## Features

- Track customer accounts and activity
- Manage board game inventory in real time
- Support for rentals and purchases via dedicated pages
- Full CRUD operations (Create, Read, Update, Delete) on all major entities
- Admin tools for stock management and database reset

## 🛠️ How It Works

1. **Customer Registration**  
   Customers input their account information via the **Customer** page.

2. **Game Checkout or Purchase**  
   Customers can rent or buy games. These actions are tracked through the **Rentals** and **Orders** pages.

3. **Inventory Updates**  
   Every transaction updates the inventory automatically.

4. **Admin Controls**  
   Admins can monitor stock levels and reset the database to its original state via a dedicated button.

### 🏠 Home Screen  
After connecting to the server, users land on the home screen:

![Home Screen](https://github.com/user-attachments/assets/12276cdb-0d09-49cf-9557-dfaca352b3fc)

### Customer Page  
Customers input their personal information here:

![Customer Page](https://github.com/user-attachments/assets/34a25083-8790-44f5-bda0-81d3c716558f)

### Orders Page  
Customers place orders, and inventory updates accordingly:

![Orders Page](https://github.com/user-attachments/assets/fb920804-96db-4ccc-a8c5-068456b264c8)

### Inventory Management  
Admins track board games and stock levels:

![Inventory Page](https://github.com/user-attachments/assets/a49766be-eeaa-4af7-a8f2-1c67f5911c51)

## Reset Functionality

The **Reset** button connects to a SQL server and restores the database to its original inventory state.

---

Appendix

Database Schema
<img width="888" height="504" alt="image" src="https://github.com/user-attachments/assets/aba06554-5527-4bb7-afc0-4ad24269671b" />

