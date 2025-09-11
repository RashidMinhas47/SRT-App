import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bayanat/core/remote/api_helper/end_points.dart';
import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:bayanat/modules/main/data_layer/models/amc_ac_checklsit_model.dart';
import 'package:bayanat/modules/main/data_layer/models/amc_model.dart';
import 'package:bayanat/modules/main/data_layer/models/job_card_model.dart';
import 'package:bayanat/modules/main/data_layer/models/product_model.dart';
import 'package:bayanat/modules/main/data_layer/models/service_type_model.dart';
import 'package:bayanat/modules/main/data_layer/models/spare_c_model.dart';
import 'package:bayanat/modules/main/data_layer/models/spare_model.dart';
import 'package:bayanat/modules/main/domain_layer/entities/amc_building.dart';
import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/remote/api_helper/api_constance.dart';
import '../../../../core/remote/api_helper/api_models.dart';
import '../../../../core/remote/api_helper/methods.dart';
import 'package:http/http.dart' as http;
import '../../domain_layer/entities/amc_card.dart';
import '../../domain_layer/entities/job_card.dart';
import '../../domain_layer/entities/product.dart';
import '../../domain_layer/entities/spare.dart';
import '../models/amc_card_model.dart';
import '../models/amc_building_model.dart';
import '../models/fault_model.dart';

abstract class BaseMainRemoteDataSource {
  Future<Either<Exception, bool>> amcFormReport(
      {required AmcFormModel amcFormModel, required int id});

  Future<Either<Exception, bool>> acceptJobCard({required int id});

  Future<Either<Exception, bool>> ignoreJobCard({required int id});

  Future<Either<Exception, bool>> faultReport({
    required FaultFormModel formModel,
    required int jobCardId,
  });

  Future<Either<Exception, int>> saveFaultData({
    required FaultFormModel formModel,
    required int jobCardId,
  });

  Future<Either<Exception, bool>> updateFaultData({
    required FaultFormModel formModel,
    required int jobCardId,
  });

  Future<Either<Exception, bool>> deleteFaultData({
    required FaultFormModel formModel,
    required int jobCardId,
  });

  Future<Either<Exception, List<FaultFormModel>>> getFaultReport(
      {required int jobCardId, required bool isComplaint});

  // Future<Either<Exception, List<JobCard>>> getJobCards();
  Future<Either<Exception, List<JobCard>>> getJobCards({
    required int offset,
    required int limit,
  });

  Future<Either<Exception, String>> getPDF({
    required int jobCardId,
    required String pdfType,
  });

  Future<Either<Exception, List<Product>>> getProducts();

  Future<Either<Exception, List<Spare>>> getSpares();

  Future<Either<Exception, List<AmcCard>>> getAmcCards();

  Future<Either<Exception, List<AmcBuilding>>> getAmcBuilding(
      {required int amcCardId});

  Future<Either<Exception, bool>> submitAmcCardReport({
    required List<AmcAcCheckListModel> amcAcCheckListModels,
    required Map<String, int> acTypesValues,
    required Map<String, int> acTypesIndex,
    required int numWetServices,
    required int numDryServices,
    required int amcCardId,
    required List<int> flatsNumbers,
    required int buildingId,
  });
}

