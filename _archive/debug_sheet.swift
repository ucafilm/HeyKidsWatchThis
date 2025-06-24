// Debug Sheet Issue
// This script helps identify the white screen problem

print("🔍 Debugging White Screen Issue")
print("="*40)

print("\n📊 Analysis:")
print("- White screen in sheet suggests view rendering failure")
print("- Could be missing dependencies or SwiftUI state issues")
print("- Replaced complex scheduler with minimal test sheet")

print("\n🧪 Test Strategy:")
print("1. Minimal sheet with basic NavigationView")
print("2. Simple VStack with Text and Button")
print("3. Standard toolbar with Done button")
print("4. Direct showingMovieScheduler = false for dismissal")

print("\n✅ Expected Results:")
print("- Test sheet should show movie title")
print("- Close and Done buttons should dismiss sheet")
print("- No white screen should appear")
print("- Console should show debug messages")

print("\n🔄 Next Steps if Test Works:")
print("1. Gradually add back scheduler features")
print("2. Test each component individually")
print("3. Identify what causes the white screen")
print("4. Create working scheduler incrementally")

print("\n⚠️ If Test Still Shows White Screen:")
print("- Issue is with sheet presentation mechanism")
print("- May need to check TabView or NavigationStack conflicts")
print("- Could be environment or state management issue")

print("\n📝 Debug Output to Watch:")
print("- '🔄 scheduleMovie called for: [Movie Title]'")
print("- '🔄 selectedMovie set to: [Movie Title]'") 
print("- '🔄 showingMovieScheduler set to: true'")

print("\n🎯 Test this minimal version first!")
