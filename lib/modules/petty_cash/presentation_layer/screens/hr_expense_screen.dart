import 'package:bayanat/modules/petty_cash/controllers/hr_expense_ctr.dart';
import 'package:bayanat/modules/petty_cash/models/employee_model.dart';
import 'package:bayanat/modules/petty_cash/models/hr_expense.dart';
import 'package:bayanat/modules/petty_cash/models/tax_type.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpenseFormScreen extends StatefulWidget {
  const ExpenseFormScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();
  final _totalAmountCompanyController = TextEditingController();

  int? _selectedCategoryId;
  int? _selectedAccountId;
  int? _selectedCompanyId;
  int? _selectedTaxId;
  double? _totalAmountCompany;
  DateTime _selectedDate = DateTime.now();

  final _controller = Get.put(HrExpenseController());

  // Custom input decoration for consistency
  InputDecoration _getInputDecoration(String label,
      {String? helperText, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      helperText: helperText,
      helperStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffixIcon,
    );
  }

  // Custom dropdown decoration
  InputDecoration _getDropdownDecoration(String label, {String? helperText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      helperText: helperText,
      helperStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'New Expense',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading form data...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Form(
          key: _formKey,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue[200]!, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Expense Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Fill in the required information to submit your expense',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Progress Indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.blue[600], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Form Progress',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _getFormProgress(),
                        backgroundColor: Colors.blue[100],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(_getFormProgress() * 100).round()}% Complete',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Employee Selection
                Obx(() => DropdownButtonFormField<int>(
                      value: _controller.selectedEmployeeId.value == 0
                          ? null
                          : _controller.selectedEmployeeId.value,
                      decoration: _getDropdownDecoration(
                        'Employee *',
                        helperText: 'Select the employee for this expense',
                      ).copyWith(
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person, color: Colors.grey),
                            const SizedBox(width: 8),
                            const Icon(Icons.keyboard_arrow_down,
                                color: Colors.grey),
                          ],
                        ),
                      ),
                      items: _controller.employees
                          .map((emp) => DropdownMenuItem<int>(
                                value: emp.id,
                                child: Text(
                                  emp.name,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (int? value) {
                        _controller.selectedEmployeeId.value = value ?? 0;
                      },
                      validator: (v) =>
                          v == null ? 'Please select an employee' : null,
                    )),
                const SizedBox(height: 20),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: _getInputDecoration(
                    'Description *',
                    helperText: 'Enter a detailed description of the expense',
                    suffixIcon:
                        const Icon(Icons.description, color: Colors.grey),
                  ),
                  maxLines: 3,
                  validator: (v) {
                    if (v?.isEmpty ?? true) {
                      return 'Description is required';
                    }
                    if (v!.length < 10) {
                      return 'Description must be at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Reference Field
                TextFormField(
                  controller: _referenceController,
                  decoration: _getInputDecoration(
                    'Reference',
                    helperText: 'Enter a reference number or code (optional)',
                    suffixIcon: const Icon(Icons.receipt, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),

                // Category Selection
                DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  decoration: _getDropdownDecoration(
                    'Category *',
                    helperText: 'Select the expense category',
                  ).copyWith(
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.category, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Icon(Icons.keyboard_arrow_down,
                            color: Colors.grey),
                      ],
                    ),
                  ),
                  items: _controller.categories
                      .map((cat) => DropdownMenuItem(
                            value: cat['id'] as int,
                            child: Text(
                              cat['name'] as String,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                  validator: (v) =>
                      v == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 20),

                // Date Selection
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Colors.blue[700]!,
                              onPrimary: Colors.white,
                              onSurface: Colors.black87,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date *',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down,
                            color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Company ID Field
                TextFormField(
                  controller: TextEditingController(
                      text: _selectedCompanyId?.toString() ?? ''),
                  decoration: _getInputDecoration(
                    'Company ID',
                    helperText: _controller.companyField.value.isNotEmpty
                        ? _controller.companyField.value
                        : 'Enter the company identifier',
                    suffixIcon: const Icon(Icons.business, color: Colors.grey),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      setState(() => _selectedCompanyId = int.tryParse(value)),
                ),
                const SizedBox(height: 20),

                // Tax Type Selection
                Obx(() => DropdownButtonFormField<int>(
                      value: _selectedTaxId,
                      decoration: _getDropdownDecoration(
                        'Tax Type *',
                        helperText: 'Select the applicable tax type',
                      ).copyWith(
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.receipt, color: Colors.grey),
                            const SizedBox(width: 8),
                            const Icon(Icons.keyboard_arrow_down,
                                color: Colors.grey),
                          ],
                        ),
                      ),
                      items: _controller.filteredTaxes
                          .map((tax) => DropdownMenuItem<int>(
                                value: (tax as TaxType).id,
                                child: Text(
                                  (tax as TaxType).name,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (int? value) {
                        setState(() {
                          _selectedTaxId = value;
                        });
                      },
                      validator: (v) =>
                          v == null ? 'Please select a tax type' : null,
                    )),
                const SizedBox(height: 20),

                // Amount Fields Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green[200]!, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green[600],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.attach_money,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Amount Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Total Amount Company
                      TextFormField(
                        controller: _totalAmountCompanyController,
                        decoration: _getInputDecoration(
                          'Total Amount (Company) *',
                          helperText: 'Enter the total amount including taxes',
                          suffixIcon: const Icon(Icons.account_balance,
                              color: Colors.grey),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) {
                          if (v?.isEmpty ?? true) {
                            return 'Total amount is required';
                          }
                          final amount = double.tryParse(v!);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _totalAmountCompany = double.tryParse(value);
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Base Amount Field
                      TextFormField(
                        controller: _amountController,
                        decoration: _getInputDecoration(
                          'Base Amount *',
                          helperText: 'Enter the base amount before taxes',
                          suffixIcon:
                              const Icon(Icons.money, color: Colors.grey),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) {
                          if (v?.isEmpty ?? true) {
                            return 'Base amount is required';
                          }
                          final amount = double.tryParse(v!);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue[600]!,
                        Colors.blue[700]!,
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _controller.isSubmitting.value ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _controller.isSubmitting.value
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Submitting...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'Submit Expense',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Error Display
                Obx(() {
                  if (_controller.error.value.isNotEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[200]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _controller.error.value,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        );
      }),
    );
  }

  double _getFormProgress() {
    int completedFields = 0;
    int totalFields =
        6; // Employee, Description, Category, Date, Tax Type, Amount

    if (_controller.selectedEmployeeId.value != 0) completedFields++;
    if (_descriptionController.text.isNotEmpty) completedFields++;
    if (_selectedCategoryId != null) completedFields++;
    if (_selectedTaxId != null) completedFields++;
    if (_totalAmountCompanyController.text.isNotEmpty) completedFields++;
    if (_amountController.text.isNotEmpty) completedFields++;

    return completedFields / totalFields;
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final expense = HrExpenseModel(
        name: _descriptionController.text,
        productId: _selectedCategoryId,
        employeeId: _controller.selectedEmployeeId.value,
        paymentMode: 'company_account',
        accountId: _selectedAccountId,
        amount: double.tryParse(_totalAmountCompanyController.text),
        date: _selectedDate,
        companyId: _selectedCompanyId?.toString(),
        reference: _referenceController.text.isNotEmpty
            ? _referenceController.text
            : null,
      );

      final success = await _controller.submitExpense(expense);
      if (success) {
        Get.snackbar(
          'Success',
          'Expense submitted successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        Get.back();
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _referenceController.dispose();
    _amountController.dispose();
    _totalAmountCompanyController.dispose();
    super.dispose();
  }
}
