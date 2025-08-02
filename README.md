
# Steero – iPhone Steering Wheel for Mac Games

## Overview
Revora turns your **iPhone** into a **wireless steering wheel** for Mac racing games.  
Using the phone’s gyroscope and Bluetooth Low Energy (BLE), it transmits your steering and control inputs directly to a Mac app that integrates with games via a **virtual steering device**.

### Features
- **Tilt-to-steer** using phone’s roll angle
- **Pitch forward/back** for acceleration and braking
- On-screen buttons for extra controls (e.g., handbrake, reset)
- Low-latency BLE connection
- Works with **any iPhone with a gyroscope** (iPhone 5s or newer)
- Calibration & sensitivity adjustment

---

## How It Works
```

iPhone (BLE Peripheral: motion + button data)
▶ Mac (BLE Central: receives data)
▶ Virtual steering device (HID)
▶ Racing game

```

---

## Development Plan

### Phase 1 – iPhone Sensor & BLE Prototype
- [ ] Read roll and pitch using `CoreMotion`
- [ ] Show live steering, throttle, brake values on screen
- [ ] Add one on-screen button
- [ ] Send control data over BLE as a custom service

### Phase 2 – Mac BLE Receiver
- [ ] Connect to iPhone via `CoreBluetooth`
- [ ] Receive & decode control data
- [ ] Map to temporary keyboard input for testing

### Phase 3 – Virtual Steering Device
- [ ] Create a virtual HID steering device with `IOHIDUserDevice`
- [ ] Feed steering and pedal values into HID reports
- [ ] Test in racing games for auto-detection

### Phase 4 – Calibration & UX
- [ ] Neutral steering calibration
- [ ] Sensitivity sliders
- [ ] Connection status display
- [ ] Save/load control profiles

### Phase 5 – Polishing & Extra Features
- [ ] Haptic feedback on events (e.g., collisions)
- [ ] Gesture-based controls (quick flick for handbrake)
- [ ] Multiplayer telemetry overlay

---

## Tech Stack
- **iOS:** Swift, CoreMotion, CoreBluetooth, SwiftUI
- **macOS:** Swift, CoreBluetooth, IOKit HID
- **Data Encoding:** Compact binary struct over BLE

---

## Requirements
- iPhone with gyroscope (iPhone 5s or newer)
- macOS device with Bluetooth 4.0+
- Xcode for building iOS/macOS apps

---

## Getting Started (Development)
1. Clone this repo
2. Build & run `Revora-iOS` on iPhone
3. Build & run `Revora-macOS` on Mac
4. Pair devices via BLE
5. Calibrate neutral steering
6. Launch a racing game – steer with your iPhone

---

## License
[GNU General Public License v3.0](LICENSE)

---

**Revora** – Turn your iPhone into the ultimate racing wheel.
