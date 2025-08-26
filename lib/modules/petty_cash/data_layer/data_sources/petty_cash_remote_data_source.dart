import 'dart:convert';
import 'dart:developer' as developer;
import 'package:bayanat/core/remote/api_helper/api_models.dart';
import 'package:bayanat/core/remote/api_helper/api_constance.dart';
import 'package:bayanat/core/remote/api_helper/end_points.dart';
import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../data_layer/models/petty_cash_model.dart';

abstract class BasePettyCashRemoteDataSource {
  Future<Either<Exception, bool>> submitPettyCash({
    required PettyCashModel pettyCash,
  });

  // Debug method to test API connection
  Future<void> debugApiConnection();

  // Get pending bills for bill submission
  Future<Either<Exception, List<PettyCashModel>>> getPendingBills();

  // Complete advance payment with final bill details
  Future<Either<Exception, PettyCashModel>> completeAdvancePayment({
    required String advanceId,
    required String vendorName,
    required double actualAmount,
    required List<String> billPhotos,
  });

  // Generate PDF for petty cash request
  Future<Either<Exception, String>> generatePettyCashPDF(String requestId);

  // Get PDF content for download
  Future<Either<Exception, List<int>>> downloadPettyCashPDF(String requestId);

  // Get user's petty cash requests with PDF links
  Future<Either<Exception, List<PettyCashModel>>> getUserPettyCashRequests();

  // Enhanced debug methods
  Future<void> debugModelAndData();
  Future<void> testDifferentSearchMethods();
}

class PettyCashRemoteDataSource extends BasePettyCashRemoteDataSource {
  // Simple debug print function
  void _debugPrint(String message) {
    print('🔍 [PettyCashAPI] $message');
    developer.log(message, name: 'PettyCashAPI');
  }

  // Test API connection and session validity
  Future<bool> _testApiConnection() async {
    try {
      _debugPrint('Testing API connection...');
      _debugPrint('Session ID: ${ConstanceManager.sessionId}');
      _debugPrint('User ID: ${ConstanceManager.userId}');

      final testUrl = ApiConsts.baseUrl + ApiEndPoints.callKw;
      _debugPrint('Test URL: $testUrl');

      final testBody = {
        "params": {
          "model": "res.users",
          "method": "search_read",
          "kwargs": {
            "domain": [
              ["id", "=", ConstanceManager.userId ?? 0]
            ],
            "fields": ["id", "name"]
          },
          "args": []
        }
      };

      _debugPrint('Test request body: ${jsonEncode(testBody)}');

      final response = await http.post(
        Uri.parse(testUrl),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode(testBody),
      );

      _debugPrint('Test response status: ${response.statusCode}');
      _debugPrint('Test response body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      _debugPrint('API connection test failed: $e');
      return false;
    }
  }

  // Check if petty cash model exists and get its fields
  Future<Map<String, dynamic>?> _checkPettyCashModel() async {
    try {
      _debugPrint('Checking petty cash model structure...');

      final checkUrl = ApiConsts.baseUrl + ApiEndPoints.callKw;
      final checkBody = {
        "params": {
          "model": ApiModels.pettyCash,
          "method": "fields_get",
          "kwargs": {},
          "args": []
        }
      };

      _debugPrint('Model check request body: ${jsonEncode(checkBody)}');

      final response = await http.post(
        Uri.parse(checkUrl),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode(checkBody),
      );

      _debugPrint('Model check response status: ${response.statusCode}');
      _debugPrint('Model check response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey("result")) {
          _debugPrint('Petty cash model fields: ${responseData["result"]}');
          return responseData["result"];
        }
      }

      return null;
    } catch (e) {
      _debugPrint('Error checking petty cash model: $e');
      return null;
    }
  }

  Future<List<int>> _uploadToAttachments({required List<String> photos}) async {
    List<int> list = [];
    _debugPrint('Starting photo upload process for ${photos.length} photos');

    for (int i = 0; i < photos.length; i++) {
      var element = photos[i];
      _debugPrint('Processing photo ${i + 1}/${photos.length}');

      if (!element.contains(ApiConsts.imageUrl)) {
        try {
          List<int> binaryImageData = base64Decode(element);
          String format = _getImageFormat(binaryImageData);

          final uploadUrl = ApiConsts.baseUrl + ApiEndPoints.callKw;
          _debugPrint('Uploading photo to: $uploadUrl');

          final uploadBody = {
            "params": {
              "model": ApiModels.attachment,
              "method": "create",
              "kwargs": {},
              "args": [
                {
                  "name": "petty_${element.length}.$format",
                  "datas": element,
                }
              ],
            },
          };

          _debugPrint('Upload request body: ${jsonEncode(uploadBody)}');

          final res = await http.post(
            Uri.parse(uploadUrl),
            headers: {
              'Content-Type': 'application/json',
              'Connection': 'keep-alive',
              'Cookie': ConstanceManager.sessionId.toString(),
            },
            body: jsonEncode(uploadBody),
          );

          _debugPrint('Upload response status: ${res.statusCode}');
          _debugPrint('Upload response body: ${res.body}');

          if (res.statusCode == 200) {
            final responseData = jsonDecode(res.body);
            if (responseData.containsKey("result")) {
              final value = responseData["result"];
              list.add(value);
              _debugPrint('Successfully uploaded photo, ID: $value');
            } else {
              _debugPrint('Upload response missing result field: ${res.body}');
            }
          } else {
            _debugPrint(
                'Upload failed with status ${res.statusCode}: ${res.body}');
          }
        } catch (e) {
          _debugPrint('Error uploading photo: $e');
          // ignore and continue; we'll return what succeeded
        }
      } else {
        _debugPrint('Photo already has image URL, skipping upload');
      }
    }

    _debugPrint(
        'Photo upload completed. Successfully uploaded: ${list.length}/${photos.length}');
    return list;
  }

