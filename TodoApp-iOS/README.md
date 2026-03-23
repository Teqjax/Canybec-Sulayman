# TodoApp for iPhone

A native iOS todo app built with SwiftUI. Requires a Mac with Xcode to build and deploy.

## Requirements

- **Mac** with Xcode 15 or later
- **iPhone** running iOS 16 or later (iPhone Air supported)
- Apple ID (free — no paid developer account needed for personal device)

## How to Run on Your iPhone

### 1. Clone the repo and open the project

```
open TodoApp-iOS/TodoApp.xcodeproj
```

Or double-click `TodoApp.xcodeproj` in Finder.

### 2. Sign the app

1. In Xcode, click **TodoApp** in the Project Navigator (left sidebar)
2. Select the **TodoApp** target
3. Go to the **Signing & Capabilities** tab
4. Check **Automatically manage signing**
5. Set **Team** to your Apple ID (add it via Xcode → Settings → Accounts if needed)

### 3. Connect your iPhone

- Plug your iPhone into your Mac via USB
- Tap **Trust** on your iPhone when prompted
- Select your iPhone from the device picker in Xcode's toolbar

### 4. Run the app

Press **⌘R** or click the **▶ Run** button.

### 5. Trust the developer certificate (first time only)

On your iPhone:
**Settings → General → VPN & Device Management → [Your Apple ID] → Trust**

The app will then launch and stay on your device.

---

## Features

| Feature | How |
|---|---|
| Add a task | Tap the **+** button |
| Complete a task | Tap the circle next to it |
| Delete a task | Swipe left on any row |
| Filter tasks | Use **All / Active / Done** tabs |
| Clear finished tasks | Tap **Clear Done** in the top-right |
| Offline & persistent | Tasks saved locally — no internet needed |

## Project Structure

```
TodoApp-iOS/
├── TodoApp.xcodeproj/       ← open this in Xcode
└── TodoApp/
    ├── TodoApp.swift        ← app entry point
    ├── ContentView.swift    ← all views
    ├── TodoItem.swift       ← data model
    ├── TodoStore.swift      ← state & persistence
    └── Assets.xcassets/     ← icons & colors
```
