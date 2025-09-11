import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';

void main() async {
  await convertCsvToJson();
}

Future<void> convertCsvToJson() async {
  try {
    // Read CSV file
    final input = File('/mnt/c/Projects/hansickcookcook/CookingManual/MENU_manual.csv');
    final csvString = await input.readAsString();
    
    // Parse CSV with Korean character handling
    final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);
    
    // Skip header rows (first 2 rows)
    final List<Map<String, dynamic>> recipes = [];
    
    for (int i = 2; i < csvData.length; i++) {
      final row = csvData[i];
      
      // Skip empty rows
      if (row.isEmpty || row[0] == null || row[0].toString().trim().isEmpty) {
        continue;
      }
      
      // Parse ingredients
      List<String> ingredients = [];
      if (row.length > 3 && row[3] != null) {
        String ingredientText = row[3].toString();
        // Split by bullet points and clean up
        ingredients = ingredientText
            .split('•')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      
      // Parse requirements
      List<String> requirements = [];
      if (row.length > 4 && row[4] != null) {
        String requirementText = row[4].toString();
        // Split by bullet points and clean up
        requirements = requirementText
            .split('•')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      
      // Parse exam time
      int examTime = 30; // default
      if (row.length > 5 && row[5] != null) {
        String timeText = row[5].toString();
        try {
          examTime = int.parse(timeText.replaceAll(RegExp(r'[^0-9]'), ''));
        } catch (e) {
          examTime = 30;
        }
      }
      
      // Parse steps
      List<Map<String, dynamic>> steps = [];
      int stepOrder = 1;
      
      // Steps start from column 6 (index 6)
      for (int j = 6; j < row.length; j++) {
        if (row[j] != null && row[j].toString().trim().isNotEmpty) {
          String stepDescription = row[j].toString().trim();
          
          steps.add({
            'order': stepOrder,
            'description': stepDescription,
          });
          stepOrder++;
        }
      }
      
      // Create recipe object
      final recipe = {
        'id': int.tryParse(row[0].toString()) ?? i - 1,
        'name': row[1]?.toString().trim() ?? '',
        'category': row[2]?.toString().trim() ?? '',
        'ingredients': ingredients,
        'requirements': requirements,
        'examTime': examTime,
        'steps': steps,
        'bookmarked': false,
        'masteryLevel': 0,
      };
      
      // Only add if name is not empty
      if (recipe['name'].toString().isNotEmpty) {
        recipes.add(recipe);
      }
    }
    
    // Create JSON structure
    final jsonOutput = {
      'version': '1.0.0',
      'lastUpdated': DateTime.now().toIso8601String(),
      'totalCount': recipes.length,
      'recipes': recipes,
    };
    
    // Ensure assets directory exists
    final outputDir = Directory('/mnt/c/Projects/hansickcookcook/assets/data');
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }
    
    // Write JSON file
    final outputFile = File('/mnt/c/Projects/hansickcookcook/assets/data/recipes.json');
    await outputFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(jsonOutput),
    );
    
    print('✅ Conversion completed successfully!');
    print('📊 Total recipes converted: ${recipes.length}');
    print('📁 Output file: ${outputFile.path}');
    
    // Print first recipe as sample
    if (recipes.isNotEmpty) {
      print('\n📋 Sample recipe:');
      print('Name: ${recipes[0]['name']}');
      print('Category: ${recipes[0]['category']}');
      print('Exam Time: ${recipes[0]['examTime']}분');
      print('Ingredients count: ${(recipes[0]['ingredients'] as List).length}');
      print('Steps count: ${(recipes[0]['steps'] as List).length}');
    }
    
  } catch (e, stackTrace) {
    print('❌ Error during conversion: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}