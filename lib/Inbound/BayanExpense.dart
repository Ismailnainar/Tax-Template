import 'dart:convert';
import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:aljeflutterapp/components/Style.dart';
import 'package:flutter/material.dart';

class BayanExpense extends StatefulWidget {
  const BayanExpense({super.key});

  @override
  State<BayanExpense> createState() => _BayanExpenseState();
}

class _BayanExpenseState extends State<BayanExpense> {
  final List<Map<String, String>> _expenses = [];
  final TextEditingController _amountController = TextEditingController();

  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();
  final FocusNode AddFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();

// Improved _addExpense with validation
  void _addExpense() {
    if (_formKey.currentState!.validate()) {
      if (expenseCatController.text.isEmpty ||
          expenseNameController.text.isEmpty ||
          _amountController.text.isEmpty) {
        _showErrorDialog('Kindly fill the all fields');
        return;
      }

      setState(() {
        _expenses.add({
          'Bayan No': '778',
          'Category': expenseCatController.text,
          'Name': expenseNameController.text,
          'Amount': double.parse(_amountController.text).toStringAsFixed(2),
        });
        // Clear controllers
        expenseCatController.clear();
        expenseNameController.clear();
        _amountController.clear();
      });
    }
  }

  double get _totalAmount {
    return _expenses.fold(
      0.0,
      (sum, item) => sum + (double.tryParse(item['Amount'] ?? '0') ?? 0.0),
    );
  }

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  TextEditingController expenseCatController = TextEditingController();
  TextEditingController expenseNameController = TextEditingController();

  List<String> expenseCatList = [];
  List<String> expenseNameList = [];

  bool _filterEnabledCat = false;
  bool _filterEnabledName = false;

  int? _selectedIndexCat;
  int? _selectedIndexName;

  int? _hoveredIndexCat;
  int? _hoveredIndexName;

  String? selectedCat;
  String? selectedName;

