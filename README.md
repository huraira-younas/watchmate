# 🎬 WatchMate – Self-Hosted Movie Sync App

**WatchMate** is a modern, self-hosted (local) movie streaming app built for **watching together**, perfectly in sync whether you're long-distance couples, friends, or movie buffs.

Inspired by Rave. Built with ❤️ using **Flutter** (Frontend) + **Node.js** (Backend).  
No ads. No noise. Just movies together.

---

## 🚀 Features

- 🛠️ 100% Self-hosted (your server, your rules)
- 🎥 HLS Video Streaming with `better_player`
- 🔒 Secure Auth Flow (Login, Signup, OTP)
- 📡 Real-time Sync via WebSockets
- 🖥️ Beautiful, Couple-Friendly UI
- 🎛️ Create & Join Watch Rooms
- 🌑 Fully Dark Mode (only)

---

## 🧑‍💻 Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Node.js + Express
- **Sync:** WebSocket (Socket.IO)
- **Streaming:** HLS / M3U8 via `better_player`
- **State Management:** BLoC / Cubit (clean architecture)
- **Auth & Storage:** Firebase, MySQL (can be replaced)

---

## 📦 Installation (Dev Mode)

> Make sure you have Flutter, MySQL and Node.js installed.

```bash
# Backend Setup
cd backend
npm install
npm run dev

# Frontend Setup
cd ../watchmate_app
flutter pub get
flutter run
