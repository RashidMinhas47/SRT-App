import 'dart:convert';
import 'package:bayanat/core/remote/api_helper/api_models.dart';
import 'package:bayanat/core/remote/api_helper/methods.dart';
import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:bayanat/modules/job_card/models/job_card_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/remote/api_helper/api_constance.dart';

class JobCardController extends GetxController {
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString error = ''.obs;

  // Lists for dropdown data
  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> customers = <Map<String, dynamic>>[].obs;

  // Selected values
  final RxInt selectedUserId = RxInt(0);
  final RxInt selectedCustomerId = RxInt(0);
  final RxString selectedHighlight = RxString('');

  // Highlight options
  final RxList<Map<String, String>> highlightOptions = <Map<String, String>>[
    {'value': 'yes', 'label': 'Yes'},
    {'value': 'no', 'label': 'No'},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        _fetchUsers(),
        _fetchCustomers(),
      ]);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitJobCard(JobCardModel jobCard) async {
    try {
      print('📝 Starting job card submission...');
      isSubmitting.value = true;

      if (selectedUserId.value == 0) {
        error.value = 'Please select an assigned user';
        Fluttertoast.showToast(
          msg: 'Please select an assigned user',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return false;
      }

      if (selectedCustomerId.value == 0) {
        error.value = 'Please select a customer';
        Fluttertoast.showToast(
          msg: 'Please select a customer',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return false;
      }

      final jobCardData = {
        'customer_id': selectedCustomerId.value,
        'customer_mobile_number': jobCard.customerMobileNumber,
        'location': jobCard.location,
        'assigned_user_id': selectedUserId.value,
        'customer_building_number': jobCard.customerBuildingName,
        'customer_house_flat_number': jobCard.customerHouseFlatNumber,
        'complaint_number': jobCard.complaintNumber,
        'work_description': jobCard.workDescription,
        'highlight':
            selectedHighlight.value.isNotEmpty ? selectedHighlight.value : 'no',
        // 'state': 'draft',
      };

      print('📦 Job Card data to submit: ${jsonEncode(jobCardData)}');

      // Validate mandatory fields
      if (jobCardData['customer_id'] == null ||
          jobCardData['customer_id'] == 0 ||
          jobCardData['customer_mobile_number'] == null ||
          jobCardData['customer_mobile_number'].toString().isEmpty ||
          jobCardData['location'] == null ||
          jobCardData['location'].toString().isEmpty ||
          jobCardData['work_description'] == null ||
          jobCardData['work_description'].toString().isEmpty) {
        print('❌ Mandatory fields missing');
        error.value = 'Please fill all required fields';
        Fluttertoast.showToast(
          msg: 'Please fill all required fields',
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
            'model': ApiModels.jobCard,
            'method': ApiMethods.create,
            'args': [jobCardData],
            'kwargs': {},
          }
        }),
      );

      print('🔍 Response Status Code: ${response.statusCode}');
      print('🔍 Response Headers: ${response.headers}');
      print('🔍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Response Body: ${jsonEncode(result)}');

        if (result['result'] != null) {
          print(
              '✅ Job Card submitted successfully with ID: ${result['result']}');
          Fluttertoast.showToast(
            msg: 'Job Card submitted successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          return true;
        } else if (result['error'] != null) {
          // Handle Odoo error message
          final errorData = result['error']['data'];
          final errorMessage =
              errorData['message'] ?? errorData['debug'] ?? 'Unknown error';
          print('❌ Odoo Error: $errorMessage');
          error.value = 'Server Error: $errorMessage';
          Fluttertoast.showToast(
            msg: 'Failed to submit job card: $errorMessage',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          return false;
        }
      }

      print('❌ Error Response Body: ${response.body}');
      error.value = 'Failed to submit job card: ${response.statusCode}';
      Fluttertoast.showToast(
        msg: 'Failed to submit job card: ${response.statusCode}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return false;
    } catch (e) {
      print('❌ Exception during submission: $e');
      error.value = 'Error submitting job card: $e';
      Fluttertoast.showToast(
        msg: 'Error submitting job card: $e',
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

  Future<void> _fetchUsers() async {
    try {
      print('📍 Fetching users...');

      final response = await http.post(
        Uri.parse('${ApiConsts.baseUrl}/web/dataset/call_kw'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode({
          'params': {
            'model': 'res.users',
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'fields': ['id', 'name', 'login'],
              'domain': [
                ['active', '=', true]
              ],
            }
          }
        }),
      );

      print('🔍 Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Response Body: ${jsonEncode(result)}');

        if (result['result'] != null) {
          users.value = List<Map<String, dynamic>>.from(result['result']);
          print('✅ Users fetched: ${users.length}');
        } else {
          throw Exception('No users found in response');
        }
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching users: $e');
      error.value = 'Error fetching users: $e';
      rethrow;
    }
  }

  Future<void> _fetchCustomers() async {
    try {
      print('📍 Fetching customers...');

      final response = await http.post(
        Uri.parse('${ApiConsts.baseUrl}/web/dataset/call_kw'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode({
          'params': {
            'model': 'res.partner',
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'fields': ['id', 'name', 'phone', 'mobile'],
              'domain': [
                ['is_company', '=', false],
                ['active', '=', true]
              ],
            }
          }
        }),
      );

      print('🔍 Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Response Body: ${jsonEncode(result)}');

        if (result['result'] != null) {
          customers.value = List<Map<String, dynamic>>.from(result['result']);
          print('✅ Customers fetched: ${customers.length}');
        } else {
          throw Exception('No customers found in response');
        }
      } else {
        throw Exception('Failed to fetch customers: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching customers: $e');
      error.value = 'Error fetching customers: $e';
      rethrow;
    }
  }

  // Helper method to get user by ID
  Map<String, dynamic>? getUserById(int id) {
    return users.firstWhereOrNull((user) => user['id'] == id);
  }

  // Helper method to get customer by ID
  Map<String, dynamic>? getCustomerById(int id) {
    return customers.firstWhereOrNull((customer) => customer['id'] == id);
  }

  // Helper method to validate mobile number
  bool isValidMobileNumber(String mobile) {
    // Basic validation for mobile number (can be customized based on requirements)
    return mobile.length >= 10 && mobile.length <= 15;
  }

  // Helper method to validate required fields
  String? validateRequiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
