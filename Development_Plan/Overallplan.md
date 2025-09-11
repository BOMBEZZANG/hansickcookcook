# Development Request Document: Korean Cuisine Certification Recipe Memorization App (MVP)

## Project Overview
Development of a Flutter-based mobile application to help users memorize recipes for the Korean Cuisine Certification (한식조리기능사) practical exam. The app will focus on efficient recipe memorization through flashcards and visual learning techniques.

## Technical Specifications
- **Framework**: Flutter (latest stable version)
- **Platform**: Cross-platform (iOS & Android)
- **Data Storage**: Local device storage only (no server/backend required)
- **State Management**: Provider pattern
- **Data Format**: JSON (converted from existing CSV)

## Core Features for MVP

### 1. Home Screen - Learning Dashboard
**Requirements:**
- Display all 33 recipes in a **grid layout** (3 columns recommended)
- Each grid item shows:
  - Recipe name
  - Category icon
  - Category-specific background color
  - Visual indicator for bookmarked items
  - Mastery level indicator (optional for MVP)
- **Tap action**: Navigate to flashcard screen for selected recipe
- **Category color coding** must be visually distinct
- Grid items should be responsive to different screen sizes

### 2. Flashcard Screen - Recipe Memorization
**Requirements:**
- **Card Structure** (in order):
  1. Recipe Name (always visible at top)
  2. Exam Time Limit (e.g., "30분")
  3. Ingredients (collapsible dropdown)
  4. Exam Requirements (collapsible dropdown)
  5. Recipe Steps (main focus area)

- **Step-by-Step Display Logic**:
  - Initially show ONLY the first recipe step
  - User taps anywhere on the card to reveal the next step
  - Each tap adds the next step below the previous one
  - Steps remain visible once revealed (cumulative display)
  - After showing all steps, provide option to reset or move to next recipe
  
- **Visual Design**:
  - Ingredients and Requirements sections should be **collapsible dropdowns** to minimize visual clutter
  - Recipe steps should have maximum visual prominence
  - Clear step numbering (Step 1, Step 2, etc.)
  - Smooth animation when revealing new steps

- **Bookmark Feature**:
  - Star icon in top-right corner for bookmarking
  - Bookmarked state persists in local storage

### 3. Search Functionality
**Requirements:**
- **Search criteria**:
  - Recipe name (partial match supported)
  - Ingredient name
  - Category name
- **Search bar** accessible from home screen
- **Real-time search** results as user types
- Search results displayed in same grid format as home screen
- Clear button to reset search

### 4. Bookmarks/Favorites Screen
**Requirements:**
- Dedicated screen showing ONLY bookmarked recipes
- Same grid layout as home screen
- Empty state message when no bookmarks exist
- Quick access from bottom navigation or app bar
- Option to remove bookmark directly from this screen

### 5. Visual Design System

#### Category Color Coding
Each category must have a unique, distinguishable color:

```
- 밥류 (Rice dishes): #FFA726 (Orange)
- 죽류 (Porridge): #FFD54F (Yellow)
- 탕류 (Soups): #EF5350 (Red)
- 찌개류 (Stews): #E53935 (Deep Red)
- 구이류 (Grilled dishes): #8D6E63 (Brown)
- 전류 (Pan-fried dishes): #FFB74D (Light Orange)
- 조림류 (Braised dishes): #795548 (Dark Brown)
- 생채류 (Fresh vegetables): #66BB6A (Green)
- 무침류 (Seasoned vegetables): #4CAF50 (Dark Green)
- 회류 (Raw dishes): #42A5F5 (Blue)
- 적류 (Skewered dishes): #EF9A9A (Pink)
- 숙채류 (Blanched vegetables): #81C784 (Light Green)
- 김치류 (Kimchi): #FF7043 (Red-Orange)
```

#### Icon System
- Each category should have an intuitive emoji or icon
- Icons should be consistent in size and style
- Examples: 🍚 for rice, 🥘 for stew, 🔥 for grilled, etc.

## Data Migration Requirements

