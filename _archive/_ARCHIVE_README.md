# Archive Organization Guide

## WHAT WAS MOVED AND WHY

### Files Moved to Archive (2024-06-22):

**Development Scripts (.sh files)** - ✅ APPROPRIATE IN ARCHIVE
- These were build automation scripts used during TDD development
- Not needed for production app
- Safely archived for reference

**Experimental Code Files** - ✅ APPROPRIATE IN ARCHIVE  
- MinimalApp.swift, TestApp.swift - Testing different app structures
- BasicMovieService.swift - Early service iterations
- Various fix validation files - Debugging and fix testing

**Fix & Diagnostic Files** - ✅ APPROPRIATE IN ARCHIVE
- build_test.swift, debug_sheet.swift - Development testing
- pthread_fix_validation.swift - Threading issue diagnosis  
- surgical_fix_validation.swift - Latest fix validation
- All other *_fix_*.swift files - Bug fix development

## CURRENT CLEAN STRUCTURE

```
HeyKidsWatchThis/
├── HeyKidsWatchThis/           <- MAIN APP CODE ONLY
├── HeyKidsWatchThis.xcodeproj/ <- XCODE PROJECT
├── HeyKidsWatchThisTests/      <- UNIT TESTS
├── HeyKidsWatchThisUITests/    <- UI TESTS
└── _archive/                   <- ALL EXPERIMENTAL/OLD FILES
```

## PROBLEMS THIS SOLVED

1. **Xcode Indexing**: No more confusion from loose Swift files
2. **Import Conflicts**: Removed multiple App entry points
3. **Build Issues**: Clean separation of production vs development code
4. **Navigation**: Easy to find actual source files
5. **Source Control**: Clean working directory

## MAINTENANCE RULES

✅ **DO:**
- Keep main source in HeyKidsWatchThis/ folder
- Archive experimental files immediately  
- Use proper test targets for tests

❌ **DON'T:**
- Create loose files in project root
- Keep multiple App entry points in main source
- Mix production and development code

The .sh scripts in archive are build automation tools from our TDD process - they're safely stored but not cluttering the main project.
