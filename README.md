# booking_room_fullstack

# 🛠️ Project Setup Guide (Flutter + Odoo)

## **Frontend (Flutter) Setup** 📱

1. **Install Dependencies**  
   Grab all the required packages:
   ```bash
   flutter pub get 
   ```

2. **Configure Environment Variable**

Copy .env.example to .env in your Flutter project root.

Update variables (e.g., API_URL, Odoo credentials, tunneling URL).

    ```
    API_URL=your_odoo_backend_url
    API_KEY=your_odoo_api_key 
    # Add other Odoo credentials if needed
    ```

3. **Run the App** 🎉
Start the Flutter development server:

    ```bash
    flutter run 
    ```

## **Backend (Odoo) Setup** ⚙️

1. **Set Up Database**

Open your Odoo configuration file (odoo.conf).

      ```
      db_host = localhost
      db_port = 5432
      db_user = odoo
      db_password = your_db_password
      db_name = your_database_name 
      ```

2. **Start Odoo Server**
Run Odoo with:

    ```bash
    ./odoo-bin --config=odoo.conf 
    ```

3. **Install Booking Module**
Log in as admin
Go to Apps → Search "booking_apps" → Install

4. **Generate API Key** 🔑

Log in as target user (not just admin)
Go to User Profile (top-right)
Under "API Keys" section:
Click "Generate New API Key"
Enter your account password
Add description (e.g., "Postman Access")

IMPORTANT: Copy and save the key immediately - it won't be shown again!


5. Use tunneling (e.g., ngrok) to make the backend accessible
      ```bash
      ngrok http 8069  # Odoo’s default port is 8069 
      ```

Keep the tunnel active for API testing 🌍.

6. Backend ready! Your Odoo instance is live. 🔥

    
    > http://localhost:8069.


## **Postman Setup** 📬

1. **Import Collection**

Import postman collection (file that in .son format) into Postman.

2. **Configure Environment**

3. **Create/update a Postman environment**

4. **Test the Connection**

5. **Send a sample request to verify the URL works.**

All set! Start testing those endpoints. 🚨




Next development to improve: 
1. create login page in web, right now is just using 1 user(admin)
2. instead of hard code the language as label use translation
