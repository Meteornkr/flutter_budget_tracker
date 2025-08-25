// screens/add_edit_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? transaction;
  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  _AddEditTransactionScreenState createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late double _amount;
  late DateTime _date;
  late String _selectedCategoryId;
  late bool _isExpense;

  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _title = widget.transaction!.title;
      _amount = widget.transaction!.amount;
      _date = widget.transaction!.date;
      _selectedCategoryId = widget.transaction!.categoryId;
      _isExpense = widget.transaction!.isExpense;
    } else {
      _title = '';
      _amount = 0.0;
      _date = DateTime.now();
      _selectedCategoryId = 'food';
      _isExpense = true;
    }
    _dateController.text = DateFormat.yMMMd().format(_date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _amount.toString(),
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                onSaved: (value) => _amount = double.parse(value!),
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _presentDatePicker,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                items: _getCategoryDropdownItems(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              SwitchListTile(
                title: Text(_isExpense ? 'Expense' : 'Income'),
                value: _isExpense,
                onChanged: (value) {
                  setState(() {
                    _isExpense = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                child: const Text('Save Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getCategoryDropdownItems() {
    final categoriesBox = Hive.box<Category>('categories');
    return categoriesBox.values.map((category) {
      return DropdownMenuItem(
        value: category.id,
        child: Text(category.name),
      );
    }).toList();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _date = pickedDate;
        _dateController.text = DateFormat.yMMMd().format(_date);
      });
    });
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final transactionsBox = Hive.box<Transaction>('transactions');
      if (widget.transaction == null) {
        final newTransaction = Transaction(
          id: const Uuid().v4(),
          title: _title,
          amount: _amount,
          date: _date,
          categoryId: _selectedCategoryId,
          isExpense: _isExpense,
        );
        transactionsBox.add(newTransaction);
      } else {
        widget.transaction!.title = _title;
        widget.transaction!.amount = _amount;
        widget.transaction!.date = _date;
        widget.transaction!.categoryId = _selectedCategoryId;
        widget.transaction!.isExpense = _isExpense;
        widget.transaction!.save();
      }
      Navigator.of(context).pop();
    }
  }
}