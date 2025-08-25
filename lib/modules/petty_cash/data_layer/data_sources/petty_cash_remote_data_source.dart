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
      _debugPrint('Current user ID: $currentUserId');

      final url = ApiConsts.baseUrl + ApiEndPoints.callKw;
      final body = {
        "params": {
          "model": ApiModels.pettyCash,
          "method": "search_read",
          "kwargs": {
            "domain": [
              ["x_status", "=", "pendingBillSubmission"],
              ["x_is_advance_request", "=", true],
              ["x_user_id", "=", currentUserId]
            ],
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

      _debugPrint('Get pending bills request: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode(body),
      );

      _debugPrint('Get pending bills response status: ${response.statusCode}');
      _debugPrint('Get pending bills response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _debugPrint('Response data keys: ${responseData.keys.toList()}');

        if (responseData.containsKey("result")) {
          final List<dynamic> bills = responseData["result"];
          _debugPrint('Raw bills data: $bills');

          if (bills.isEmpty) {
            _debugPrint('No pending bills found for user: $currentUserId');
            return Right([]);
          }

          final List<PettyCashModel> pendingBills = [];
          for (int i = 0; i < bills.length; i++) {
            try {
              final bill = PettyCashModel.fromJson(bills[i]);
              pendingBills.add(bill);
              _debugPrint('Successfully parsed bill $i: ${bill.id}');
            } catch (e) {
              _debugPrint('Error parsing bill $i: $e');
              _debugPrint('Bill $i data: ${bills[i]}');
            }
          }

          _debugPrint(
              'Successfully parsed ${pendingBills.length} pending bills');
          return Right(pendingBills);
        } else {
          _debugPrint('Response does not contain "result" key');
          return Left(
              Exception('Invalid response format: missing "result" key'));
        }
      }

      return Left(Exception(
          'Failed to get pending bills: ${response.statusCode} - ${response.body}'));
    } catch (e) {
      _debugPrint('Error getting pending bills: $e');
      return Left(e as Exception);
    }
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
      _debugPrint('Getting user\'s petty cash requests...');
      final currentUserId = ConstanceManager.userId?.toString() ?? 'unknown';
      _debugPrint('Current user ID: $currentUserId');

      final url = ApiConsts.baseUrl + ApiEndPoints.callKw;
      final body = {
        "params": {
          "model": ApiModels.pettyCash,
          "method": "search_read",
          "kwargs": {
            "domain": [
              ["x_user_id", "=", currentUserId],
            ],
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

      _debugPrint('Get user petty cash requests request: ${jsonEncode(body)}');

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
          'Get user petty cash requests response status: ${response.statusCode}');
      _debugPrint(
          'Get user petty cash requests response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey("result")) {
          final List<dynamic> requests = responseData["result"];
          final List<PettyCashModel> userRequests =
              requests.map((req) => PettyCashModel.fromJson(req)).toList();

          _debugPrint('Found ${userRequests.length} user petty cash requests');
          return Right(userRequests);
        }
      }

      return Left(Exception(
          'Failed to get user petty cash requests: ${response.statusCode}'));
    } catch (e) {
      _debugPrint('Error getting user petty cash requests: $e');
      return Left(e as Exception);
    }
  }
}
