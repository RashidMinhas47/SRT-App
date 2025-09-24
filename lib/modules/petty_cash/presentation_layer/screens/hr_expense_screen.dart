import 'package:bayanat/core/utils/color_manager.dart';
import 'package:bayanat/modules/petty_cash/controllers/hr_expense_ctr.dart';
import 'package:bayanat/modules/petty_cash/models/hr_expense.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:bayanat/modules/petty_cash/presentation_layer/screens/pending_bills_screen.dart';

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
  final List<String> _subCategories = const [
    'Material Purchase',
    'Food/Meals',
    'Transport/Fuel',
    'Miscellaneous',
    'Advance Request',
  ];
  String? _selectedSubCategory;

  int? _selectedCategoryId;
  int? _selectedAccountId;
  int? _selectedCompanyId;
  // Removed single tax id; using multi-select list instead
  final List<int> _selectedTaxIds = <int>[];
  DateTime _selectedDate = DateTime.now();
  bool _hasValidationError = false;
  String? _billImageBase64;
  XFile? _billPhotoFile;

  final _controller = Get.put(HrExpenseController());

  @override
  void initState() {
    super.initState();
    // Refresh dropdown data each time the screen is opened
    _controller.refreshDropdownData();

    // Listen for categories to be loaded and set default Petty Cash
    _controller.categories.listen((categories) {
      if (categories.isNotEmpty && _selectedCategoryId == null) {
        final pettyCashCategory = categories.firstWhereOrNull((cat) =>
            (cat['name'] as String?)?.toLowerCase() == 'petty cash bill');
        if (pettyCashCategory != null) {
          setState(() {
            _selectedCategoryId = pettyCashCategory['id'] as int;
          });
        }
      }
    });
  }

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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Petty Cash Bill',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: ColorManager.primary,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: OutlinedButton.icon(
              onPressed: () {
                Get.to(() => const PendingBillsScreen());
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.pending_actions, color: Colors.white),
              label: const Text(
                'Pending Bills',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
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
                                helperText:
                                    'Tap to search and select an employee',
                                helperStyle: TextStyle(
                                  color: _hasValidationError &&
                                          _controller
                                                  .selectedEmployeeId.value ==
                                              0
                                      ? const Color.fromARGB(255, 250, 82, 70)
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

                // Sub Category Selection
                DropdownButtonFormField<String>(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  value: _selectedSubCategory,
                  decoration: _getDropdownDecoration(
                    'Sub Category *',
                    helperText: 'Select a sub category',
                  ),
                  items: _subCategories
                      .map((s) => DropdownMenuItem<String>(
                            value: s,
                            child: Text(
                              s,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedSubCategory = val;
                    });
                  },
                  validator: (v) => v == null || v.isEmpty
                      ? 'Please select a sub category'
                      : null,
                ),
                const SizedBox(height: 20),

                // Bill Photo (optional)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bill Photo',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _choosePhotoSource,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorManager.primary,
                          ),
                          icon:
                              const Icon(Icons.camera_alt, color: Colors.white),
                          label: const Text(
                            'Add or Take Photo',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (_billPhotoFile != null)
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _billImageBase64 == null
                                      ? const SizedBox.shrink()
                                      : Image.memory(
                                          base64Decode(_billImageBase64!),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _billPhotoFile!.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Remove',
                                  onPressed: () {
                                    setState(() {
                                      _billImageBase64 = null;
                                      _billPhotoFile = null;
                                    });
                                  },
                                  icon: const Icon(Icons.close,
                                      color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
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

                // Paid by Selection
                Obx(() => DropdownButtonFormField<String>(
                      icon: const Icon(Icons.keyboard_arrow_down),
                      value: _controller.selectedPaymentMode.value.isNotEmpty
                          ? _controller.selectedPaymentMode.value
                          : null,
                      decoration: _getDropdownDecoration(
                        'Paid by',
                        helperText:
                            'Select who will pay for this expense (optional)',
                      ),
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'company',
                          child: Text(
                            'Company',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: 'employee',
                          child: Text(
                            'Employee',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (String? value) {
                        _controller.selectedPaymentMode.value =
                            value?.toLowerCase() ?? '';
                      },
                    )),
                const SizedBox(height: 20),

                // Taxes Selection (multi-select, optional)
                Obx(() {
                  final selectedNames = _controller.filteredTaxes
                      .where((t) => _selectedTaxIds.contains(t.id))
                      .map((t) => t.name)
                      .toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: _openTaxesDialog,
                        child: InputDecorator(
                          decoration: _getDropdownDecoration(
                            'Taxes',
                            helperText: 'Select one or more taxes (optional)',
                          ),
                          child: selectedNames.isEmpty
                              ? const Text(
                                  'No tax selected',
                                  style: TextStyle(color: Colors.grey),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: selectedNames
                                      .map((name) => Chip(
                                            label: Text(name),
                                            deleteIconColor: Colors.grey,
                                          ))
                                      .toList(),
                                ),
                        ),
                      ),
                    ],
                  );
                }),
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
        paymentMode: _controller.selectedPaymentMode.value,
        taxIds: _selectedTaxIds,
        accountId: _selectedAccountId,
        amount: double.tryParse(_totalAmountCompanyController.text),
        date: _selectedDate,
        // companyId: _selectedCompanyId?.toString(),
        reference: _referenceController.text.isNotEmpty
            ? _referenceController.text
            : null,
        empId: _controller.selectedPaymentMode.value == 'employee'
            ? _controller.selectedEmployeeId.value
            : null,
        billImage: _billImageBase64,
        subCategory: _selectedSubCategory,
      );

      final success = await _controller.submitExpense(expense);
      if (success) {
        // Clear all form fields
        _clearAllFields();

        // Navigate back to main screen
        Get.offAllNamed('/main');
      }
    }
  }

  void _openTaxesDialog() async {
    final List<int> tempSelected = List<int>.from(_selectedTaxIds);
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Select Taxes'),
              content: SizedBox(
                width: double.maxFinite,
                child: Obx(() {
                  final taxes = _controller.filteredTaxes;
                  if (taxes.isEmpty) {
                    return const Text('No taxes available');
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: taxes.length,
                    itemBuilder: (context, index) {
                      final tax = taxes[index];
                      final checked = tempSelected.contains(tax.id);
                      return CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        value: checked,
                        title: Text(tax.name),
                        onChanged: (bool? val) {
                          setStateDialog(() {
                            if (val == true) {
                              if (!tempSelected.contains(tax.id)) {
                                tempSelected.add(tax.id);
                              }
                            } else {
                              tempSelected.remove(tax.id);
                            }
                          });
                        },
                      );
                    },
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedTaxIds
                        ..clear()
                        ..addAll(tempSelected.toSet());
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _clearAllFields() {
    setState(() {
      // Clear text controllers
      _descriptionController.clear();
      _referenceController.clear();
      _amountController.clear();
      _totalAmountCompanyController.clear();
      _employeeDisplayController.clear();

      // Reset selected values
      _selectedAccountId = null;
      _selectedCompanyId = null;
      _selectedTaxIds.clear();
      _selectedDate = DateTime.now();
      _hasValidationError = false;
      _billImageBase64 = null;
      _billPhotoFile = null;

      // Reset controller values
      _controller.selectedEmployeeId.value = 0;
      _controller.selectedPaymentMode.value = '';
    });
  }

  Future<void> _pickBillPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1600,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _billImageBase64 = base64Encode(bytes);
        _billPhotoFile = file;
      });
    } catch (_) {
      // ignore
    }
  }

  Future<void> _takeBillPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
        maxWidth: 1600,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _billImageBase64 = base64Encode(bytes);
        _billPhotoFile = file;
      });
    } catch (_) {
      // ignore
    }
  }

  Future<void> _choosePhotoSource() async {
    try {
      final selected = await showModalBottomSheet<String>(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () => Navigator.pop(context, 'gallery'),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
                  onTap: () => Navigator.pop(context, 'camera'),
                ),
              ],
            ),
          );
        },
      );

      if (selected == 'gallery') {
        await _pickBillPhoto();
      } else if (selected == 'camera') {
        await _takeBillPhoto();
      }
    } catch (_) {
      // ignore
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
