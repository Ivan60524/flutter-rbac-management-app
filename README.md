# Flutter Mobile Management App

Mobile application developed with **Flutter + Firebase** for congregational administrative management, featuring authentication, role-based access control, multi-user synchronization, reporting, attendance tracking, and PDF generation.

---

## Project Overview

This application was designed and developed as a real-world mobile solution to streamline administrative workflows for authorized congregation users.

The project includes:

- Secure authentication with Firebase Authentication
- Cloud Firestore real-time database integration
- Multi-user architecture
- Role-based access control (RBAC)
- Monthly report management
- Attendance tracking
- PDF export generation
- Android release deployment
- Real device QA validation

---

## Key Features

### Authentication & Security
✅ Firebase Authentication login  
✅ Session persistence  
✅ Secure logout flow  
✅ Firestore access rules configured  
✅ Role-based access control (RBAC)

---

### User Roles
Supported user roles:

- Secretary
- Coordinator
- Elders
- Auxiliary authorized users

Dashboard modules adapt according to assigned permissions.

---

### Core Modules

#### Publishers Management
- Create publishers
- Edit publisher information
- Centralized cloud synchronization

#### Groups Management
- Create groups
- Edit group assignments
- Shared multi-user access

#### Reports Management
- Create monthly reports
- Edit reports
- Delete reports
- Prevent duplicate reports for the same publisher in the same month

#### Attendance Management
- Register midweek attendance
- Register weekend attendance
- Edit attendance records
- Monthly attendance persistence in Firestore

#### PDF Reporting
- Generate monthly PDF reports
- Open generated files on Android devices
- Real device validation completed

---

## Technical Stack

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Android Studio
- Material Design
- PDF generation libraries

---

## Architecture Highlights

- Modular Flutter page structure
- Firebase backend integration
- Role-based access control architecture
- Shared cloud data synchronization
- Android mobile deployment pipeline

---

## QA Validation Performed

Manual testing executed on:

✅ Android Emulator  
✅ Real Android Device (Motorola Edge 30)

Validated scenarios:

- Login / logout
- Role access validation
- CRUD operations
- Multi-user synchronization
- Attendance save/edit
- Monthly reports
- Duplicate report prevention
- PDF generation
- Firebase permission troubleshooting
- Release APK installation testing

---

## Release Information

Current version:

```text
v1.0.0-beta
```

APK release generated successfully:

```text
app-release.apk
```

---

## Project Metrics

Estimated implementation effort:

**~80+ hours**

Includes:

- Development
- Firebase integration
- Debugging
- QA validation
- Release deployment

---

## Project Purpose

This project demonstrates practical experience in:

- Mobile application development
- Firebase backend integration
- Role-based access control implementation
- QA testing and bug validation
- Android deployment workflows

It also reflects the combination of **QA Engineering mindset + software development execution**.

---

## Author

**Iván Suárez**

QA Engineer | Manual Testing | API Testing | Mobile Testing | Automation Learning

GitHub:
https://github.com/Ivan60524

LinkedIn:www.linkedin.com/in/ivan-suarez-qa


---


(Add application screenshots here)