  String _getImageFormat(List<int> binary) {
    if (binary.length >= 3 &&
        binary[0] == 0xFF &&
        binary[1] == 0xD8 &&
        binary[2] == 0xFF) {
      return 'jpg';
    }
    if (binary.length >= 8 &&
        binary[0] == 0x89 &&
        binary[1] == 0x50 &&
        binary[2] == 0x4E &&
        binary[3] == 0x47 &&
        binary[4] == 0x0D &&
        binary[5] == 0x0A &&
        binary[6] == 0x1A &&
        binary[7] == 0x0A) {
      return 'png';
    }
    return 'jpg';
  }

  @override
  Future<Either<Exception, bool>> submitPettyCash({
    required PettyCashModel pettyCash,
  }) async {
    try {
      developer.log('Starting petty cash submission', name: 'PettyCashAPI');
      developer.log(
          'Petty cash data: vendor=${pettyCash.vendorName}, amount=${pettyCash.amount}, description=${pettyCash.description}',
          name: 'PettyCashAPI');

      // Test API connection first
      final isConnected = await _testApiConnection();
      if (!isConnected) {
        _debugPrint('API connection test failed');
        return Left(Exception(
            'API connection failed. Please check your session and try again.'));
      }

      // Check petty cash model structure
      final modelFields = await _checkPettyCashModel();
      if (modelFields == null) {
        _debugPrint('Petty cash model not found or not accessible');
        // Continue with fallback to job card
      } else {
        _debugPrint(
            'Petty cash model found with fields: ${modelFields.keys.toList()}');
      }

      final billIds = await _uploadToAttachments(
        photos: pettyCash.billPhotosBase64,
      );

      // Try to use the proper petty cash model first
      final pettyCashUrl = ApiConsts.baseUrl + ApiEndPoints.callKw;
      _debugPrint('Submitting petty cash to: $pettyCashUrl');

      // Build request body based on available fields
      Map<String, dynamic> pettyCashData = {};
      if (modelFields != null) {
        // Use actual model fields if available
        if (modelFields.containsKey('x_vendor_name') ||
            modelFields.containsKey('vendor_name')) {
          pettyCashData['x_vendor_name'] = pettyCash.vendorName;
        }
        if (modelFields.containsKey('x_description') ||
            modelFields.containsKey('description')) {
          pettyCashData['x_description'] = pettyCash.description;
        }
        if (modelFields.containsKey('x_amount') ||
            modelFields.containsKey('amount')) {
          pettyCashData['x_amount'] = pettyCash.amount;
        }
        if (modelFields.containsKey('x_date') ||
            modelFields.containsKey('date')) {
          pettyCashData['x_date'] =
              pettyCash.date.toIso8601String().split('T').first;
        }
        if (modelFields.containsKey('x_bill_photos') ||
            modelFields.containsKey('bill_photos')) {
          pettyCashData['x_bill_photos'] = billIds.isNotEmpty ? billIds : [];
        }
        // Add new fields
        if (modelFields.containsKey('x_bill_type') ||
            modelFields.containsKey('bill_type')) {
          pettyCashData['x_bill_type'] = pettyCash.billType.name;
        }
        if (modelFields.containsKey('x_bill_number') ||
            modelFields.containsKey('bill_number')) {
          pettyCashData['x_bill_number'] = pettyCash.billNumber;
        }
        if (modelFields.containsKey('x_customer_project_name') ||
            modelFields.containsKey('customer_project_name')) {
          pettyCashData['x_customer_project_name'] =
              pettyCash.customerProjectName;
        }
        if (modelFields.containsKey('x_location') ||
            modelFields.containsKey('location')) {
          pettyCashData['x_location'] = pettyCash.location;
        }
        if (modelFields.containsKey('x_comments') ||
            modelFields.containsKey('comments')) {
          pettyCashData['x_comments'] = pettyCash.comments;
        }
        if (modelFields.containsKey('x_is_advance_request') ||
            modelFields.containsKey('is_advance_request')) {
          pettyCashData['x_is_advance_request'] = pettyCash.isAdvanceRequest;
        }
        if (modelFields.containsKey('x_advance_purpose') ||
            modelFields.containsKey('advance_purpose')) {
          pettyCashData['x_advance_purpose'] = pettyCash.advancePurpose;
        }
        if (modelFields.containsKey('x_expected_amount') ||
            modelFields.containsKey('expected_amount')) {
          pettyCashData['x_expected_amount'] = pettyCash.expectedAmount;
        }
        if (modelFields.containsKey('x_project_customer_name') ||
            modelFields.containsKey('project_customer_name')) {
          pettyCashData['x_project_customer_name'] =
              pettyCash.projectCustomerName;
        }
        if (modelFields.containsKey('x_status') ||
            modelFields.containsKey('status')) {
          pettyCashData['x_status'] =
              pettyCash.isAdvanceRequest ? "pendingBillSubmission" : "pending";
        }
        if (modelFields.containsKey('x_user_id') ||
            modelFields.containsKey('user_id')) {
          pettyCashData['x_user_id'] = pettyCash.userId;
        }
      } else {
        // Fallback to default field names
        pettyCashData = {
          "x_vendor_name": pettyCash.vendorName,
          "x_description": pettyCash.description,
          "x_amount": pettyCash.amount,
          "x_date": pettyCash.date.toIso8601String().split('T').first,
          "x_bill_photos": billIds.isNotEmpty ? billIds : [],
          "x_bill_type": pettyCash.billType.name,
          "x_bill_number": pettyCash.billNumber,
          "x_customer_project_name": pettyCash.customerProjectName,
          "x_location": pettyCash.location,
          "x_comments": pettyCash.comments,
          "x_is_advance_request": pettyCash.isAdvanceRequest,
          "x_advance_purpose": pettyCash.advancePurpose,
          "x_expected_amount": pettyCash.expectedAmount,
          "x_project_customer_name": pettyCash.projectCustomerName,
          "x_status":
              pettyCash.isAdvanceRequest ? "pendingBillSubmission" : "pending",
          "x_user_id": pettyCash.userId,
        };
      }

      final pettyCashBody = {
        "params": {
          "model": ApiModels.pettyCash,
          "method": "create",
          "kwargs": {},
          "args": [pettyCashData],
        },
      };

      _debugPrint('Petty cash request body: ${jsonEncode(pettyCashBody)}');

      var response = await http.post(
        Uri.parse(pettyCashUrl),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode(pettyCashBody),
      );

      _debugPrint('Petty cash response status: ${response.statusCode}');
      _debugPrint('Petty cash response body: ${response.body}');

      // If petty cash model doesn't exist (404), fall back to job card
      if (response.statusCode == 404) {
        _debugPrint(
            'Petty cash model not found, falling back to job card model');

        final jobCardBody = {
          "params": {
            "model": ApiModels.jobCard,
            "method": "create",
            "kwargs": {},
            "args": [
              {
                "customer_name": pettyCash.vendorName,
                "work_description": pettyCash.description,
                "comments":
                    "Petty Cash: ${pettyCash.amount} - ${pettyCash.date.toIso8601String().split('T').first} - ${pettyCash.comments}",
                "location": pettyCash.location,
                "fault_ids": billIds.isNotEmpty ? [billIds.first] : [],
              }
            ],
          },
        };

        _debugPrint(
            'Job card fallback request body: ${jsonEncode(jobCardBody)}');

        response = await http.post(
          Uri.parse(pettyCashUrl),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
            'Cookie': ConstanceManager.sessionId.toString(),
          },
          body: jsonEncode(jobCardBody),
        );

        _debugPrint(
            'Job card fallback response status: ${response.statusCode}');
        _debugPrint('Job card fallback response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        _debugPrint('Petty cash submission successful');
        return const Right(true);
      }

      _debugPrint(
          'Petty cash submission failed with status ${response.statusCode}: ${response.body}');
      return Left(Exception(
          "Failed to submit petty cash: ${response.statusCode} - ${response.body}"));
    } on Exception catch (e) {
      _debugPrint('Exception during petty cash submission: $e');
      return Left(e);
    }
  }

