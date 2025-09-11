# Phase 2: Core UI Implementation - Development Request Document

## 📋 Project Context
Building upon the successfully completed Phase 1 foundation (see PHASE1_IMPLEMENTATION.md), this document outlines the requirements for Phase 2, focusing on implementing the core user interface components of the Korean Cuisine Certification Recipe Memorization App.

## 🎯 Phase 2 Objectives
Transform the placeholder screens into fully functional UI components with Material Design 3 principles, implementing the home screen grid layout, category visualization system, basic flashcard UI, and navigation structure.

## ⏱️ Timeline
**Estimated Duration**: 4-5 days
- Day 1-2: Home Screen & Grid Implementation
- Day 3: Bottom Navigation & Screen Integration  
- Day 4: Flashcard Screen Basic UI
- Day 5: Polish, Animations & Testing

## 📱 Detailed Requirements

### 1. Home Screen Implementation (Priority: HIGH)

#### 1.1 Grid Layout Requirements
```dart
// Expected Grid Configuration
- Columns: 3 for tablets, 2 for phones
- Aspect Ratio: 1:1 (square cards)
- Spacing: 12px between cards
- Padding: 16px screen edges
- Responsive: Adapt to screen orientation
```

#### 1.2 Recipe Card Widget
Create `widgets/recipe_card.dart` with following specifications:

**Visual Design:**
- **Background**: Category-specific color with 0.9 opacity
- **Border Radius**: 12px
- **Elevation**: 4dp with shadow
- **Ripple Effect**: On tap with category color at 0.2 opacity

**Content Layout:**
```
┌─────────────────────┐
│  [Category Icon]    │ <- 24px, centered
│                     │
│   Recipe Name       │ <- 14sp, bold, centered
│                     │
│  ⏱️ 30분  ⭐        │ <- Bottom row
└─────────────────────┘
```

**Required Elements:**
- Category emoji/icon (top center, 32x32)
- Recipe name (Korean text, max 2 lines, ellipsis overflow)
- Exam time with clock icon (bottom left)
- Bookmark star icon (bottom right, filled if bookmarked)
- Mastery level indicator (optional - subtle progress bar at bottom)

**Interactions:**
- **Tap**: Navigate to flashcard screen with hero animation
- **Long Press**: Show quick actions (bookmark toggle, info)
- **Bookmark Tap**: Toggle bookmark with animation

#### 1.3 Category Filter System
Implement horizontal scrollable filter chips above the grid:

```dart
// Filter Chip Specifications
- Height: 36px
- Horizontal scroll if overflow
- "전체" (All) chip always first
- Selected state: Filled with category color
- Unselected state: Outlined with category color
- Smooth animation on selection change (200ms)
```

#### 1.4 App Bar Design
```dart
AppBar(
  title: "한식조리기능사 레시피",
  actions: [
    // Search icon (navigate to search screen)
    // Filter icon (show/hide category filters)
  ],
  bottom: PreferredSize(
    // Progress indicator: "15/33 마스터"
  )
)
```

### 2. Bottom Navigation Implementation (Priority: HIGH)

#### 2.1 Navigation Structure
```dart
BottomNavigationBar with 3 items:
1. Home (홈) - Icons.home_rounded
2. Search (검색) - Icons.search_rounded  
3. Bookmarks (즐겨찾기) - Icons.bookmark_rounded

// Visual specifications
- Selected color: Primary color
- Unselected color: Grey 600
- Background: White with top border
- Label: Always show
- Animation: Fade transition between screens
```

#### 2.2 Navigation State Management
- Maintain scroll position when switching tabs
- Preserve filter selection in home screen
- Keep search query when returning to search

### 3. Flashcard Screen Basic UI (Priority: MEDIUM)

#### 3.1 Screen Layout Structure
```
┌────────────────────────┐
│      [App Bar]         │
│   Recipe Name          │
├────────────────────────┤
│                        │
│    [Card Container]    │
│                        │
│   ┌──────────────┐     │
│   │              │     │
│   │   Recipe     │     │
│   │   Content    │     │
│   │              │     │
│   └──────────────┘     │
│                        │
│   [Navigation Dots]    │
│                        │
└────────────────────────┘
```

