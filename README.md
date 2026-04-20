# Flo Backend

> Go with the Flo — a mindfulness & habit-tracking app backend

Spring Boot 3.2 · Java 21 · PostgreSQL · JWT Auth · Flyway Migrations

---

## Stack

| Layer        | Tech                          |
|--------------|-------------------------------|
| Runtime      | Java 21                       |
| Framework    | Spring Boot 3.2.5             |
| Database     | PostgreSQL 15+                |
| Migrations   | Flyway                        |
| Auth         | JWT (JJWT 0.12)               |
| Security     | Spring Security 6             |
| Build        | Maven                         |

---

## Getting Started

### Prerequisites
- Java 21
- PostgreSQL running locally
- Maven 3.9+

### Setup

```bash
# Clone
git clone https://github.com/Sopanha9/flo-backend.git
cd flo-backend

# Configure DB — copy and edit
cp src/main/resources/application.yml src/main/resources/application-local.yml
# Edit DB credentials in application-local.yml

# Run
./mvnw spring-boot:run
```

Default port: `8080`

---

## API Endpoints

### Auth (public)
| Method | Path                | Description     |
|--------|---------------------|-----------------|
| POST   | `/api/auth/register`| Register user   |
| POST   | `/api/auth/login`   | Login, get JWT  |

### Users (authenticated)
| Method | Path            | Description          |
|--------|-----------------|----------------------|
| GET    | `/api/users/me` | Current user profile |
| GET    | `/api/users/{id}` | Get user by ID (admin) |

All protected routes require:
```
Authorization: Bearer <token>
```

---

## Database Schema

12 tables covering:
- `users` + `profiles` — auth & social identity
- `moods` — daily mood tracking (1–10 scale)
- `habits` + `habit_logs` — habit streaks
- `journal_entries` + `tags` + `journal_tags` — private journaling
- `goals` + `goal_milestones` — goal setting
- `follows` — social graph
- `notifications` — in-app alerts

Migrations live in `src/main/resources/db/migration/`.

---

## Project Structure

```
src/main/java/com/flo/
├── FloApplication.java
├── auth/
│   ├── AuthController.java
│   ├── AuthService.java
│   ├── JwtUtil.java
│   ├── JwtAuthFilter.java
│   └── dto/
│       ├── LoginRequest.java
│       ├── RegisterRequest.java
│       └── AuthResponse.java
├── user/
│   ├── UserController.java
│   ├── UserService.java
│   ├── UserRepository.java
│   └── entity/
│       └── User.java
├── config/
│   └── SecurityConfig.java
└── common/
    ├── response/
    │   └── ApiResponse.java
    └── exception/
        ├── GlobalExceptionHandler.java
        ├── ResourceNotFoundException.java
        ├── UnauthorizedException.java
        └── DuplicateResourceException.java
```

---

## License

MIT