class MainRemoteDataSource extends BaseMainRemoteDataSource {
  // final client = http.Client();
  /// AMC
  @override
  Future<Either<Exception, bool>> amcFormReport(
      {required AmcFormModel amcFormModel, required int id}) async {
    try {
      List<int> spareCIds = [];
      for (SpareCModel element in amcFormModel.sparesC!) {
        await http
            .post(
          Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
            'Cookie': ConstanceManager.sessionId.toString()
          },
          body: jsonEncode(
            {
              "params": {
                "model": ApiModels.spareC,
                "method": ApiMethods.create,
                "args": [element.toJson(id: id)],
                "kwargs": {},
              },
            },
          ),
        )
            .then(
          (res) {
            var value = jsonDecode(res.body);
            spareCIds.add(value["result"]);
          },
        );
      }
      amcFormModel.sparesCIds = spareCIds;
      await http.post(
        Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString()
        },
        body: jsonEncode(
          {
            "params": {
              "model": ApiModels.jobCard,
              "method": ApiMethods.write,
              "args": [id, amcFormModel.toJson()],
              "kwargs": {},
            },
          },
        ),
      );
      return const Right(true);
    } on Exception catch (error) {
      return Left(error);
    }
  }

  //  JOB CARD
  @override
  Future<Either<Exception, List<JobCard>>> getJobCards({
    required int offset,
    required int limit,
    int maxRetries = 15,
    Duration retryDelay = const Duration(seconds: 0),
  }) async {
    List<JobCard> jobCards = [];
    List<String> jobs = [
      "location",
      "action",
      "fault_ids",
      "assigned_user_id",
      "work_description",
      "User_name",
      "revisit",
      "start_work",
      "id",
      "comments",
      "quotation_status",
      "write_date",
      "customer_mobile_number",
      "brand",
      "report_type",
      "customer_building_number",
      "complaint_number",
      "job_card_number",
      "customer_house_flat_number",
      "customer_name"
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
              body: jsonEncode(
                {
                  "params": {
                    "model": ApiModels.jobCard,
                    "method": ApiMethods.searchRead,
                    "kwargs": {
                      "fields": jobs,
                      "limit": limit,
                      "offset": offset,
                      "order":
                          "job_card_number desc" //change to "job_card_number asc"asc if need oldest first
                    },
                    "args": [{}],
                  }
                },
              ),
            )
            .timeout(const Duration(seconds: 20));

        /*
        print("🔑 Session ID: ${ConstanceManager.sessionId.toString()}");
        print("📡 API URL: ${ApiConsts.baseUrl + ApiEndPoints.callKw}");
        print("📋 Request Body: ${jsonEncode({
              "params": {
                "model": ApiModels.jobCard,
                "method": ApiMethods.searchRead,
                "kwargs": {
                  "fields": jobs,
                  "limit": limit,
                  "offset": offset,
                  "order": "job_card_number desc"
                },
                "args": [{}],
              }
            })}");
        */

        if (response.statusCode == 200) {
          var value = jsonDecode(response.body);
          // print('🔍 API Response Status: ${response.statusCode}');
          // print('🔍 API Response Body: ${response.body}');
          // print('🔍 Parsed Response: ${jsonEncode(value)}');

          if (value["result"] != null) {
            // print('📊 Result is List: ${value["result"] is List}');
            // print('📊 Result length: ${value["result"]?.length ?? "null"}');
            // print('📊 Result type: ${value["result"].runtimeType}');

            // if (value["result"] is List &&
            //     (value["result"] as List).isNotEmpty) {
            //   print('📋 First element: ${jsonEncode(value["result"][0])}');
            // }
          } else {
            print('❌ Result is null or missing');
          }

          value["result"].forEach((element) {
            try {
              // print('🔍 Processing element: ${jsonEncode(element)}');
              final jobCard = JobCardModel.fromJson(element);
              jobCards.add(jobCard);
              // print('✅ Successfully parsed job card with ID: ${jobCard.id}');
            } catch (parseError) {
              print('❌ Error parsing job card element: $parseError');
              // print('❌ Element data: ${jsonEncode(element)}');
            }
          });

          // print('🎯 Total job cards parsed: ${jobCards.length}');
          return Right(jobCards); // Return the job cards on success
        } else {
          // Handle non-200 responses
          print('❌ HTTP Error: ${response.statusCode}');
          // print('❌ Response body: ${response.body}');
          // print('❌ Response headers: ${response.headers}');
          return Left(
              Exception("Failed to fetch job cards: ${response.statusCode}"));
        }
      } on Exception catch (e) {
        // Handle exceptions
        print('❌ Exception during attempt ${attempt + 1}: $e');
        print('❌ Exception type: ${e.runtimeType}');
        attempt++;
        if (attempt < maxRetries) {
          print(
              '🔄 Retrying in ${retryDelay.inMilliseconds}ms... (Attempt ${attempt + 1}/$maxRetries)');
          await Future.delayed(retryDelay); // Wait before retrying
        } else {
          print('❌ All retry attempts failed');
          return Left(Exception(
              "Failed to fetch job cards after $maxRetries attempts: $e"));
        }
      }
    }

    // Return the last encountered error if all retries fail
    return Left(
        Exception("Failed to fetch job cards after $maxRetries attempts"));
  }

  // Future<Either<Exception, List<JobCard>>> getJobCards({
  //   int maxRetries = 15, // Number of retries
  //   Duration retryDelay = const Duration(seconds: 0), // Delay between retries
  // }) async {
  //   List<JobCard> jobCards = [];
  //   List<String> jobs = [
  //     "location",
  //     "action",
  //     "fault_ids",
  //     "assigned_user_id",
  //     "work_description",
  //     "User_name",
  //     "revisit",
  //     "start_work",
  //     "id",
  //     "comments",
  //     "quotation_status",
  //     "write_date",
  //     "customer_mobile_number",
  //     "brand",
  //     "write_date",
  //     "report_type",
  //     "customer_building_number",
  //     "complaint_number",
  //     "job_card_number",
  //     "customer_house_flat_number",
  //     "customer_name"
  //   ];
  //   int attempt = 0;

  //   while (attempt < maxRetries) {
  //     try {
  //       final response = await http
  //           .post(
  //             Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
  //             headers: {
  //               'Content-Type': 'application/json',
  //               'Connection': 'keep-alive',
  //               'Cookie': ConstanceManager.sessionId.toString(),
  //             },
  //             body: jsonEncode(
  //               {
  //                 "params": {
  //                   "model": ApiModels.jobCard,
  //                   "method": ApiMethods.searchRead,
  //                   "kwargs": {
  //                     "fields": jobs,
  //                     "limit": 200,
  //                     "order": "job_card_number asc"
  //                   },
  //                   "args": [{}],
  //                 }
  //               },
  //             ),
  //           )
  //           .timeout(const Duration(seconds: 20));

  //       if (response.statusCode == 200) {
  //         var value = jsonDecode(response.body);
  //         value["result"].forEach((element) {
  //           jobCards.add(JobCardModel.fromJson(element));
  //         });

  //         return Right(jobCards); // Return the job cards on success
  //       } else {}
  //     } on Exception {}

  //     attempt++;
  //     if (attempt < maxRetries) {
  //       await Future.delayed(retryDelay); // Wait before retrying
  //     }
  //   }

  //   // Return the last encountered error if all retries fail
  //   return Left(
  //       Exception("Failed to fetch job cards after $maxRetries attempts"));
  // }

  @override
  Future<Either<Exception, String>> getPDF({
    required int jobCardId,
    required String pdfType,
    int maxRetries = 20,
    Duration retryDelay = const Duration(seconds: 0),
  }) async {
    String pdfBase64 = "";
    int attempt = 0;
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    try {
      print("PDF Trying");
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/jobcard_${jobCardId}_$pdfType.pdf";
      final filePaths = "$filePath=$timestamp"; //added with timestamp
      final file = File(filePath);
      if (await file.exists()) {
        print("PDF File Path $filePath");
        //return Right(filePath);
        return Right(filePaths);
      }
      while (attempt < maxRetries) {
        try {
          final response = await http
              .post(
                Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept-Encoding': 'gzip, deflate, br',
                  'Connection': 'keep-alive',
                  'Cookie': ConstanceManager.sessionId.toString()
                },
                body: jsonEncode(
                  {
                    "jsonrpc": "2.0",
                    "params": {
                      "model": ApiModels.jobCard,
                      "method": ApiMethods.searchRead,
                      "kwargs": {
                        "fields": [
                          pdfType == "fault"
                              ? "Attending_Technician"
                              : "amc_file"
                        ]
                      },
                      "args": [
                        [
                          ["id", "=", jobCardId]
                        ]
                      ]
                    }
                  },
                ),
              )
              .timeout(const Duration(seconds: 60));

          if (response.statusCode == 200) {
            var result = jsonDecode(response.body)?["result"];

            if (result != null && result.isNotEmpty) {
              final item = result[0];
              if (pdfType == "fault" && item["Attending_Technician"] != false) {
                pdfBase64 = item["Attending_Technician"];
              }
              if (pdfType == "amc" && item["amc_file"] != false) {
                pdfBase64 = item["amc_file"];
              }

              if (pdfBase64.isNotEmpty) {
                final pdfBytes = base64Decode(pdfBase64);
                await file.writeAsBytes(pdfBytes);
                return Right(filePath);
              } else {
                return Left(Exception("PDF data is empty or not available"));
              }
            }
          }
        } catch (_) {
          // silently catch and retry
        }

        attempt++;
        if (attempt < maxRetries) {
          await Future.delayed(retryDelay);
        }
      }
    } catch (e) {
      return Left(Exception("File system error: $e"));
    }

    return Left(Exception("Failed to fetch PDF after $maxRetries attempts"));
  }

  // Future<Either<Exception, String>> getPDF({
  //   required int jobCardId,
  //   required String pdfType,
  //   int maxRetries = 20, // Number of retries
  //   Duration retryDelay = const Duration(seconds: 0), // Delay between retries
  // }) async {
  //   String pdf = "";
  //   int attempt = 0;

  //   while (attempt < maxRetries) {

  //     try {

  //       final response = await http
  //           .post(
  //             Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
  //             headers: {
  //               'Content-Type': 'application/json',
  //               'Connection': 'keep-alive',
  //               'Cookie': ConstanceManager.sessionId.toString()
  //             },
  //             body: jsonEncode(
  //               {
  //                 "jsonrpc": "2.0",
  //                 "params": {
  //                   "model": ApiModels.jobCard,
  //                   "method": ApiMethods.searchRead,
  //                   "kwargs": {},
  //                   "args": [
  //                     [
  //                       ["id", "=", jobCardId]
  //                     ]
  //                   ]
  //                 }
  //               },
  //             ),
  //           )
  //           .timeout(const Duration(seconds: 20));

  //       if (response.statusCode == 200) {

  //         var value = jsonDecode(response.body)["result"];
  //         if (pdfType == "fault" && value[0]["Attending_Technician"] != false) {
  //           pdf = value[0]["Attending_Technician"];
  //         }
  //         if (pdfType == "amc" && value[0]["amc_file"] != false) {
  //           pdf = value[0]["amc_file"];
  //         }

  //         return Right(pdf); // Return successful result
  //       } else {

  //       }
  //     } on Exception  {

  //     }

  //     attempt++;
  //     if (attempt < maxRetries) {
  //       await Future.delayed(retryDelay); // Wait before retrying
  //     }
  //   }

  //   // Return the last encountered error if all retries fail
  //   return Left(Exception("Unexpected error"));
  // }

  @override
  Future<Either<Exception, bool>> acceptJobCard({required int id}) async {
    try {
      await http.post(
        Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString()
        },
        body: jsonEncode(
          {
            "params": {
              "model": ApiModels.jobCard,
              "method": ApiMethods.write,
              "kwargs": {},
              "args": [
                id,
                {"User_name": ConstanceManager.name}
              ]
            },
          },
        ),
      );
      return const Right(true);
    } on Exception catch (error) {
      return Left(error);
    }
  }

  @override
  Future<Either<Exception, bool>> ignoreJobCard({required int id}) async {
    try {
      await http.post(
        Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString()
        },
        body: jsonEncode(
          {
            "params": {
              "model": ApiModels.jobCard,
              "method": ApiMethods.write,
              "kwargs": {},
              "args": [
                id,
                {"User_name": null}
              ]
            }
          },
        ),
      );
      return const Right(true);
    } on Exception catch (error) {
      return Left(error);
    }
  }

  /// FAULT
  @override
  Future<Either<Exception, bool>> faultReport({
    required FaultFormModel formModel,
    required int jobCardId,
  }) async {
    try {
      /// photos
      if (formModel.purchaseBillPhoto!.isNotEmpty) {
        await _uploadToAttachments(photos: formModel.purchaseBillPhoto!)
            .then((value) {
          formModel.purchaseBillPhotoIds = value;
        });
      }
      if (formModel.beforePhotos!.isNotEmpty) {
        await _uploadToAttachments(photos: formModel.beforePhotos!)
            .then((value) {
          formModel.beforePhotosIds = value;
        });
      }
      if (formModel.afterPhotos!.isNotEmpty) {
        await _uploadToAttachments(photos: formModel.afterPhotos!)
            .then((value) {
          formModel.afterPhotosIds = value;
        });
      }
      await _writeFault(
          data: formModel.toJson(id: jobCardId), faultId: formModel.faultId!);
      await _writeJobCard(
        {
          "Attending_Technician": formModel.faultFile,
          "report_type": formModel.reportType,
          "comments": formModel.comment,
          "revisit": false,
          "start_work": false,
        },
        jobCardId,
      );
      return const Right(true);
    } on Exception catch (error) {
      return Left(error);
    }
  }

  @override
  Future<Either<Exception, int>> saveFaultData({
    required FaultFormModel formModel,
    required int jobCardId,
  }) async {
    try {
      int faultId = 0;
      await _createFault(jobCardId).then((value) => faultId = value);
      formModel.faultId = faultId;

      /// serviceTypesIds
      List<int> serviceTypesIds = [];
      if (formModel.serviceTypes != null &&
          formModel.serviceTypes!.isNotEmpty) {
        for (ServiceTypeModel serviceType in formModel.serviceTypes!) {
          int value = await _createServiceLine(
            serviceType.toJson(faultId: faultId),
          );
          serviceTypesIds.add(value);
        }
      }
      formModel.serviceTypesIds = serviceTypesIds;

      /// photos
      if (formModel.purchaseBillPhoto!.isNotEmpty) {
        await _uploadToAttachments(photos: formModel.purchaseBillPhoto!)
            .then((value) {
          formModel.purchaseBillPhotoIds = value;
        });
      }
      if (formModel.beforePhotos!.isNotEmpty) {
        await _uploadToAttachments(photos: formModel.beforePhotos!)
            .then((value) {
          formModel.beforePhotosIds = value;
        });
      }
      if (formModel.afterPhotos!.isNotEmpty) {
        await _uploadToAttachments(photos: formModel.afterPhotos!)
            .then((value) {
          formModel.afterPhotosIds = value;
        });
      }
      await _writeFault(
          data: formModel.toJson(id: jobCardId), faultId: faultId);
      await _writeJobCard({
        "Attending_Technician": formModel.faultFile,
        "report_type": formModel.reportType,
        "comments": formModel.comment
      }, jobCardId);

      return Right(faultId);
    } on Exception catch (error) {
      return Left(error);
    }
  }

  @override
  Future<Either<Exception, bool>> updateFaultData({
    required FaultFormModel formModel,
    required int jobCardId,
  }) async {
    try {
      /// serviceTypesId;
      if (formModel.serviceTypesIds != null &&
          formModel.serviceTypesIds!.isNotEmpty) {
        for (int serviceTypesId in formModel.serviceTypesIds!) {
          await _deleteServiceLine(serviceTypesId);
        }
        formModel.serviceTypesIds = [];
      }
      List<int> serviceTypesIds = [];
      if (formModel.serviceTypes != null &&
          formModel.serviceTypes!.isNotEmpty) {
        for (ServiceTypeModel serviceType in formModel.serviceTypes!) {
          int value = await _createServiceLine(
              serviceType.toJson(faultId: formModel.faultId!));
          serviceTypesIds.add(value);
        }
      }
      formModel.serviceTypesIds = serviceTypesIds;

      /// photos
      if (formModel.purchaseBillPhoto!.isNotEmpty) {
        await _uploadToAttachments(photos: formModel.purchaseBillPhoto!)
            .then((value) {
          formModel.purchaseBillPhotoIds!.addAll(value);
          formModel.purchaseBillPhoto = [];
        });
      }
      if (formModel.beforePhotos!.isNotEmpty) {
        await _uploadToAttachments(photos: formModel.beforePhotos!)
            .then((value) {
          formModel.beforePhotosIds!.addAll(value);
          formModel.beforePhotos = [];
        });
      }
      if (formModel.afterPhotos!.isNotEmpty) {
        await _uploadToAttachments(photos: formModel.afterPhotos!)
            .then((value) {
          formModel.afterPhotosIds!.addAll(value);
          formModel.afterPhotos = [];
        });
      }
      await _writeFault(
          data: formModel.toJson(id: jobCardId), faultId: formModel.faultId!);
      return const Right(true);
    } on Exception catch (error) {
      return Left(error);
    }
  }

  @override
  Future<Either<Exception, bool>> deleteFaultData({
    required FaultFormModel formModel,
    required int jobCardId,
  }) async {
    try {
      /// serviceTypesIds
      if (formModel.serviceTypesIds != null &&
          formModel.serviceTypesIds!.isNotEmpty) {
        for (int serviceTypesId in formModel.serviceTypesIds!) {
          await _deleteServiceLine(serviceTypesId);
        }
      }

      /// photos
      if (formModel.purchaseBillPhoto!.isNotEmpty) {
        await _deletePhoto(photos: formModel.purchaseBillPhotoIds ?? []);
      }
      if (formModel.beforePhotos!.isNotEmpty) {
        await _deletePhoto(photos: formModel.beforePhotosIds ?? []);
      }
      if (formModel.afterPhotos!.isNotEmpty) {
        await _deletePhoto(photos: formModel.afterPhotosIds ?? []);
      }

      await _deleteFault(formModel.faultId!);
      await _writeJobCard({
        "Attending_Technician": "",
        "report_type": "",
        "comments": "",
        "revisit": false,
        "start_work": false,
      }, jobCardId);
      return const Right(true);
    } on Exception catch (error) {
      return Left(error);
    }
  }

  @override
  Future<Either<Exception, List<FaultFormModel>>> getFaultReport({
    required int jobCardId,
    required bool isComplaint,
    int maxRetries = 15, // Number of retries
    Duration retryDelay = const Duration(seconds: 0), // Delay between retries
  }) async {
    List<FaultFormModel> formModels = [];
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
              body: jsonEncode(
                {
                  "params": {
                    "model": ApiModels.fault,
                    "method": ApiMethods.searchRead,
                    "kwargs": {},
                    "args": [
                      [
                        ["job_card_id", "=", jobCardId]
                      ]
                    ]
                  }
                },
              ),
            )
            .timeout(const Duration(minutes: 2));

        if (response.statusCode == 200) {
          var value = jsonDecode(response.body)["result"];
          value.forEach((element) {
            formModels.add(FaultFormModel.fromJson(element));
          });

          if (!isComplaint) {
            for (var formModel in formModels) {
              await _populatePhotosAndServiceTypes(formModel);
            }
          }

          return Right(formModels); // Return the formModels on success
        } else {}
      } on Exception {}

      attempt++;
      if (attempt < maxRetries) {
        await Future.delayed(retryDelay); // Wait before retrying
      }
    }

    // Return the last encountered error if all retries fail
    return Left(
        Exception("Failed to fetch fault report after $maxRetries attempts"));
  }

  Future<void> _populatePhotosAndServiceTypes(FaultFormModel formModel) async {
    List<String> beforePhotos = [];
    List<String> afterPhotos = [];
    List<String> purchaseBillPhoto = [];
    List<ServiceTypeModel> serviceTypes = [];

    // Populate beforePhotos, afterPhotos, and purchaseBillPhoto
    if (formModel.beforePhotosIds != null &&
        formModel.beforePhotosIds!.isNotEmpty) {
      for (var beforePhotoId in formModel.beforePhotosIds!) {
        // beforePhotosMemory.add(await _convertImageToMemory(beforePhotoId));
        beforePhotos.add(ApiConsts.imageUrl + beforePhotoId.toString());
      }
    }

    if (formModel.afterPhotosIds != null &&
        formModel.afterPhotosIds!.isNotEmpty) {
      for (var afterPhotoId in formModel.afterPhotosIds!) {
        // afterPhotosMemory.add(await _convertImageToMemory(afterPhotoId));
        afterPhotos.add(ApiConsts.imageUrl + afterPhotoId.toString());
      }
    }

    if (formModel.purchaseBillPhotoIds != null &&
        formModel.purchaseBillPhotoIds!.isNotEmpty) {
      for (var purchaseBillPhotoId in formModel.purchaseBillPhotoIds!) {
        // purchaseBillPhotoMemory.add(await _convertImageToMemory(purchaseBillPhotoId));
        purchaseBillPhoto
            .add(ApiConsts.imageUrl + purchaseBillPhotoId.toString());
      }
    }

    formModel.beforePhotos = beforePhotos;
    formModel.afterPhotos = afterPhotos;
    formModel.purchaseBillPhoto = purchaseBillPhoto;

    // Populate serviceTypes
    final serviceLineResponse = await http
        .post(
          Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
            'Cookie': ConstanceManager.sessionId.toString(),
          },
          body: jsonEncode(
            {
              "params": {
                "model": ApiModels.serviceLine,
                "method": ApiMethods.searchRead,
                "kwargs": {},
                "args": [
                  [
                    ["fault_id", "=", formModel.faultId]
                  ]
                ]
              }
            },
          ),
        )
        .timeout(const Duration(minutes: 2));

    if (serviceLineResponse.statusCode == 200) {
      var serviceLineValue = jsonDecode(serviceLineResponse.body)["result"];
      serviceLineValue.forEach((element) {
        serviceTypes.add(ServiceTypeModel.fromJson(element));
      });
    }

    formModel.serviceTypes = serviceTypes;
  }

  /// AMC CARD
  @override
  Future<Either<Exception, List<AmcCard>>> getAmcCards() async {
    List<AmcCard> amcCards = [];
    try {
      await http
          .post(
        Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString()
        },
        body: jsonEncode(
          {
            "params": {
              "model": ApiModels.amcCard,
              "method": ApiMethods.searchRead,
              "kwargs": {},
              "args": [{}]
            },
          },
        ),
      )
          .then(
        (res) {
          var value = jsonDecode(res.body)["result"];
          value.forEach((element) {
            amcCards.add(AmcCardModel.fromJson(element));
          });
        },
      );
      return Right(amcCards);
    } on Exception catch (error) {
      return Left(error);
    }
  }

  @override
  Future<Either<Exception, List<AmcBuilding>>> getAmcBuilding(
      {required int amcCardId}) async {
    List<AmcBuilding> amcBuildings = [];
    try {
      await http
          .post(
        Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString()
        },
        body: jsonEncode(
          {
            "params": {
              "model": ApiModels.amcBuilding,
              "method": ApiMethods.searchRead,
              "kwargs": {},
              "args": [{}]
            },
          },
        ),
      )
          .then(
        (res) {
          var value = jsonDecode(res.body)["result"];
          value.forEach((element) {
            amcBuildings.add(AmcBuildingModel.fromJson(element));
          });
        },
      );
      return Right(amcBuildings);
    } on Exception catch (error) {
      return Left(error);
    }
  }

  @override
  Future<Either<Exception, bool>> submitAmcCardReport({
    required List<AmcAcCheckListModel> amcAcCheckListModels,
    required Map<String, int> acTypesValues,
    required Map<String, int> acTypesIndex,
    required int amcCardId,
    required List<int> flatsNumbers,
    required int buildingId,
    required int numDryServices,
    required int numWetServices,
  }) async {
    try {
      Map<String, int> mp = {};
      int numDryServicesUpdated = 0;
      int numWetServicesUpdated = 0;
      Map<int, int> acTypesUpdated = {};

      /// submit AcCheckList
      for (var amcAcCheckListModel in amcAcCheckListModels) {
        mp.update(amcAcCheckListModel.acType, (value) => (value) + 1,
            ifAbsent: () => 1);
        if (amcAcCheckListModel.numServices == "Dry") {
          numDryServicesUpdated++;
        } else if (amcAcCheckListModel.numServices == "Wet") {
          numWetServicesUpdated++;
        }
        await http.post(
          Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
            'Cookie': ConstanceManager.sessionId.toString()
          },
          body: jsonEncode(
            {
              "params": {
                "model": ApiModels.amcAcChecklist,
                "method": ApiMethods.create,
                "args": [amcAcCheckListModel.toJson(amcCardId: amcCardId)],
                "kwargs": {},
              },
            },
          ),
        );
      }

      /// Decrease
      for (var ac in acTypesValues.entries) {
        if (mp.containsKey(ac.key)) {
          acTypesUpdated.addAll({
            acTypesIndex[ac.key]!: ac.value - mp[ac.key]!
            //  index       presentValue - ac(will be decreased)
          });
        }
      }
      for (var updated in acTypesUpdated.entries) {
        await http.post(
          Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
            'Cookie': ConstanceManager.sessionId.toString()
          },
          body: jsonEncode(
            {
              "params": {
                "model": ApiModels.amcAcType,
                "method": ApiMethods.write,
                "args": [
                  updated.key,
                  {"quantity": updated.value}
                ],
                "kwargs": {},
              },
            },
          ),
        );
      }
      await http.post(
        Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString()
        },
        body: jsonEncode(
          {
            "params": {
              "model": ApiModels.amcBuilding,
              "method": ApiMethods.write,
              "args": [
                buildingId,
                {
                  "flat_building": flatsNumbers,
                  "num_dry_services": numDryServices - numDryServicesUpdated,
                  "num_wet_services": numWetServices - numWetServicesUpdated,
                }
              ],
              "kwargs": {},
            }
          },
        ),
      );
      await http.post(
        Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString()
        },
        body: jsonEncode(
          {
            "params": {
              "model": ApiModels.amcCard,
              "method": ApiMethods.write,
              "args": [
                amcCardId,
                {"amc_file_c": amcAcCheckListModels.last.amcFile}
              ],
              "kwargs": {},
            }
          },
        ),
      );
      return const Right(true);
    } on Exception catch (error) {
      return Left(error);
    }
  }

  Future<void> _deleteFault(int faultId) async {
    await http.post(
      Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
      headers: {
        'Content-Type': 'application/json',
        'Connection': 'keep-alive',
        'Cookie': ConstanceManager.sessionId.toString()
      },
      body: jsonEncode(
        {
          "params": {
            "model": ApiModels.fault,
            "method": ApiMethods.unlink,
            "kwargs": {},
            "args": [faultId],
          },
        },
      ),
    );
  }

  Future<void> _deleteServiceLine(int serviceTypesId) async {
    // await client.callKw({
    //   "model": ApiModels.serviceLine,
    //   "method": ApiMethods.unlink,
    //   "kwargs": {},
    //   "args": [serviceTypesId],
    // });
    await http.post(
      Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
      headers: {
        'Content-Type': 'application/json',
        'Connection': 'keep-alive',
        'Cookie': ConstanceManager.sessionId.toString()
      },
      body: jsonEncode(
        {
          "params": {
            "model": ApiModels.serviceLine,
            "method": ApiMethods.unlink,
            "kwargs": {},
            "args": [serviceTypesId],
          },
        },
      ),
    );
  }

  Future<int> _createFault(int id) async {
    return await http
        .post(
          Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
            'Cookie': ConstanceManager.sessionId.toString()
          },
          body: jsonEncode(
            {
              "params": {
                "model": ApiModels.fault,
                "method": ApiMethods.create,
                "kwargs": {},
                "args": [
                  {
                    "job_card_id": id,
                  }
                ],
              },
            },
          ),
        )
        .then((value) => jsonDecode(value.body)["result"]);
  }

  Future<int> _createServiceLine(var serviceLine) async {
    return await http
        .post(
          Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
            'Cookie': ConstanceManager.sessionId.toString()
          },
          body: jsonEncode(
            {
              "params": {
                "model": ApiModels.serviceLine,
                "method": ApiMethods.create,
                "kwargs": {},
                "args": [serviceLine],
              },
            },
          ),
        )
        .then((value) => jsonDecode(value.body)["result"]);
  }

  Future<void> _writeFault({required var data, required int faultId}) async {
    await http.post(
      Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
      headers: {
        'Content-Type': 'application/json',
        'Connection': 'keep-alive',
        'Cookie': ConstanceManager.sessionId.toString()
      },
      body: jsonEncode(
        {
          "params": {
            "model": ApiModels.fault,
            "method": ApiMethods.write,
            "kwargs": {},
            "args": [faultId, data],
          },
        },
      ),
    );
  }

  Future<void> _writeJobCard(var data, int jobCardId) async {
    await http.post(
      Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
      headers: {
        'Content-Type': 'application/json',
        'Connection': 'keep-alive',
        'Cookie': ConstanceManager.sessionId.toString()
      },
      body: jsonEncode(
        {
          "params": {
            "model": ApiModels.jobCard,
            "method": ApiMethods.write,
            "kwargs": {},
            "args": [jobCardId, data],
          },
        },
      ),
    );
  }

  Future<List<int>> _uploadToAttachments({required List<String> photos}) async {
    List<int> list = [];
    for (var element in photos) {
      if (!element.contains(ApiConsts.imageUrl)) {
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
          body: jsonEncode(
            {
              "params": {
                "model": ApiModels.attachment,
                "method": ApiMethods.create,
                "kwargs": {},
                "args": [
                  {
                    "name": "${element.length}.$format",
                    "datas": element,
                  }
                ],
              },
            },
          ),
        )
            .then(
          (res) {
            var value = jsonDecode(res.body)["result"];
            list.add(value);
          },
        );
      }
    }
    return list;
  }

  Future<void> _deletePhoto({required List<int> photos}) async {
    for (var element in photos) {
      await http.post(
        Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString()
        },
        body: jsonEncode(
          {
            "params": {
              "model": ApiModels.attachment,
              "method": ApiMethods.unlink,
              "kwargs": {},
              "args": [element],
            },
          },
        ),
      );
    }
  }

  String _getImageFormat(List<int> imageData) {
    if (imageData.length < 4) {
      return "";
    }
    if (imageData[0] == 0xFF && imageData[1] == 0xD8) {
      return "jpg"; // JPEG format
    } else if (imageData[0] == 0x89 &&
        imageData[1] == 0x50 &&
        imageData[2] == 0x4E &&
        imageData[3] == 0x47) {
      return "png";
    }
    return "";
  }

  /// SERVICE LINE
  @override
  Future<Either<Exception, List<Product>>> getProducts() async {
    try {
      List<Product> products = [];
      var fields = {
        "fields": ["partner_ref", "id"]
      };
      await http
          .post(
        Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString()
        },
        body: jsonEncode(
          {
            "params": {
              "model": ApiModels.product,
              "method": ApiMethods.searchRead,
              "kwargs": fields,
              "args": [{}]
            },
          },
        ),
      )
          .then(
        (res) {
          var value = jsonDecode(res.body)["result"];
          value.forEach((element) {
            products.add(ProductModel.fromJson(element));
          });
        },
      );

      return Right(products);
    } on Exception catch (error) {
      return Left(error);
    }
  }

  /// SPARE
  @override
  Future<Either<Exception, List<Spare>>> getSpares() async {
    try {
      List<Spare> spares = [];
      await http
          .post(
        Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString()
        },
        body: jsonEncode(
          {
            "params": {
              "model": ApiModels.spare,
              "method": ApiMethods.searchRead,
              "kwargs": {},
              "args": [{}]
            },
          },
        ),
      )
          .then(
        (res) {
          var value = jsonDecode(res.body)["result"];
          value.forEach((element) {
            spares.add(SpareModel.fromJson(element));
          });
        },
      );
      return Right(spares);
    } on Exception catch (error) {
      return Left(error);
    }
  }
}
