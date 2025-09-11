# Phase 3: Core Features Development - Development Request Document

## 📋 Project Context
Building upon the successfully completed Phase 2 UI implementation (see PHASE2_IMPLEMENTATION.md), this document outlines requirements for Phase 3, focusing on core learning features including the step-ordering game, advanced flashcard functionality, learning statistics, and complete recipe data integration.

## 🎯 Phase 3 Objectives
Implement core learning features that transform the app from a simple viewer into an interactive learning tool, including gamification elements, progress tracking, and the complete 33-recipe dataset.

## ⏱️ Timeline
**Estimated Duration**: 4-5 days
- Day 1: Complete Recipe Data Integration (33 recipes)
- Day 2-3: Step Ordering Game Implementation
- Day 4: Advanced Flashcard Features & Learning Statistics
- Day 5: Testing, Polish & Data Validation

## 📱 Detailed Requirements

### 1. Complete Recipe Data Integration (Priority: CRITICAL)

#### 1.1 Data Conversion & Validation
**Current State**: 3 sample recipes  
**Target State**: All 33 Korean Cuisine Certification recipes

**Required Recipe List**:
```
밥류 (2): 비빔밥, 콩나물밥
죽류 (1): 장국죽
탕류 (1): 완자탕
찌개류 (2): 두부젓국찌개, 생선찌개
구이류 (5): 제육구이, 너비아니구이, 더덕구이, 생선양념구이, 북어구이
전류 (4): 육원전, 표고전, 생선전, 풋고추전
조림류 (2): 두부조림, 홍합초
적류 (3): 섭산적, 화양적, 지짐누름적
생채류 (4): 무생채, 더덕생채, 도라지생채, 겨자채
무침류 (2): 탕평채, 잡채
회류 (2): 육회, 미나리강회
숙채류 (2): 칠절판, 오징어볶음
김치류 (2): 배추김치, 오이소박이
기타 (1): 재료썰기
```

#### 1.2 Data Structure Enhancement
```json
{
  "recipes": [
    {
      "id": 1,
      "name": "비빔밥",
      "category": "밥류",
      "examTime": 50,
      "difficulty": 3, // NEW: 1-5 scale
      "ingredients": [...],
      "requirements": [...],
      "steps": [
        {
          "order": 1,
          "description": "밥을 고슬고슬하게 짓기",
          "keyPoint": "물 조절 중요", // NEW: Key memorization point
          "timeEstimate": 15 // NEW: Minutes for this step
        }
      ],
      "tips": [ // NEW: Exam tips
        "다시마는 수분 차단 필수",
        "재료 볶는 순서 암기"
      ],
      "commonMistakes": [ // NEW: Common exam mistakes
        "약고추장 농도 실수",
        "다시마 고명 빠뜨림"
      ]
    }
  ]
}
```

#### 1.3 Data Validation Requirements
- Verify all 33 recipes are included
- Ensure Korean text encoding (UTF-8)
- Validate step order continuity
- Check category assignments
- Confirm exam time accuracy
- Test special characters in recipe names

### 2. Step Ordering Game Implementation (Priority: HIGH)

#### 2.1 Game Screen Structure
```
┌────────────────────────┐
│    [Recipe Name]       │
│   "순서 맞추기 게임"    │
├────────────────────────┤
│                        │
│   [Shuffled Steps]     │
│   ┌──────────────┐     │
│   │ Step Card 3  │     │
│   └──────────────┘     │
│   ┌──────────────┐     │
│   │ Step Card 1  │     │
│   └──────────────┘     │
│   ┌──────────────┐     │
│   │ Step Card 2  │     │
│   └──────────────┘     │
│                        │
│   [Check Answer]       │
└────────────────────────┘
```

#### 2.2 Game Mechanics
**Game Flow**:
1. User selects recipe from home screen or dedicated game menu
2. Recipe steps are shuffled randomly
3. User drags and drops to reorder steps
4. Submit answer for validation
5. Show result with visual feedback
6. Update mastery level based on performance

