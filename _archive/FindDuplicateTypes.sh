#!/bin/bash
# FindDuplicateTypes.sh
# Search for MovieSortCriteria definitions across the project

echo "🔍 Searching for MovieSortCriteria definitions..."
echo "================================================"

cd "T:/AI/Hey Kids Watch This/Real/HeyKidsWatchThis"

echo "📁 Searching in Swift files..."
find . -name "*.swift" -exec grep -l "MovieSortCriteria" {} \;

echo ""
echo "📄 Detailed occurrences:"
find . -name "*.swift" -exec grep -n "MovieSortCriteria" {} \;

echo ""
echo "🔍 Searching for 'enum MovieSort'..."
find . -name "*.swift" -exec grep -n "enum MovieSort" {} \;

echo ""
echo "🔍 Searching for any enum with 'Sort' in name..."
find . -name "*.swift" -exec grep -n "enum.*Sort" {} \;

echo ""
echo "✅ Search complete"
