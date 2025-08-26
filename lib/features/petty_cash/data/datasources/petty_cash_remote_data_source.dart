import 'package:bayanat/core/local/shared_prefrences.dart';
import 'package:bayanat/core/remote/api_helper/api_constance.dart';
import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:bayanat/features/petty_cash/domain/entities/petty_cash_bill.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/petty_cash_bill_model.dart';

abstract class PettyCashRemoteDataSource {
  Future<Either<Exception, PettyCashBillModel>> submitBill(
      PettyCashBillModel bill);
  Future<Either<Exception, PettyCashBillModel>> updateBill(
      PettyCashBillModel bill);
  Future<Either<Exception, List<PettyCashBillModel>>> getUserBills(
      String userId);
  Future<Either<Exception, List<PettyCashBillModel>>> getPendingAdvances(
      String userId);
  Future<Either<Exception, String>> uploadPhoto(String filePath);
  Future<Either<Exception, PettyCashBillModel>> linkBillToAdvance(
      String billId, String advanceId);
  Future<Either<Exception, List<PettyCashBillModel>>> getFilteredBills({
    String? userId,
    String? status,
    String? billType,
    String? startDate,
    String? endDate,
  });
  Future<Either<Exception, PettyCashBillModel>> updateBillStatus(
      String billId, String status, String? adminComments);
  Future<Either<Exception, String>> exportToExcel({
    String? userId,
    String? status,
    String? billType,
    String? startDate,
    String? endDate,
  });
}

class PettyCashRemoteDataSourceImpl implements PettyCashRemoteDataSource {
  final http.Client _client = http.Client();

  // Get current session/authentication - implement based on your auth system
  Future<Map<String, String>> _getAuthHeaders() async {
    // Get session from your auth service
    final sessionId = await _getCurrentSessionId();
    return {
      'Content-Type': 'application/json',
      'Cookie': 'session_id=$sessionId',
    };
  }

  String _getCurrentSessionId() {
    final String sessionId = ConstanceManager.sessionId ?? "";
    debugPrint(
        "Session ID:>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $sessionId<<<<<<<<<<<<<<<<<<<<<<");
    //  await CacheHelper.getData(key: 'sessionId') as String?;
    // if (sessionId == null) {
    //   throw Exception('No session found. Please login first.');
    // }
    return sessionId;
  }

  Future<int> _getCurrentUserId() async {
    final userId = ConstanceManager.userId as int;
    debugPrint(
        "Session ID:>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $userId<<<<<<<<<<<<<<<<<<<<<<");

    // await CacheHelper.getData(key: 'userId') as int?;
    // if (userId == null) {
    //   throw Exception('No user ID found. Please login first.');
    // }
    return userId;
  }