**Drag & Drop Implementation**:
```dart
class DraggableStepCard extends StatelessWidget {
  // Requirements:
  - Visual feedback during drag (elevation, opacity)
  - Smooth reordering animation (300ms)
  - Auto-scroll when dragging near edges
  - Clear drop zones between cards
  - Haptic feedback on reorder
}
```

#### 2.3 Visual Design
```dart
// Step Card Design
Container(
  margin: EdgeInsets.symmetric(vertical: 8),
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: isCorrect ? Colors.green : Colors.grey[300],
      width: 2,
    ),
    boxShadow: [/* shadow */],
  ),
  child: Row(
    children: [
      // Drag handle icon
      Icon(Icons.drag_handle),
      SizedBox(width: 12),
      // Step number badge (hidden in game mode)
      Container(/* Step number */),
      // Step description
      Expanded(child: Text(step.description)),
    ],
  ),
)
```

#### 2.4 Answer Validation & Feedback
```dart
// Success State
showDialog(
  title: "정답입니다! 🎉",
  content: "완벽하게 순서를 맞추셨습니다!",
  actions: [
    "다시 하기",
    "다음 레시피",
    "홈으로"
  ],
  // Update mastery level
  onSuccess: () => updateMastery(recipeId, +1),
)

// Failure State  
showDialog(
  title: "다시 도전하세요",
  content: "틀린 단계: Step 3과 Step 5",
  showCorrectOrder: true,
  actions: [
    "다시 시도",
    "정답 보기",
    "홈으로"
  ],
)
```

#### 2.5 Scoring System
```dart
class GameScoring {
  // Points calculation
  - First attempt correct: 100 points
  - Second attempt: 70 points
  - Third attempt: 40 points
  - Time bonus: -1 point per 10 seconds
  
  // Mastery level update
  - 3 consecutive correct: Level up
  - 2 failures: Level down (minimum 0)
  - Max mastery level: 5
}
```

### 3. Advanced Flashcard Features (Priority: HIGH)

#### 3.1 Study Modes
```dart
enum StudyMode {
  sequential,  // Original step-by-step
  random,      // Random step order
  hideSteps,   // Hide random steps for fill-in
  speedRun,    // Timed challenge
}
```

#### 3.2 Bookmark Collection Study
**Requirements**:
- "Study Bookmarks" button on bookmarks screen
- Sequential study through bookmarked recipes only
- Progress tracking within session
- Quick navigation between bookmarked items

#### 3.3 Smart Review System
```dart
class SmartReview {
  // Algorithm for spaced repetition
  List<Recipe> getReviewQueue() {
    // Priority order:
    1. Never studied (mastery = 0)
    2. Low mastery (1-2)
    3. Last studied > 3 days ago
    4. Failed recent game attempts
    5. Random selection from remaining
  }
  
  // Daily review suggestions
  int dailyGoal = 5; // recipes per day
  showDailyReviewPrompt();
}
```

#### 3.4 Flashcard Navigation Enhancement
```dart
// Quick actions bar
Row(
  children: [
    IconButton(icon: Icons.skip_previous, onPressed: previousRecipe),
    IconButton(icon: Icons.shuffle, onPressed: randomRecipe),
    IconButton(icon: Icons.skip_next, onPressed: nextRecipe),
    IconButton(icon: Icons.quiz, onPressed: startQuiz),
  ],
)
```

### 4. Learning Statistics & Progress Tracking (Priority: MEDIUM)

#### 4.1 Statistics Data Model
```dart
class LearningStatistics {
  int totalStudyTime;          // minutes
  int recipesStudied;          // count
  int recipesMastered;         // mastery level >= 4
  Map<int, int> studyCount;    // recipe_id: count
  Map<int, DateTime> lastStudied; // recipe_id: date
  List<GameResult> gameHistory;
  int currentStreak;           // days
  int longestStreak;           // days
  DateTime lastActiveDate;
}
```

