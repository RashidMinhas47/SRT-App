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
  final RxString companyField = ''.obs;

  // Add employees list
  final RxList<EmployeeModel> employees = <EmployeeModel>[].obs;

  final RxString error = ''.obs;
  // Add filtered taxes list
  final RxList<TaxType> filteredTaxes = <TaxType>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  // Add RxMap to store field descriptions
  final RxMap<String, dynamic> paymentModeField = <String, dynamic>{}.obs;

  final RxInt selectedEmployeeId = RxInt(0);
  final RxList<TaxModel> taxes = <TaxModel>[].obs;
  final Rx<TextEditingController> totalAmountCompanyController =
      TextEditingController().obs;

  @override
  void onInit() {
    super.onInit();
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        _fetchCategories(),
        _fetchTaxes(),
        _fetchAccounts(),
        _fetchCompanyField(),
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
        'payment_mode': 'company_account',
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
          Get.offAll(() => JobCardScreen());
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

  // Future<bool> submitExpenseWithCustomData(
  //     Map<String, dynamic> expenseData) async {
  //   try {
  //     print('📝 Starting expense submission with custom data...');
  //     isSubmitting.value = true;

  //     if (selectedEmployeeId.value == 0) {
  //       error.value = 'Please select an employee';
  //       Get.snackbar(
  //         'Error',
  //         'Please select an employee',
  //         snackPosition: SnackPosition.TOP,
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //       );
  //       return false;
  //     }

  //     // Add employee_id and payment_mode to the data
  //     expenseData['employee_id'] = selectedEmployeeId.value;
  //     expenseData['payment_mode'] = 'company_account'; // Fixed value

  //     print('📦 Custom Expense data to submit: ${jsonEncode(expenseData)}');

  //     // Validate mandatory fields
  //     if (expenseData['name'] == null ||
  //         expenseData['product_id'] == null ||
  //         // expenseData['unit_amount'] == null ||
  //         expenseData['date'] == null) {
  //       print('❌ Mandatory fields missing');
  //       error.value = 'Please fill all required fields';
  //       Get.snackbar(
  //         'Error',
  //         'Please fill all required fields',
  //         snackPosition: SnackPosition.TOP,
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //       );
  //       return false;
  //     }

  //     final response = await http.post(
  //       Uri.parse('${ApiConsts.baseUrl}/web/dataset/call_kw'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Cookie': ConstanceManager.sessionId.toString(),
  //       },
  //       body: jsonEncode({
  //         'params': {
  //           'model': 'hr.expense',
  //           'method': 'create',
  //           'args': [expenseData],
  //           'kwargs': {},
  //         }
  //       }),
  //     );

  //     print('🔍 Response Status Code: ${response.statusCode}');
  //     print('🔍 Response Headers: ${response.headers}');
  //     print('🔍 Response Body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final result = jsonDecode(response.body);
  //       print('✅ Response Body: ${jsonEncode(result)}');

  //       if (result['result'] != null) {
  //         print(
  //             '✅ Expense submitted successfully with ID: ${result['result']}');
  //         Get.snackbar(
  //           'Success',
  //           'Expense submitted successfully',
  //           snackPosition: SnackPosition.TOP,
  //           backgroundColor: Colors.green,
  //           colorText: Colors.white,
  //         );
  //         return true;
  //       } else if (result['error'] != null) {
  //         // Handle Odoo error message
  //         final errorData = result['error']['data'];
  //         final errorMessage =
  //             errorData['message'] ?? errorData['debug'] ?? 'Unknown error';
  //         print('❌ Odoo Error: $errorMessage');
  //         error.value = 'Server Error: $errorMessage';
  //         Get.snackbar(
  //           'Error',
  //           'Failed to submit expense: $errorMessage',
  //           snackPosition: SnackPosition.TOP,
  //           backgroundColor: Colors.red,
  //           colorText: Colors.white,
  //         );
  //         return false;
  //       }
  //     }

  //     print('❌ Error Response Body: ${response.body}');
  //     error.value = 'Failed to submit expense: ${response.statusCode}';
  //     Get.snackbar(
  //       'Error',
  //       'Failed to submit expense: ${response.statusCode}',
  //       snackPosition: SnackPosition.TOP,
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //     return false;
  //   } catch (e) {
  //     print('❌ Exception during submission: $e');
  //     error.value = 'Error submitting expense: $e';
  //     Get.snackbar(
  //       'Error',
  //       'Error submitting expense: $e',
  //       snackPosition: SnackPosition.TOP,
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //     return false;
  //   } finally {
  //     isSubmitting.value = false;
  //   }
  // }

  // Update _getCurrentEmployeeId to be more robust
  // Future<int?> _getCurrentEmployeeId() async {
  //   try {
  //     print('🔍 Fetching employee ID for user: ${ConstanceManager.userId}');

  //     final response = await http.post(
  //       Uri.parse('${ApiConsts.baseUrl}/web/dataset/call_kw'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Cookie': ConstanceManager.sessionId.toString(),
  //       },
  //       body: jsonEncode({
  //         'params': {
  //           'model': 'hr.employee',
  //           'method': 'search_read',
  //           'args': [],
  //           'kwargs': {
  //             'fields': ['id', 'name'],
  //             'domain': [
  //               ['user_id', '=', ConstanceManager.userId],
  //             ],
  //             'limit': 1,
  //           }
  //         }
  //       }),
  //     );

  //     print('🔍 Response Status Code: ${response.statusCode}');

  //     if (response.statusCode == 200) {
  //       final result = jsonDecode(response.body);
  //       print('✅ Response Body: ${jsonEncode(result)}');

  //       if (result['result'] != null && result['result'].isNotEmpty) {
  //         final employeeId = result['result'][0]['id'] as int;
  //         print('✅ Found employee ID: $employeeId');
  //         return employeeId;
  //       } else {
  //         print('⚠️ No employee record found');
  //         return null;
  //       }
  //     }

  //     print('❌ Failed to fetch employee ID');
  //     return null;
  //   } catch (e) {
  //     print('❌ Error fetching employee ID: $e');
  //     return null;
  //   }
  // }

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
              'fieldnames': ['company_id']
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['result'] != null &&
            result['result']['company_id'] != null) {
          companyField.value = result['result']['company_id'].toString();
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
}
