⚡ Smart Energy Monitoring & Optimization System

A real-time IoT-based system that monitors energy consumption, controls appliances remotely, and provides smart recommendations to optimize energy usage.

---

📱 Project Overview

This project integrates:

- Flutter Mobile App → User interface & control
- ESP32 Microcontroller → Sensor data + device control
- Firebase (Planned) → Cloud data storage & real-time sync

The system allows users to monitor environmental conditions and control home appliances efficiently.

---

🚀 Features

🔹 Energy Monitoring

- Displays real-time energy usage (kWh)
- Calculates energy cost dynamically
- Visual energy meter with progress indicator

🔹 Device Control

- Control appliances:
  - AC
  - Fridge
  - Washer
  - Heater
- Toggle ON/OFF directly from mobile app

🔹 Smart Automation

- Smart Mode for automatic optimization
- Turns off devices when no motion detected
- Activates cooling when temperature is high

🔹 Environment Monitoring

- Temperature
- Humidity
- Motion detection
- Light intensity

🔹 Data Visualization

- Weekly energy usage graph (Bar Chart)
- Easy-to-read analytics

🔹 Smart Suggestions

- Provides energy-saving recommendations
- Alerts based on usage and environment

🔹 Energy Efficiency Score

- Displays system efficiency percentage
- Helps users track performance

---

🏗️ System Architecture

Sensors → ESP32 → WiFi → Flutter App
            ↑            ↓
        Relay Control ← User Input

---

🛠️ Technologies Used

Frontend (Mobile App)

- Flutter (Dart)
- Material UI
- fl_chart (for graphs)

Backend / IoT

- ESP32
- REST API (HTTP)
- JSON data format

Sensors

- DHT11 / DHT22 → Temperature & Humidity
- PIR Sensor → Motion Detection
- LDR → Light Intensity

Future Integration

- Firebase Realtime Database
- Push Notifications

---

📂 Project Structure

lib/
 ├── screens/
 │    └── dashboard.dart
 ├── services/
 │    └── api_service.dart
 └── main.dart

---

🔌 API Endpoints (ESP32)

Endpoint| Description
"/data"| Get sensor data
"/on1"| Turn ON device 1
"/off1"| Turn OFF device 1

---

📊 Sample Data Format

{
  "temperature": 28,
  "humidity": 58,
  "motion": true,
  "light": 1700,
  "relay1": true,
  "relay2": false
}

---

⚙️ Setup Instructions

1️⃣ Clone the Repository

git clone <your-repo-link>
cd my_app

---

2️⃣ Install Dependencies

flutter pub get

---

3️⃣ Run the App

flutter run

---

4️⃣ Build APK

flutter build apk --debug

APK Location:

build/app/outputs/flutter-apk/app-debug.apk

---

🔄 Mock Mode (Testing Without Hardware)

In "api_service.dart":

static bool useMock = true;

Set to "false" when ESP32 is connected.

---

📈 Future Enhancements

- Firebase integration (real-time sync)
- Push notifications for alerts
- AI-based energy prediction
- User authentication
- Historical analytics dashboard

---

🎯 Use Cases

- Smart homes
- Energy-efficient buildings
- IoT learning projects
- College mini/major project

---

📌 Author

Sharada C
B.Tech – Information Science & Engineering

---

⭐ Conclusion

This project demonstrates how IoT and mobile applications can work together to create an intelligent energy monitoring system that improves efficiency, reduces wastage, and enhances user convenience.

---