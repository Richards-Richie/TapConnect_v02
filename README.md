# TapConnect_v02
**TapConnect v2** is an upgraded version of a mobile application designed to facilitate the seamless exchange of contact information between users through a simple QR code scanning mechanism. The app allows users to share and store their contact details (name, phone number, email, etc.) with minimal effort. Below is a detailed breakdown of the TapConnect v2 application:

### Key Features and Functionalities:

1. **User Profiles and QR Codes**:
   - Every user has a personal profile containing essential contact information such as their name, mobile number, and email address. 
   - The app generates a unique QR code for each user based on their profile data. This QR code acts as the "digital business card" of the user.
   - Other users can scan this QR code to access the profile information of the person it belongs to.

2. **Enhanced Contact Sharing**:
   - **Bidirectional Contact Sharing (New Feature in v2)**: The major upgrade in TapConnect v2 is the ability for automatic, two-way data sharing. When one user (User1) scans the QR code of another user (User2), both User1 and User2's contact information is exchanged automatically. In the previous version, both users had to scan each other’s QR codes for contact sharing. However, with this new feature, once User1 scans User2’s QR code, User1’s contact information is sent to User2 as well, without User2 needing to scan back.
   - This feature is connected via the internet, ensuring that both users receive the other’s details instantly and without manual intervention.

3. **App Components**:
   - **Frontend (Flutter)**: 
     - The app's interface is built using **Flutter**, a powerful UI toolkit for crafting visually appealing, cross-platform mobile applications.
     - The user interface (UI) allows users to easily navigate the app, view their contact information, generate their personal QR code, and scan other users’ QR codes. 
     - TapConnect v2's UI has been designed with simplicity and convenience in mind, ensuring that any user can scan and share details in a matter of seconds.
   - **Backend (Node.js)**:
     - The backend, built with **Node.js**, is responsible for handling the user requests, managing the database, and enabling the exchange of user data over the internet.
     - When a user scans a QR code, a POST request is sent to the Node.js server, which retrieves the necessary data and responds to the user’s device with the contact information of the other party.
   - **Database (MongoDB)**:
     - **MongoDB** is used as the database to store user information such as name, mobile number, and email. MongoDB provides flexibility and scalability for managing contact data.
     - Each user profile is stored as a document in MongoDB, making it easy to retrieve and update user information when needed.

4. **Data Exchange Process**:
   - When User1 scans User2’s QR code:
     1. User1 opens the scanning page on the app and scans User2's QR code.
     2. The app sends a **POST request** to the **Node.js backend**, along with User1’s details and the QR code data (User2’s unique identifier).
     3. The backend processes the request by looking up User2’s profile in the **MongoDB** database.
     4. User2’s details are then sent back to User1’s app.
     5. Simultaneously, User1’s details are also sent to User2 (via their identifier) without User2 needing to scan back. This creates an automatic **two-way sharing** experience.

5. **Internet Connectivity**:
   - The automatic two-way sharing feature in TapConnect v2 is made possible via internet connectivity. Both the user's device and the backend server are connected to the internet to facilitate real-time sharing of contact information between users.
   - Unlike in offline systems where QR codes only contain static data (and need mutual scanning for data sharing), the online architecture allows dynamic, automated sharing, making the process faster and more efficient.

6. **Security and Privacy**:
   - TapConnect v2 ensures that only the necessary contact details are shared between users. The data exchanged during QR code scanning is securely transferred to the Node.js server and back to the respective users.
   - Each user has full control over the information they share through their profile settings.

### Frontend (Flutter):
In **TapConnect v2**, the front end is implemented using **Flutter**. Some key elements include:
   - **Main Screen**: Users can access their profile information and QR code, along with the option to scan other QR codes.
   - **QR Code Scanner**: A built-in scanner that utilizes the device camera to scan other users’ QR codes.
   - **Multiple Pages**: Users can navigate between different pages of the app. For instance, there will be options to view their own contact information, scan a QR code, or view the shared contact list.

### Backend (Node.js):
   - The Node.js backend serves as the intermediary between the Flutter frontend and the MongoDB database. It handles user requests, processes QR code data, and retrieves or sends user details.
   - It includes endpoints for:
     - **POST requests** when a QR code is scanned, containing both users’ details.
     - **GET requests** to retrieve user profiles based on their unique QR code.

### Database (MongoDB):
   - MongoDB stores user profiles as documents. Each document contains fields such as:
     - User’s **name**
     - **Mobile number**
     - **Email**
     - A unique **QR code identifier**
   - The database allows for fast and flexible querying, enabling real-time contact data retrieval when QR codes are scanned.

### Overall User Experience:
The new version of TapConnect emphasizes simplicity and speed in sharing contact details. The automatic two-way sharing feature eliminates the need for both users to perform a manual scan, making the process more intuitive and seamless. By using an internet-connected backend, the app ensures that even if two users do not scan each other’s QR codes simultaneously, both can still receive the other’s contact information in real time.

---

**TapConnect v2** is thus an efficient solution for quickly exchanging contact information in networking events, business meetings, and social gatherings. The streamlined process of bidirectional contact sharing sets it apart from conventional methods, creating a fast and secure experience for users.