### CSV to JSON Conversion
**Current Data Location**: `C:\Projects\hansickcookcook\CookingManual\MENU_manual.csv`

**Required JSON Structure**:
```json
{
  "recipes": [
    {
      "id": 1,
      "name": "비빔밥",
      "category": "밥류",
      "examTime": 50,
      "ingredients": ["쌀", "소고기", "고사리", ...],
      "requirements": [
        "재료분리 주의",
        "다시마 수분 차단"
      ],
      "steps": [
        {
          "order": 1,
          "description": "밥을 고슬고슬하게 짓기"
        },
        {
          "order": 2,
          "description": "고사리 불려서 양념하기"
        }
      ]
    }
  ]
}
```

**Conversion Requirements**:
- Parse CSV file and extract all recipe data
- Separate recipe steps into individual array items
- Ensure Korean text encoding (UTF-8) is preserved
- Validate all 33 recipes are included
- Store converted JSON in `assets/data/recipes.json`

## Navigation Structure
```
- Home Screen (Grid View)
  ├── Flashcard Screen
  ├── Search Screen
  └── Bookmarks Screen
- Bottom Navigation (3 tabs):
  ├── Home
  ├── Search  
  └── Bookmarks
```

## Local Storage Requirements
Using **SharedPreferences** to store:
- Bookmarked recipe IDs
- User progress (optional for MVP)
- Last viewed recipe (optional for MVP)

## UI/UX Requirements
- **Material Design 3** guidelines
- Smooth animations for card transitions
- Responsive design for various screen sizes
- Korean font support (Noto Sans KR recommended)
- Minimum tap target size: 48x48 dp
- Loading states for data fetching
- Error handling with user-friendly messages

## Performance Requirements
- App launch time: < 3 seconds
- Smooth scrolling in grid view (60 fps)
- Instant search results (< 100ms)
- Minimal memory footprint

## Deliverables
1. Complete Flutter source code
2. APK for Android testing
3. iOS build (if applicable)
4. Brief documentation for:
   - Project structure
   - How to update recipe data
   - Build instructions

## Development Priorities (MVP)
1. **High Priority**:
   - Home screen with grid layout
   - Flashcard functionality with step-by-step reveal
   - Bookmark feature
   - Data conversion from CSV to JSON

2. **Medium Priority**:
   - Search functionality
   - Category color coding
   - Dedicated bookmarks screen

3. **Future Enhancements** (Post-MVP):
   - Quiz/Game features
   - Progress tracking
   - Spaced repetition algorithm
   - Recipe comparison feature
   - Study statistics

## Testing Requirements
- Test on minimum 2 Android devices (different screen sizes)
- Verify all 33 recipes display correctly
- Test bookmark persistence after app restart
- Ensure Korean text renders properly
- Validate search functionality with various inputs

## Timeline Estimate
Suggested MVP development timeline: 2-3 weeks
- Week 1: Core UI and navigation
- Week 2: Flashcard logic and bookmark feature
- Week 3: Search, polish, and testing

## Additional Notes
- The app should work completely offline
- No user authentication required
- No analytics or tracking needed for MVP
- Focus on simplicity and usability over complex features

---
MVP Development Phases📊 Overall Development Phases Overview

## PHASE 1: Foundation & Data Setup (3-4 days)

Project initialization and architecture setup
Data migration (CSV to JSON)
Core data models and repository implementation
Basic navigation structure

## PHASE 2: Core UI Implementation (4-5 days)

Home screen with grid layout
Category color system implementation
Basic flashcard screen UI
Bottom navigation setup

## PHASE 3: Core Features Development (4-5 days)

Flashcard step-by-step logic
Bookmark functionality
Local storage integration
State management implementation

## PHASE 4: Additional Features (3-4 days)

Search functionality
Bookmarks dedicated screen
UI polish and animations
Error handling

## PHASE 5: Testing & Deployment (2-3 days)

Comprehensive testing
Bug fixes
Performance optimization
Build preparation


**Contact for Clarification**: [Your contact information]
**Project Repository**: [GitHub/GitLab link if applicable]