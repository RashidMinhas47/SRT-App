import 'package:bayanat/core/remote/api_helper/api_constance.dart';
import 'package:bayanat/core/remote/api_helper/api_models.dart';
import 'package:bayanat/core/remote/api_helper/end_points.dart';
import 'package:bayanat/core/remote/api_helper/methods.dart';
import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/employee_model.dart';

class EmployeeController {
  Future<Either<String, List<EmployeeModel>>> getAllEmployees() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString()
        },
        body: jsonEncode({
          "params": {
            "model": ApiModels.employee,
            "method": "search_read",
            "args": [
              [], // Domain
              [
                // Fields to fetch
                "active", "activity_calendar_event_id",
                "activity_date_deadline",
                "activity_exception_decoration", "activity_exception_icon",
                "activity_ids", "activity_state", "activity_summary",
                "activity_type_icon", "activity_type_id", "activity_user_id",
                "additional_note", "address_home_id", "address_id",
                "allocation_count", "allocation_display",
                "allocation_remaining_display",
                "allocations_count", "applicant_id", "avatar_1024",
                "avatar_128", "avatar_1920", "avatar_256", "avatar_512",
                "badge_ids", "bank_account_id", "barcode", "birthday",
                "calendar_mismatch", "car_ids", "category_ids", "certificate",
                "child_all_count", "child_ids", "children", "coach_id",
                "color", "company_country_code", "company_country_id",
                "company_id"
              ]
            ],
            "kwargs": {},
          },
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body)['result'];
        final List<EmployeeModel> employees =
            jsonData.map((json) => EmployeeModel.fromJson(json)).toList();
        return Right(employees);
      } else {
        return Left('Failed to fetch employees: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Error fetching employees: ${e.toString()}');
    }
  }

  Future<Either<String, EmployeeModel>> getEmployeeById(int employeeId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString()
        },
        body: jsonEncode({
          "params": {
            "model": ApiModels.employee,
            "method": ApiMethods.searchRead,
            "args": [
              [
                ["id", "=", employeeId]
              ], // Domain with ID filter
              [
                // Fields to fetch
                "active", "activity_calendar_event_id",
                "activity_date_deadline",
                "activity_exception_decoration", "activity_exception_icon",
                "activity_ids", "activity_state", "activity_summary",
                "activity_type_icon", "activity_type_id", "activity_user_id",
                "additional_note", "address_home_id", "address_id",
                "allocation_count", "allocation_display",
                "allocation_remaining_display",
                "allocations_count", "applicant_id", "avatar_1024",
                "avatar_128", "avatar_1920", "avatar_256", "avatar_512",
                "badge_ids", "bank_account_id", "barcode", "birthday",
                "calendar_mismatch", "car_ids", "category_ids", "certificate",
                "child_all_count", "child_ids", "children", "coach_id",
                "color", "company_country_code", "company_country_id",
                "company_id"
              ]
            ],
            "kwargs": {},
          },
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body)['result'];
        if (jsonData.isNotEmpty) {
          return Right(EmployeeModel.fromJson(jsonData.first));
        } else {
          return Left('Employee not found');
        }
      } else {
        return Left('Failed to fetch employee: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Error fetching employee: ${e.toString()}');
    }
  }
}
