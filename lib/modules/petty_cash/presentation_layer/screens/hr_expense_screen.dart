import 'package:bayanat/modules/petty_cash/controllers/hr_expense_ctr.dart';
import 'package:bayanat/modules/petty_cash/models/employee_model.dart';
import 'package:bayanat/modules/petty_cash/models/hr_expense.dart';
import 'package:bayanat/modules/petty_cash/models/tax_type.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../controllers/expense_controller.dart';

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
  List<int> _selectedTaxIds = [];
  int? _selectedAccountId;
  String _paymentMode = 'company'; // or 'employee'
  int? _selectedCompanyId;
  int? _selectedTaxId; // Add this to your state
  double? _totalAmountCompany;

  final _controller = Get.put(HrExpenseController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Expense'),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Obx(() => DropdownButtonFormField<int>(
                    value: _controller.selectedEmployeeId.value == 0
                        ? null
                        : _controller.selectedEmployeeId.value,
                    decoration: const InputDecoration(
                      labelText: 'Employee *',
                      border: OutlineInputBorder(),
                    ),
                    items: _controller.employees
                        .map((emp) => DropdownMenuItem<int>(
                              value: emp.id,
                              child: Text(emp.name),
                            ))
                        .toList(),
                    onChanged: (int? value) {
                      _controller.selectedEmployeeId.value = value ?? 0;
                    },
                    validator: (v) =>
                        v == null ? 'Please select an employee' : null,
                  )),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                ),
                items: _controller.categories
                    .map((cat) => DropdownMenuItem(
                          value: cat['id'] as int,
                          child: Text(cat['name'] as String),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
                validator: (v) => v == null ? 'Required' : null,
              ),

              // Replace company dropdown with company ID field
              TextFormField(
                controller: TextEditingController(
                    text: _selectedCompanyId?.toString() ?? ''),
                decoration: InputDecoration(
                  labelText: 'Company ID',
                  helperText: _controller.companyField.value,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    setState(() => _selectedCompanyId = int.tryParse(value)),
              ),

              Obx(() => DropdownButtonFormField<int>(
                    value: _selectedTaxId,
                    decoration: const InputDecoration(
                      labelText: 'Tax Type *',
                      border: OutlineInputBorder(),
                    ),
                    items: _controller.filteredTaxes
                        .map((tax) => DropdownMenuItem<int>(
                              value: (tax as TaxType).id,
                              child: Text((tax as TaxType).name),
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

              TextFormField(
                controller: _totalAmountCompanyController,
                decoration: const InputDecoration(
                  labelText: 'Total Amount (Company) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onChanged: (value) {
                  setState(() {
                    _totalAmountCompany = double.tryParse(value);
                  });
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _controller.totalAmountCompanyController.value,
                decoration: const InputDecoration(
                  labelText: 'Amount *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),

              ElevatedButton(
                onPressed: _controller.isSubmitting.value ? null : _submit,
                child: _controller.isSubmitting.value
                    ? const CircularProgressIndicator()
                    : const Text('Submit'),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final expense = HrExpenseModel(
        name: _descriptionController.text,

        productId: _selectedCategoryId,
        employeeId: _controller.selectedEmployeeId.value,
        paymentMode: _paymentMode,
        accountId: _selectedAccountId,
        amount: double.tryParse(
            _controller.totalAmountCompanyController.value.text),
        date: DateTime.now(),
        companyId: _selectedCompanyId?.toString(),
        // Add other fields as needed
      );

      final success = await _controller.submitExpense(expense);
      if (success) {
        Get.back();
      }
    }
  }
}
