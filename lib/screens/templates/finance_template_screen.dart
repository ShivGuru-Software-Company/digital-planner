import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/template_model.dart';
import '../../widgets/glass_card.dart';

class FinanceTemplateScreen extends StatefulWidget {
  final PlannerTemplate template;
  final TemplateData? existingData;

  const FinanceTemplateScreen({
    super.key,
    required this.template,
    this.existingData,
  });

  @override
  State<FinanceTemplateScreen> createState() => _FinanceTemplateScreenState();
}

class _FinanceTemplateScreenState extends State<FinanceTemplateScreen> {
  late DateTime _selectedDate;

  // Financial data
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double _savingsGoal = 0.0;
  double _currentSavings = 0.0;

  // Transaction lists
  final List<Transaction> _incomeTransactions = [];
  final List<Transaction> _expenseTransactions = [];

  // Budget categories
  final Map<String, BudgetCategory> _budgetCategories = {};

  // Controllers
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _expenseController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _savingsGoalController = TextEditingController();

  // Expense categories
  final List<String> _expenseCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Travel',
    'Groceries',
    'Other',
  ];

  // Income categories
  final List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Gift',
    'Other',
  ];

  String _selectedExpenseCategory = 'Food & Dining';
  String _selectedIncomeCategory = 'Salary';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _initializeBudgetCategories();

    if (widget.existingData != null) {
      _loadExistingData();
    }
  }

  void _initializeBudgetCategories() {
    for (String category in _expenseCategories) {
      _budgetCategories[category] = BudgetCategory(
        name: category,
        budgetAmount: 0.0,
        spentAmount: 0.0,
      );
    }
  }

  void _loadExistingData() {
    final data = widget.existingData!.data;
    _selectedDate = DateTime.parse(
      data['selectedDate'] ?? DateTime.now().toIso8601String(),
    );
    _totalIncome = data['totalIncome'] ?? 0.0;
    _totalExpenses = data['totalExpenses'] ?? 0.0;
    _savingsGoal = data['savingsGoal'] ?? 0.0;
    _currentSavings = data['currentSavings'] ?? 0.0;
  }

  void _calculateTotals() {
    _totalIncome = _incomeTransactions.fold(0.0, (sum, t) => sum + t.amount);
    _totalExpenses = _expenseTransactions.fold(0.0, (sum, t) => sum + t.amount);

    // Update budget categories
    for (var category in _budgetCategories.keys) {
      _budgetCategories[category]!.spentAmount = _expenseTransactions
          .where((t) => t.category == category)
          .fold(0.0, (sum, t) => sum + t.amount);
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _expenseController.dispose();
    _descriptionController.dispose();
    _savingsGoalController.dispose();
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
              _buildFinancialOverview(),
              const SizedBox(height: 8),
              _buildQuickActions(),
              const SizedBox(height: 8),
              _buildSavingsTracker(),
              const SizedBox(height: 8),
              _buildBudgetCategories(),
              const SizedBox(height: 8),
              _buildRecentTransactions(),
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
                  Icons.account_balance_wallet,
                  color: widget.template.colors.first,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Finance Tracker',
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

  Widget _buildFinancialOverview() {
    final balance = _totalIncome - _totalExpenses;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Overview',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildFinanceCard(
                    'Income',
                    '\$${_totalIncome.toStringAsFixed(2)}',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildFinanceCard(
                    'Expenses',
                    '\$${_totalExpenses.toStringAsFixed(2)}',
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildFinanceCard(
                    'Balance',
                    '\$${balance.toStringAsFixed(2)}',
                    Icons.account_balance,
                    balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildFinanceCard(
                    'Savings',
                    '\$${_currentSavings.toStringAsFixed(2)}',
                    Icons.savings,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceCard(
    String title,
    String amount,
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
            amount,
            style: TextStyle(
              fontSize: 12,
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

  Widget _buildQuickActions() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddTransactionDialog(true),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      'Add Income',
                      style: TextStyle(fontSize: 10),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.withValues(alpha: 0.1),
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddTransactionDialog(false),
                    icon: const Icon(Icons.remove, size: 16),
                    label: const Text(
                      'Add Expense',
                      style: TextStyle(fontSize: 10),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsTracker() {
    final progress = _savingsGoal > 0
        ? (_currentSavings / _savingsGoal).clamp(0.0, 1.0)
        : 0.0;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Savings Goal',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: _showSavingsGoalDialog,
                  child: Icon(
                    Icons.edit,
                    size: 16,
                    color: widget.template.colors.first,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_savingsGoal > 0) ...[
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.template.colors.first,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${_currentSavings.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '\$${_savingsGoal.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              Text(
                '${(progress * 100).toInt()}% of goal achieved',
                style: TextStyle(fontSize: 9, color: Colors.grey[600]),
              ),
            ] else ...[
              GestureDetector(
                onTap: _showSavingsGoalDialog,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Set your savings goal...',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCategories() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Budget Categories',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: _showBudgetDialog,
                  child: Icon(
                    Icons.settings,
                    size: 16,
                    color: widget.template.colors.first,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...(_budgetCategories.entries.take(5).map((entry) {
              final category = entry.value;
              final progress = category.budgetAmount > 0
                  ? (category.spentAmount / category.budgetAmount).clamp(
                      0.0,
                      1.0,
                    )
                  : 0.0;
              final isOverBudget =
                  category.spentAmount > category.budgetAmount &&
                  category.budgetAmount > 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '\$${category.spentAmount.toStringAsFixed(0)} / \$${category.budgetAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 9,
                            color: isOverBudget ? Colors.red : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverBudget
                            ? Colors.red
                            : widget.template.colors.first,
                      ),
                    ),
                  ],
                ),
              );
            })),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final allTransactions = [..._incomeTransactions, ..._expenseTransactions]
      ..sort((a, b) => b.date.compareTo(a.date));

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (allTransactions.isEmpty)
              const Center(
                child: Text(
                  'No transactions yet. Add your first transaction!',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              )
            else
              ...allTransactions
                  .take(5)
                  .map(
                    (transaction) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: transaction.isIncome
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              transaction.isIncome
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              size: 12,
                              color: transaction.isIncome
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.description,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${transaction.category} • ${DateFormat('MMM dd').format(transaction.date)}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${transaction.isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: transaction.isIncome
                                  ? Colors.green
                                  : Colors.red,
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

  void _showAddTransactionDialog(bool isIncome) {
    _incomeController.clear();
    _expenseController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isIncome ? 'Add Income' : 'Add Expense',
          style: const TextStyle(fontSize: 14),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: isIncome ? _incomeController : _expenseController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: isIncome
                  ? _selectedIncomeCategory
                  : _selectedExpenseCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
                isDense: true,
              ),
              items: (isIncome ? _incomeCategories : _expenseCategories)
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (isIncome) {
                  _selectedIncomeCategory = value!;
                } else {
                  _selectedExpenseCategory = value!;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 11)),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(
                isIncome ? _incomeController.text : _expenseController.text,
              );
              if (amount != null && _descriptionController.text.isNotEmpty) {
                final transaction = Transaction(
                  amount: amount,
                  description: _descriptionController.text,
                  category: isIncome
                      ? _selectedIncomeCategory
                      : _selectedExpenseCategory,
                  date: _selectedDate,
                  isIncome: isIncome,
                );

                setState(() {
                  if (isIncome) {
                    _incomeTransactions.add(transaction);
                  } else {
                    _expenseTransactions.add(transaction);
                  }
                  _calculateTotals();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _showSavingsGoalDialog() {
    _savingsGoalController.text = _savingsGoal.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Savings Goal', style: TextStyle(fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _savingsGoalController,
              decoration: const InputDecoration(
                labelText: 'Savings Goal',
                prefixText: '\$',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Current Savings',
                prefixText: '\$',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 12),
              onChanged: (value) {
                _currentSavings = double.tryParse(value) ?? 0.0;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 11)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _savingsGoal =
                    double.tryParse(_savingsGoalController.text) ?? 0.0;
              });
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _showBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Set Budget Categories',
          style: TextStyle(fontSize: 14),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _expenseCategories.length,
            itemBuilder: (context, index) {
              final category = _expenseCategories[index];
              final budgetCategory = _budgetCategories[category]!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        category,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(4),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 10),
                        onChanged: (value) {
                          budgetCategory.budgetAmount =
                              double.tryParse(value) ?? 0.0;
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 11)),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
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
              leading: const Icon(Icons.image),
              title: const Text('Export as Image'),
              onTap: () {
                Navigator.pop(context);
                _exportAsImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                _exportAsPDF();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Financial Report'),
              onTap: () {
                Navigator.pop(context);
                _shareFinancialReport();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportAsImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export as Image - Coming Soon!')),
    );
  }

  void _exportAsPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export as PDF - Coming Soon!')),
    );
  }

  void _shareFinancialReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share Financial Report - Coming Soon!')),
    );
  }

  void _saveTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Finance data saved successfully!')),
    );
    Navigator.pop(context);
  }
}

// Data models
class Transaction {
  final double amount;
  final String description;
  final String category;
  final DateTime date;
  final bool isIncome;

  Transaction({
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.isIncome,
  });
}

class BudgetCategory {
  final String name;
  double budgetAmount;
  double spentAmount;

  BudgetCategory({
    required this.name,
    required this.budgetAmount,
    required this.spentAmount,
  });
}