#### 3.2 Flashcard Container Design
```dart
// Card specifications
Container(
  margin: EdgeInsets.all(20),
  padding: EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [subtle shadow],
  ),
  child: // Content based on current view
)
```

#### 3.3 Content Display States
Implement different views for flashcard content:

**State 1: Recipe Overview**
```
Recipe Name (Large, centered)
━━━━━━━━━━━━━━━━━━━━
⏱️ Exam Time: 30 minutes
📝 Category: 밥류
━━━━━━━━━━━━━━━━━━━━
[TAP TO START]
```

**State 2: Ingredients (Collapsible)**
```dart
ExpansionTile(
  title: "재료 (Ingredients)",
  initiallyExpanded: false,
  children: [
    // Chip layout for ingredients
  ]
)
```

**State 3: Requirements (Collapsible)**
```dart
ExpansionTile(
  title: "요구사항 (Requirements)",
  initiallyExpanded: false,
  children: [
    // Bullet list of requirements
  ]
)
```

**State 4: Recipe Steps (Main Focus)**
```
Step 1 of 8
━━━━━━━━━━━━━━━━━━━━
[Step Description]

[Tap anywhere to continue]
```

#### 3.4 Step Progression Logic
```dart
// Implementation requirements
- Initially show only Step 1
- Each tap reveals next step BELOW previous
- Steps remain visible (cumulative display)
- Smooth slide-in animation for new steps (300ms)
- Auto-scroll to new step
- Progress indicator at bottom
```

#### 3.5 Navigation Controls
```dart
// Bottom controls
Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    IconButton(icon: Icons.replay, onPressed: resetSteps),
    LinearProgressIndicator(value: currentStep / totalSteps),
    IconButton(icon: Icons.bookmark_border, onPressed: toggleBookmark),
  ]
)
```

### 4. Search Screen Basic UI (Priority: LOW)

#### 4.1 Search Bar Implementation
```dart
TextField(
  decoration: InputDecoration(
    prefixIcon: Icon(Icons.search),
    hintText: "레시피, 재료, 카테고리 검색",
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    filled: true,
    fillColor: Colors.grey[100],
  ),
  onChanged: (query) => provider.searchRecipes(query),
)
```

#### 4.2 Search Results Display
- Use same grid layout as home screen
- Show "No results" empty state
- Highlight matching text in results

### 5. Bookmarks Screen Basic UI (Priority: LOW)

#### 5.1 Layout Requirements
- Reuse home screen grid component
- Show only bookmarked recipes
- Empty state: "즐겨찾기한 레시피가 없습니다"
- Quick remove bookmark option

### 6. Shared Components to Create

#### 6.1 `widgets/common/loading_widget.dart`
```dart
// Centered circular progress with message
CircularProgressIndicator + "레시피 로딩 중..."
```

#### 6.2 `widgets/common/empty_state_widget.dart`
```dart
// Customizable empty state
- Icon
- Title
- Description  
- Optional action button
```

#### 6.3 `widgets/common/category_chip.dart`
```dart
// Reusable category filter chip
- Category name
- Category color
- Selected state
- Tap callback
```

## 🎨 Design Specifications

### Color Palette Extension
```dart
// Add to AppColors
static const Color cardShadow = Color(0x1A000000);
static const Color divider = Color(0xFFE0E0E0);
static const Color selectedChip = Color(0xFF2196F3);
static const Color progressBar = Color(0xFF4CAF50);
static const Color bookmarkActive = Color(0xFFFFC107);
```

### Animation Specifications
```dart
// Standard durations
static const Duration shortAnimation = Duration(milliseconds: 200);
static const Duration mediumAnimation = Duration(milliseconds: 300);
static const Duration longAnimation = Duration(milliseconds: 500);

// Curves
static const Curve defaultCurve = Curves.easeInOut;
static const Curve bounceCurve = Curves.elasticOut;
```

### Typography Extensions
```dart
// Text styles
static TextStyle cardTitle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
  height: 1.2,
);

static TextStyle cardSubtitle = TextStyle(
  fontSize: 12,
  color: Colors.grey[600],
);

static TextStyle stepText = TextStyle(
  fontSize: 16,
  height: 1.5,
);
```

