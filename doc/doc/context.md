# 🔮 AI Astrology Chatbot & Tarot Reading App

![App Banner](https://via.placeholder.com/800x200/151030/FFD700?text=AI+Astrology+%26+Tarot)

## ✨ Overview

A sophisticated mobile application offering AI-powered astrology insights and tarot card readings in Thai language. The app features an immersive dark theme with celestial animations, creating a mystical and engaging user experience.

## 🌟 Core Features

### 🚪 User Journey

1. **Enchanting Welcome Screen**
   - Elegant dark-themed interface with cosmic animations
   - Prominent app branding and mystical tagline
   - Multiple access options:
     - ✅ **Sign Up** - Create a new account
     - 🔑 **Login** - Access existing account
     - 👤 **Guest Mode** - Limited preview experience

2. **Seamless Authentication**
   - **New User Registration**
     - Email and password setup
     - Birth date collection for personalized astrology insights
   - **Returning User Login**
     - Secure email/password authentication
   - **Future Enhancement:** Social login integration (Google, Facebook, Apple)

3. **Personalized Dashboard**
   - Dynamic astrology profile based on user's birth data
   - Daily horoscope highlights
   - Intuitive AI chatbot interface
   - Quick-access tarot reading section
   - Archived readings and conversation history

4. **Interactive AI Consultation**
   - Natural conversation in **Thai language**
   - Astrology-focused guidance and insights
   - Convenient preset questions:
     - "วันนี้ฉันควรระวังอะไร?" (What should I be cautious about today?)
     - "ดวงความรักของฉันเป็นอย่างไร?" (How is my love fortune?)
   - Rich responses combining textual insights and visual astrology charts

5. **Immersive Tarot Experience**
   - Multiple spread options:
     - 🃏 Single Card (Quick Insight)
     - 🃏🃏🃏 Three-Card Spread (Past-Present-Future)
     - 🃏🃏🃏🃏🃏 Celtic Cross (Comprehensive Reading)
   - Realistic card shuffling animations
   - Detailed AI interpretation of card meanings
   - Save and share functionality for readings

6. **Mindful Focus Mode**
   - Distraction-free environment for deeper connection
   - Customizable meditation timer
   - Soothing cosmic soundscapes
   - Post-session personalized spiritual insights

7. **Customizable User Experience**
   - Detailed profile management
   - AI interaction style preferences
   - Language settings (Thai primary, English future option)
   - Visual theme customization options

8. **Premium Tier Offerings**
   - 🌙 Enhanced daily horoscope with detailed aspects
   - 🔮 Advanced tarot spread interpretations
   - 📊 Comprehensive birth chart analysis
   - 🚫 Ad-free experience
   - 💬 Expert astrologer consultations

## 🛠️ Technical Architecture

### Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| Frontend | Flutter | Cross-platform mobile experience |
| Backend | Laravel 11 | API services and business logic |
| AI Engine | anthropic API | Natural language processing for insights |
| Database | Superbase |
| Authentication | Firebase Auth/OAuth | Secure user identity management |

### Design Philosophy

- **Color Palette:** Deep cosmic purples and blues with golden celestial accents
- **Animation Elements:** Twinkling stars, zodiac wheel rotations, fluid card movements
- **Typography:** Elegant Thai script optimized for readability with modern UI components
- **Accessibility:** Thoughtful contrast ratios and interaction patterns

## 📊 Database Schema

### Core Tables

#### `users`
| Column | Type | Description |
|--------|------|-------------|
| `id` | BIGINT | Primary key |
| `email` | VARCHAR(255) | User's email address (unique) |
| `password` | VARCHAR(255) | Encrypted password |
| `name` | VARCHAR(255) | User's display name |
| `birth_date` | DATE | User's date of birth |
| `birth_time` | TIME | User's time of birth (nullable) |
| `birth_location` | VARCHAR(255) | User's place of birth (nullable) |
| `zodiac_sign` | VARCHAR(50) | User's zodiac sign (calculated) |
| `profile_image` | VARCHAR(255) | Path to profile image (nullable) |
| `language` | VARCHAR(10) | Preferred language (default: 'th') |
| `is_premium` | BOOLEAN | Premium status flag |
| `last_login` | TIMESTAMP | Last login timestamp |
| `created_at` | TIMESTAMP | Account creation timestamp |
| `updated_at` | TIMESTAMP | Account update timestamp |

#### `subscriptions`
| Column | Type | Description |
|--------|------|-------------|
| `id` | BIGINT | Primary key |
| `user_id` | BIGINT | Foreign key to users table |
| `plan_id` | BIGINT | Foreign key to subscription_plans table |
| `status` | VARCHAR(50) | Subscription status (active, canceled, expired) |
| `start_date` | DATE | Subscription start date |
| `end_date` | DATE | Subscription end date |
| `payment_method` | VARCHAR(100) | Payment method used |
| `auto_renew` | BOOLEAN | Auto-renewal flag |
| `created_at` | TIMESTAMP | Record creation timestamp |
| `updated_at` | TIMESTAMP | Record update timestamp |

#### `subscription_plans`
| Column | Type | Description |
|--------|------|-------------|
| `id` | BIGINT | Primary key |
| `name` | VARCHAR(100) | Plan name |
| `description` | TEXT | Plan description |
| `price` | DECIMAL(10,2) | Plan price |
| `duration_days` | INTEGER | Plan duration in days |
| `features` | JSON | Features included in plan |
| `is_active` | BOOLEAN | Plan availability status |
| `created_at` | TIMESTAMP | Record creation timestamp |
| `updated_at` | TIMESTAMP | Record update timestamp |

#### `chat_conversations`
| Column | Type | Description |
|--------|------|-------------|
| `id` | BIGINT | Primary key |
| `user_id` | BIGINT | Foreign key to users table |
| `title` | VARCHAR(255) | Conversation title (auto-generated) |
| `created_at` | TIMESTAMP | Conversation start timestamp |
| `updated_at` | TIMESTAMP | Last message timestamp |

#### `chat_messages`
| Column | Type | Description |
|--------|------|-------------|
| `id` | BIGINT | Primary key |
| `conversation_id` | BIGINT | Foreign key to chat_conversations table |
| `sender_type` | VARCHAR(50) | Message sender (user/ai) |
| `content` | TEXT | Message content |
| `has_attachments` | BOOLEAN | Flag for message attachments |
| `created_at` | TIMESTAMP | Message timestamp |

#### `tarot_readings`
| Column | Type | Description |
|--------|------|-------------|
| `id` | BIGINT | Primary key |
| `user_id` | BIGINT | Foreign key to users table |
| `spread_type` | VARCHAR(100) | Type of spread used |
| `question` | TEXT | User's question (nullable) |
| `cards` | JSON | Cards drawn and positions |
| `interpretation` | TEXT | AI interpretation of reading |
| `is_saved` | BOOLEAN | User saved reading flag |
| `created_at` | TIMESTAMP | Reading timestamp |
| `updated_at` | TIMESTAMP | Record update timestamp |

#### `tarot_cards`
| Column | Type | Description |
|--------|------|-------------|
| `id` | BIGINT | Primary key |
| `name` | VARCHAR(100) | Card name |
| `name_th` | VARCHAR(100) | Card name in Thai |
| `suit` | VARCHAR(50) | Card suit (Major Arcana, Cups, etc.) |
| `number` | INTEGER | Card number within suit |
| `image_path` | VARCHAR(255) | Path to card image |
| `keywords` | TEXT | Keywords associated with card |
| `keywords_th` | TEXT | Keywords in Thai |
| `upright_meaning` | TEXT | Upright card meaning |
| `upright_meaning_th` | TEXT | Upright meaning in Thai |
| `reversed_meaning` | TEXT | Reversed card meaning |
| `reversed_meaning_th` | TEXT | Reversed meaning in Thai |
| `created_at` | TIMESTAMP | Record creation timestamp |
| `updated_at` | TIMESTAMP | Record update timestamp |

#### `daily_horoscopes`
| Column | Type | Description |
|--------|------|-------------|
| `id` | BIGINT | Primary key |
| `zodiac_sign` | VARCHAR(50) | Zodiac sign |
| `date` | DATE | Horoscope date |
| `content` | TEXT | Horoscope content |
| `content_th` | TEXT | Horoscope content in Thai |
| `love_rating` | INTEGER | Love aspect rating (1-5) |
| `career_rating` | INTEGER | Career aspect rating (1-5) |
| `health_rating` | INTEGER | Health aspect rating (1-5) |
| `lucky_number` | VARCHAR(50) | Lucky number(s) |
| `lucky_color` | VARCHAR(50) | Lucky color(s) |
| `created_at` | TIMESTAMP | Record creation timestamp |
| `updated_at` | TIMESTAMP | Record update timestamp |

#### `focus_sessions`
| Column | Type | Description |
|--------|------|-------------|
| `id` | BIGINT | Primary key |
| `user_id` | BIGINT | Foreign key to users table |
| `duration_minutes` | INTEGER | Session duration |
| `theme` | VARCHAR(100) | Session theme/background |
| `start_time` | TIMESTAMP | Session start time |
| `end_time` | TIMESTAMP | Session end time |
| `completed` | BOOLEAN | Session completion status |
| `notes` | TEXT | User notes (nullable) |
| `insights` | TEXT | AI-generated insights |
| `created_at` | TIMESTAMP | Record creation timestamp |
| `updated_at` | TIMESTAMP | Record update timestamp |

#### `user_preferences`
| Column | Type | Description |
|--------|------|-------------|
| `id` | BIGINT | Primary key |
| `user_id` | BIGINT | Foreign key to users table |
| `theme` | VARCHAR(50) | UI theme preference |
| `notifications_enabled` | BOOLEAN | Notifications toggle |
| `sound_enabled` | BOOLEAN | Sound effects toggle |
| `animation_level` | VARCHAR(50) | Animation intensity (low/medium/high) |
| `ai_formality` | VARCHAR(50) | AI conversation style |
| `created_at` | TIMESTAMP | Record creation timestamp |
| `updated_at` | TIMESTAMP | Record update timestamp |

### Relationships

- `users` 1:N `chat_conversations`
- `users` 1:N `tarot_readings`
- `users` 1:N `focus_sessions`
- `users` 1:1 `user_preferences`
- `users` 1:N `subscriptions`
- `subscription_plans` 1:N `subscriptions`
- `chat_conversations` 1:N `chat_messages`

## 📁 Project Structure

### Frontend (Flutter)

```
astrology_app/
├── android/                 # Android-specific files
├── ios/                     # iOS-specific files
├── lib/
│   ├── main.dart            # Application entry point
│   ├── app.dart             # App configuration
│   ├── config/              # App configuration
│   │   ├── routes.dart      # Route definitions
│   │   ├── themes.dart      # Theme configurations
│   │   └── constants.dart   # App constants
│   ├── core/                # Core functionality
│   │   ├── api/             # API service clients
│   │   ├── models/          # Data models
│   │   ├── services/        # Business logic services
│   │   └── utils/           # Utility functions
│   ├── features/            # Feature modules
│   │   ├── auth/            # Authentication
│   │   │   ├── screens/     # UI screens
│   │   │   ├── widgets/     # UI components
│   │   │   └── providers/   # State management
│   │   ├── dashboard/       # Main dashboard
│   │   ├── chat/            # AI chat functionality
│   │   ├── tarot/           # Tarot reading feature
│   │   ├── horoscope/       # Daily horoscope feature
│   │   ├── focus/           # Focus mode feature
│   │   └── profile/         # User profile management
│   ├── shared/              # Shared components
│   │   ├── widgets/         # Reusable widgets
│   │   ├── animations/      # Animation definitions
│   │   └── styles/          # Shared styles
│   └── l10n/                # Localization
│       ├── th.dart          # Thai translations
│       └── en.dart          # English translations
├── assets/                  # Static assets
│   ├── images/              # Image assets
│   │   ├── zodiac/          # Zodiac sign images
│   │   ├── tarot/           # Tarot card images
│   │   └── backgrounds/     # Background images
│   ├── animations/          # Lottie animations
│   ├── fonts/               # Custom fonts
│   └── audio/               # Sound effects and music
├── test/                    # Unit and widget tests
└── pubspec.yaml             # Dependencies
```

### Backend (Laravel 11)

```
astrology_api/
├── app/
│   ├── Console/             # Console commands
│   ├── Exceptions/          # Exception handlers
│   ├── Http/
│   │   ├── Controllers/     # API controllers
│   │   │   ├── AuthController.php
│   │   │   ├── ChatController.php
│   │   │   ├── TarotController.php
│   │   │   ├── HoroscopeController.php
│   │   │   ├── FocusController.php
│   │   │   ├── UserController.php
│   │   │   └── SubscriptionController.php
│   │   ├── Middleware/      # Request middleware
│   │   └── Requests/        # Form requests
│   ├── Models/              # Eloquent models
│   │   ├── User.php
│   │   ├── Subscription.php
│   │   ├── SubscriptionPlan.php
│   │   ├── ChatConversation.php
│   │   ├── ChatMessage.php
│   │   ├── TarotReading.php
│   │   ├── TarotCard.php
│   │   ├── DailyHoroscope.php
│   │   ├── FocusSession.php
│   │   └── UserPreference.php
│   ├── Services/            # Business logic services
│   │   ├── AstrologyService.php
│   │   ├── TarotService.php
│   │   ├── AIService.php
│   │   └── PaymentService.php
│   └── Repositories/        # Data access layer
├── config/                  # Configuration files
├── database/
│   ├── migrations/          # Database migrations
│   └── seeders/             # Database seeders
├── routes/
│   ├── api.php              # API routes
│   └── web.php              # Web routes
├── storage/                 # File storage
├── tests/                   # Automated tests
└── composer.json            # Dependencies
```

## 📝 Step-by-Step Development Plan

### Phase 1: Project Setup & Foundation (Weeks 1-2)

#### Step 1: Environment Setup
1. **Day 1-2: Development Environment**
   - Install Flutter SDK and required dependencies
   - Set up Laravel development environment
   - Configure version control (Git)
   - Set up project repositories
   - Configure CI/CD pipelines

2. **Day 3-4: Project Scaffolding**
   - Initialize Flutter project with recommended architecture
   - Create Laravel project with API structure
   - Set up Supabase database
   - Configure Firebase authentication
   - Establish project coding standards and documentation

3. **Day 5: Design System Foundation**
   - Define color palette variables
   - Create typography scale
   - Establish spacing system
   - Design component library structure

#### Step 2: Core Infrastructure
1. **Day 6-7: Database Implementation**
   - Create database migrations for core tables
   - Implement database models and relationships
   - Set up database seeders for testing
   - Configure database backup strategy

2. **Day 8-9: Authentication System**
   - Implement Firebase authentication integration
   - Create user registration and login API endpoints
   - Develop authentication middleware
   - Set up secure token management

3. **Day 10: API Foundation**
   - Establish API structure and versioning
   - Implement API response standards
   - Create error handling middleware
   - Set up API documentation with Swagger/OpenAPI

### Phase 2: Core Features Development (Weeks 3-6)

#### Step 3: User Interface Foundations
1. **Day 11-13: Theme & Navigation**
   - Implement dark theme with cosmic design
   - Create navigation system and route management
   - Develop shared UI components
   - Build animation system for transitions

2. **Day 14-16: Welcome & Authentication Screens**
   - Design and implement welcome screen with animations
   - Create sign-up flow with birth data collection
   - Build login screen with validation
   - Implement guest mode access

3. **Day 17-19: Dashboard Structure**
   - Design main dashboard layout
   - Implement bottom navigation
   - Create user profile section
   - Build settings interface

#### Step 4: Astrology Core Features
1. **Day 20-22: Zodiac System**
   - Implement zodiac sign calculation logic
   - Create zodiac sign data models and assets
   - Build zodiac profile visualization
   - Develop planetary position calculations

2. **Day 23-25: Horoscope System**
   - Create daily horoscope generation system
   - Implement horoscope API endpoints
   - Build horoscope display components
   - Develop horoscope notification system

3. **Day 26-28: User Profile & Preferences**
   - Implement user profile management
   - Create preferences system
   - Build theme customization options
   - Develop language switching functionality

#### Step 5: Tarot Reading System
1. **Day 29-31: Tarot Card Database**
   - Create tarot card database with meanings
   - Implement card imagery and assets
   - Build card selection algorithms
   - Develop card relationship logic

2. **Day 32-34: Tarot Reading Interface**
   - Design tarot reading screens
   - Implement card shuffling animations
   - Create spread layout system
   - Build reading interpretation display

3. **Day 35-37: Reading Interpretation System**
   - Implement AI interpretation generation
   - Create reading history storage
   - Build reading sharing functionality
   - Develop reading favorites system

### Phase 3: AI Integration & Advanced Features (Weeks 7-10)

#### Step 6: AI Chatbot Implementation
1. **Day 38-40: Anthropic API Integration**
   - Set up Anthropic API connection
   - Implement prompt engineering for astrology
   - Create conversation management system
   - Build response formatting for Thai language

2. **Day 41-43: Chat Interface**
   - Design chat interface with cosmic theme
   - Implement message bubbles and typing indicators
   - Create preset question system
   - Build conversation history management

3. **Day 44-46: AI Response Enhancement**
   - Implement astrological context injection
   - Create visualization generation for responses
   - Build response caching system
   - Develop fallback mechanisms for API failures

#### Step 7: Focus Mode Development
1. **Day 47-49: Focus Mode Interface**
   - Design distraction-free environment
   - Implement meditation timer
   - Create cosmic soundscape system
   - Build focus session tracking

2. **Day 50-52: Meditation Features**
   - Implement guided meditation scripts
   - Create breathing exercise animations
   - Build progress tracking
   - Develop personalized insights generation

3. **Day 53-55: Focus Analytics**
   - Implement session statistics
   - Create visualization of meditation progress
   - Build streak and achievement system
   - Develop personalized recommendations

#### Step 8: Premium Features & Monetization
1. **Day 56-58: Subscription System**
   - Implement subscription plans and tiers
   - Create payment processing integration
   - Build subscription management interface
   - Develop feature gating system

2. **Day 59-61: Advanced Astrology Features**
   - Implement birth chart analysis
   - Create compatibility calculation system
   - Build detailed aspect interpretation
   - Develop personalized forecasts

3. **Day 62-64: Premium UI Enhancements**
   - Create premium-exclusive animations
   - Implement advanced visualization options
   - Build ad-free experience
   - Develop premium user recognition

### Phase 4: Optimization & Launch Preparation (Weeks 11-12)

#### Step 9: Performance Optimization
1. **Day 65-67: Frontend Optimization**
   - Implement lazy loading for assets
   - Optimize animation performance
   - Reduce memory footprint
   - Improve startup time

2. **Day 68-70: Backend Optimization**
   - Implement API caching
   - Optimize database queries
   - Set up load balancing
   - Configure auto-scaling

3. **Day 71-73: Thai Language Optimization**
   - Fine-tune Thai text rendering
   - Optimize Thai language AI responses
   - Improve Thai language input handling
   - Enhance Thai language assets

#### Step 10: Testing & Launch
1. **Day 74-76: Comprehensive Testing**
   - Conduct unit and integration testing
   - Perform user acceptance testing
   - Test on various device configurations
   - Validate localization quality

2. **Day 77-79: Pre-launch Preparation**
   - Prepare app store listings
   - Create marketing materials
   - Configure analytics tracking
   - Set up user feedback channels

3. **Day 80-84: Launch & Initial Support**
   - Submit to app stores
   - Monitor initial user feedback
   - Address critical issues
   - Implement quick improvements based on feedback

### Phase 5: Post-Launch Improvements (Ongoing)

#### Step 11: Analytics & Optimization
1. **Week 13: User Behavior Analysis**
   - Analyze user engagement patterns
   - Identify feature usage statistics
   - Measure conversion rates
   - Track retention metrics

2. **Week 14: Performance Tuning**
   - Address performance bottlenecks
   - Optimize high-usage features
   - Reduce API latency
   - Improve battery efficiency

#### Step 12: Feature Expansion
1. **Week 15-16: Community Features**
   - Implement user profiles
   - Create reading sharing functionality
   - Build community forums
   - Develop friend connections

2. **Week 17-18: Expert Consultation**
   - Create expert astrologer profiles
   - Implement booking system
   - Build video consultation interface
   - Develop expert rating system

## 🚀 Future Roadmap

- **Live Consultation:** Real-time video/audio sessions with astrology experts
- **Compatibility Analysis:** Relationship insights based on astrological profiles
- **Guided Practices:** Daily affirmations and meditation routines
- **Community Features:** Share readings and connect with like-minded users

---

## 📝 Development Guidelines

- Optimize all text rendering for Thai language display
- Train AI models with Thai astrology terminology and cultural context
- Maintain consistent dark theme implementation across all screens
- Ensure smooth animation performance across device specifications
- Implement comprehensive analytics to track user engagement patterns

---

*This document serves as the central reference for the development team to understand the application vision, feature requirements, and implementation priorities.*