  @override
  Future<Either<Exception, PettyCashBillModel>> submitBill(
      PettyCashBillModel bill) async {
    try {
      final headers = await _getAuthHeaders();
      final userId = await _getCurrentUserId();

      // Map your model fields to hr.expense standard fields + custom fields
      final expenseData = {
        // Standard hr.expense fields
        'name': bill.comments.isNotEmpty
            ? bill.comments
            : '${bill.billType.name} - ${bill.location}',
        'unit_amount': bill.amount,
        'date': bill.expenseDate.toIso8601String().split('T')[0],
        'employee_id':
            userId, // This should be the employee record ID, not string
        'product_id':
            1, // You need to get/create a product for petty cash expenses
        'payment_mode': 'own_account',

        // Your custom fields (add these to hr.expense model)
        'x_bill_type': bill.billType.name,
        'x_bill_number': bill.billNumber,
        'x_vendor_name': bill.vendorName,
        'x_customer_project_name': bill.customerProjectName,
        'x_location': bill.location,
        'x_comments': bill.comments,
        'x_photo_url': bill.photoUrl,
        'x_status': bill.status.name,
        'x_user_id': bill.userId,
        'x_is_advance_payment': bill.isAdvancePayment,
        'x_advance_purpose': bill.advancePurpose,
        'x_expected_amount': bill.expectedAmount,
        'x_parent_advance_id': bill.parentAdvanceId,
      };

      // Remove null values
      expenseData.removeWhere((key, value) => value == null);

      final requestBody = {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'service': 'object',
          'method': 'execute_kw',
          'args': [
            ApiConsts.db,
            userId,
            'password', // You need to handle authentication properly
            'hr.expense', // Use existing hr.expense model
            'create',
            [expenseData]
          ]
        }
      };

      final response = await _client.post(
        Uri.parse('${ApiConsts.baseUrl}web/dataset/call_kw'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('Expense create response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['result'] != null && jsonData['error'] == null) {
          final expenseId = jsonData['result'];

          // Return updated bill with Odoo ID
          final updatedBill = PettyCashBillModel(
            id: expenseId.toString(),
            billType: bill.billType,
            billNumber: bill.billNumber,
            vendorName: bill.vendorName,
            customerProjectName: bill.customerProjectName,
            location: bill.location,
            amount: bill.amount,
            expenseDate: bill.expenseDate,
            comments: bill.comments,
            photoUrl: bill.photoUrl,
            status: BillStatus.pending,
            userId: bill.userId,
            createdAt: DateTime.now(),
            isAdvancePayment: bill.isAdvancePayment,
            advancePurpose: bill.advancePurpose,
            expectedAmount: bill.expectedAmount,
            parentAdvanceId: bill.parentAdvanceId,
          );

          return Right(updatedBill);
        } else {
          return Left(
              Exception('Failed to create expense: ${jsonData['error']}'));
        }
      } else {
        return Left(Exception('HTTP Error: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Exception('Error submitting bill: $e'));
    }
  }

  @override
  Future<Either<Exception, List<PettyCashBillModel>>> getUserBills(
      String userId) async {
    try {
      final headers = await _getAuthHeaders();
      final currentUserId = await _getCurrentUserId();

      final requestBody = {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'service': 'object',
          'method': 'execute_kw',
          'args': [
            ApiConsts.db,
            currentUserId,
            'password',
            'hr.expense',
            'search_read',
            [
              [
                ['x_user_id', '=', userId]
              ] // Filter by your mobile app user ID
            ],
            {
              'fields': [
                'id',
                'name',
                'unit_amount',
                'date',
                'state',
                'employee_id',
                'x_bill_type',
                'x_bill_number',
                'x_vendor_name',
                'x_customer_project_name',
                'x_location',
                'x_comments',
                'x_photo_url',
                'x_status',
                'x_user_id',
                'create_date',
                'write_date',
                'x_is_advance_payment',
                'x_advance_purpose',
                'x_expected_amount',
                'x_parent_advance_id'
              ],
              'order': 'create_date desc'
            }
          ]
        }
      };

      final response = await _client.post(
        Uri.parse('${ApiConsts.baseUrl}web/dataset/call_kw'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['result'] != null) {
          final List<dynamic> expenses = jsonData['result'];
          final bills = expenses.map((expense) {
            return PettyCashBillModel(
              id: expense['id'].toString(),
              billType: _parseBillType(expense['x_bill_type']),
              billNumber: expense['x_bill_number'],
              vendorName: expense['x_vendor_name'],
              customerProjectName: expense['x_customer_project_name'],
              location: expense['x_location'] ?? '',
              amount: (expense['unit_amount'] ?? 0.0).toDouble(),
              expenseDate: DateTime.parse(expense['date']),
              comments: expense['x_comments'] ?? '',
              photoUrl: expense['x_photo_url'] ?? '',
              status: _parseBillStatus(expense['x_status']),
              userId: expense['x_user_id'] ?? '',
              createdAt: DateTime.parse(expense['create_date']),
              updatedAt: expense['write_date'] != null
                  ? DateTime.parse(expense['write_date'])
                  : null,
              isAdvancePayment: expense['x_is_advance_payment'] ?? false,
              advancePurpose: expense['x_advance_purpose'],
              expectedAmount: expense['x_expected_amount']?.toDouble(),
              parentAdvanceId: expense['x_parent_advance_id'],
            );
          }).toList();
          return Right(bills);
        } else {
          return Left(Exception('Failed to fetch bills'));
        }
      } else {
        return Left(Exception('HTTP Error: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Exception('Error fetching user bills: $e'));
    }
  }

  @override
  Future<Either<Exception, String>> uploadPhoto(String filePath) async {
    try {
      final headers = await _getAuthHeaders();
      final file = File(filePath);

      if (!file.existsSync()) {
        return Left(Exception('File does not exist'));
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConsts.baseUrl}web/binary/upload_attachment'),
      );

      // Remove Content-Type as it's set automatically for multipart
      final headersWithoutContentType = Map<String, String>.from(headers);
      headersWithoutContentType.remove('Content-Type');
      request.headers.addAll(headersWithoutContentType);

      request.files.add(await http.MultipartFile.fromPath('ufile', filePath));
      request.fields['model'] = 'hr.expense';
      request.fields['id'] = '0';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        // Return the file URL that can be stored in x_photo_url
        return Right('${ApiConsts.baseUrl}web/content/${jsonData['id']}');
      } else {
        return Left(Exception('Upload failed: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Exception('Error uploading photo: $e'));
    }
  }

  // Helper methods to parse enums
  BillType _parseBillType(String? value) {
    switch (value) {
      case 'materialPurchase':
        return BillType.materialPurchase;
      case 'foodMeals':
        return BillType.foodMeals;
      case 'transportFuel':
        return BillType.transportFuel;
      case 'miscellaneous':
        return BillType.miscellaneous;
      case 'advanceRequest':
        return BillType.advanceRequest;
      default:
        return BillType.miscellaneous;
    }
  }

  BillStatus _parseBillStatus(String? value) {
    switch (value) {
      case 'pending':
        return BillStatus.pending;
      case 'pendingBillSubmission':
        return BillStatus.pendingBillSubmission;
      case 'billPending':
        return BillStatus.billPending;
      case 'approved':
        return BillStatus.approved;
      case 'rejected':
        return BillStatus.rejected;
      case 'needsClarification':
        return BillStatus.needsClarification;
      default:
        return BillStatus.pending;
    }
  }

  // Implement remaining methods with similar patterns
  @override
  Future<Either<Exception, PettyCashBillModel>> updateBill(
      PettyCashBillModel bill) async {
    // Similar to submitBill but using 'write' instead of 'create'
    return Left(Exception('Not implemented yet'));
  }

  @override
  Future<Either<Exception, List<PettyCashBillModel>>> getPendingAdvances(
      String userId) async {
    // Filter by x_is_advance_payment = true and x_status = 'approved'
    return Left(Exception('Not implemented yet'));
  }

  @override
  Future<Either<Exception, PettyCashBillModel>> linkBillToAdvance(
      String billId, String advanceId) async {
    // Update x_parent_advance_id field
    return Left(Exception('Not implemented yet'));
  }

  @override
  Future<Either<Exception, List<PettyCashBillModel>>> getFilteredBills({
    String? userId,
    String? status,
    String? billType,
    String? startDate,
    String? endDate,
  }) async {
    // Build dynamic domain filters
    return Left(Exception('Not implemented yet'));
  }

  @override
  Future<Either<Exception, PettyCashBillModel>> updateBillStatus(
      String billId, String status, String? adminComments) async {
    // Update x_status field
    return Left(Exception('Not implemented yet'));
  }

  @override
  Future<Either<Exception, String>> exportToExcel({
    String? userId,
    String? status,
    String? billType,
    String? startDate,
    String? endDate,
  }) async {
    return Left(Exception('Not implemented yet'));
  }
}
