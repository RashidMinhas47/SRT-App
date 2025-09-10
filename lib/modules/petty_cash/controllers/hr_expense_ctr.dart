import 'dart:convert';
import 'package:bayanat/core/remote/api_helper/api_models.dart';
import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:bayanat/modules/main/presentation_layer/screens/main_screen.dart';
import 'package:bayanat/modules/petty_cash/models/hr_expense.dart';
import 'package:bayanat/modules/petty_cash/models/tax_type.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/remote/api_helper/api_constance.dart';
import '../models/tax_model.dart';
import '../models/account_model.dart';
import '../models/employee_model.dart';

class HrExpenseController extends GetxController {
  final RxList<AccountModel> accounts = <AccountModel>[].obs;
  // Lists for dropdown data
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;

  // Update to store just company field data
  final RxMap companyField = {}.obs;

  // Add employee field data
  final RxMap employeeField = {}.obs;

  // Add employees list
  final RxList<EmployeeModel> employees = <EmployeeModel>[].obs;
  // Expenses list for pending bills screen
  final RxList<HrExpenseModel> expenses = <HrExpenseModel>[].obs;

  final RxString error = ''.obs;
  // Add filtered taxes list
  final RxList<TaxType> filteredTaxes = <TaxType>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  // Add RxMap to store field descriptions
  final RxMap<String, dynamic> paymentModeField = <String, dynamic>{}.obs;

  final RxInt selectedEmployeeId = RxInt(0);
  final RxString selectedPaymentMode = ''.obs;
  final RxList<TaxModel> taxes = <TaxModel>[].obs;
  final Rx<TextEditingController> totalAmountCompanyController =
      TextEditingController().obs;

  @override
  void onInit() {
    super.onInit();
    fetchDropdownData();
  }

