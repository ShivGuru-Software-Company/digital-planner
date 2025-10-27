import 'package:flutter/material.dart';
import '../models/template_model.dart';
import '../utils/template_data.dart';
import '../widgets/glass_card.dart';
import 'templates/daily_template_screen.dart';
import 'templates/weekly_template_screen.dart';
import 'templates/monthly_template_screen.dart';
import 'templates/yearly_template_screen.dart';

class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({super.key});

  @override
  State<TemplateSelectionScreen> createState() =>
      _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  TemplateType? _selectedType;
  TemplateDesign? _selectedDesign;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FA), Color(0xFFE0E7FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildFilters(),
              Expanded(child: _buildTemplateGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Template',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select your perfect planner style',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.palette_outlined, color: Color(0xFF6366F1)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search templates...',
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Color(0xFF6366F1)),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Template Type Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: TemplateType.values.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildFilterChip('All', _selectedType == null, () {
                    setState(() {
                      _selectedType = null;
                    });
                  });
                }

                final type = TemplateType.values[index - 1];
                final isSelected = _selectedType == type;

                return _buildFilterChip(
                  _getTypeDisplayName(type),
                  isSelected,
                  () {
                    setState(() {
                      _selectedType = isSelected ? null : type;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Design Filter
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: TemplateDesign.values.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildDesignChip(
                    'All Designs',
                    _selectedDesign == null,
                    () {
                      setState(() {
                        _selectedDesign = null;
                      });
                    },
                  );
                }

                final design = TemplateDesign.values[index - 1];
                final isSelected = _selectedDesign == design;

                return _buildDesignChip(
                  _getDesignDisplayName(design),
                  isSelected,
                  () {
                    setState(() {
                      _selectedDesign = isSelected ? null : design;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDesignChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.grey[300]!,
          ),
          color: isSelected
              ? const Color(0xFF6366F1).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF6366F1)
                : const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateGrid() {
    final templates = _getFilteredTemplates();

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return _buildTemplateCard(template);
      },
    );
  }

  Widget _buildTemplateCard(PlannerTemplate template) {
    return GestureDetector(
      onTap: () => _openTemplate(template),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: template.colors,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(template.icon, size: 48, color: Colors.white),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getDesignDisplayName(template.design),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        template.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PlannerTemplate> _getFilteredTemplates() {
    var templates = PlannerTemplateData.getAllTemplates();

    // Filter by type
    if (_selectedType != null) {
      templates = templates.where((t) => t.type == _selectedType).toList();
    }

    // Filter by design
    if (_selectedDesign != null) {
      templates = templates.where((t) => t.design == _selectedDesign).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      templates = templates
          .where(
            (t) =>
                t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                t.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return templates;
  }

  String _getTypeDisplayName(TemplateType type) {
    switch (type) {
      case TemplateType.daily:
        return 'Daily';
      case TemplateType.weekly:
        return 'Weekly';
      case TemplateType.monthly:
        return 'Monthly';
      case TemplateType.yearly:
        return 'Yearly';
      case TemplateType.meal:
        return 'Meal';
      case TemplateType.finance:
        return 'Finance';
      case TemplateType.mood:
        return 'Mood';
    }
  }

  String _getDesignDisplayName(TemplateDesign design) {
    switch (design) {
      case TemplateDesign.minimal:
        return 'Minimal';
      case TemplateDesign.colorful:
        return 'Colorful';
      case TemplateDesign.elegant:
        return 'Elegant';
    }
  }

  void _openTemplate(PlannerTemplate template) {
    Widget screen;

    switch (template.type) {
      case TemplateType.daily:
        screen = DailyTemplateScreen(template: template);
        break;
      case TemplateType.weekly:
        screen = WeeklyTemplateScreen(template: template);
        break;
      case TemplateType.monthly:
        screen = MonthlyTemplateScreen(template: template);
        break;
      case TemplateType.yearly:
        screen = YearlyTemplateScreen(template: template);
        break;
      case TemplateType.meal:
        // TODO: Implement meal template
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal template - Coming Soon!')),
        );
        return;
      case TemplateType.finance:
        // TODO: Implement finance template
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Finance template - Coming Soon!')),
        );
        return;
      case TemplateType.mood:
        // TODO: Implement mood template
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mood template - Coming Soon!')),
        );
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
