---
title: "Eugene Cayle L. Maniego"
description: "Resume of an IT graduate who wants to work in networking and DevOps."
toc: true
---

Muntinlupa City, Philippines · {{< email >}} · [LinkedIn](https://www.linkedin.com/in/eugene-cayle-maniego) · [GitHub](https://github.com/Kreprep) · [PDF version](/resume.pdf)

## Summary

I want to work as a network or DevOps engineer. I like self-hosting and owning my own infrastructure, and building and running my homelab is where I got hands-on experience with virtualization, Linux administration, networking and security. I'm also interested in cloud computing and enterprise data management.

## Experience

### Dashlabs.ai, Client Success / Quality Assurance Intern

January 2026 to May 2026, remote (Philippines). College on-the-job training.

- Triaged and resolved 5 to 10 enterprise support inquiries a day from Maxicare's Viber queue (technical and patient inquiries about PEME and APE schedules), tracked in Jira
- Executed 28 manual test scenarios on pre-release features and logged bugs in Jira before deployment
- Fixed stuck e-commerce orders by tracing GCash and QR PH payment intents and reattaching them to carts
- Migrated operational dashboards to Looker Studio with JSON attribute mapping
- Co-built a prototype employee ID card generator with two fellow interns (see Company ID Project under Projects)

### Creotec Philippines Inc., Documentation Intern

March 2023, remote. Senior high school work immersion.

- Documented project development and produced usage manuals for applications

## Projects

### Self-Hosted Homelab (2025 to present)

Proxmox VE, LXC, Docker, ZFS, Caddy, CrowdSec, Bash. [Full write-up](/homelab/).

- Built and maintain a Proxmox VE 9 server (Ryzen 5 3600, 24 GB RAM) running 7 LXC containers with Docker Compose stacks: media streaming, reverse proxy, notes sync (CouchDB), game servers (Pelican), a public thesis web app and this website
- Published services under a personal domain through Caddy with Let's Encrypt TLS (Cloudflare DNS-01), CrowdSec intrusion prevention and an AppSec WAF on every public request, and dynamic DNS. Web traffic from the internet reaches only the proxy, on ports 80 and 443
- Hardened access with key-only SSH on the host and every container, root SSH disabled in containers, TOTP 2FA on the Proxmox web UI, and unprivileged containers by default
- Manage a 7.2 TB ZFS RAIDZ1 pool on three 4 TB enterprise HDDs: replaced failing disks by resilvering, vetted used drives with SMART and Seagate FARM logs (caught two relabeled drives), and tuned drive firmware power settings with openSeaChest
- Recovered from a boot SSD failure by reinstalling Proxmox and rebuilding services from self-written runbooks. Set up nightly vzdump snapshot backups (zstd, tiered daily, weekly and monthly retention) with email alerts
- Passed an AMD RX 580 into an unprivileged LXC (device passthrough and UID/GID mapping) for hardware-accelerated Jellyfin transcoding over VA-API
- Wrote a Bash forced-command SSH script that restricts an AI assistant's key to an allowlist of read-only checks, with input validation, symlink resolution and audit logging to journald

### GearView 3D (thesis, 2026)

"GearView 3D: A Web-Based Interactive 3D Model for Heavy Equipment Usage and Parts Identification of Forklifts". React Three Fiber, Three.js, Rapier, Node.js, Express, Prisma, PostgreSQL, Docker, nginx. [Live app](https://gearview3d.krepre.com), [source](https://github.com/Kreprep/GearView3D).

- Full-stack web app for the preparatory stage of TESDA Heavy Equipment Operation (Forklift) NC II training at Alpha Innovative Skills Training and Assessment Center (AISTAC): 3D parts identification, five training modules with guided inspections and driving activities, server-graded quizzes, a scored final driving test, and a skills checklist that instructors sign off
- Built a real-time 3D driving simulator with React Three Fiber, Three.js and the Rapier physics engine on a deterministic fixed-step core that runs in automated tests without a browser. Loads ride on the forks by friction and slide under hard braking, and tip-overs come from a stability model based on the reference truck's specifications and load chart
- Turned OSHA 29 CFR 1910.178 into 20 safety rules that show ISO 7010 signs in English and Filipino while the trainee drives, record each violation as training evidence, and score the final driving test
- Connected a steering wheel, pedals and gear shifter through the browser Gamepad API, with live calibration and button mapping, alongside full keyboard support and a working cab dashboard with a real pre-start sequence
- Developed a secure REST API with Node.js, Express, Prisma and PostgreSQL: JWT authentication, hashed passwords (bcrypt), Helmet, rate limiting, and role-based access for trainees, instructors and IT admins on all 45 admin routes. Staff edit modules, 3D hotspots, quizzes and courses with draft and publish controls, and review trainee progress with CSV export
- Verified the final build with 896 automated tests (run by GitHub Actions CI on every push, which also builds the Docker images), 41 scripted regression drives, and a role-by-route check of all 45 admin API routes. Evaluated with 30 trainees, instructors and admins under ISO/IEC 25010, where trainees rated usability 4.66 out of 5
- Containerized the app with Docker Compose (PostgreSQL, API, nginx) and deployed it publicly on a self-hosted server behind a Caddy reverse proxy and CrowdSec, shipping each Scrum sprint's increment through a pg_dump backup and a deploy script that pulls, rebuilds, migrates and health-checks

### TravelEase (2025)

"TravelEase: A Checklist System for Flight and Multi-type Visa Documents with AI-Assisted Verification for Philippine Travel". Flutter, Dart, Firebase, Google Cloud Functions, OpenAI API. Team project. [Demo video](https://www.youtube.com/watch?v=fS2SoIeM3h0&t=677s), [source](https://github.com/BiancaEllaOcampo/TravelEase).

- Flutter (Android) app that gives Filipino travelers destination-specific document checklists (Japan, Hong Kong, South Korea, Singapore, China) and checks uploaded flight tickets, visas and proof of accommodation with AI. Reviewed and merged the team's pull requests on GitHub
- Built a serverless AI pipeline with Firebase Cloud Functions and the OpenAI GPT-4o API that reads each uploaded document and marks it verified or needing correction, with the API key secured in Google Secret Manager
- Implemented authentication and role-based access control for travelers, admins and super admins using Firebase Authentication and Firestore and Storage security rules
- Developed the app's screens for all three roles in Flutter and Dart: document uploads from camera or gallery, live status tracking, dashboards, document review, announcements, and account management

### Company ID Project (Dashlabs.ai internship, 2026)

"Web-Based Employee ID Management System". Node.js, Express, MySQL, vanilla JavaScript. [Source](https://github.com/NordeHana28/Company_ID_Project).

- Internal prototype built with two fellow interns at Dashlabs.ai to replace employee ID cards designed by hand in graphic software. Employee records and company branding fill an HTML template that renders a printable front and back ID card
- Node.js and Express REST API for employee records (add, edit, delete, auto-generated employee IDs) with photo uploads through Multer and a MySQL database, plus a vanilla JavaScript frontend with search, JSON import and export, and an editable HTML card template
- Built the front and back ID card layout and its live preview, which follows the selected employee and the branding settings, and added the organization name and color inputs, the employee selection bar and a responsive top bar
- Presented as the internship's final project, with a roadmap for QR verification, approval statuses and audit logs

## Education

### Mapúa University, Makati

Bachelor of Science in Information Technology, specialization in Enterprise Data Management. August 2023 to October 2026. GWA 1.54, cum laude.

### Mapúa University, Makati (senior high school)

Science, Technology, Engineering and Mathematics (STEM) track. September 2021 to 2023. Graduated with honors.

## Certifications

- SAKURA Cloud Hands-on Training, Sakura Internet Co. (March 2026)
- Oracle Cloud Infrastructure 2025 Certified AI Foundations Associate (October 2025)
- Oracle Data Platform 2025 Certified Foundations Associate (October 2025)
- Oracle Cloud Infrastructure 2025 Certified Foundations Associate (October 2025)

## CTF competitions (team APTWatch)

- Hack The Box University CTF 2025: Tinsel Trouble, rank 117
- Hack The Box University CTF 2024: Binary Badlands, rank 348
- HackDay Qualifications CTF by ESIEESPACE, rank 93 of 189

## Skills

| Area | Skills |
|---|---|
| Languages | Bash, Python, JavaScript (Node.js), SQL, Java, C++, Dart |
| Infrastructure and virtualization | Linux (Debian, Ubuntu), Proxmox VE, Docker, Docker Compose, LXC, GPU passthrough (VA-API), Windows Active Directory |
| Storage and backup | ZFS (RAIDZ1, resilvering, scrubs), LVM-thin, Samba, vzdump snapshot backups, SMART disk diagnostics |
| Networking and security | TCP/IP, DNS (Cloudflare, Pi-hole), dynamic DNS, reverse proxies (Caddy, nginx), TLS (Let's Encrypt, DNS-01), port forwarding, CrowdSec (IPS, AppSec WAF), SSH hardening, TOTP 2FA |
| Cloud | Oracle Cloud Infrastructure, Firebase / Google Cloud |
| Frameworks and tools | Git, GitHub Actions, Jira, React, Vite, Three.js / React Three Fiber, Express, Prisma, PostgreSQL, MySQL, Flutter, Tailwind CSS, OpenAI API |
