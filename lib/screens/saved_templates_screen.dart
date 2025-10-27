import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/saved_template_model.dart';
import '../widgets/glass_card.dart';
import 'templates/daily_template_screen.dart';
import 'templates/weekly_template_screen.dart';
import 'templates/monthly_template_screen.dart';
import 'templates/yearly_template_screen.dart';
import 'templates/meal_template_screen.dart';
import 'templates/mood_template_screen.dart';
import '../models/template_model.dart';

class SavedTemplatesScreen extends StatefulWidget {
  const SavedTemplatesScreen({super.key});

  @override
  State<SavedTemplatesScreen> createState() => _SavedTemplatesScreenState();
}

class _SavedTemplatesScreenState extends State<SavedTemplatesScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<SavedTemplateModel> _savedTemplates = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  final List<String> _filterOptions = [
    'All',
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
    'Meal',
    'Mood',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedTemplates();
  }

  Future<void> _loadSavedTemplates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final templates = await _databaseHelper.getAllSavedTemplates();
      setState(() {
        _savedTemplates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading templates: $e')));
      }
    }
  }

  List<SavedTemplateModel> get _filteredTemplates {
    if (_selectedFilter == 'All') {
      return _savedTemplates;
    }
    return _savedTemplates
        .where(
          (template) =>
              template.templateType.toLowerCase() ==
              _selectedFilter.toLowerCase(),
        )
        .toList();
  }

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
              _buildFilters(),
              Expanded(child: _buildTemplatesList()),
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
                'Saved Templates',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_filteredTemplates.length} saved templates',
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
            child: const Icon(Icons.bookmark, color: Color(0xFF6366F1)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _filterOptions.length,
          itemBuilder: (context, index) {
            final filter = _filterOptions[index];
            final isSelected = _selectedFilter == filter;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
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
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTemplatesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
        ),
      );
    }

    if (_filteredTemplates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 'All'
                  ? 'No saved templates yet'
                  : 'No ${_selectedFilter.toLowerCase()} templates saved',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create and save templates to see them here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSavedTemplates,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _filteredTemplates.length,
        itemBuilder: (context, index) {
          final template = _filteredTemplates[index];
          return _buildTemplateCard(template);
        },
      ),
    );
  }

  Widget _buildTemplateCard(SavedTemplateModel template) {
    return GestureDetector(
      onTap: () => _openTemplate(template),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Template Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: template.templateColors),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    template.templateIcon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Template Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.templateName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: template.templateColors.first.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${template.templateType} • ${template.templateDesign}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: template.templateColors.first,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Updated ${DateFormat('MMM dd, yyyy').format(template.updatedAt)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // More Options
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, template),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'export_png',
                      child: Row(
                        children: [
                          Icon(Icons.image, size: 16),
                          SizedBox(width: 8),
                          Text('Export as PNG'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'export_pdf',
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf, size: 16),
                          SizedBox(width: 8),
                          Text('Export as PDF'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share, size: 16),
                          SizedBox(width: 8),
                          Text('Share'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  child: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action, SavedTemplateModel template) {
    switch (action) {
      case 'edit':
        _openTemplate(template);
        break;
      case 'export_png':
        _exportAsPNG(template);
        break;
      case 'export_pdf':
        _exportAsPDF(template);
        break;
      case 'share':
        _shareTemplate(template);
        break;
      case 'delete':
        _deleteTemplate(template);
        break;
    }
  }

  void _openTemplate(SavedTemplateModel savedTemplate) {
    // Create a PlannerTemplate from SavedTemplateModel
    final plannerTemplate = PlannerTemplate(
      id: savedTemplate.templateId,
      name: savedTemplate.templateName,
      description: 'Saved ${savedTemplate.templateType} Template',
      type: _getTemplateType(savedTemplate.templateType),
      design: _getTemplateDesign(savedTemplate.templateDesign),
      icon: savedTemplate.templateIcon,
      colors: savedTemplate.templateColors,
      previewImage: '',
    );

    // Create TemplateData from saved data
    final templateData = TemplateData(
      id: savedTemplate.id,
      date: savedTemplate.updatedAt,
      data: savedTemplate.data,
      createdAt: savedTemplate.createdAt,
      updatedAt: savedTemplate.updatedAt,
    );

    Widget screen;
    switch (savedTemplate.templateType.toLowerCase()) {
      case 'daily':
        screen = DailyTemplateScreen(
          template: plannerTemplate,
          existingData: templateData,
        );
        break;
      case 'weekly':
        screen = WeeklyTemplateScreen(
          template: plannerTemplate,
          existingData: templateData,
        );
        break;
      case 'monthly':
        screen = MonthlyTemplateScreen(
          template: plannerTemplate,
          existingData: templateData,
        );
        break;
      case 'yearly':
        screen = YearlyTemplateScreen(
          template: plannerTemplate,
          existingData: templateData,
        );
        break;
      case 'meal':
        screen = MealTemplateScreen(
          template: plannerTemplate,
          existingData: templateData,
        );
        break;
      case 'mood':
        screen = MoodTemplateScreen(
          template: plannerTemplate,
          existingData: templateData,
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Template type not supported')),
        );
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  TemplateType _getTemplateType(String type) {
    switch (type.toLowerCase()) {
      case 'daily':
        return TemplateType.daily;
      case 'weekly':
        return TemplateType.weekly;
      case 'monthly':
        return TemplateType.monthly;
      case 'yearly':
        return TemplateType.yearly;
      case 'meal':
        return TemplateType.meal;
      case 'mood':
        return TemplateType.mood;
      default:
        return TemplateType.daily;
    }
  }

  TemplateDesign _getTemplateDesign(String design) {
    switch (design.toLowerCase()) {
      case 'minimal':
        return TemplateDesign.minimal;
      case 'colorful':
        return TemplateDesign.colorful;
      case 'elegant':
        return TemplateDesign.elegant;
      default:
        return TemplateDesign.minimal;
    }
  }

  void _exportAsPNG(SavedTemplateModel template) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export as PNG - Coming Soon!')),
    );
  }

  void _exportAsPDF(SavedTemplateModel template) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export as PDF - Coming Soon!')),
    );
  }

  void _shareTemplate(SavedTemplateModel template) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share Template - Coming Soon!')),
    );
  }

  void _deleteTemplate(SavedTemplateModel template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text(
          'Are you sure you want to delete "${template.templateName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _databaseHelper.deleteSavedTemplate(template.id);
                await _loadSavedTemplates();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Template deleted successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting template: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
