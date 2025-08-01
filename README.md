# 🎬 WatchMate – Self-Hosted Movie Sync App

**WatchMate** is a self-hosted, real-time movie streaming and sync app designed for watching movies **together**, no matter the distance — perfect for long-distance couples, close friends, or remote movie nights.

Inspired by **Rave**. Built with ❤️ using **Flutter** & **Node.js**.  
**No ads. No distractions. Just movies. Together.**

---

## 🚀 Features

- 🛠️ 100% **Self-Hosted** – You control the server and data
- 🎥 **HLS Video Streaming** with `better_player`
- 🔐 Secure Authentication (Login, Signup, OTP)
- 🔄 **Real-time Sync** powered by WebSockets
- 💑 Couple-Friendly, Modern & Minimal UI
- 🎛️ Create & Join Private **Watch Rooms**
- 🌙 **Dark Mode Only** – for cozy late-night sessions

---

## 🧰 Tech Stack

| Layer      | Tech Stack                            |
|------------|----------------------------------------|
| Frontend   | Flutter (Dart)                         |
| Backend    | Node.js + Express                      |
| Sync       | WebSocket (Socket.IO)                  |
| Streaming  | HLS / M3U8 via `better_player`         |
| State Mgmt | BLoC / Cubit (Clean Architecture)      |
| Auth       | Firebase (can be swapped)              |
| Database   | MySQL                                  |

---

## ⚙️ Installation (Development Mode)

> Prerequisites: Flutter SDK, Node.js, MySQL installed and configured.

```bash
# 1. Backend Setup
cd backend
npm install
npm run dev

# 2. Frontend Setup
cd ../watchmate_app
flutter pub get
flutter run
```

---

## 📸 Screenshots

> Coming soon...

---

## 🤝 Contributing

Contributions are welcome! Please open an issue or submit a pull request for improvements, features, or fixes.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 🙌 Credits

Built with passion by movie lovers, for movie lovers.  
Special thanks to the open-source community & inspiration from Rave.

---
