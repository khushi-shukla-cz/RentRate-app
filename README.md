# 🏠 RentRate — Trust-Driven Rental Platform

A full-stack mobile application where tenants and landlords can rate and review each other, building verified trust scores for informed rental decisions.

---

## 📁 Project Structure

```
rentrate/
├── backend/          ← Node.js + Express + MongoDB API
│   ├── src/
│   │   ├── models/   ← Mongoose models (User, Property, Review, Message)
│   │   ├── routes/   ← REST API routes
│   │   ├── middleware/← JWT auth middleware
│   │   └── utils/    ← Seed script
│   ├── .env
│   └── package.json
│
└── frontend/         ← Flutter app
    ├── lib/
    │   ├── config/   ← App constants, theme, colors
    │   ├── models/   ← Dart data models
    │   ├── services/ ← API service classes
    │   ├── providers/← State management (Provider)
    │   ├── screens/  ← All UI screens
    │   └── widgets/  ← Reusable UI components
    └── pubspec.yaml
```

---

## 🚀 Quick Start

### Prerequisites
- Node.js v18+
- MongoDB (local or Atlas)
- Flutter SDK 3.x
- Android Studio / Xcode

---

### 1. Backend Setup

```bash
cd rentrate/backend
npm install
```

Edit `.env`:
```env
PORT=5000
MONGODB_URI=mongodb://localhost:27017/rentrate
JWT_SECRET=your_secret_key
JWT_EXPIRES_IN=7d
```

Start the server:
```bash
npm start
# or with auto-reload:
npm run dev
```

Seed demo data:
```bash
npm run seed
```

The API will be live at: `http://localhost:5000`

---

### 2. Flutter Setup

```bash
cd rentrate/frontend
flutter pub get
```

**Update the API base URL** in `lib/config/app_config.dart`:

```dart
// For Android Emulator:
static const String baseUrl = 'http://10.0.2.2:5000/api';

// For iOS Simulator or Web:
// static const String baseUrl = 'http://localhost:5000/api';

// For physical device (use your machine's IP):
// static const String baseUrl = 'http://192.168.x.x:5000/api';
```

Run the app:
```bash
flutter run
```

---

## 🔑 Demo Accounts (after seeding)

| Role   | Email              | Password    |
|--------|--------------------|-------------|
| Owner  | rajesh@demo.com    | password123 |
| Owner  | priya@demo.com     | password123 |
| Tenant | amit@demo.com      | password123 |
| Tenant | sneha@demo.com     | password123 |

> You can also tap demo tiles directly on the login screen.

---

## 📡 API Endpoints

### Auth
| Method | Endpoint           | Description        |
|--------|--------------------|--------------------|
| POST   | /api/auth/register | Register new user  |
| POST   | /api/auth/login    | Login              |
| GET    | /api/auth/me       | Get current user   |

### Properties
| Method | Endpoint                    | Description           |
|--------|-----------------------------|-----------------------|
| GET    | /api/properties             | List (with filters)   |
| GET    | /api/properties/:id         | Get single property   |
| POST   | /api/properties             | Create property       |
| PUT    | /api/properties/:id         | Update property       |
| DELETE | /api/properties/:id         | Delete property       |
| GET    | /api/properties/owner/my    | Owner's properties    |
| POST   | /api/properties/:id/save    | Toggle save           |
| GET    | /api/properties/saved/list  | Saved properties      |

### Reviews
| Method | Endpoint                | Description           |
|--------|-------------------------|-----------------------|
| GET    | /api/reviews/user/:id   | Reviews for a user    |
| POST   | /api/reviews            | Submit review         |

### Messages
| Method | Endpoint                    | Description           |
|--------|-----------------------------|-----------------------|
| POST   | /api/messages               | Send message          |
| GET    | /api/messages/conversations | List conversations    |
| GET    | /api/messages/thread/:id    | Chat thread           |

### Users
| Method | Endpoint                    | Description           |
|--------|-----------------------------|-----------------------|
| GET    | /api/users/:id              | Get user profile      |
| PUT    | /api/users/profile/update   | Update profile        |

---

## 🗄️ Database Schema

### Users
```js
{ name, email, phone, password (hashed), role: 'tenant'|'owner',
  trustScore, averageRating, totalReviews, avatar, bio, isVerified,
  savedProperties: [PropertyRef] }
```

### Properties
```js
{ ownerId, title, description, price, deposit, location: {address, city, state, pincode},
  images, propertyType, furnishing, bedrooms, bathrooms, area, amenities, isAvailable, views }
```

### Reviews
```js
{ reviewerId, reviewedUserId, propertyId,
  ratings: { behavior, communication, cleanliness, payment, maintenance },
  averageRating, comment, reviewType: 'tenant-to-owner'|'owner-to-tenant' }
```

### Messages
```js
{ senderId, receiverId, propertyId, content, isRead, messageType: 'inquiry'|'message' }
```

---

## 🎨 Design System

| Token         | Color    | Usage                         |
|---------------|----------|-------------------------------|
| Background    | #FFFFFF  | App background                |
| Card          | #F9FAFB  | Card surfaces                 |
| Text Dark     | #1F2937  | Primary headings              |
| Text Body     | #6B7280  | Secondary text                |
| Primary       | #E76F51  | Buttons, accents              |
| Trust High    | #2A9D8F  | High trust score indicator    |
| Rating        | #F4A261  | Star ratings                  |
| Warning       | #E63946  | Errors, warnings              |

---

## 🏗️ Architecture

- **Backend**: Node.js + Express, REST API, JWT auth, Mongoose ODM
- **Database**: MongoDB with auto-calculated trust scores (post-save hooks)
- **Frontend**: Flutter with Provider state management, clean layered architecture
- **Trust Score**: Dynamically recalculated after every review (avg rating × 2 = score/10)

---

## 🔌 Production Deployment

1. Deploy MongoDB to **MongoDB Atlas**
2. Deploy backend to **Railway / Render / AWS EC2**
3. Update `.env` `MONGODB_URI` to Atlas connection string
4. Update `AppConstants.baseUrl` in Flutter to your deployed API URL
5. Build Flutter for release: `flutter build apk --release`

---

## 🔮 Extensibility

- **Real-time chat**: Replace polling with Socket.io or Firebase Realtime Database
- **Image uploads**: Add Cloudinary/S3 + multer for property photo uploads
- **Push notifications**: Firebase Cloud Messaging
- **Maps**: Google Maps integration for property locations
- **Payments**: Razorpay integration for deposit collection
