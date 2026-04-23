<div align="center">

<br/>

<img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=flat" />
<img src="https://img.shields.io/badge/Status-MVP%20Development-E8650A?style=flat" />
<img src="https://img.shields.io/badge/Made%20in-Morocco%20🇲🇦-red?style=flat" />

<br/><br/>

```
  ██████╗ ██████╗ ██╗██╗  ██╗ ██████╗ ██╗     ██╗██╗  ██╗
  ██╔══██╗██╔══██╗██║██║ ██╔╝██╔═══██╗██║     ██║██║ ██╔╝
  ██████╔╝██████╔╝██║█████╔╝ ██║   ██║██║     ██║█████╔╝ 
  ██╔══██╗██╔══██╗██║██╔═██╗ ██║   ██║██║     ██║██╔═██╗ 
  ██████╔╝██║  ██║██║██║  ██╗╚██████╔╝███████╗██║██║  ██╗
  ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝╚═╝  ╚═╝
```

### **Services à domicile · Morocco's Home Services Marketplace**

*Connecting homeowners with trusted local professionals — fast, simple, reliable.*

<br/>

[**View Demo**](#) · [**Report Bug**](../../issues) · [**Request Feature**](../../issues) · [**Contact**](#-contact)

<br/>

---

</div>

<br/>

## ◈ What is Brikolik?

**Brikolik** is a mobile-first marketplace that bridges the gap between Moroccan homeowners and skilled local artisans. Whether you need a plumber at midnight or a painter for the weekend, Brikolik connects you in seconds.

> *"بريكوليك — لأن بيتك يستحق الأفضل"*
> *"Brikolik — because your home deserves the best"*

<br/>

## ◈ Core Features

<table>
<tr>
<td width="50%">

### 🏠 For Customers
- Post a job in under 60 seconds
- Browse verified workers nearby
- Direct WhatsApp/phone contact & instant quotes
- Track jobs from request to completion
- Rate & review after every service
- Full MAD (درهم) support

</td>
<td width="50%">

### 🔧 For Workers
- Receive geo-targeted job alerts
- One-tap applications
- Build a public reputation profile
- Manage availability & schedule
- Direct in-app payments
- Grow your local client base

</td>
</tr>
</table>

<br/>

## ◈ App Screens

| Login | Role Select | Job List | Job Details |
|:---:|:---:|:---:|:---:|
| ![](screenshots/login.png) | ![](screenshots/role.png) | ![](screenshots/jobs.png) | ![](screenshots/details.png) |

| Post Job | Worker Profile | Notifications | Rating |
|:---:|:---:|:---:|:---:|
| ![](screenshots/post.png) | ![](screenshots/worker.png) | ![](screenshots/notifications.png) | ![](screenshots/rating.png) |

<br/>

## ◈ Tech Stack

```
┌─────────────────────────────────────────────────────────┐
│                      BRIKOLIK MVP                        │
├──────────────────┬──────────────────────────────────────┤
│  Mobile          │  Flutter 3.x  (iOS + Android)        │
│  UI              │  Material 3 · Custom Design System   │
│  State           │  Provider / Riverpod                 │
│  Backend         │  Firebase · Firestore                │
│  Auth            │  Firebase Auth · Phone OTP           │
│  Storage         │  Firebase Storage                    │
│  Maps            │  Google Maps SDK                     │
│  Payments        │  Stripe · CMI · WafaCash             │
│  Notifications   │  Firebase Cloud Messaging            │
│  CI/CD           │  GitHub Actions                      │
└──────────────────┴──────────────────────────────────────┘
```

<br/>

## ◈ Project Structure

```
brikolik_mvp/
│
├── lib/
│   ├── models/
│   │   └── app_models.dart          # Data models
│   │
│   ├── screens/
│   │   ├── login_screen.dart        # Auth (login + signup)
│   │   ├── role_screen.dart         # Customer / Worker selection
│   │   ├── customer_profile_screen.dart
│   │   ├── worker_profile_screen.dart
│   │   ├── job_list_screen.dart     # Home feed
│   │   ├── job_details_screen.dart
│   │   ├── post_job_screen.dart     # 3-step job wizard
│   │   ├── notifications_screen.dart
│   │   └── rating_screen.dart
│   │
│   ├── theme/
│   │   ├── app_theme.dart           # Design system + tokens
│   │   └── widgets.dart             # Shared reusable components
│   │
│   └── main.dart                    # Routes + app entry
│
├── assets/
│   └── fonts/
│       └── Nunito/
│
├── android/
├── ios/
└── pubspec.yaml
```

<br/>

## ◈ Design System

The app uses a custom design system built on top of Material 3.

```dart
// Primary palette
BrikolikColors.primary       →  #E8650A  (Amber Orange)
BrikolikColors.primaryLight  →  #FFF0E6
BrikolikColors.background    →  #F8F7F5
BrikolikColors.surface       →  #FFFFFF
BrikolikColors.textPrimary   →  #1A1512
BrikolikColors.textSecondary →  #6B6560

// Shared components
BrikolikButton    →  Primary / Outlined / Loading states
BrikolikInput     →  Styled text fields with icons
BrikolikAvatar    →  Circle avatars with initials fallback
StatusBadge       →  Open / In Progress / Done
StarRating        →  Inline rating display
CategoryChip      →  Animated filter chips
```

<br/>

## ◈ Getting Started

### Prerequisites

| Tool | Version |
|---|---|
| Flutter | 3.19+ |
| Dart | 3.x |
| Android Studio | Hedgehog+ |
| Android SDK | 36+ |

### Installation

```bash
# 1 — Clone
git clone https://github.com/yourusername/brikolik_mvp.git
cd brikolik_mvp

# 2 — Install dependencies
flutter pub get

# 3 — Run
flutter run
```

### Navigation Routes

```dart
'/login'            →  LoginScreen
'/role'             →  RoleScreen
'/customer-profile' →  CustomerProfileScreen
'/worker-profile'   →  WorkerProfileScreen
'/jobs'             →  JobListScreen
'/job-details'      →  JobDetailsScreen
'/post-job'         →  PostJobScreen
'/notifications'    →  NotificationsScreen
'/rating'           →  RatingScreen
```

### Dev Commands

```bash
r          # Hot Reload  — UI changes
R          # Hot Restart — logic / route changes
flutter run --release   # Production build
flutter build apk       # Generate APK
```

<br/>

## ◈ Roadmap

- [x] Authentication (Login / Signup)
- [x] Role selection (Customer / Worker)
- [x] Job posting — 3-step wizard
- [x] Job list with search & filters
- [x] Job details with offer system
- [x] Worker profile with verification
- [x] Rating & review system
- [x] Notifications screen
- [ ] Firebase backend integration
- [ ] Real-time notifications
- [ ] GPS-based job matching
- [ ] In-app payments (MAD)
- [ ] Arabic language support
- [ ] iOS release
- [ ] Production launch 🚀

<br/>

## ◈ Contributing

Contributions are welcome and appreciated.

```bash
# 1 — Fork the project
# 2 — Create your branch
git checkout -b feature/your-feature-name

# 3 — Commit
git commit -m "feat: add your feature"

# 4 — Push
git push origin feature/your-feature-name

# 5 — Open a Pull Request
```

Please follow [conventional commits](https://www.conventionalcommits.org/) for commit messages.

<br/>

## ◈ Contact

<table>
<tr>
<td><strong>Project</strong></td>
<td>Brikolik — Home Services Marketplace</td>
</tr>
<tr>
<td><strong>Region</strong></td>
<td>Morocco 🇲🇦 — Casablanca first</td>
</tr>
<tr>
<td><strong>Website</strong></td>
<td><a href="https://brikolik.ma">brikolik.ma</a> <em>(coming soon)</em></td>
</tr>
<tr>
<td><strong>Email</strong></td>
<td>hello@brikolik.ma</td>
</tr>
<tr>
<td><strong>Instagram</strong></td>
<td><a href="https://instagram.com/brikolik.ma">@brikolik.ma</a></td>
</tr>
</table>

<br/>

## ◈ License

```
MIT License — Copyright (c) 2026 Brikolik

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software to use, copy, modify, merge, publish, and
distribute, subject to the conditions of the MIT License.
```

See [LICENSE](LICENSE) for full details.

<br/>

---

<div align="center">

**Built with ❤️ in Morocco**

*If this project helped you, consider giving it a* ⭐

</div>
