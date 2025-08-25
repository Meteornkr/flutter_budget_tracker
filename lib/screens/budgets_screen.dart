// screens/budgets_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import 'add_edit_budget_screen.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  _BudgetsScreenState createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Budget>('budgets').listenable(),
        builder: (context, Box<Budget> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text('No budgets set yet.'));
          }
          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              final budget = box.getAt(index)!;
              return _buildBudgetItem(budget);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditBudgetScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBudgetItem(Budget budget) {
    final categoriesBox = Hive.box<Category>('categories');
    final category = categoriesBox.values.firstWhere((c) => c.id == budget.categoryId);
    
    final transactionsBox = Hive.box<Transaction>('transactions');
    double spent = transactionsBox.values
        .where((t) => t.isExpense && t.categoryId == budget.categoryId && _isTransactionInBudgetPeriod(t, budget.period))
        .fold(0, (sum, item) => sum + item.amount);
        
    double progress = spent / budget.limit;
    if (progress > 1) progress = 1;
    if (progress < 0) progress = 0;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${category.name} (${budget.period})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddEditBudgetScreen(budget: budget)),
                    );
                  },
                )
              ],
            ),
            const SizedBox(height: 8),
            Text('Spent: \$${spent.toStringAsFixed(2)} of \$${budget.limit.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(progress > 0.8 ? Colors.red : Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  bool _isTransactionInBudgetPeriod(Transaction t, String period) {
    final now = DateTime.now();
    if (period == 'Weekly') {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      return t.date.isAfter(startOfWeek);
    } else if (period == 'Monthly') {
      return t.date.month == now.month && t.date.year == now.year;
    } else if (period == 'Annual') {
      return t.date.year == now.year;
    }
    return false;
  }
}