  Future<void> fetchExpenseCats() async {
    final IpAddress = await getActiveIpAddress();
    final response = await http.get(Uri.parse("$IpAddress/get_expense_cat/"));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['expense_categories'];
      setState(() {
        expenseCatList = List<String>.from(data);
      });
    }
  }

  Future<void> fetchExpenseNames(String cat) async {
    final IpAddress = await getActiveIpAddress();
    final response =
        await http.get(Uri.parse("$IpAddress/get_names_by_cat/$cat/"));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['names'];
      setState(() {
        expenseNameList = List<String>.from(data);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchExpenseCats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 16),
          child: const Text('Bayan Expenses', style: TextStyle(fontSize: 16)),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Bayan No
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Bayan No : 121'),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Category and Name in a row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth <
                              600; // Adjust breakpoint as needed

                          return isMobile
                              ? Column(
                                  children: [
                                    SizedBox(
                                        width: double.infinity,
                                        child: CategoryDropdown()),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                        width: double.infinity,
                                        child: NameDropdown()),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: _buildCompactTextField(
                                        focusNode: _amountFocus,
                                        nextFocus: AddFocus,
                                        'Amount (SAR)',
                                        _amountController,
                                        icon: Icons.money,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        onPressed: _addExpense,
                                        icon: Icon(Icons.add),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    SizedBox(
                                        width: 250, child: CategoryDropdown()),
                                    SizedBox(width: 12),
                                    SizedBox(width: 250, child: NameDropdown()),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 180,
                                      child: _buildCompactTextField(
                                        focusNode: _amountFocus,
                                        nextFocus: AddFocus,
                                        'Amount (SAR)',
                                        _amountController,
                                        icon: Icons.money,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: _addExpense,
                                        icon: Icon(Icons.add)),
                                  ],
                                );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Expenses List
            if (_expenses.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Expenses List', style: TextStyle(fontSize: 13)),
                  Chip(
                    label: Text('${_totalAmount.toStringAsFixed(2)}  SAR'),
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Replace your current AnimatedList with this:
              Expanded(
                child: ListView.builder(
                  itemCount: _expenses.length,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    return _buildExpenseItem(_expenses[index], index);
                  },
                ),
              ),
            ] else ...[
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No expenses added yet',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.save, size: 16),
                  label: Text('Save', style: commonWhiteStyle),
                  onPressed: _saveExpenses,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(Map<String, String> item, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.receipt,
            color: Colors.blue.shade800,
            size: 20,
          ),
        ),
        title: Text(
          item['Name']!,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          '${item['Category']} • Bayan #${item['Bayan No']}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => _removeExpense(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.red.shade400,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${item['Amount']} SAR',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  } // Add this method for animated removal

  void _removeExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
  }

  Widget _buildCompactTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    IconData? icon,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    TextInputType? keyboardType, // Remove non-constant default here
    String? Function(String?)? validator,
    bool numbersOnly = true,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: numbersOnly
          ? TextInputType.numberWithOptions(decimal: true) // Set here instead
          : keyboardType ?? TextInputType.text,
      inputFormatters: numbersOnly
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12),
        prefixIcon: icon != null ? Icon(icon, size: 16) : null,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        isDense: true,
      ),
      validator: validator ??
          (value) {
            if (numbersOnly && value != null && value.isNotEmpty) {
              if (double.tryParse(value) == null) {
                return 'Enter a valid number';
              }
            }
            return null;
          },
      textInputAction:
          nextFocus != null ? TextInputAction.next : TextInputAction.done,
      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        }
      },
      style: TextStyle(fontSize: 12),
    );
  }

  Widget CategoryDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                expenseCatList.indexOf(expenseCatController.text);
            if (currentIndex < expenseCatList.length - 1) {
              setState(() {
                _selectedIndexCat = currentIndex + 1;
                // Take only the customer number part before the colon
                expenseCatController.text =
                    expenseCatList[currentIndex + 1].split(':')[0];
                _filterEnabledCat = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                expenseCatList.indexOf(expenseCatController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndexCat = currentIndex - 1;
                // Take only the customer number part before the colon
                expenseCatController.text =
                    expenseCatList[currentIndex - 1].split(':')[0];
                _filterEnabledCat = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: _categoryFocus,
          controller: expenseCatController,
          onSubmitted: (String? suggestion) async {},
          decoration: InputDecoration(
            labelText: 'Expense Category',
            labelStyle: TextStyle(fontSize: 12),
            prefixIcon: Icon(Icons.category, size: 16),
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            isDense: true,
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            ),
          ),
          style: TextStyle(fontSize: 12),
          onChanged: (text) {
            setState(() {
              _filterEnabledCat = true;
              selectedCat = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabledCat && pattern.isNotEmpty) {
            return expenseCatList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return expenseCatList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = expenseCatList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndexCat = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndexCat = null;
            }),
            child: Container(
              color: _selectedIndexCat == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndexCat == null &&
                          expenseCatList.indexOf(expenseCatController.text) ==
                              index
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.transparent,
              height: 28,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                dense: true,
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(suggestion, style: TextStyle(fontSize: 13)),
                ),
              ),
            ),
          );
        },
        suggestionsBoxDecoration: const SuggestionsBoxDecoration(
          constraints: BoxConstraints(maxHeight: 150),
        ),
        onSuggestionSelected: (suggestion) async {
          expenseCatController.text = suggestion;
          selectedCat = suggestion;

          await fetchExpenseNames(suggestion);

          Future.delayed(Duration(milliseconds: 100), () {
            FocusScope.of(context).requestFocus(_nameFocus);
          });
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: DropdownTextStyle,
          ),
        ),
      ),
    );
  }

  Widget NameDropdown() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Handle arrow down event
            int currentIndex =
                expenseNameList.indexOf(expenseNameController.text);
            if (currentIndex < expenseNameList.length - 1) {
              setState(() {
                _selectedIndexName = currentIndex + 1;
                // Take only the customer number part before the colon
                expenseNameController.text =
                    expenseNameList[currentIndex + 1].split(':')[0];
                _filterEnabledName = false;
              });
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Handle arrow up event
            int currentIndex =
                expenseNameList.indexOf(expenseNameController.text);
            if (currentIndex > 0) {
              setState(() {
                _selectedIndexName = currentIndex - 1;
                // Take only the customer number part before the colon
                expenseNameController.text =
                    expenseNameList[currentIndex - 1].split(':')[0];
                _filterEnabledName = false;
              });
            }
          }
        }
      },
      child: TypeAheadFormField<String>(
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: _nameFocus,
          controller: expenseNameController,
          onSubmitted: (String? suggestion) async {},
          decoration: InputDecoration(
            labelText: 'Expense Name',
            labelStyle: TextStyle(fontSize: 12),
            prefixIcon: Icon(Icons.description, size: 16),
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            isDense: true,
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            ),
          ),
          style: TextStyle(fontSize: 12),
          onChanged: (text) {
            setState(() {
              _filterEnabledName = true;
              selectedName = text.isEmpty ? null : text;
            });
          },
        ),
        suggestionsCallback: (pattern) {
          if (_filterEnabledName && pattern.isNotEmpty) {
            return expenseNameList.where(
                (item) => item.toLowerCase().contains(pattern.toLowerCase()));
          } else {
            return expenseNameList;
          }
        },
        itemBuilder: (context, suggestion) {
          final index = expenseNameList.indexOf(suggestion);
          return MouseRegion(
            onEnter: (_) => setState(() {
              _hoveredIndexName = index;
            }),
            onExit: (_) => setState(() {
              _hoveredIndexName = null;
            }),
            child: Container(
              color: _selectedIndexName == index
                  ? Colors.grey.withOpacity(0.3)
                  : _selectedIndexName == null &&
                          expenseNameList.indexOf(expenseNameController.text) ==
                              index
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.transparent,
              height: 28,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                dense: true,
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(suggestion, style: TextStyle(fontSize: 13)),
                ),
              ),
            ),
          );
        },
        suggestionsBoxDecoration: const SuggestionsBoxDecoration(
          constraints: BoxConstraints(maxHeight: 150),
        ),
        onSuggestionSelected: (suggestion) {
          expenseNameController.text = suggestion;
          selectedName = suggestion;
          FocusScope.of(context).requestFocus(_amountFocus);
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Items Found!!!',
            style: DropdownTextStyle,
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.yellow,
            ),
            Text(
              'Warning',
              style: textStyle,
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 12),
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _saveExpenses() async {
    if (_expenses.isEmpty) {
      _showErrorDialog('Please add at least one expense before saving');
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final IpAddress = await getActiveIpAddress();
      final response = await http.post(
        Uri.parse("$IpAddress/save_expense_details/"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "expense_data": _expenses
              .map((expense) => {
                    "BAYAN_NO": expense['Bayan No'] ?? '778',
                    "EXPENSE_CAT": expense['Category'],
                    "NAME": expense['Name'],
                    "AMOUNT": expense['Amount'],
                  })
              .toList()
        }),
      );

      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Expenses saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() => _expenses.clear());
        } else {
          _showErrorDialog(
              responseData['message'] ?? 'Failed to save expenses');
        }
      } else {
        _showErrorDialog('Server error: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showErrorDialog('Error: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    expenseCatController.dispose();
    expenseNameController.dispose();
    _amountController.dispose();
    _categoryFocus.dispose();
    _nameFocus.dispose();
    _amountFocus.dispose();
    super.dispose();
  }
}
