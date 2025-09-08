import 'package:bayanat/core/utils/color_manager.dart';
import 'package:bayanat/modules/petty_cash/controllers/hr_expense_ctr.dart';
import 'package:bayanat/modules/petty_cash/models/hr_expense.dart';
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
  final _employeeDisplayController = TextEditingController();

  int? _selectedCategoryId;
  int? _selectedAccountId;
  int? _selectedCompanyId;
  int? _selectedTaxId;
  DateTime _selectedDate = DateTime.now();
  bool _hasValidationError = false;

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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set default category to Petty Cash if present
    if (_selectedCategoryId == null && _controller.categories.isNotEmpty) {
      final petty = _controller.categories.firstWhereOrNull(
          (c) => (c['name'] as String?)?.toLowerCase() == 'petty cash bill');
      if (petty != null) {
        _selectedCategoryId = petty['id'] as int;
      }
    }
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Petty Cash Bill',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: ColorManager.primary,
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
                    color: ColorManager.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: ColorManager.primary.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ColorManager.primary.withOpacity(0.8),
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
                              'Petty Cash Details',
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

                // Employee Selection (searchable)
                FormField<int>(
                  validator: (v) => _controller.selectedEmployeeId.value == 0
                      ? 'Please select an employee'
                      : null,
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _openEmployeeSearchDialog,
                          child: AbsorbPointer(
                            absorbing: true,
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Employee *',
                                labelStyle: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                helperText: _hasValidationError &&
                                        _controller.selectedEmployeeId.value ==
                                            0
                                    ? 'Please select an employee'
                                    : 'Tap to search and select an employee',
                                helperStyle: TextStyle(
                                  color: _hasValidationError &&
                                          _controller
                                                  .selectedEmployeeId.value ==
                                              0
                                      ? Colors.red
                                      : Colors.grey,
                                  fontSize: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: state.hasError
                                          ? Colors.red
                                          : Colors.grey,
                                      width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: state.hasError
                                          ? Colors.red
                                          : ColorManager.primary,
                                      width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 1),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2),
                                ),
                                filled: true,
                                fillColor: state.hasError
                                    ? Colors.red[50]
                                    : Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                suffixIcon: Obx(() => Icon(
                                      _controller.selectedEmployeeId.value == 0
                                          ? Icons.search
                                          : Icons.keyboard_arrow_down,
                                      color: state.hasError
                                          ? Colors.red
                                          : Colors.grey,
                                    )),
                              ),
                              controller: _employeeDisplayController,
                              readOnly: true,
                            ),
                          ),
                        ),
                        if (state.hasError)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, left: 12.0),
                            child: Text(
                              state.errorText ?? '',
                              style: TextStyle(
                                  color: Colors.red[700], fontSize: 12),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Description Field (optional)
                TextFormField(
                  controller: _descriptionController,
                  decoration: _getInputDecoration(
                    'Description',
                    helperText: 'Enter a description (optional)',
                    suffixIcon:
                        const Icon(Icons.description, color: Colors.grey),
                  ),
                  maxLines: 3,
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

                // Category Selection (fixed to Petty Cash)
                DropdownButtonFormField<int>(
                  icon: Icon(Icons.category),
                  value: _selectedCategoryId,
                  decoration: _getDropdownDecoration(
                    'Category *',
                    helperText: 'Fixed to Petty Cash',
                  ).copyWith(
                    suffixIcon: null,
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
                  onChanged: null,
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
                              primary: ColorManager.primary,
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

                // Tax Type Selection (optional)
                Obx(() => DropdownButtonFormField<int>(
                      icon: Icon(Icons.keyboard_arrow_down),
                      value: _selectedTaxId,
                      decoration: _getDropdownDecoration(
                        'Tax Type',
                        helperText: 'Select the applicable tax type (optional)',
                      ),
                      items: _controller.filteredTaxes
                          .map((tax) => DropdownMenuItem<int>(
                                value: tax.id,
                                child: Text(
                                  tax.name,
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

                      // Total Amount Company (optional)
                      TextFormField(
                        controller: _totalAmountCompanyController,
                        decoration: _getInputDecoration(
                          'Total Amount (Company)',
                          helperText:
                              'Enter the total amount including taxes (optional)',
                          suffixIcon: const Icon(Icons.account_balance,
                              color: Colors.grey),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 16),

                      // Base Amount Field (optional)
                      TextFormField(
                        controller: _amountController,
                        decoration: _getInputDecoration(
                          'Base Amount',
                          helperText:
                              'Enter the base amount before taxes (optional)',
                          suffixIcon:
                              const Icon(Icons.money, color: Colors.grey),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
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
                        ColorManager.primary.withOpacity(0.8),
                        ColorManager.primary.withOpacity(0.6),
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
                // Obx(() {
                //   if (_controller.error.value.isNotEmpty) {
                //     return Container(
                //       padding: const EdgeInsets.all(16),
                //       decoration: BoxDecoration(
                //         color: Colors.red[50],
                //         borderRadius: BorderRadius.circular(12),
                //         border: Border.all(color: Colors.red[200]!, width: 1),
                //       ),
                //       child: Row(
                //         children: [
                //           Icon(Icons.error_outline, color: Colors.red[600]),
                //           const SizedBox(width: 12),
                //           Expanded(
                //             child: Text(
                //               _controller.error.value,
                //               style: TextStyle(
                //                 color: Colors.red[700],
                //                 fontSize: 14,
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     );
                //   }
                //   return const SizedBox.shrink();
                // }),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _hasValidationError = true;
    });

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
    _employeeDisplayController.dispose();
    super.dispose();
  }

  void _openEmployeeSearchDialog() async {
    final List<dynamic> allEmployees =
        List<dynamic>.from(_controller.employees);
    String query = '';
    final TextEditingController searchController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        List<dynamic> filtered = List<dynamic>.from(allEmployees);
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void applyFilter(String q) {
              setStateDialog(() {
                query = q;
                filtered = allEmployees
                    .where((emp) => (emp.name?.toString().toLowerCase() ?? '')
                        .contains(query.toLowerCase()))
                    .toList();
              });
            }

            return AlertDialog(
              title: const Text('Select Employee'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search employee...',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: applyFilter,
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: filtered.isEmpty
                          ? const Center(child: Text('No results'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final employee = filtered[index];
                                final employeeName =
                                    employee.name?.toString() ?? '';
                                return ListTile(
                                  title: Text(employeeName),
                                  onTap: () {
                                    final int id = employee.id;
                                    _controller.selectedEmployeeId.value = id;
                                    _employeeDisplayController.text =
                                        employeeName;
                                    setState(() {
                                      _hasValidationError = false;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
