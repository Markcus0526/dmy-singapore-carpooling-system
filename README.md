# Singapore Carpooling System

A full-stack carpooling mobile application for Singapore that connects passengers heading in the same direction to share taxi rides and save costs.

## Project Overview

This is a comprehensive carpooling platform that includes:
- **iOS App** - Native iOS application (Objective-C)
- **Android App** - Native Android application
- **Web Backend** - ASP.NET MVC web portal
- **Service Backend** - WCF RESTful API service
- **Database** - SQL Server database

## Architecture

```
├── Android/          # Android native application
├── Database/         # SQL Server database files
├── iOS/              # iOS native application (Objective-C)
├── Service/          # WCF RESTful API service
└── Web/              # ASP.NET MVC web portal
```

## Features

### Core Functionality
- **User Registration & Authentication** - Email and Facebook login support
- **Carpool Matching** - Match passengers heading to similar destinations
- **Taxi Stand Locator** - Find nearby taxi stands
- **Destination Search** - Search and select destinations
- **Credit System** - Manage ride credits
- **Pairing History** - View past carpool trips
- **User Ratings** - Rate and review carpool partners
- **Real-time Matching** - Match found notifications

### User Preferences
- Gender preference for grouping (male, female, no preference)
- Delay time tolerance
- Grouping preferences

## Technology Stack

### iOS Client
- **Language**: Objective-C
- **UI**: XIB-based views
- **Networking**: AFNetworking, ASIHTTPRequest
- **Libraries**: 
  - SBJSON (JSON parsing)
  - Reachability (network status)
  - LinkedIn API integration
  - Pull-to-refresh (SVPullToRefresh)

### Android Client
- **Language**: Java
- **Platform**: Android SDK
- **Features**: OAuth authentication

### Backend
- **Web Framework**: ASP.NET MVC 4
- **Service Framework**: WCF (Windows Communication Foundation)
- **Database ORM**: LINQ to SQL
- **Protocol**: RESTful JSON API

### Database
- **DBMS**: SQL Server
- **ORM**: LINQ to SQL (DbMetal)

## Database Schema

### Core Tables

| Table | Description |
|-------|-------------|
| `tbl_user` | User accounts and profile information |
| `tbl_dest` | Destination/landmark database |
| `tbl_queue` | Active carpool queue entries |
| `tbl_serve` | Service/pairing records |
| `tbl_sharelog` | Trip sharing logs |
| `tbl_smslog` | SMS notification records |
| `tbl_taxistand` | Taxi stand locations |
| `tbl_admin` | Admin user accounts |

### User Profile Fields
- Name, Gender, Birth Year
- Phone Number, Email
- Credits, Total Savings
- Registration Date
- Gender Preference for Grouping
- Delay Time Tolerance
- Profile Image

## API Endpoints (WCF Service)

### Authentication
- `RequestRegister` - User registration
- `RequestLogin` - Email login
- `RequestFLLogin` - Facebook login
- `IsValidUser` - Validate credentials
- `RequestResetPassword` - Password reset

### Pairing
- `RequestPair` - Request carpool pairing
- `RequestIsPaired` - Check pairing status
- `RequestPairOff` - Cancel pairing
- `RequestPairAgree` - Agree to pairing

### User Management
- `RequestUserProfile` - Get user profile
- `RequestUserProfileUpdate` - Update profile
- `RequestUserCredits` - Get credit balance

### Locations
- `RequestTaxiStand` - Get nearby taxi stands
- `RequestTaxiStandList` - Get all taxi stands
- `GetDestList` - Search destinations

### History & Ratings
- `RequestPairingHistoryList` - Get pairing history
- `RequestEvaluate` - Rate a carpool partner

### Utilities
- `RequestSendSMS` - Send SMS notifications
- `GetSharable` - Get shareable info
- `RequestShareLog` - Log sharing data

## iOS App Structure

### View Controllers
- `LoginViewController` / `SignInViewController` - Authentication
- `RegisterViewController` - New user registration
- `MatchingViewController` - Find carpool matches
- `MatchFoundViewController` - Display match results
- `ProfileViewController` / `MyInfoViewController` - User profiles
- `CheckInViewController` - Check in for rides
- `OnBoardViewController` - Board confirmation
- `HistoryViewController` - Trip history
- `CreditViewController` / `BuyCreditsViewController` - Credit management
- `RouteViewController` - Route display
- `DestFindViewController` - Destination search
- `RatingViewController` - Rate partners
- `FriendViewController` - Friends list
- `HelpViewController` - Help & support

### Common Components
- `SuperViewController` - Base controller class
- `SlideMenuView` - Side menu navigation
- `Common` - Shared utilities

## Building & Running

### Prerequisites
- **iOS**: Xcode 5+, iOS SDK 5+
- **Android**: Android SDK, Eclipse/Android Studio
- **Backend**: .NET Framework 4.0+, IIS 7+
- **Database**: SQL Server 2008+

### Database Setup
1. Restore `Database/Database.rar` to SQL Server
2. Update connection strings in:
   - `Service/CarPoolService/Web.config`
   - `Web/CarPool/Web.config`

### Service Setup
1. Open `Service/CarPoolService.sln` in Visual Studio
2. Build and deploy to IIS
3. Configure URL endpoints in Web.config

### Web Portal Setup
1. Open `Web/CarPool.sln` in Visual Studio
2. Build and deploy to IIS

### iOS App Setup
1. Open `iOS/CarPool.xcodeproj` in Xcode
2. Update API endpoints in `Common.m`
3. Build and run on simulator/device

### Android App Setup
1. Import `Android/` project to Eclipse/Android Studio
2. Update API endpoints in source code
3. Build and install APK

## Test Account

```
Email: gamesbird@gmail.com
Password: a123456789A
```


## License

This project appears to be proprietary software. All rights reserved.

## Version

- Last Updated: 2013
- Status: Legacy/Historical Project

