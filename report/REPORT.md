# Applicant Showcase App – Development Report

## 1. Introduction

When I first approached this project, I felt genuinely excited but also challenged. While I have solid experience as a backend and full-stack developer, this project required me to operate end-to-end: UI, state management, Firebase integration, and real user experience polish. I saw it not only as an assignment, but as an opportunity to build something production-ready and representative of how I approach real-world software development.

---

## 2. Learning Journey

Throughout the development of this project, I deepened my knowledge of several technologies and workflows that I had not previously used in production together.

One of the main learning areas was **Flutter with Clean Architecture**, especially structuring features into data, domain, and presentation layers while keeping responsibilities clearly separated. I also strengthened my understanding of **Bloc/Cubit** for predictable state management and UI synchronization.

Another important learning milestone was working hands-on with **Firebase**:
- Firestore with strict security rules
- Firebase Storage for media handling
- Anonymous Authentication for fast testing and controlled access
- Debugging permission issues using structured logs and DevTools

To learn and validate my approach, I relied on official documentation (Flutter, Firebase), DevTools inspection, and iterative debugging using structured logs. I applied this knowledge directly by building real publishing, reading, and AI-assisted editorial flows instead of isolated demos.

---

## 3. Challenges Faced

One of the main challenges was ensuring **data consistency between the UI, Firestore, and Firebase Storage**. Early on, the UI indicated successful article creation, while Firestore writes were silently failing due to permission rules and mismatched payloads.

To overcome this, I implemented **structured logging across the entire publish pipeline** (UI → Cubit → Repository → Firestore → Storage). This allowed me to trace exactly what data was being sent, how it was transformed, and where failures occurred.

Another challenge was handling **null safety and schema mismatches** when reading data back from Firestore. Some optional fields caused runtime errors during deserialization. I resolved this by validating incoming data, aligning DTOs with the Firestore schema, and logging raw documents before mapping them into domain entities.

These challenges reinforced the importance of observability, defensive programming, and treating backend integrations as first-class citizens in frontend development.

---

## 4. Reflection and Future Directions

Overall, this project was a very rewarding experience. Technically, it strengthened my ability to build production-grade Flutter applications with clean boundaries, strong debugging practices, and real backend integration. Professionally, it reinforced my mindset of ownership: if something breaks, I trace it, understand it, and fix it properly.

For future improvements, I would consider:
- Adding pagination and caching to the article feed
- Introducing role-based permissions for editors vs readers
- Expanding the AI editorial feature with tone or length controls
- Adding analytics to measure reading engagement

This project reflects how I approach software: not just to make it work, but to make it understandable, debuggable, and scalable.

---

## 5. Proof of the Project

This section presents visual proof of the final version of the Applicant Showcase App. The following screenshots and videos were captured directly from the running application and reflect the real user experience, design decisions, and functional scope achieved during development.

### 🚀 Splash Screen
The splash screen introduces the app with a clean and editorial-focused visual identity.

![Splash Screen](./assets/screenshots/splash_screen.png)

### 🏠 Home Feed
The home screen dynamically loads articles from Firebase and presents them in a modern, readable layout.

![Home Screen](./assets/screenshots/home_screen.png)

### 🌗 Light Mode Support
The application fully supports light mode while maintaining typography clarity and visual hierarchy.

![Light Mode](./assets/screenshots/light_mode.png)

### 📰 Article Formats
Standard and AI-enhanced article formats demonstrate flexibility in editorial content.

![Standard Article](./assets/screenshots/normal_format.png)  
![AI Article](./assets/screenshots/ia_format.png)

### ✍️ Markdown Rendering
Articles written in Markdown are rendered accurately for long-form reading.

![Markdown Rendering](./assets/screenshots/markdown.png)

### 📖 Reading Experience
Optimized layout for comfortable long-form content consumption.

![Read Article](./assets/screenshots/read_article.png)

### 🎥 AI Feature Demo
▶️ [AI Feature Demo](./assets/videos/aifeature.webm)

### 🎬 Full App Walkthrough
▶️ [Full App Showcase](./assets/videos/videoshowcase.webm)

---

## 6. Overdelivery

### New Features Implemented

**AI-Assisted Editorial Improvement**  
An AI feature allows writers to improve drafts while preserving their original intent. This enhances productivity without replacing human authorship.

**Anonymous Authentication for Fast Testing**  
Anonymous auth was implemented to allow rapid testing without blocking development, while still enforcing Firestore security rules.

**Structured Logging System**  
A full logging trail was added across UI, Cubits, Repositories, Firestore, and Storage, enabling fast debugging and clear observability.

---

### Prototypes Created

**Editorial Architecture Prototype**  
A Clean Architecture structure was designed and implemented to clearly separate domain logic, data sources, and UI concerns.

**Firestore Data Schema Prototype**  
A documented Firestore schema was created to ensure consistency between published content and application models.

---

### How Can You Improve This

Future overdelivery ideas include:
- Editorial dashboards with analytics
- Offline reading support
- AI-powered article categorization
- A/B testing different article layouts

---

## 7. Extra Sections

### Code Quality & Observability
- Clean Architecture applied consistently
- Structured logs using `dart:developer`
- Defensive data mapping and validation
- Clear fallback strategies for repository failures

### Metrics
- End-to-end publish flow fully traceable
- Zero silent failures after logging integration
- Production-ready Firebase rules and schema

---

**Final Note:**  
This project represents how I approach real-world software development: ownership, clarity, and thoughtful overdelivery beyond the initial requirements.
