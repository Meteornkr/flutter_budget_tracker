// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import 'dart:math';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Transaction>('transactions').listenable(),
        builder: (context, Box<Transaction> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text('No transactions yet.'));
          }

          double totalIncome = box.values
              .where((t) => !t.isExpense)
              .fold(0, (sum, item) => sum + item.amount);
          double totalExpense = box.values
              .where((t) => t.isExpense)
              .fold(0, (sum, item) => sum + item.amount);
          double balance = totalIncome - totalExpense;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSummaryCard(totalIncome, totalExpense, balance),
              const SizedBox(height: 20),
              const Text('Expense Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildPieChart(box),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
      double income, double expense, double balance) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryRow('Total Income', income, Colors.green),
            const Divider(),
            _buildSummaryRow('Total Expense', expense, Colors.red),
            const Divider(),
            _buildSummaryRow(
                'Balance', balance, balance >= 0 ? Colors.blue : Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildPieChart(Box<Transaction> box) {
    final categoriesBox = Hive.box<Category>('categories');
    if (categoriesBox.isEmpty) _addDefaultCategories();

    Map<String, double> expenseByCategory = {};
    box.values.where((t) => t.isExpense).forEach((transaction) {
      expenseByCategory.update(
        transaction.categoryId,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    });

    if (expenseByCategory.isEmpty) {
        return const SizedBox(
            height: 200,
            child: Center(child: Text("No expense data for chart."))
        );
    }

    List<PieChartSectionData> sections =
        expenseByCategory.entries.map((entry) {
      final category = categoriesBox.values
          .firstWhere((c) => c.id == entry.key, orElse: () => Category(id: 'other', name: 'Other', colorValue: Colors.grey.value));
      return PieChartSectionData(
        color: Color(category.colorValue),
        value: entry.value,
        title: category.name,
        radius: 100,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: sections,
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
  
  void _addDefaultCategories() {
    final categoriesBox = Hive.box<Category>('categories');
    if (categoriesBox.isEmpty) {
      categoriesBox.add(Category(id: 'food', name: 'Food', colorValue: Colors.orange.value));
      categoriesBox.add(Category(id: 'transport', name: 'Transport', colorValue: Colors.blue.value));
      categoriesBox.add(Category(id: 'shopping', name: 'Shopping', colorValue: Colors.purple.value));
      categoriesBox.add(Category(id: 'bills', name: 'Bills', colorValue: Colors.red.value));
      categoriesBox.add(Category(id: 'entertainment', name: 'Entertainment', colorValue: Colors.green.value));
      categoriesBox.add(Category(id: 'salary', name: 'Salary', colorValue: Colors.lightGreen.value));
    }
  }
}