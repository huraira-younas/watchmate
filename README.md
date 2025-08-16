# 🎬 WatchMate

<p align="center">
  <img src="https://github.com/huraira-younas/watchmate/blob/master/watchmate_app/assets/images/icons/app_icon.png?raw=true" alt="WatchMate Logo" width="200"/>
</p>

**WatchMate** is a self-hosted watch party application that lets you **upload, stream, and sync videos with friends** — all while chatting in real time.  
Built with modern technologies, it’s designed for **seamless video synchronization, private hosting, and community-driven streaming.**

---

## 🚀 Tech Stack

- **Frontend** → Flutter
- **Backend** → Node.js
- **Database** → MySQL
- **Real-time Sync** → Socket.IO
- **File Storage** → Cloudflare R2 (Can changed to AWS S3)
- **Hosting** → supports self-hosting on your PC too
- **Cache & Performance** → Redis

---

## ⚡ Features

### 📂 File Upload

- **Local Upload** → Upload any video (up to **2GB**) to the server.
- **Link Upload** → Paste a YouTube or direct video link, and the server downloads it for you.

### 👀 Visibility

- **Public** → Share videos with the entire platform.
- **Private** → Restrict to yourself or those with a direct link.

### 📺 Streaming

- Videos are streamed directly from **Cloudflare R2**, with smooth playback.

### 🤝 Watch Party

- Share a link to instantly create a room.
- Friends can join and watch together in real time.

### ⏯ Synchronisation

- Only the **leader** (host) controls playback: play, pause, seek, skip, change speed.
- All viewers stay perfectly in sync.

### 💬 Chat

- **Inside Party** → Chat while watching, reply to messages, add reactions and share images.
- **Outside Party** → Personal 1-on-1 chats.

### 🛠 Controls

- Leader can **kick users** or **end the party**.

### 📑 Manage Videos

- Edit or delete uploaded videos in **MyList**.
- Switch visibility between public/private anytime.

### 🌍 Public Library

- Browse videos uploaded publicly by other users.

### 📥 Unique Download Mode

- Users can **pre-download** videos for offline sync playback.
- Even on poor networks, playback runs locally while still staying in sync with the party.

---

## 📸 Screenshots (Coming Soon)

---

## 🏗 Setup & Installation

### Prerequisites

- Node.js v20+
- Flutter SDK
- MySQL v8+
- Redis
- cPanel hosting (or any Node.js supported server)
- Cloudflare R2 or AWS S3 credentials

### 1. Clone Repository

```bash
git clone https://github.com/your-username/watchmate.git
cd watchmate
```

### 2. Server Setup

```bash
cd server
npm install
npm start
```

### 3. Flutter App Setup

```bash
cd app
flutter pub get
flutter run
```

### 4. Environment Variables

A `.env.example` file is provided in the repository.  
Simply copy it and update with your own credentials:

```bash
cp .env.example .env
```

---

## 🤝 Contributing

Contributions are welcome! 🎉
1. Fork the repo
2. Create your feature branch (`git checkout -b feature/your-feature`)
3. Commit changes (`git commit -m 'Add feature'`)
4. Push to branch (`git push origin feature/your-feature`)
5. Open a Pull Request

---

## 📜 License
This project is licensed under the **MIT License** – free to use, modify, and distribute.

---

## 🌟 Support
If you like this project, give it a ⭐ on GitHub to show your support!