## 📝 Implementation Checklist

### Day 1-2: Home Screen
- [ ] Create `RecipeCard` widget
- [ ] Implement responsive grid layout
- [ ] Add category filter chips
- [ ] Connect to RecipeProvider
- [ ] Implement bookmark toggle
- [ ] Add navigation to flashcard

### Day 3: Navigation
- [ ] Implement BottomNavigationBar
- [ ] Create navigation provider
- [ ] Setup page transitions
- [ ] Preserve screen states
- [ ] Add navigation animations

### Day 4: Flashcard UI
- [ ] Create flashcard container
- [ ] Implement step progression
- [ ] Add collapsible sections
- [ ] Create progress indicators
- [ ] Add bookmark control

### Day 5: Polish
- [ ] Add loading states
- [ ] Implement empty states
- [ ] Smooth animations
- [ ] Responsive testing
- [ ] Bug fixes

## 🧪 Testing Requirements

### Functional Testing
- [ ] Grid adapts to screen sizes (phone/tablet)
- [ ] Category filters work correctly
- [ ] Bookmark toggle persists
- [ ] Navigation maintains state
- [ ] Step progression works smoothly
- [ ] Search returns correct results

### UI/UX Testing
- [ ] Korean text displays properly
- [ ] Touch targets are 48dp minimum
- [ ] Animations are smooth (60fps)
- [ ] Color contrast meets accessibility standards
- [ ] Works in both orientations

### Device Testing
Test on minimum:
- [ ] Small phone (5.5")
- [ ] Large phone (6.5")
- [ ] Tablet (10")
- [ ] Both Android and iOS

## 📊 Success Metrics

### Performance Targets
- Grid scroll: 60fps
- Screen transition: <300ms
- Search response: <100ms
- Memory usage: <150MB

### Completion Criteria
- ✅ All 33 recipes display in grid
- ✅ Category colors applied correctly
- ✅ Bookmark state persists
- ✅ Navigation works smoothly
- ✅ Flashcard shows steps progressively
- ✅ Search filters recipes correctly
- ✅ Responsive on all screen sizes

## 🚀 Deliverables

1. **Updated Source Code**
   - All UI components implemented
   - Connected to existing providers
   - Proper state management

2. **Screenshots**
   - Home screen with grid
   - Flashcard screen states
   - Navigation examples
   - Different screen sizes

3. **Documentation Updates**
   - Widget documentation
   - UI component usage guide
   - Known issues/limitations

## 🔄 Migration from Phase 1

### Files to Update
```
- presentation/screens/home/home_screen.dart
- presentation/screens/flashcard/flashcard_screen.dart  
- presentation/screens/search/search_screen.dart
- presentation/screens/bookmarks/bookmarks_screen.dart
- app.dart (add bottom navigation)
```

### New Files to Create
```
- presentation/widgets/recipe_card.dart
- presentation/widgets/category_filter_chip.dart
- presentation/widgets/flashcard_content.dart
- presentation/widgets/common/loading_widget.dart
- presentation/widgets/common/empty_state_widget.dart
- presentation/providers/navigation_provider.dart
```

## ⚠️ Important Notes

1. **Maintain Phase 1 Architecture**: Don't modify core data layer
2. **Provider Pattern**: Use existing RecipeProvider, extend as needed
3. **Responsive Design**: Must work on phones and tablets
4. **Performance**: Lazy load images, optimize grid scrolling
5. **Accessibility**: Maintain touch targets, color contrast
6. **Error Handling**: Show appropriate error states

## 📌 Dependencies to Add

```yaml
dependencies:
  # Existing dependencies from Phase 1...
  
  # New for Phase 2
  flutter_staggered_grid_view: ^0.7.0  # For responsive grid
  animations: ^2.0.8  # For smooth transitions
  cached_network_image: ^3.3.1  # For image caching (future use)
```

---

**Phase 2 Development Ready to Begin**  
**Estimated Completion**: 5 working days  
**Prerequisites**: Phase 1 complete ✅