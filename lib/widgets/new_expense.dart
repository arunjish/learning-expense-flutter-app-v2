import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onAddExpense});

  final void Function(Expense expense) onAddExpense;

  @override
  State<NewExpense> createState() {
    return _NewExpenseState();
  }
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime? _selectedDate;
  Category _selectedCategory = Category.leisure;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    setState(() {
      _selectedDate = _selectedDate ?? DateTime.now();
    });

    return LayoutBuilder(builder: (ctx, constraints) {
      final width = constraints.maxWidth;

      return SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.fromLTRB(16, 48, 16, keyboardSpace + 16),
              child: Column(
                children: [
                  if (width > 600)
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _titleController,
                              maxLength: 50,
                              decoration:
                                  const InputDecoration(label: Text("Title")),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: const InputDecoration(
                                prefixText: '\$ ',
                                labelText: 'Amount',
                              ),
                            ),
                          ),
                        ])
                  else
                    TextField(
                      controller: _titleController,
                      maxLength: 50,
                      decoration: const InputDecoration(label: Text("Title")),
                    ),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          prefixText: '\$ ',
                          labelText: 'Amount',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(_selectedDate == null
                              ? 'No date selected'
                              : formatter.format(_selectedDate!)),
                          IconButton(
                              onPressed: _presentDatePicker,
                              icon: const Icon(Icons.calendar_month))
                        ],
                      ),
                    )
                  ]),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DropdownButton(
                          value: _selectedCategory,
                          items: Category.values
                              .map((c) => DropdownMenuItem(
                                  value: c, child: Text(c.name.toUpperCase())))
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _selectedCategory = value;
                            });
                          }),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                          onPressed: _submitExpenseData,
                          child: const Text('Save Expense'))
                    ],
                  )
                ],
              )),
        ),
      );
    });
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    var firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: firstDate,
        lastDate: now);
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _submitExpenseData() {
    final enteredAmount = double.tryParse(_amountController.text);
    final amountInvalid = enteredAmount == null || enteredAmount <= 0;
    if (amountInvalid ||
        _titleController.text.trim().isEmpty ||
        _selectedDate == null) {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Invalid input'),
              content: const Text(
                  'Please make sure a valid title, amount, date and category was entered'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: const Text('Okay'))
              ],
            );
          });
      return;
    }

    var newEntry = Expense(
        title: _titleController.text,
        amount: double.tryParse(_amountController.text)!,
        date: _selectedDate!,
        category: _selectedCategory);
    widget.onAddExpense(newEntry);

    Navigator.pop(context);
  }
}
