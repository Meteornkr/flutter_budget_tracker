// screens/transactions_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import 'add_edit_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Transactions',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Transaction>('transactions').listenable(),
              builder: (context, Box<Transaction> box, _) {
                if (box.values.isEmpty) {
                  return const Center(child: Text('No transactions yet.'));
                }
                
                final filteredTransactions = box.values.where((transaction) {
                  final titleLower = transaction.title.toLowerCase();
                  final searchLower = _searchQuery.toLowerCase();
                  return titleLower.contains(searchLower);
                }).toList();
                
                filteredTransactions.sort((a, b) => b.date.compareTo(a.date));

                return ListView.builder(
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return _buildTransactionItem(transaction);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddEditTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final categoriesBox = Hive.box<Category>('categories');
    final category = categoriesBox.values.firstWhere((c) => c.id == transaction.categoryId, orElse: () => Category(id: 'other', name: 'Other', colorValue: Colors.grey.value));
    final color = transaction.isExpense ? Colors.red : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(category.colorValue).withOpacity(0.2),
          child: Icon(Icons.category, color: Color(category.colorValue)),
        ),
        title: Text(transaction.title),
        subtitle: Text(
            '${category.name} - ${DateFormat.yMMMd().format(transaction.date)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddEditTransactionScreen(transaction: transaction),
            ),
          );
        },
        onLongPress: () => _deleteTransaction(transaction),
      ),
    );
  }

  void _deleteTransaction(Transaction transaction) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              transaction.delete();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}