  // Method to refresh all dropdown data
  Future<void> refreshDropdownData() async {
    await fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        _fetchCategories(),
        _fetchTaxes(),
        _fetchAccounts(),
        _fetchCompanyField(),
        _fetchEmployeeField(),
        _fetchPaymentModeField(),
        _fetchEmployees(), // Add employees fetch
        _fetchTaxes(),
      ]);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch hr.expense list (for now: all expenses)
  Future<void> fetchExpenses() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConsts.baseUrl}/web/dataset/call_kw'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode({
          'params': {
            'model': 'hr.expense',
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'fields': [
                'id',
                'name',
                'date',
                'employee_id',
                'total_amount',
                'state',
                'payment_mode',
                'product_id'
              ],
              // Domain empty: show all as richiesto
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['result'] != null) {
          final List list = result['result'] as List;
          expenses.value = list
              .map((e) => HrExpenseModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } else {
        throw Exception('Failed to fetch expenses: ${response.statusCode}');
      }
    } catch (e) {
      error.value = 'Error fetching expenses: $e';
      rethrow;
    }
  }

  Future<bool> submitExpense(HrExpenseModel expense) async {
    try {
      isSubmitting.value = true;

      if (selectedEmployeeId.value == 0) {
        error.value = 'Please select an employee';
        Fluttertoast.showToast(
          msg: 'Please select an employee',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return false;
      }
      if (expense.productId == null) {
        error.value = 'Please select a category';
        Fluttertoast.showToast(
          msg: 'Please select a category',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return false;
      }

      final expenseData = {
        'name': expense.name,
        'product_id': expense.productId,
        // 'unit_amount': expense.amount ?? 100,
        'quantity': 1.0,
        'date': expense.date?.toIso8601String().split('T')[0],
        'employee_id': selectedEmployeeId.value,
        'payment_mode': selectedPaymentMode.value == 'company'
            ? 'company_account'
            : selectedPaymentMode.value == 'employee'
                ? 'own_account'
                : 'company_account',
        if (expense.taxIds != null && expense.taxIds!.isNotEmpty)
          'tax_ids': [
            [6, 0, expense.taxIds]
          ],
        if (expense.accountId != null) 'account_id': expense.accountId,
        'reference': expense.reference,
        'total_amount_company': expense.amount, // <-- Add this line
        'total_amount': expense.amount,
      };

      // Validate mandatory fields: only product (category) and employee
      if (expenseData['product_id'] == null ||
          expenseData['employee_id'] == null) {
        error.value = 'Please select required fields';
        Fluttertoast.showToast(
          msg: 'Please select required fields',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return false;
      }

      final response = await http.post(
        Uri.parse('${ApiConsts.baseUrl}/web/dataset/call_kw'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode({
          'params': {
            'model': 'hr.expense',
            'method': 'create',
            'args': [expenseData],
            'kwargs': {},
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['result'] != null) {
          Fluttertoast.showToast(
            msg: 'Expense submitted successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          Get.offAll(() => const JobCardScreen());
          return true;
        } else if (result['error'] != null) {
          // Handle Odoo error message
          final errorData = result['error']['data'];
          final errorMessage =
              errorData['message'] ?? errorData['debug'] ?? 'Unknown error';
          error.value = 'Server Error: $errorMessage';
          Fluttertoast.showToast(
            msg: 'Failed to submit expense: $errorMessage',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          return false;
        }
      }

      error.value = 'Failed to submit expense: ${response.statusCode}';
      Fluttertoast.showToast(
        msg: 'Failed to submit expense: ${response.statusCode}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return false;
    } catch (e) {
      error.value = 'Error submitting expense: $e';
      Fluttertoast.showToast(
        msg: 'Error submitting expense: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // Add method for archiving expenses instead of deleting
  Future<bool> archiveExpense(int expenseId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConsts.baseUrl}/web/dataset/call_kw'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode({
          'params': {
            'model': 'hr.expense',
            'method': 'write',
            'args': [
              [expenseId],
              {'active': false}
            ],
            'kwargs': {},
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['result'] == true) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Helper method to get account by ID
  AccountModel? getAccountById(int id) {
    return accounts.firstWhereOrNull((account) => account.id == id);
  }

  // Helper method to get tax by ID
  TaxModel? getTaxById(int id) {
    return taxes.firstWhereOrNull((tax) => tax.id == id);
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConsts.baseUrl}/web/dataset/call_kw'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': ConstanceManager.sessionId.toString(), // Add session cookie
        },
        body: jsonEncode({
          'params': {
            'model': 'product.product',
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'fields': ['id', 'name'],
              'domain': [
                ['can_be_expensed', '=', true]
              ],
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['result'] != null) {
          categories.value = List<Map<String, dynamic>>.from(result['result']);
        } else {
          throw Exception('No results found in response');
        }
      } else {
        throw Exception('Failed to fetch categories: ${response.statusCode}');
      }
    } catch (e) {
      error.value = 'Error fetching expense categories: $e';
      rethrow;
    }
  }

  Future<void> _fetchTaxes() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConsts.baseUrl}/web/dataset/call_kw'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode({
          'params': {
            'model': 'account.tax',
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'fields': ['id', 'name'],
              'domain': [
                ['active', '=', true]
              ],
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['result'] != null) {
          // Only keep the two required tax names
          filteredTaxes.value = (result['result'] as List)
              .map((tax) => TaxType.fromJson(tax))
              .where((tax) =>
                  tax.name == "Purchase Tax 5%" || tax.name == "Vat 5%")
              .toList();
        }
      } else {
        throw Exception('Failed to fetch taxes: ${response.statusCode}');
      }
    } catch (e) {
      error.value = 'Error fetching taxes: $e';
      rethrow;
    }
  }

  Future<void> _fetchAccounts() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConsts.baseUrl}/web/dataset/call_kw'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode({
          'params': {
            'model': ApiModels.account,
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'fields': ['id', 'display_name', 'code'],
              'domain': [
                ['deprecated', '=', false],
                ['internal_type', '=', 'other']
              ],
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['result'] != null) {
          accounts.value = (result['result'] as List)
              .map((account) => AccountModel.fromJson(account))
              .toList();
        }
      } else {
        throw Exception('Failed to fetch accounts: ${response.statusCode}');
      }
    } catch (e) {
      error.value = 'Error fetching accounts: $e';
      rethrow;
    }
  }

  // Update fetchDropdownData to include company field fetch
  Future<void> _fetchCompanyField() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConsts.baseUrl}/web/dataset/call_kw'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode({
          'params': {
            'model': 'hr.expense',
            'method': 'fields_get',
            'args': [],
            'kwargs': {
              'attributes': ['string', 'required', 'type', 'selection'],
              'fieldnames': ['company_id', "_id"]
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['result'] != null &&
            result['result']['company_id'] != null) {
          companyField.value = {
            'id': result['result']['company_id']['id']?.toString(),
            'name': result['result']['company_id']['string']?.toString() ??
                'Company',
          };
        } else {
          throw Exception('Company field info not found in response');
        }
      } else {
        throw Exception(
            'Failed to fetch company field: ${response.statusCode}');
      }
    } catch (e) {
      error.value = 'Error fetching company field: $e';
      rethrow;
    }
  }

  Future<void> _fetchPaymentModeField() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConsts.baseUrl}/web/dataset/call_kw'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode({
          'params': {
            'model': 'ir.model.fields',
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'fields': ['id', 'field_description', 'selection'],
              'domain': [
                ['model', '=', 'hr.expense'],
                ['name', '=', 'payment_mode'],
              ],
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['result'] != null && result['result'].isNotEmpty) {
          final Map<String, dynamic> fieldInfo =
              Map<String, dynamic>.from(result['result'][0] as Map);
          paymentModeField.value = fieldInfo;
        } else {
          throw Exception('Payment Mode field info not found in response');
        }
      } else {
        throw Exception(
            'Failed to fetch payment mode field: ${response.statusCode}');
      }
    } catch (e) {
      error.value = 'Error fetching payment mode field: $e';
      rethrow;
    }
  }

  // Add method to fetch employee field info
  Future<void> _fetchEmployeeField() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConsts.baseUrl}/web/dataset/call_kw'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode({
          'params': {
            'model': 'hr.expense',
            'method': 'fields_get',
            'args': [],
            'kwargs': {
              'attributes': ['string', 'required', 'type', 'selection'],
              'fieldnames': ['emp_id', "_id"]
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['result'] != null && result['result']['emp_id'] != null) {
          employeeField.value = {
            'id': result['result']['emp_id']['id']?.toString(),
            'name':
                result['result']['emp_id']['string']?.toString() ?? 'Employee',
          };
        } else {
          throw Exception('Employee field info not found in response');
        }
      } else {
        throw Exception(
            'Failed to fetch employee field: ${response.statusCode}');
      }
    } catch (e) {
      error.value = 'Error fetching employee field: $e';
      rethrow;
    }
  }

  // Add method to fetch employees
  Future<void> _fetchEmployees() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConsts.baseUrl}/web/dataset/call_kw'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode({
          'params': {
            'model': 'hr.employee',
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'fields': ['id', 'name', 'user_id'],
              'domain': [
                ['active', '=', true]
              ],
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['result'] != null) {
          employees.value = (result['result'] as List)
              .map((emp) => EmployeeModel.fromJson(emp))
              .toList();
        } else {
          throw Exception('No employees found in response');
        }
      } else {
        throw Exception('Failed to fetch employees: ${response.statusCode}');
      }
    } catch (e) {
      error.value = 'Error fetching employees: $e';
      rethrow;
    }
  }

  // Map payment mode to display text
  String getPaymentModeDisplayText(String? paymentMode) {
    switch (paymentMode) {
      case 'own_account':
        return 'Employee (to reimburse)';
      case 'company_account':
        return 'Company';
      default:
        return paymentMode ?? '-';
    }
  }

  // Fetch category name by ID from Odoo
  Future<String?> getCategoryNameById(int id) async {
    try {
      // Try cached categories first
      final cachedCategory =
          categories.firstWhereOrNull((cat) => cat['id'] == id);
      if (cachedCategory != null) {
        return cachedCategory['name'] as String?;
      }

      // Fetch from Odoo if not in cache
      final response = await http.post(
        Uri.parse('${ApiConsts.baseUrl}/web/dataset/call_kw'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode({
          'params': {
            'model': 'product.product',
            'method': 'search_read',
            'args': [
              [
                ['id', '=', id]
              ]
            ],
            'kwargs': {
              'fields': ['id', 'name'],
              'limit': 1,
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['result'] != null && (result['result'] as List).isNotEmpty) {
          final map = Map<String, dynamic>.from(result['result'][0] as Map);
          return map['name'] as String?;
        }
      }
    } catch (_) {
      // ignore network errors here; UI will show '-'
    }
    return null;
  }

  // Resolve employee name by id. Uses cache first, otherwise fetches from Odoo
  Future<String?> getEmployeeNameById(int id) async {
    try {
      // Try cached list
      final cached = employees.firstWhereOrNull((e) => e.id == id);
      if (cached != null) return cached.name.toString();

      // Fetch from Odoo
      final response = await http.post(
        Uri.parse('${ApiConsts.baseUrl}/web/dataset/call_kw'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode({
          'params': {
            'model': 'hr.employee',
            'method': 'search_read',
            'args': [
              [
                ['id', '=', id]
              ]
            ],
            'kwargs': {
              'fields': ['id', 'name'],
              'limit': 1,
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['result'] != null && (result['result'] as List).isNotEmpty) {
          final map = Map<String, dynamic>.from(result['result'][0] as Map);
          return map['name'].toString();
        }
      }
    } catch (_) {
      // ignore network errors here; UI will show '-'
    }
    return null;
  }
}
