import 'dart:convert';
import 'dart:developer' as developer;
import 'package:bayanat/modules/petty_cash/models/petty_cash.dart';
import 'package:get/get.dart';
import 'package:bayanat/core/remote/api_helper/api_models.dart';
import 'package:bayanat/core/remote/api_helper/api_constance.dart';
import 'package:bayanat/core/remote/api_helper/end_points.dart';
import 'package:bayanat/core/remote/api_helper/methods.dart';
import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:http/http.dart' as http;

class ExpenseController extends GetxController {
  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString errorMessage = ''.obs;

  // Observable lists
  final RxList<PettyCashModel> pettyCashRecords = <PettyCashModel>[].obs;
  final RxList<PettyCashModel> userRequests = <PettyCashModel>[].obs;
  final RxList<PettyCashModel> pendingBills = <PettyCashModel>[].obs;

  // Pagination
  final RxInt currentOffset = 0.obs;
  final RxInt itemsPerPage = 20.obs;
  final RxBool hasMoreData = true.obs;

  // PettyCashController(PettyCashController find);

  void _debugPrint(String message) {
    print('🔍 [PettyCashAPI] $message');
    developer.log(message, name: 'PettyCashAPI');
  }

  void clearError() {
    errorMessage.value = '';
  }

  // Submit petty cash
  Future<bool> submitPettyCash({
    required PettyCashModel pettyCash,
    int maxRetries = 5,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempt = 0;
    isSubmitting.value = true;
    clearError();

    while (attempt < maxRetries) {
      try {
        _debugPrint('Starting petty cash submission - Attempt ${attempt + 1}');

        // Upload photos first
        List<int> billIds = [];
        if (pettyCash.billPhotosBase64.isNotEmpty) {
          billIds =
              await _uploadToAttachments(photos: pettyCash.billPhotosBase64);
          _debugPrint('Uploaded ${billIds.length} photos');
        }

        // Create petty cash record with pending report_type
        Map<String, dynamic> pettyCashData = pettyCash.toJson();
        pettyCashData['x_bill_photos'] = billIds;
        pettyCashData['state'] = 'Pending';

        final response = await http
            .post(
              Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
              headers: {
                'Content-Type': 'application/json',
                'Connection': 'keep-alive',
                'Cookie': ConstanceManager.sessionId.toString()
              },
              body: jsonEncode({
                "params": {
                  "model": ApiModels.expense,
                  "method": ApiMethods.create,
                  "args": [pettyCashData],
                  "kwargs": {},
                },
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          _debugPrint('Petty cash submitted successfully');
          isSubmitting.value = false;

          // Refresh user requests after successful submission
          await getUserPettyCashRequests();

          Get.snackbar(
            'Success',
            'Petty cash submitted successfully',
            snackPosition: SnackPosition.TOP,
          );
          return true;
        } else {
          _debugPrint('HTTP Error ${response.statusCode}: ${response.body}');
          errorMessage.value =
              'Failed to submit petty cash: ${response.statusCode}';
        }
      } catch (error) {
        _debugPrint('Exception on attempt ${attempt + 1}: $error');
        errorMessage.value = 'Failed to submit petty cash: $error';
        attempt++;
        if (attempt < maxRetries) {
          _debugPrint('Retrying in ${retryDelay.inSeconds} seconds...');
          await Future.delayed(retryDelay);
        }
      }
    }

    isSubmitting.value = false;
    Get.snackbar(
      'Error',
      errorMessage.value,
      snackPosition: SnackPosition.TOP,
    );
    return false;
  }

  // Update petty cash
  Future<bool> updatePettyCash({
    required PettyCashModel pettyCash,
    required int id,
  }) async {
    try {
      isUpdating.value = true;
      clearError();
      _debugPrint('Updating petty cash with ID: $id');

      // Upload new photos if any
      List<int> billIds = [];
      if (pettyCash.billPhotosBase64.isNotEmpty) {
        billIds =
            await _uploadToAttachments(photos: pettyCash.billPhotosBase64);
        _debugPrint('Uploaded ${billIds.length} new photos');
      }

      Map<String, dynamic> updateData = pettyCash.toJson();
      if (billIds.isNotEmpty) {
        updateData['x_bill_photos'] = billIds;
      }

      final response = await http.post(
        Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString()
        },
        body: jsonEncode({
          "params": {
            "model": ApiModels.pettyCash,
            "method": ApiMethods.write,
            "args": [id, updateData],
            "kwargs": {},
          },
        }),
      );

      if (response.statusCode == 200) {
        _debugPrint('Petty cash updated successfully');
        isUpdating.value = false;

        // Refresh data after update
        await getUserPettyCashRequests();

        Get.snackbar(
          'Success',
          'Petty cash updated successfully',
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        errorMessage.value =
            'Failed to update petty cash: ${response.statusCode}';
      }
    } catch (error) {
      _debugPrint('Error updating petty cash: $error');
      errorMessage.value = 'Error updating petty cash: $error';
    }

    isUpdating.value = false;
    Get.snackbar(
      'Error',
      errorMessage.value,
      snackPosition: SnackPosition.TOP,
    );
    return false;
  }

  // Delete petty cash
  Future<bool> deletePettyCash({required int id}) async {
    try {
      isDeleting.value = true;
      clearError();
      _debugPrint('Deleting petty cash with ID: $id');

      final response = await http.post(
        Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString()
        },
        body: jsonEncode({
          "params": {
            "model": ApiModels.pettyCash,
            "method": ApiMethods.unlink,
            "args": [id],
            "kwargs": {},
          },
        }),
      );

      if (response.statusCode == 200) {
        _debugPrint('Petty cash deleted successfully');
        isDeleting.value = false;

        // Remove from local lists
        pettyCashRecords.removeWhere((item) => item.id == id.toString());
        userRequests.removeWhere((item) => item.id == id.toString());
        pendingBills.removeWhere((item) => item.id == id.toString());

        Get.snackbar(
          'Success',
          'Petty cash deleted successfully',
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        errorMessage.value =
            'Failed to delete petty cash: ${response.statusCode}';
      }
    } catch (error) {
      _debugPrint('Error deleting petty cash: $error');
      errorMessage.value = 'Error deleting petty cash: $error';
    }

    isDeleting.value = false;
    Get.snackbar(
      'Error',
      errorMessage.value,
      snackPosition: SnackPosition.TOP,
    );
    return false;
  }

  // Get petty cash records with pagination
  Future<void> getPettyCashRecords({
    bool refresh = false,
    int maxRetries = 15,
    Duration retryDelay = const Duration(seconds: 0),
  }) async {
    if (refresh) {
      currentOffset.value = 0;
      pettyCashRecords.clear();
      hasMoreData.value = true;
    }

    if (!hasMoreData.value) return;

    isLoading.value = true;
    clearError();

    List<String> fields = [
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
      "x_bill_photos",
      "create_date",
      "write_date"
    ];

    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        final response = await http
            .post(
              Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
              headers: {
                'Content-Type': 'application/json',
                'Connection': 'keep-alive',
                'Cookie': ConstanceManager.sessionId.toString(),
              },
              body: jsonEncode({
                "params": {
                  "model": ApiModels.pettyCash,
                  "method": ApiMethods.searchRead,
                  "kwargs": {
                    "fields": fields,
                    "limit": itemsPerPage.value,
                    "offset": currentOffset.value,
                    "order": "create_date desc"
                  },
                  "args": [{}],
                }
              }),
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          var value = jsonDecode(response.body);
          if (value["result"] != null) {
            List<PettyCashModel> newRecords = [];
            value["result"].forEach((element) {
              newRecords.add(PettyCashModel.fromJson(element));
            });

            if (newRecords.length < itemsPerPage.value) {
              hasMoreData.value = false;
            }

            pettyCashRecords.addAll(newRecords);
            currentOffset.value += itemsPerPage.value;
          }
          isLoading.value = false;
          return;
        } else {
          errorMessage.value =
              "Failed to fetch petty cash records: ${response.statusCode}";
        }
      } catch (e) {
        attempt++;
        if (attempt < maxRetries) {
          await Future.delayed(retryDelay);
        } else {
          errorMessage.value =
              "Failed to fetch petty cash records after $maxRetries attempts: $e";
        }
      }
    }

    isLoading.value = false;
    if (errorMessage.value.isNotEmpty) {
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Get user petty cash requests
  Future<void> getUserPettyCashRequests({
    int maxRetries = 15,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    isLoading.value = true;
    clearError();
    final currentUserId = ConstanceManager.userId ?? 0;
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        _debugPrint(
            'Getting user petty cash requests - Attempt ${attempt + 1}');

        final response = await http
            .post(
              Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
              headers: {
                'Content-Type': 'application/json',
                'Connection': 'keep-alive',
                'Cookie': ConstanceManager.sessionId.toString(),
              },
              body: jsonEncode({
                "params": {
                  "model": ApiModels.pettyCash,
                  "method": ApiMethods.searchRead,
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
                      "x_bill_photos",
                      "create_date",
                      "write_date"
                    ]
                  },
                  "args": [
                    [
                      ["x_user_id", "=", currentUserId]
                    ]
                  ]
                }
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          var value = jsonDecode(response.body);
          if (value["result"] != null) {
            userRequests.clear();
            value["result"].forEach((element) {
              userRequests.add(PettyCashModel.fromJson(element));
            });
          }
          _debugPrint(
              'Successfully retrieved ${userRequests.length} user requests');
          isLoading.value = false;
          return;
        } else {
          errorMessage.value =
              "Failed to get user requests: ${response.statusCode}";
        }
      } catch (e) {
        _debugPrint('Exception on attempt ${attempt + 1}: $e');
        attempt++;
        if (attempt < maxRetries) {
          await Future.delayed(retryDelay);
        } else {
          errorMessage.value =
              "Failed to get user requests after $maxRetries attempts: $e";
        }
      }
    }

    isLoading.value = false;
    if (errorMessage.value.isNotEmpty) {
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Get pending bills
  Future<void> getPendingBills({
    int maxRetries = 15,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    isLoading.value = true;
    clearError();
    final currentUserId = ConstanceManager.userId ?? 0;
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        _debugPrint('Getting pending bills - Attempt ${attempt + 1}');

        final response = await http
            .post(
              Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
              headers: {
                'Content-Type': 'application/json',
                'Connection': 'keep-alive',
                'Cookie': ConstanceManager.sessionId.toString(),
              },
              body: jsonEncode({
                "params": {
                  "model": ApiModels.pettyCash,
                  "method": ApiMethods.searchRead,
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
                      "x_bill_photos",
                      "create_date",
                      "write_date"
                    ]
                  },
                  "args": [
                    [
                      ["x_status", "=", "pendingBillSubmission"],
                      ["x_is_advance_request", "=", true],
                      ["x_user_id", "=", currentUserId]
                    ]
                  ]
                }
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          var value = jsonDecode(response.body);
          if (value["result"] != null) {
            pendingBills.clear();
            value["result"].forEach((element) {
              pendingBills.add(PettyCashModel.fromJson(element));
            });
          }
          _debugPrint(
              'Successfully retrieved ${pendingBills.length} pending bills');
          isLoading.value = false;
          return;
        } else {
          errorMessage.value =
              "Failed to get pending bills: ${response.statusCode}";
        }
      } catch (e) {
        _debugPrint('Exception on attempt ${attempt + 1}: $e');
        attempt++;
        if (attempt < maxRetries) {
          await Future.delayed(retryDelay);
        } else {
          errorMessage.value =
              "Failed to get pending bills after $maxRetries attempts: $e";
        }
      }
    }

    isLoading.value = false;
    if (errorMessage.value.isNotEmpty) {
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Complete advance payment
  Future<PettyCashModel?> completeAdvancePayment({
    required String advanceId,
    required String vendorName,
    required double actualAmount,
    required List<String> billPhotos,
  }) async {
    try {
      isUpdating.value = true;
      clearError();
      _debugPrint('Completing advance payment for ID: $advanceId');

      // Upload bill photos
      final billIds = await _uploadToAttachments(photos: billPhotos);

      final response = await http.post(
        Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString()
        },
        body: jsonEncode({
          "params": {
            "model": ApiModels.pettyCash,
            "method": ApiMethods.write,
            "args": [
              int.parse(advanceId),
              {
                "x_vendor_name": vendorName,
                "x_amount": actualAmount,
                "x_bill_photos": billIds,
                "x_status": "billPending",
                "x_is_advance_request": false,
              }
            ],
            "kwargs": {},
          },
        }),
      );

      if (response.statusCode == 200) {
        // Get updated record
        final getResponse = await http.post(
          Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
            'Cookie': ConstanceManager.sessionId.toString()
          },
          body: jsonEncode({
            "params": {
              "model": ApiModels.pettyCash,
              "method": ApiMethods.searchRead,
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
                  "x_bill_photos",
                  "create_date",
                  "write_date"
                ]
              },
              "args": [
                [
                  ["id", "=", int.parse(advanceId)]
                ]
              ],
            },
          }),
        );

        if (getResponse.statusCode == 200) {
          var value = jsonDecode(getResponse.body);
          if (value["result"] != null && value["result"].isNotEmpty) {
            final bill = PettyCashModel.fromJson(value["result"][0]);

            // Update local lists
            await getPendingBills();
            await getUserPettyCashRequests();

            isUpdating.value = false;
            Get.snackbar(
              'Success',
              'Advance payment completed successfully',
              snackPosition: SnackPosition.TOP,
            );
            return bill;
          }
        }
      }

      errorMessage.value = 'Failed to complete advance payment';
    } catch (e) {
      _debugPrint('Error completing advance payment: $e');
      errorMessage.value = 'Error completing advance payment: $e';
    }

    isUpdating.value = false;
    Get.snackbar(
      'Error',
      errorMessage.value,
      snackPosition: SnackPosition.TOP,
    );
    return null;
  }

  // Private helper methods
  Future<List<int>> _uploadToAttachments({required List<String> photos}) async {
    List<int> list = [];
    _debugPrint('Starting photo upload for ${photos.length} photos');

    for (var element in photos) {
      if (!element.contains(ApiConsts.imageUrl)) {
        try {
          List<int> binaryImageData = base64Decode(element);
          String format = _getImageFormat(binaryImageData);

          await http
              .post(
            Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
            headers: {
              'Content-Type': 'application/json',
              'Connection': 'keep-alive',
              'Cookie': ConstanceManager.sessionId.toString()
            },
            body: jsonEncode({
              "params": {
                "model": ApiModels.attachment,
                "method": ApiMethods.create,
                "kwargs": {},
                "args": [
                  {
                    "name": "petty_${element.length}.$format",
                    "datas": element,
                  }
                ],
              },
            }),
          )
              .then((res) {
            var value = jsonDecode(res.body);
            if (value["result"] != null) {
              list.add(value["result"]);
            }
          });
        } catch (e) {
          _debugPrint('Error uploading photo: $e');
        }
      }
    }

    _debugPrint('Successfully uploaded ${list.length} photos');
    return list;
  }

  String _getImageFormat(List<int> imageData) {
    if (imageData.length < 4) {
      return "jpg";
    }
    if (imageData[0] == 0xFF && imageData[1] == 0xD8) {
      return "jpg"; // JPEG format
    } else if (imageData[0] == 0x89 &&
        imageData[1] == 0x50 &&
        imageData[2] == 0x4E &&
        imageData[3] == 0x47) {
      return "png";
    }
    return "jpg";
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    await Future.wait([
      getUserPettyCashRequests(),
      getPendingBills(),
    ]);
  }
}
