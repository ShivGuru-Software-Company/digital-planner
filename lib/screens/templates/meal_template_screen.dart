import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/template_model.dart';
import '../../models/saved_template_model.dart';
import '../../database/database_helper.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/save_template_dialog.dart';


class MealTemplateScreen extends StatefulWidget {
  final PlannerTemplate template;
  final TemplateData? existingData;

  const MealTemplateScreen({
    super.key,
    required this.template,
    this.existingData,
  });

  @override
  State<MealTemplateScreen> createState() => _MealTemplateScreenState();
}

class _MealTemplateScreenState extends State<MealTemplateScreen> {
  late DateTime _selectedDate;

  // Meal controllers
  final Map<String, TextEditingController> _mealControllers = {};
  final Map<String, int> _caloriesData = {};
  final Map<String, List<String>> _ingredientsData = {};

  // Water and nutrition tracking
  int _waterIntake = 0;
  int _totalCalories = 0;

  // Meal types
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

  // Quick meal suggestions
  final Map<String, List<String>> _mealSuggestions = {
    'Breakfast': [
      'Oatmeal with berries',
      'Greek yogurt with granola',
      'Avocado toast',
      'Smoothie bowl',
      'Eggs and toast',
    ],
    'Lunch': [
      'Grilled chicken salad',
      'Quinoa bowl',
      'Sandwich and soup',
      'Pasta with vegetables',
      'Rice and curry',
    ],
    'Dinner': [
      'Grilled salmon with vegetables',
      'Chicken stir-fry',
      'Vegetable curry with rice',
      'Pasta with marinara',
      'Beef and broccoli',
    ],
    'Snacks': [
      'Mixed nuts',
      'Fresh fruit',
      'Yogurt',
      'Vegetable sticks with hummus',
      'Protein bar',
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _initializeControllers();

    if (widget.existingData != null) {
      _loadExistingData();
    }
  }

  void _initializeControllers() {
    for (String mealType in _mealTypes) {
      _mealControllers[mealType] = TextEditingController();
      _caloriesData[mealType] = 0;
      _ingredientsData[mealType] = [];
    }
  }

  void _loadExistingData() {
    final data = widget.existingData!.data;
    _selectedDate = DateTime.parse(
      data['selectedDate'] ?? DateTime.now().toIso8601String(),
    );
    _waterIntake = data['waterIntake'] ?? 0;

    for (String mealType in _mealTypes) {
      final mealData = data[mealType] as Map<String, dynamic>? ?? {};
      _mealControllers[mealType]!.text = mealData['meal'] ?? '';
      _caloriesData[mealType] = mealData['calories'] ?? 0;
      _ingredientsData[mealType] = List<String>.from(
        mealData['ingredients'] ?? [],
      );
    }
    _calculateTotalCalories();
  }

  void _calculateTotalCalories() {
    _totalCalories = _caloriesData.values.fold(
      0,
      (sum, calories) => sum + calories,
    );
  }

  @override
  void dispose() {
    for (var controller in _mealControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template.name),
        backgroundColor: widget.template.colors.first,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showExportMenu,
          ),
          IconButton(icon: const Icon(Icons.check), onPressed: _saveTemplate),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.template.colors.first.withValues(alpha: 0.1),
              widget.template.colors.last.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              _buildDateSection(),
              const SizedBox(height: 8),
              _buildNutritionOverview(),
              const SizedBox(height: 8),
              _buildWaterTracker(),
              const SizedBox(height: 8),
              ..._mealTypes.map(
                (mealType) => Column(
                  children: [
                    _buildMealSection(mealType),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restaurant,
                  color: widget.template.colors.first,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Meal Planner',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: widget.template.colors),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionOverview() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Nutrition Overview',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildNutritionCard(
                    'Total Calories',
                    _totalCalories.toString(),
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildNutritionCard(
                    'Water Intake',
                    '${_waterIntake * 250}ml',
                    Icons.water_drop,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildNutritionCard(
                    'Meals Planned',
                    '${_mealControllers.values.where((c) => c.text.isNotEmpty).length}/4',
                    Icons.restaurant_menu,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildNutritionCard(
                    'Goal Progress',
                    '${((_totalCalories / 2000) * 100).toInt()}%',
                    Icons.track_changes,
                    widget.template.colors.first,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 9, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTracker() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Water Intake Tracker',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(8, (index) {
                final isFilled = index < _waterIntake;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _waterIntake = index + 1;
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isFilled ? Colors.blue[400] : Colors.transparent,
                      border: Border.all(
                        color: isFilled ? Colors.blue[400]! : Colors.grey[400]!,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.water_drop,
                      color: isFilled ? Colors.white : Colors.grey[400],
                      size: 16,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                '${_waterIntake * 250}ml / 2000ml ($_waterIntake/8 glasses)',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(String mealType) {
    final controller = _mealControllers[mealType]!;
    final calories = _caloriesData[mealType] ?? 0;
    final ingredients = _ingredientsData[mealType] ?? [];

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getMealIcon(mealType),
                  color: widget.template.colors.first,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  mealType,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.template.colors.first,
                  ),
                ),
                const Spacer(),
                if (calories > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$calories cal',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'What are you having for $mealType?',
                hintStyle: const TextStyle(fontSize: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                isDense: true,
                suffixIcon: PopupMenuButton<String>(
                  icon: const Icon(Icons.restaurant_menu, size: 16),
                  onSelected: (value) {
                    controller.text = value;
                  },
                  itemBuilder: (context) => _mealSuggestions[mealType]!
                      .map(
                        (suggestion) => PopupMenuItem(
                          value: suggestion,
                          child: Text(
                            suggestion,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              style: const TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Calories',
                      hintStyle: const TextStyle(fontSize: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 10),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _caloriesData[mealType] = int.tryParse(value) ?? 0;
                        _calculateTotalCalories();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () => _showIngredientsDialog(mealType),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ingredients.isEmpty
                            ? 'Add ingredients...'
                            : '${ingredients.length} ingredients',
                        style: TextStyle(
                          fontSize: 10,
                          color: ingredients.isEmpty
                              ? Colors.grey[600]
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (ingredients.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 2,
                children: ingredients
                    .take(3)
                    .map(
                      (ingredient) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: widget.template.colors.first.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ingredient,
                          style: const TextStyle(fontSize: 8),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return Icons.free_breakfast;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Dinner':
        return Icons.dinner_dining;
      case 'Snacks':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  void _showIngredientsDialog(String mealType) {
    final ingredients = List<String>.from(_ingredientsData[mealType] ?? []);
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '$mealType Ingredients',
          style: const TextStyle(fontSize: 14),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Add ingredient...',
                        hintStyle: TextStyle(fontSize: 11),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(8),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        setState(() {
                          ingredients.add(controller.text);
                          controller.clear();
                        });
                      }
                    },
                    icon: const Icon(Icons.add, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) => ListTile(
                    dense: true,
                    title: Text(
                      ingredients[index],
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          ingredients.removeAt(index);
                        });
                      },
                      icon: const Icon(Icons.delete, size: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 11)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _ingredientsData[mealType] = ingredients;
              });
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _showExportMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Save to Gallery'),
              onTap: () {
                Navigator.pop(context);
                _saveToGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Meal Plan'),
              onTap: () {
                Navigator.pop(context);
                _shareMealPlan();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveToGallery() async {
    // TODO: Implement save to gallery functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Save to Gallery functionality will be implemented soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _shareMealPlan() async {
    // TODO: Implement share template functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share Template functionality will be implemented soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }



  Future<void> _saveTemplate() async {
    // Show save dialog to get custom name
    final customName = await _showSaveDialog();
    if (customName == null) return; // User cancelled

    await _performSave(customName);
  }

  Future<String?> _showSaveDialog() async {
    final defaultName =
        '${widget.template.name} - ${DateFormat('MMM dd').format(_selectedDate)}';

    return await Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            SaveTemplateDialog(defaultName: defaultName, templateType: 'Meal'),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _performSave(String customName) async {
    final data = {
      'selectedDate': _selectedDate.toIso8601String(),
      'waterIntake': _waterIntake,
      'totalCalories': _totalCalories,
    };

    // Add meal data
    for (String mealType in _mealTypes) {
      data[mealType] = {
        'meal': _mealControllers[mealType]!.text,
        'calories': _caloriesData[mealType] ?? 0,
        'ingredients': _ingredientsData[mealType] ?? [],
      };
    }

    try {
      final databaseHelper = DatabaseHelper();

      if (widget.existingData != null) {
        final existingTemplates = await databaseHelper.getAllSavedTemplates();
        final existingTemplate = existingTemplates.firstWhere(
          (t) =>
              t.templateId == widget.template.id &&
              t.updatedAt.day == _selectedDate.day &&
              t.updatedAt.month == _selectedDate.month &&
              t.updatedAt.year == _selectedDate.year,
          orElse: () => SavedTemplateModel.create(
            templateId: widget.template.id,
            templateName: customName,
            templateType: widget.template.type.name,
            templateDesign: widget.template.design.name,
            templateColors: widget.template.colors,
            templateIcon: widget.template.icon,
            data: data,
          ),
        );

        final updatedTemplate = existingTemplate.copyWith(
          templateName: customName,
          data: data,
          updatedAt: DateTime.now(),
        );

        await databaseHelper.updateSavedTemplate(updatedTemplate);
      } else {
        final savedTemplate = SavedTemplateModel.create(
          templateId: widget.template.id,
          templateName: customName,
          templateType: widget.template.type.name,
          templateDesign: widget.template.design.name,
          templateColors: widget.template.colors,
          templateIcon: widget.template.icon,
          data: data,
        );

        await databaseHelper.insertSavedTemplate(savedTemplate);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Template "$customName" saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving template: $e')));
      }
    }
  }
}
