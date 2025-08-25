// screens/add_edit_budget_screen.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/budget.dart';
import '../models/category.dart';

class AddEditBudgetScreen extends StatefulWidget {
  final Budget? budget;
  const AddEditBudgetScreen({super.key, this.budget});

  @override
  _AddEditBudgetScreenState createState() => _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends State<AddEditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedCategoryId;
  late double _limit;
  late String _period;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _selectedCategoryId = widget.budget!.categoryId;
      _limit = widget.budget!.limit;
      _period = widget.budget!.period;
    } else {
      _selectedCategoryId = 'food';
      _limit = 0.0;
      _period = 'Monthly';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget == null ? 'Add Budget' : 'Edit Budget'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
              TextFormField(
                initialValue: _limit.toString(),
                decoration: const InputDecoration(labelText: 'Limit'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid limit';
                  }
                  return null;
                },
                onSaved: (value) => _limit = double.parse(value!),
              ),
              DropdownButtonFormField<String>(
                value: _period,
                items: ['Weekly', 'Monthly', 'Annual']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _period = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Period'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                child: const Text('Save Budget'),
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

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final budgetsBox = Hive.box<Budget>('budgets');
      if (widget.budget == null) {
        final newBudget = Budget(
          id: const Uuid().v4(),
          categoryId: _selectedCategoryId,
          limit: _limit,
          period: _period,
        );
        budgetsBox.add(newBudget);
      } else {
        widget.budget!.categoryId = _selectedCategoryId;
        widget.budget!.limit = _limit;
        widget.budget!.period = _period;
        widget.budget!.save();
      }
      Navigator.of(context).pop();
    }
  }
}