  @override
  Future<void> debugApiConnection() async {
    final isConnected = await _testApiConnection();
    _debugPrint(
        'API Connection Debug: ${isConnected ? 'Connected' : 'Disconnected'}');

    final modelFields = await _checkPettyCashModel();
    if (modelFields != null) {
      _debugPrint(
          'Petty Cash Model Debug: Found with fields: ${modelFields.keys.toList()}');
    } else {
      _debugPrint('Petty Cash Model Debug: Not found or accessible.');
    }
  }

  @override
  Future<Either<Exception, List<PettyCashModel>>> getPendingBills() async {
    try {
      _debugPrint('Getting pending bills...');
      final currentUserId = ConstanceManager.userId?.toString() ?? 'unknown';
      final currentUserIdInt = int.tryParse(currentUserId) ?? 0;
      _debugPrint(
          'Current user ID (string): $currentUserId, (int): $currentUserIdInt');

      final url = ApiConsts.baseUrl + ApiEndPoints.callKw;

      // First, try to get bills from petty cash model
      final List<Map<String, dynamic>> pettyCashSearchVariants = [
        {
          "domain": [
            ["x_status", "=", "pendingBillSubmission"],
            ["x_is_advance_request", "=", true],
            ["x_user_id", "=", currentUserIdInt]
          ],
          "description": "Petty Cash - Integer User ID"
        },
        {
          "domain": [
            ["x_status", "=", "pendingBillSubmission"],
            ["x_is_advance_request", "=", true],
            ["x_user_id", "=", currentUserId]
          ],
          "description": "Petty Cash - String User ID"
        },
        {
          "domain": [
            ["x_status", "=", "pendingBillSubmission"],
            ["x_is_advance_request", "=", true],
            ["user_id", "=", currentUserIdInt]
          ],
          "description": "Petty Cash - user_id field (int)"
        },
        {
          "domain": [
            ["x_status", "=", "pendingBillSubmission"],
            ["x_is_advance_request", "=", true],
            ["create_uid", "=", currentUserIdInt]
          ],
          "description": "Petty Cash - create_uid field"
        }
      ];

      // Try petty cash model first
      for (int i = 0; i < pettyCashSearchVariants.length; i++) {
        final variant = pettyCashSearchVariants[i];
        _debugPrint(
            'Trying petty cash search variant ${i + 1}: ${variant["description"]}');

        final body = {
          "params": {
            "model": ApiModels.pettyCash,
            "method": "search_read",
            "kwargs": {
              "domain": variant["domain"],
              "fields": [
                "id",
                "x_vendor_name",
                "x_description",
                "x_amount",
                "x_date",
                "x_bill_type",
                "x_bill_number",
                "x_customer_project_name",
                "x_location",
                "x_comments",
                "x_is_advance_request",
                "x_advance_purpose",
                "x_expected_amount",
                "x_project_customer_name",
                "x_status",
                "x_user_id",
                "create_date",
                "write_date"
              ]
            },
            "args": []
          }
        };

        _debugPrint('Petty cash request: ${jsonEncode(body)}');

        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
            'Cookie': ConstanceManager.sessionId.toString(),
          },
          body: jsonEncode(body),
        );

        _debugPrint('Petty cash response status: ${response.statusCode}');
        _debugPrint('Petty cash response body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData.containsKey("result")) {
            final List<dynamic> bills = responseData["result"];

            if (bills.isNotEmpty) {
              _debugPrint(
                  '✅ Found ${bills.length} petty cash records with ${variant["description"]}');

              final List<PettyCashModel> pendingBills = [];
              for (int j = 0; j < bills.length; j++) {
                try {
                  final bill = PettyCashModel.fromJson(bills[j]);
                  pendingBills.add(bill);
                  _debugPrint(
                      'Successfully parsed petty cash bill $j: ${bill.id}');
                } catch (e) {
                  _debugPrint('Error parsing petty cash bill $j: $e');
                  _debugPrint('Bill $j data: ${bills[j]}');
                }
              }

              return Right(pendingBills);
            } else {
              _debugPrint(
                  '❌ No petty cash bills found with ${variant["description"]}');
            }
          } else {
            _debugPrint(
                '❌ Petty cash response missing "result" key for ${variant["description"]}');
            _debugPrint('Available keys: ${responseData.keys.toList()}');
          }
        } else {
          _debugPrint(
              '❌ Petty cash HTTP Error ${response.statusCode} for ${variant["description"]}');
        }
      }

      // If petty cash model fails, try job card model where bills might be stored
      _debugPrint(
          'Petty cash model not found or no records, trying job card model...');

      final List<Map<String, dynamic>> jobCardSearchVariants = [
        {
          "domain": [
            ["comments", "ilike", "Petty Cash"],
            ["assigned_user_id", "=", currentUserIdInt]
          ],
          "description": "Job Card - Petty Cash Comments + User ID"
        },
        {
          "domain": [
            ["comments", "ilike", "Petty Cash"]
          ],
          "description": "Job Card - Petty Cash Comments Only"
        },
        {
          "domain": [
            ["assigned_user_id", "=", currentUserIdInt]
          ],
          "description": "Job Card - User ID Only"
        }
      ];

      for (int i = 0; i < jobCardSearchVariants.length; i++) {
        final variant = jobCardSearchVariants[i];
        _debugPrint(
            'Trying job card search variant ${i + 1}: ${variant["description"]}');

        final body = {
          "params": {
            "model": ApiModels.jobCard,
            "method": "search_read",
            "kwargs": {
              "domain": variant["domain"],
              "fields": [
                "id",
                "customer_name",
                "work_description",
                "comments",
                "location",
                "assigned_user_id",
                "create_date",
                "write_date"
              ]
            },
            "args": []
          }
        };

        _debugPrint('Job card request: ${jsonEncode(body)}');

        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
            'Cookie': ConstanceManager.sessionId.toString(),
          },
          body: jsonEncode(body),
        );

        _debugPrint('Job card response status: ${response.statusCode}');
        _debugPrint('Job card response body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData.containsKey("result")) {
            final List<dynamic> requests = responseData["result"];
            if (requests.isNotEmpty) {
              _debugPrint(
                  '✅ Found ${requests.length} job card records with ${variant["description"]}');
              final List<PettyCashModel> models = [];

              for (int j = 0; j < requests.length; j++) {
                try {
                  // Convert job card data to petty cash model
                  final jobCardData = requests[j];
                  final comments = jobCardData['comments'] ?? '';

                  // Only process if it's a petty cash entry
                  if (comments.toString().contains('Petty Cash')) {
                    final pettyCashData =
                        _convertJobCardToPettyCash(jobCardData);
                    final model = PettyCashModel.fromJson(pettyCashData);
                    models.add(model);
                    _debugPrint(
                        'Successfully converted job card to petty cash: ${jobCardData['id']}');
                  }
                } catch (e) {
                  _debugPrint('Error parsing job card record $j: $e');
                }
              }

              if (models.isNotEmpty) {
                _debugPrint(
                    '✅ Successfully converted ${models.length} job card records to petty cash models');
                return Right(models);
              } else {
                _debugPrint('❌ No valid petty cash records found in job cards');
              }
            } else {
              _debugPrint(
                  '❌ No job card records found with ${variant["description"]}');
            }
          } else {
            _debugPrint(
                '❌ Job card response missing "result" key for ${variant["description"]}');
            _debugPrint('Available keys: ${responseData.keys.toList()}');
          }
        } else {
          _debugPrint(
              '❌ Job card HTTP Error ${response.statusCode} for ${variant["description"]}');
        }
      }

      _debugPrint('⚠️ No pending bills found with any search method');
      return Right([]);
    } catch (e) {
      _debugPrint('Error getting pending bills: $e');
      return Left(e as Exception);
    }
  }

  // Helper method to convert job card data to petty cash format
  Map<String, dynamic> _convertJobCardToPettyCash(
      Map<String, dynamic> jobCardData) {
    final comments = jobCardData['comments'] ?? '';
    final customerName = jobCardData['customer_name'] ?? '';
    final workDescription = jobCardData['work_description'] ?? '';
    final location = jobCardData['location'] ?? '';

    // Extract amount from comments if possible
    double amount = 0.0;
    final amountMatch =
        RegExp(r'Petty Cash: ([\d.]+)').firstMatch(comments.toString());
    if (amountMatch != null) {
      amount = double.tryParse(amountMatch.group(1) ?? '0') ?? 0.0;
    }

    // Extract date from comments if possible
    DateTime date = DateTime.now();
    final dateMatch =
        RegExp(r'(\d{4}-\d{2}-\d{2})').firstMatch(comments.toString());
    if (dateMatch != null) {
      date = DateTime.tryParse(dateMatch.group(1) ?? '') ?? DateTime.now();
    }

    return {
      "id": jobCardData['id']?.toString(),
      "x_vendor_name": customerName,
      "x_description": workDescription,
      "x_amount": amount,
      "x_date": date.toIso8601String().split('T').first,
      "x_bill_type": "miscellaneous",
      "x_bill_number": "",
      "x_customer_project_name": "",
      "x_location": location,
      "x_comments": comments,
      "x_is_advance_request":
          true, // Assume it's an advance request since it's pending
      "x_advance_purpose": "",
      "x_expected_amount": amount,
      "x_project_customer_name": "",
      "x_status": "pendingBillSubmission",
      "x_user_id": jobCardData['assigned_user_id']?.toString() ?? "",
      "create_date":
          jobCardData['create_date'] ?? DateTime.now().toIso8601String(),
      "write_date": jobCardData['write_date']
    };
  }

  @override
  Future<Either<Exception, PettyCashModel>> completeAdvancePayment({
    required String advanceId,
    required String vendorName,
    required double actualAmount,
    required List<String> billPhotos,
  }) async {
    try {
      _debugPrint('Completing advance payment for ID: $advanceId');

      // Upload bill photos first
      final billIds = await _uploadToAttachments(photos: billPhotos);

      final url = ApiConsts.baseUrl + ApiEndPoints.callKw;
      final body = {
        "params": {
          "model": ApiModels.pettyCash,
          "method": "write",
          "kwargs": {},
          "args": [
            [int.parse(advanceId)],
            {
              "x_vendor_name": vendorName,
              "x_amount": actualAmount,
              "x_bill_photos": billIds,
              "x_status": "billPending",
              "x_is_advance_request": false,
            }
          ],
        }
      };

      _debugPrint('Complete advance payment request: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode(body),
      );

      _debugPrint(
          'Complete advance payment response status: ${response.statusCode}');
      _debugPrint('Complete advance payment response body: ${response.body}');

      if (response.statusCode == 200) {
        // Get the updated bill
        final getBody = {
          "params": {
            "model": ApiModels.pettyCash,
            "method": "read",
            "kwargs": {
              "fields": [
                "id",
                "x_vendor_name",
                "x_description",
                "x_amount",
                "x_date",
                "x_bill_type",
                "x_bill_number",
                "x_customer_project_name",
                "x_location",
                "x_comments",
                "x_is_advance_request",
                "x_advance_purpose",
                "x_expected_amount",
                "x_project_customer_name",
                "x_status",
                "x_user_id",
                "create_date",
                "write_date"
              ]
            },
            "args": [int.parse(advanceId)]
          }
        };

        final getResponse = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
            'Cookie': ConstanceManager.sessionId.toString(),
          },
          body: jsonEncode(getBody),
        );

        if (getResponse.statusCode == 200) {
          final responseData = jsonDecode(getResponse.body);
          if (responseData.containsKey("result")) {
            final bill = PettyCashModel.fromJson(responseData["result"][0]);
            _debugPrint('Advance payment completed successfully');
            return Right(bill);
          }
        }
      }

      return Left(Exception(
          'Failed to complete advance payment: ${response.statusCode}'));
    } catch (e) {
      _debugPrint('Error completing advance payment: $e');
      return Left(e as Exception);
    }
  }

  @override
  Future<Either<Exception, String>> generatePettyCashPDF(
      String requestId) async {
    try {
      _debugPrint('Generating PDF for petty cash request: $requestId');

      final url = ApiConsts.baseUrl + ApiEndPoints.callKw;
      final body = {
        "params": {
          "model": ApiModels.pettyCash,
          "method": "generate_pdf",
          "kwargs": {
            "request_id": int.parse(requestId),
          },
          "args": []
        }
      };

      _debugPrint('Generate PDF request: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode(body),
      );

      _debugPrint('Generate PDF response status: ${response.statusCode}');
      _debugPrint('Generate PDF response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey("result")) {
          final pdfUrl = responseData["result"];
          _debugPrint('PDF generated successfully: $pdfUrl');
          return Right(pdfUrl);
        }
      }

      return Left(Exception('Failed to generate PDF: ${response.statusCode}'));
    } catch (e) {
      _debugPrint('Error generating PDF: $e');
      return Left(e as Exception);
    }
  }

  @override
  Future<Either<Exception, List<int>>> downloadPettyCashPDF(
      String requestId) async {
    try {
      _debugPrint('Downloading PDF for petty cash request: $requestId');

      // First generate the PDF
      final pdfResult = await generatePettyCashPDF(requestId);
      return pdfResult.fold(
        (exception) => Left(exception),
        (pdfUrl) async {
          try {
            final response = await http.get(Uri.parse(pdfUrl));
            if (response.statusCode == 200) {
              _debugPrint('PDF downloaded successfully');
              return Right(response.bodyBytes);
            } else {
              return Left(
                  Exception('Failed to download PDF: ${response.statusCode}'));
            }
          } catch (e) {
            return Left(e as Exception);
          }
        },
      );
    } catch (e) {
      _debugPrint('Error downloading PDF: $e');
      return Left(e as Exception);
    }
  }

  @override
  Future<Either<Exception, List<PettyCashModel>>>
      getUserPettyCashRequests() async {
    try {
      _debugPrint('=== GETTING USER PETTY CASH REQUESTS ===');
      final currentUserId = ConstanceManager.userId?.toString() ?? 'unknown';
      final currentUserIdInt = int.tryParse(currentUserId) ?? 0;
      _debugPrint(
          'Current user ID (string): $currentUserId, (int): $currentUserIdInt');

      final url = ApiConsts.baseUrl + ApiEndPoints.callKw;

      // Try multiple search approaches
      final List<Map<String, dynamic>> searchVariants = [
        {
          "domain": [
            ["x_user_id", "=", currentUserIdInt]
          ],
          "description": "x_user_id (integer)"
        },
        {
          "domain": [
            ["x_user_id", "=", currentUserId]
          ],
          "description": "x_user_id (string)"
        },
        {
          "domain": [
            ["user_id", "=", currentUserIdInt]
          ],
          "description": "user_id (integer)"
        },
        {
          "domain": [
            ["create_uid", "=", currentUserIdInt]
          ],
          "description": "create_uid (integer)"
        },
        {"domain": [], "description": "no filter (all records)"}
      ];

      for (int i = 0; i < searchVariants.length; i++) {
        final variant = searchVariants[i];
        _debugPrint('🔍 Trying search approach: ${variant["description"]}');

        final body = {
          "params": {
            "model": ApiModels.pettyCash,
            "method": "search_read",
            "kwargs": {
              "domain": variant["domain"],
              "fields": [
                "id",
                "x_vendor_name",
                "x_description",
                "x_amount",
                "x_date",
                "x_bill_type",
                "x_bill_number",
                "x_customer_project_name",
                "x_location",
                "x_comments",
                "x_is_advance_request",
                "x_advance_purpose",
                "x_expected_amount",
                "x_project_customer_name",
                "x_status",
                "x_user_id",
                "create_date",
                "write_date"
              ],
              "limit": variant["description"] == "no filter (all records)"
                  ? 10
                  : null
            },
            "args": []
          }
        };

        _debugPrint('Request body: ${jsonEncode(body)}');

        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
            'Cookie': ConstanceManager.sessionId.toString(),
          },
          body: jsonEncode(body),
        );

        _debugPrint('Response status: ${response.statusCode}');
        _debugPrint('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData.containsKey("result")) {
            final List<dynamic> requests = responseData["result"];

            if (requests.isNotEmpty) {
              _debugPrint(
                  '✅ Found ${requests.length} records using ${variant["description"]}');

              // If this is the "no filter" search, just log what we found and continue
              if (variant["description"] == "no filter (all records)") {
                _debugPrint('Sample records from all data:');
                for (int j = 0; j < requests.take(3).length; j++) {
                  _debugPrint('  Record $j: ${requests[j]}');
                }
                continue; // Don't return this data, just use it for debugging
              }

              final List<PettyCashModel> userRequests = [];
              for (int j = 0; j < requests.length; j++) {
                try {
                  final model = PettyCashModel.fromJson(requests[j]);
                  userRequests.add(model);
                  _debugPrint(
                      '✅ Successfully parsed record $j: ID=${model.id}');
                } catch (e, stackTrace) {
                  _debugPrint('❌ Error parsing record $j: $e');
                  _debugPrint('Record $j data: ${requests[j]}');
                  _debugPrint('Stack trace: $stackTrace');
                }
              }

              if (userRequests.isNotEmpty) {
                _debugPrint(
                    '=== SUCCESS: Found ${userRequests.length} user petty cash requests ===');
                return Right(userRequests);
              }
            } else {
              _debugPrint('No records found with ${variant["description"]}');
            }
          } else {
            _debugPrint(
                '❌ Response missing "result" key for ${variant["description"]}');
            _debugPrint('Available keys: ${responseData.keys.toList()}');
          }
        } else {
          _debugPrint(
              '❌ HTTP Error ${response.statusCode} for ${variant["description"]}');
        }
      }

      _debugPrint('⚠️ No records found with any search approach');
      return Right([]);
    } catch (e, stackTrace) {
      _debugPrint('❌ Exception in getUserPettyCashRequests: $e');
      _debugPrint('Stack trace: $stackTrace');
      return Left(e as Exception);
    }
  }

  // Enhanced debug methods
  @override
  Future<void> debugModelAndData() async {
    _debugPrint('=== DEBUGGING MODEL AND DATA ===');

    try {
      // 1. Check if model exists and get its structure
      final modelFields = await _checkPettyCashModel();
      if (modelFields != null) {
        _debugPrint('✅ Model exists with fields:');
        modelFields.forEach((key, value) {
          _debugPrint('  - $key: ${value['type'] ?? 'unknown type'}');
        });
      } else {
        _debugPrint('❌ Model not found or not accessible');
      }

      // 2. Test basic search without domain filters
      final url = ApiConsts.baseUrl + ApiEndPoints.callKw;
      final basicSearchBody = {
        "params": {
          "model": ApiModels.pettyCash,
          "method": "search",
          "kwargs": {"domain": [], "limit": 5},
          "args": []
        }
      };

      _debugPrint('Testing basic search...');
      final searchResponse = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode(basicSearchBody),
      );

      if (searchResponse.statusCode == 200) {
        final searchData = jsonDecode(searchResponse.body);
        if (searchData.containsKey("result")) {
          final ids = searchData["result"];
          _debugPrint('Found ${ids.length} records with IDs: $ids');
        }
      } else {
        _debugPrint('Basic search failed: ${searchResponse.statusCode}');
      }

      // 3. Check current user permissions
      final userCheckBody = {
        "params": {
          "model": "res.users",
          "method": "search_read",
          "kwargs": {
            "domain": [
              ["id", "=", ConstanceManager.userId ?? 0]
            ],
            "fields": ["id", "name", "groups_id"]
          },
          "args": []
        }
      };

      _debugPrint('Checking user permissions...');
      final userResponse = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode(userCheckBody),
      );

      if (userResponse.statusCode == 200) {
        final userData = jsonDecode(userResponse.body);
        _debugPrint('User data: ${userData["result"]}');
      } else {
        _debugPrint('User check failed: ${userResponse.statusCode}');
      }

      // 4. Test different field access patterns
      await _testFieldAccess();
    } catch (e) {
      _debugPrint('Error in model/data debug: $e');
    }

    _debugPrint('=== END MODEL AND DATA DEBUG ===');
  }

  Future<void> _testFieldAccess() async {
    _debugPrint('Testing field access patterns...');

    final url = ApiConsts.baseUrl + ApiEndPoints.callKw;
    final fieldTests = [
      {
        "fields": ["id", "x_user_id"],
        "description": "Basic fields with x_user_id"
      },
      {
        "fields": ["id", "user_id"],
        "description": "Basic fields with user_id"
      },
      {
        "fields": ["id", "create_uid"],
        "description": "Basic fields with create_uid"
      },
      {
        "fields": ["id", "write_uid"],
        "description": "Basic fields with write_uid"
      }
    ];

    for (final test in fieldTests) {
      try {
        final body = {
          "params": {
            "model": ApiModels.pettyCash,
            "method": "search_read",
            "kwargs": {"domain": [], "fields": test["fields"], "limit": 3},
            "args": []
          }
        };

        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
            'Cookie': ConstanceManager.sessionId.toString(),
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data.containsKey("result")) {
            final results = data["result"];
            _debugPrint(
                '✅ ${test["description"]}: Success - ${results.length} records');
            if (results.isNotEmpty) {
              _debugPrint('   Sample: ${results.first}');
            }
          }
        } else {
          _debugPrint(
              '❌ ${test["description"]}: Failed - ${response.statusCode}');
        }
      } catch (e) {
        _debugPrint('❌ ${test["description"]}: Error - $e');
      }
    }
  }

  @override
  Future<void> testDifferentSearchMethods() async {
    _debugPrint('=== TESTING DIFFERENT SEARCH METHODS ===');

    final currentUserId = ConstanceManager.userId?.toString() ?? 'unknown';
    final currentUserIdInt = int.tryParse(currentUserId) ?? 0;
    final url = ApiConsts.baseUrl + ApiEndPoints.callKw;

    // Test 1: Search by string user ID
    await _testSearch(
        'String User ID (x_user_id)',
        [
          ["x_user_id", "=", currentUserId]
        ],
        url);

    // Test 2: Search by integer user ID
    await _testSearch(
        'Integer User ID (x_user_id)',
        [
          ["x_user_id", "=", currentUserIdInt]
        ],
        url);

    // Test 3: Search without user filter
    await _testSearch('No User Filter', [], url);

    // Test 4: Search with different field name variations
    await _testSearch(
        'user_id field (int)',
        [
          ["user_id", "=", currentUserIdInt]
        ],
        url);
    await _testSearch(
        'user_id field (string)',
        [
          ["user_id", "=", currentUserId]
        ],
        url);
    await _testSearch(
        'create_uid field',
        [
          ["create_uid", "=", currentUserIdInt]
        ],
        url);
    await _testSearch(
        'write_uid field',
        [
          ["write_uid", "=", currentUserIdInt]
        ],
        url);

    // Test 5: Search with LIKE operator
    await _testSearch(
        'x_user_id LIKE',
        [
          ["x_user_id", "ilike", currentUserId]
        ],
        url);

    // Test 6: Search with IN operator
    await _testSearch(
        'x_user_id IN',
        [
          [
            "x_user_id",
            "in",
            [currentUserId, currentUserIdInt]
          ]
        ],
        url);

    _debugPrint('=== END SEARCH METHODS TEST ===');
  }

  Future<void> _testSearch(
      String testName, List<dynamic> domain, String url) async {
    try {
      _debugPrint('Testing: $testName');

      final body = {
        "params": {
          "model": ApiModels.pettyCash,
          "method": "search_read",
          "kwargs": {
            "domain": domain,
            "fields": [
              "id",
              "x_user_id",
              "user_id",
              "create_uid",
              "x_vendor_name"
            ],
            "limit": 5
          },
          "args": []
        }
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey("result")) {
          final results = data["result"];
          _debugPrint('  ✅ $testName: Found ${results.length} records');
          if (results.isNotEmpty) {
            _debugPrint('  Sample: ${results.take(2)}');
          }
        } else {
          _debugPrint('  ❌ $testName: No result key in response');
          if (data.containsKey("error")) {
            _debugPrint('  Error: ${data["error"]}');
          }
        }
      } else {
        _debugPrint('  ❌ $testName: HTTP ${response.statusCode}');
        _debugPrint('  Response: ${response.body}');
      }
    } catch (e) {
      _debugPrint('  ❌ $testName: Error - $e');
    }
  }

  // Method to get detailed record information
  Future<Either<Exception, List<Map<String, dynamic>>>>
      getAllRecordsWithDetails() async {
    try {
      _debugPrint('=== GETTING ALL RECORDS WITH DETAILS ===');

      final url = ApiConsts.baseUrl + ApiEndPoints.callKw;
      final body = {
        "params": {
          "model": ApiModels.pettyCash,
          "method": "search_read",
          "kwargs": {
            "domain": [],
            "fields": [], // Empty fields array returns all fields
            "limit": 20
          },
          "args": []
        }
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode(body),
      );

      _debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey("result")) {
          final List<dynamic> records = responseData["result"];
          _debugPrint('Found ${records.length} total records');

          // Log field information from first record
          if (records.isNotEmpty) {
            final firstRecord = records.first as Map<String, dynamic>;
            _debugPrint(
                'Available fields in records: ${firstRecord.keys.toList()}');

            // Look for user-related fields
            final userFields = firstRecord.keys
                .where((key) =>
                    key.toLowerCase().contains('user') ||
                    key.toLowerCase().contains('uid'))
                .toList();
            _debugPrint('User-related fields found: $userFields');

            for (final field in userFields) {
              _debugPrint('$field values in first 5 records:');
              for (int i = 0; i < records.take(5).length; i++) {
                final record = records[i] as Map<String, dynamic>;
                _debugPrint('  Record $i: $field = ${record[field]}');
              }
            }
          }

          return Right(records.cast<Map<String, dynamic>>());
        }
      }

      return Left(Exception('Failed to get records: ${response.statusCode}'));
    } catch (e) {
      _debugPrint('Error getting all records: $e');
      return Left(e as Exception);
    }
  }

  // Method to search with custom domain
  Future<Either<Exception, List<PettyCashModel>>> searchWithCustomDomain(
      List<dynamic> domain) async {
    try {
      _debugPrint('=== CUSTOM DOMAIN SEARCH ===');
      _debugPrint('Domain: $domain');

      final url = ApiConsts.baseUrl + ApiEndPoints.callKw;
      final body = {
        "params": {
          "model": ApiModels.pettyCash,
          "method": "search_read",
          "kwargs": {
            "domain": domain,
            "fields": [
              "id",
              "x_vendor_name",
              "x_description",
              "x_amount",
              "x_date",
              "x_bill_type",
              "x_bill_number",
              "x_customer_project_name",
              "x_location",
              "x_comments",
              "x_is_advance_request",
              "x_advance_purpose",
              "x_expected_amount",
              "x_project_customer_name",
              "x_status",
              "x_user_id",
              "create_date",
              "write_date"
            ]
          },
          "args": []
        }
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode(body),
      );

      _debugPrint('Custom search response status: ${response.statusCode}');
      _debugPrint('Custom search response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey("result")) {
          final List<dynamic> requests = responseData["result"];
          final List<PettyCashModel> models = [];

          for (int i = 0; i < requests.length; i++) {
            try {
              final model = PettyCashModel.fromJson(requests[i]);
              models.add(model);
            } catch (e) {
              _debugPrint('Error parsing record $i: $e');
            }
          }

          return Right(models);
        }
      }

      return Left(Exception('Custom search failed: ${response.statusCode}'));
    } catch (e) {
      return Left(e as Exception);
    }
  }
}