#### 4.2 Progress Dashboard
Create new screen accessible from home screen app bar:

```
┌────────────────────────┐
│   학습 통계 Dashboard   │
├────────────────────────┤
│                        │
│ 📊 전체 진도: 15/33    │
│ ████████░░░░░░░ 45%    │
│                        │
│ 🏆 마스터: 8개         │
│ 📚 학습중: 7개         │
│ 📝 미학습: 18개        │
│                        │
│ 🔥 연속 학습: 5일      │
│ ⏱️ 총 학습시간: 3시간   │
│                        │
│ [카테고리별 진도]       │
│ 밥류: ████████ 100%    │
│ 죽류: ████░░░░ 50%     │
│ 탕류: ░░░░░░░░ 0%      │
│                        │
└────────────────────────┘
```

#### 4.3 Achievement System
```dart
class Achievements {
  static const achievements = [
    Achievement(
      id: 'first_recipe',
      title: '첫 걸음',
      description: '첫 레시피 학습 완료',
      icon: '🌱',
    ),
    Achievement(
      id: 'category_master',
      title: '카테고리 마스터',
      description: '한 카테고리 전체 마스터',
      icon: '👑',
    ),
    Achievement(
      id: 'week_streak',
      title: '열공 일주일',
      description: '7일 연속 학습',
      icon: '🔥',
    ),
    Achievement(
      id: 'game_perfect',
      title: '완벽한 기억',
      description: '게임 10회 연속 정답',
      icon: '🎯',
    ),
  ];
}
```

### 5. Recipe Comparison Feature (Priority: LOW)

#### 5.1 Comparison Screen
Allow comparing similar recipes side-by-side:

```dart
// Access from recipe card long-press menu
"비슷한 레시피 비교" -> Navigate to comparison

// Example: Compare 생채류 (무생채, 더덕생채, 도라지생채)
ComparisonScreen(
  recipes: [무생채, 더덕생채, 도라지생채],
  highlightDifferences: true,
)
```

#### 5.2 Comparison View Layout
```
┌─────────────────────────┐
│  생채류 3종 비교         │
├─────┬─────┬─────────────┤
│무생채│더덕생채│도라지생채 │
├─────┼─────┼─────────────┤
│15분  │20분   │15분       │ <- Time
├─────┼─────┼─────────────┤
│ 무   │더덕   │도라지      │ <- Main ingredient
│ 생강 │  -    │  -        │ <- Differences highlighted
│  -   │  -    │고추장      │
└─────┴─────┴─────────────┘
```

### 6. Data Export/Import (Priority: LOW)

#### 6.1 Backup User Progress
```dart
// Export learning data to JSON
Future<void> exportProgress() async {
  final data = {
    'exportDate': DateTime.now().toIso8601String(),
    'version': '1.0.0',
    'bookmarks': [...],
    'masteryLevels': {...},
    'statistics': {...},
  };
  
  // Save to device or share
  await shareFile(data);
}
```

## 🎮 Game Integration Points

### Navigation Updates
```dart
// Add game access points:
1. Home screen FAB: Quick game with random recipe
2. Recipe card menu: "게임으로 학습"
3. Flashcard screen: "순서 맞추기 게임" button
4. New tab: Dedicated games section (future)
```

### Provider Updates
```dart
class GameProvider extends ChangeNotifier {
  Recipe? currentRecipe;
  List<RecipeStep> shuffledSteps = [];
  List<RecipeStep> userOrderedSteps = [];
  int attempts = 0;
  int score = 0;
  GameState gameState = GameState.ready;
  
  void startGame(Recipe recipe);
  void reorderSteps(int oldIndex, int newIndex);
  bool checkAnswer();
  void resetGame();
  void nextRecipe();
}
```

