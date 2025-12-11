# 📦 Catalog + Multi-Channel Messaging System

A lightweight, Dockerized **Symfony 7** application that provides a unified product catalog accessible through a responsive web interface and three major messaging platforms.

Designed as a **clean architecture** example, it uses a central `CatalogService` to serve data across all channels **without code duplication**.

---

## ✨ Features

### 🌐 Web Interface
- **Responsive design** using Twig + TailwindCSS  
- Views for:
  - Product groups  
  - Item lists  
  - Item detail pages  
- **Zero-Admin**: All content is generated via fixtures (no CRUD UI)

---

### 💬 Messaging Channels
Interact with the catalog through:

- **Telegram Bot**
- **WhatsApp Cloud API**
- **Instagram Messaging API**

Each uses standardized parsers that convert messages into catalog queries.

---

### 🏗 Architecture
- **Unified Logic**: Dedicated parsers map Telegram/WhatsApp/Instagram messages into a common request object  
- **Fixtures-First**: Faker + Picsum-powered images create instant demo catalogs  
- **Fully Dockerized**: Nginx, PHP-FPM, MySQL — runs with one command  

---

## 🚀 Getting Started

### **Prerequisites**
- Docker
- Docker Compose
- *Make* (optional helpers)

---

### **Installation**

#### 1. Clone the repository
```bash
git clone https://github.com/yourusername/symfony-catalog-messaging.git
cd symfony-catalog-messaging
````

#### 2. Start the environment

```bash
docker-compose up -d --build
```

#### 3. Install dependencies

```bash
docker-compose exec php composer install
```

#### 4. Setup Database & Fixtures

This will create schema + random groups + items:

```bash
docker-compose exec php php bin/console doctrine:database:create
docker-compose exec php php bin/console doctrine:migrations:migrate
docker-compose exec php php bin/console doctrine:fixtures:load --no-interaction
```

#### 5. Build Assets (TailwindCSS)

```bash
docker-compose exec php php bin/console asset-map:compile
```

Web interface is now available at:

👉 **[http://localhost:8080](http://localhost:8080)**

---

## 🤖 Bot Commands

All platforms share unified logic, with syntax adapted to each.

---

### **Telegram**

| Command             | Description                 |
| ------------------- | --------------------------- |
| `/start`            | Welcome + help              |
| `/catalog`          | Show main menu / groups     |
| `/groups`           | List all product categories |
| `/items`            | List all items              |
| `/items {group_id}` | List items in a group       |
| `/item {slug}`      | Show item details           |

---

### **WhatsApp & Instagram**

| Message            | Description             |
| ------------------ | ----------------------- |
| `catalog`          | Show main menu          |
| `groups`           | List product categories |
| `items`            | List all items          |
| `items <group_id>` | Items in a group        |
| `item <slug>`      | Product details         |

---

## ⚙️ Configuration

### Copy environment file

```bash
cp .env.example .env
```

### Webhook Setup (using ngrok for local testing)

```bash
ngrok http 8080
```

### Update `.env`

```env
# Telegram
TELEGRAM_BOT_TOKEN=your_token_here

# Meta (WhatsApp & Instagram)
META_APP_ID=your_app_id
META_APP_SECRET=your_app_secret
WHATSAPP_PHONE_NUMBER_ID=your_phone_id
INSTAGRAM_ACCOUNT_ID=your_ig_id
META_VERIFY_TOKEN=random_string_for_verification
```

Register your ngrok URLs in:

* Telegram Bot API
* Meta App Dashboard (WhatsApp + Instagram)

---

## 📂 Project Structure

```
├── assets/                 # Tailwind & JS assets
├── config/                 # Symfony config
├── fixtures/               # Group & Item fixtures (Faker + Picsum)
├── src/
│   ├── Controller/
│   │   ├── Api/            # Telegram, WhatsApp, Instagram webhooks
│   │   └── Web/            # Twig catalog controllers
│   ├── Entity/             # Doctrine entities (Group, Item)
│   ├── Service/
│   │   ├── Catalog/        # Business logic
│   │   └── Messaging/      # Platform parsers + response builders
│   └── Repository/
├── templates/              # Twig views
├── docker-compose.yml
└── Dockerfile
```

---

## 🛠 Tech Stack

* **Framework:** Symfony 7
* **Language:** PHP 8.3
* **Database:** MySQL 8
* **Frontend:** Twig, TailwindCSS
* **ORM:** Doctrine
* **Containerization:** Docker

---

## 📄 License

MIT License — free for personal and commercial use.

---
