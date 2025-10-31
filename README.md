# 🌍 Saathi: The Verified Walker Companion Platform

Saathi is a compassion-driven mobile application developed for the aidKRIYA Walker App Challenge 2025.  
It transforms the act of walking into a secure, social, and reliable service — bridging the gap between Walkers (verified service providers) and Wanderers (individuals seeking a walking companion).

> Our core mission: “Serving Motion for the Nation.”

---

## 🚀 Key Features

### 👥 Dual Roles
- Wanderers: Clients who schedule and request assistance for companionship or support.
- Walkers: Verified helpers who set their availability, accept requests, and earn recognition.

### 🔒 Safety & Trust
- End-to-End Verification: Walkers pass an identity verification stage to display a 'Verified' badge.
- Security Protocols: Masked contact details, SOS safety button, and secure location sharing.

### 🗺 Smart Discovery
- Proximity Matching: Google Maps–based system displays available Walkers near the Wanderer's location.
- Themed UI: A clean, professional Teal-Green / Nunito theme is applied across all app components.

---

## 📱 App Flow & User Journey

### 1️⃣ Onboarding & Authentication
- *First-Time Carousel (OnboardingScreen):* Highlights key values (managed by GetStorage for persistence).
- Login/Signup: Themed flow utilizing Supabase Auth for user session management.

### 2️⃣ Discovery & Selection
- Wanderer Dashboard: Displays the Map and the Nearby Walkers list in a clean, professional card format.
- Profile Interaction: Tapping a Walker opens the detailed profile (WalkerDetailsScreen) featuring:
    - Themed gradient background
    - Chat button
    - Fully themed Reviews Section

### 3️⃣ Scheduling & Action
- Safe Scheduling: Uses locally themed Date and Time Pickers for UI consistency.
- Database Integrity: All booking actions call a single centralized function (scheduleWalk) for secure data handling.

---

## 🧠 Tech Stack

| Layer | Technology |
|-------|-------------|
| Frontend | Flutter + GetX |
| Backend | Supabase (PostgreSQL, Auth, Realtime) |
| Storage | Cloudinary |
| Payments | Razorpay / Stripe |
| Maps | Google Maps SDK |
| Location | Geolocator, background tracking |
| Design | Figma / Canva |

---

## 🧾 Database Schema (Supabase)

- users — Core user data (auth UID, role)
- walker_details — Documents, rates, and availability
- walk_requests — Help requests and tracking
- reviews — Ratings and feedback
- user_locations — Real-time positions
- background_checks — Verification records
- payments — Razorpay / Stripe transactions

---

## 🔐 Secret Management

All sensitive keys are stored securely in:
android/secrets.properties

This file is *excluded from GitHub* via .gitignore to maintain security and privacy.

---

> Saathi brings empathy to motion — ensuring every walk is guided, safe, and meaningful.