## 📊 Success Metrics

### Performance Targets
- Game drag & drop: 60fps
- Step reordering: <100ms response
- Statistics calculation: <500ms
- Data validation: All 33 recipes load correctly

### Feature Completion Criteria
- ✅ All 33 recipes with complete data
- ✅ Step ordering game fully playable
- ✅ Drag & drop smooth on all devices
- ✅ Learning statistics tracking
- ✅ Smart review suggestions
- ✅ Achievement system working
- ✅ Progress persistence across sessions

## 🧪 Testing Requirements

### Data Validation
- [ ] All 33 recipes present and correct
- [ ] Step sequences logically ordered
- [ ] Korean text encoding proper
- [ ] Exam times accurate
- [ ] Categories correctly assigned

### Game Testing
- [ ] Drag & drop works on touch devices
- [ ] Reordering animation smooth
- [ ] Correct answer validation
- [ ] Score calculation accurate
- [ ] Mastery level updates properly

### Statistics Testing  
- [ ] Study time tracking accurate
- [ ] Streak calculation correct
- [ ] Progress percentages accurate
- [ ] Achievements unlock properly
- [ ] Data persists after app restart

## 📦 Deliverables

1. **Updated Recipe Data**
   - Complete 33-recipe JSON file
   - Data validation report
   - Migration script if needed

2. **Game Implementation**
   - Step ordering game screen
   - Drag & drop functionality
   - Score and mastery system

3. **Enhanced Features**
   - Smart review algorithm
   - Statistics dashboard
   - Achievement system
   - Comparison view (if time permits)

4. **Documentation**
   - Game rules and scoring
   - Statistics calculation methods
   - Data structure changes

## 🔄 Migration from Phase 2

### New Screens to Create
```
presentation/screens/game/step_order_game_screen.dart
presentation/screens/statistics/statistics_dashboard_screen.dart
presentation/screens/comparison/recipe_comparison_screen.dart
```

### New Widgets to Create
```
presentation/widgets/game/draggable_step_card.dart
presentation/widgets/game/game_result_dialog.dart
presentation/widgets/statistics/progress_chart.dart
presentation/widgets/statistics/achievement_badge.dart
```

### New Providers to Create
```
presentation/providers/game_provider.dart
presentation/providers/statistics_provider.dart
```

### Files to Update
```
assets/data/recipes.json - Add all 33 recipes
data/models/recipe.dart - Add new fields
data/models/learning_statistics.dart - New model
presentation/providers/recipe_provider.dart - Add game methods
```

## ⚠️ Critical Requirements

1. **Data Integrity**: All 33 recipes must be accurate for exam preparation
2. **Offline Functionality**: All features work without internet
3. **Performance**: Maintain 60fps during drag & drop
4. **State Persistence**: Progress must not be lost
5. **Backward Compatibility**: Existing bookmarks/progress preserved

## 📌 Dependencies to Add

```yaml
dependencies:
  # Existing from Phase 1 & 2...
  
  # New for Phase 3
  flutter_reorderable_list: ^1.0.0  # For drag & drop
  fl_chart: ^0.65.0  # For statistics charts
  confetti: ^0.7.0  # For celebration animations
  haptic_feedback: ^0.4.0  # For tactile feedback
  share_plus: ^7.2.0  # For data export
```

## 🚀 Implementation Priority

### Must Have (MVP)
1. Complete 33 recipe data
2. Step ordering game
3. Basic statistics tracking
4. Mastery level system

### Should Have
1. Smart review algorithm
2. Achievement system
3. Statistics dashboard
4. Study mode variations

### Nice to Have
1. Recipe comparison
2. Data export/import
3. Advanced animations
4. Sound effects

---

**Phase 3 Development Ready to Begin**  
**Estimated Completion**: 5 working days  
**Prerequisites**: Phase 2 complete ✅  
**Critical Path**: Recipe data integration → Game implementation → Statistics