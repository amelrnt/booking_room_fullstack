# booking_room_fullstack

# 🛠️ Project Setup Guide (Flutter + Odoo)

## **Frontend (Flutter) Setup** 📱

1. **Install Dependencies**  
   Grab all the required packages:
   ```bash
   flutter pub get

2. **Configure Environment Variable**

Copy .env.example to .env in your Flutter project root.

Update variables (e.g., API_URL, Odoo credentials, tunneling URL).

3. **Run the App** 🎉
Start the Flutter development server:

    ```bash
    flutter run

## **Backend (Odoo) Setup** ⚙️

1. **Set Up Database**

Open your Odoo configuration file (odoo.conf).

2. **Start Odoo Server**
Run Odoo with:

    ```bash
    ./odoo-bin --config=odoo.conf


3. Use tunneling (e.g., ngrok) to make the backend accessible
      ```bash
      ngrok http 8069  # Odoo’s default port is 8069
Keep the tunnel active for API testing 🌍.

4. Backend ready! Your Odoo instance is live. 🔥

    ```bash
    http://localhost:8069.

Install the booking_apps module via Odoo Apps interface

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
