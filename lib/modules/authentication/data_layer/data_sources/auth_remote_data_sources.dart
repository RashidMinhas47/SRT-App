import 'dart:async';
import 'dart:convert';
import 'package:bayanat/core/remote/api_helper/end_points.dart';
import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:dartz/dartz.dart';
// import 'package:odoo_rpc/odoo_rpc.dart';
import '../../../../core/local/shared_prefrences.dart';
import '../../../../core/remote/api_helper/api_constance.dart';
import '../../../../core/remote/api_helper/api_models.dart';
import '../../../../core/remote/api_helper/methods.dart';
import '../../../../core/services/dep_injection.dart';
import 'package:http/http.dart' as http;

abstract class BaseAuthRemoteDataSource {
  Future<Either<Exception, bool>> loginWithEmailAndPass({
    required String email,
    required String password,
  });

  Future<void> fetchUserProfile(String cookie, int userId);
}

class AuthRemoteDataSource extends BaseAuthRemoteDataSource {
  @override
  Future<Either<Exception, bool>> loginWithEmailAndPass({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConsts.baseUrl + ApiEndPoints.authenticate),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "params": {
                "db": ApiConsts.db,
                "login": email,
                "password": password,
              }
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Invalid credentials or access denied
        if (decoded.containsKey('error')) {
          print("Login failed: ${decoded['error']}");
          return const Right(false);
        }

        //  Valid login
        String? rawCookie = response.headers['set-cookie'];
        if (rawCookie == null) {
          print("No cookie set in headers");
          return const Right(false);
        }

        int index = rawCookie.indexOf(';');
        String cookie =
            (index == -1) ? rawCookie : rawCookie.substring(0, index);

        final uid = decoded['result']?['uid'];
        if (uid == null) {
          print("UID missing from result");
          return const Right(false);
        }

        ConstanceManager.sessionId = cookie;
        ConstanceManager.userId = uid;

        await CacheHelper.saveData(key: "userId", value: uid);
        await CacheHelper.saveData(key: "sessionId", value: cookie);

        print("Login success: UID = $uid");
        return const Right(true);
      } else {
        print("Non-200 response: ${response.statusCode}");
        return const Right(false);
      }
    } on Exception catch (error) {
      print("Login exception: $error");
      return Left(error);
    }
  }

// class AuthRemoteDataSource extends BaseAuthRemoteDataSource {
//   @override
//   Future<Either<Exception, bool>> loginWithEmailAndPass({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse(ApiConsts.baseUrl + ApiEndPoints.authenticate),
//             headers: {'Content-Type': 'application/json'},
//             body: jsonEncode({
//               "params": {
//                 "db": ApiConsts.db,
//                 "login": email,
//                 "password": password,
//               }
//             }),
//           )
//           .timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         String? rawCookie = response.headers['set-cookie'];
//         int index = rawCookie!.indexOf(';');
//         String cookie =
//             (index == -1) ? rawCookie : rawCookie.substring(0, index);

//         ConstanceManager.sessionId = cookie;
//         ConstanceManager.userId = jsonDecode(response.body)["result"]["uid"];

//         await CacheHelper.saveData(
//             key: "userId", value: ConstanceManager.userId);
//         await CacheHelper.saveData(key: "sessionId", value: cookie);
//       } else {
//         return const Right(false);
//       }

//       return const Right(true);
//     } on Exception catch (error) {
//       return Left(error);
//     }
//   }

  @override
  Future<void> fetchUserProfile(String cookie, int userId) async {
    final res = await http
        .post(
          Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
          headers: {
            'Content-Type': 'application/json',
            'Cookie': cookie,
          },
          body: jsonEncode({
            "params": {
              "model": ApiModels.users,
              "method": ApiMethods.searchRead,
              "kwargs": {},
              "args": [
                [
                  ["id", "=", userId]
                ]
              ]
            }
          }),
        )
        .timeout(const Duration(seconds: 10));

    final value = jsonDecode(res.body);
    await CacheHelper.saveData(
        key: "image", value: value["result"][0]["image_1920"]);
    await CacheHelper.saveData(key: "name", value: value["result"][0]["name"]);
    await CacheHelper.saveData(
        key: "workPhone", value: value["result"][0]["work_phone"]);

    ConstanceManager.name = value["result"][0]["name"];

    if (value["result"][0]["work_phone"] != false) {
      ConstanceManager.workPhone = value["result"][0]["work_phone"].toString();
    }
    if (value["result"][0]["image_1920"] != false) {
      ConstanceManager.image = value["result"][0]["image_1920"].toString();
    }
  }
}

//Old Code
// import 'dart:async';
// import 'dart:convert';
// import 'package:bayanat/core/remote/api_helper/end_points.dart';
// import 'package:bayanat/core/utils/constance_manager.dart';
// import 'package:dartz/dartz.dart';
// // import 'package:odoo_rpc/odoo_rpc.dart';
// import '../../../../core/local/shared_prefrences.dart';
// import '../../../../core/remote/api_helper/api_constance.dart';
// import '../../../../core/remote/api_helper/api_models.dart';
// import '../../../../core/remote/api_helper/methods.dart';
// import '../../../../core/services/dep_injection.dart';
// import 'package:http/http.dart' as http;

// abstract class BaseAuthRemoteDataSource {
//   Future<Either<Exception, bool>> loginWithEmailAndPass({
//     required String email,
//     required String password,
//   });
// }

// class AuthRemoteDataSource extends BaseAuthRemoteDataSource {
//   @override
//   Future<Either<Exception, bool>> loginWithEmailAndPass(
//       {required String email, required String password}) async {
//     try {
//       // OdooClient client = sl();
//       // await client
//       //     .authenticate(ApiConsts.db, email, password)
//       //     .then((value) async {
//       //   await CacheHelper.saveData(
//       //       key: "sessionId", value: client.sessionId!.id);
//       //   await CacheHelper.saveData(
//       //       key: "userId", value: client.sessionId!.userId);
//       //   await CacheHelper.saveData(
//       //       key: "partnerId", value: client.sessionId!.partnerId);
//       //   await CacheHelper.saveData(
//       //       key: "companyId", value: client.sessionId!.companyId);
//       //   await CacheHelper.saveData(
//       //       key: "userLogin", value: client.sessionId!.userLogin);
//       //   await CacheHelper.saveData(
//       //       key: "userName", value: client.sessionId!.userName);
//       //   await CacheHelper.saveData(
//       //       key: "userLang", value: client.sessionId!.userLang);
//       //   await CacheHelper.saveData(
//       //       key: "userTz", value: client.sessionId!.userTz);
//       //   await CacheHelper.saveData(
//       //       key: "isSystem", value: client.sessionId!.isSystem);
//       //   await CacheHelper.saveData(
//       //       key: "serverVersion", value: client.sessionId!.serverVersion);
//       //   await client.callKw(
//       //     {
//       //       "model": ApiModels.users,
//       //       "method": ApiMethods.searchRead,
//       //       "kwargs": {},
//       //       "args": [
//       //         [
//       //           ["id", "=", client.sessionId!.userId]
//       //         ]
//       //       ]
//       //     },
//       //   ).then((value) async {
//       //     await CacheHelper.saveData(
//       //         key: "image", value: value["image_1920"]);
//       //     await CacheHelper.saveData(key: "name", value: value["name"]);
//       //     await CacheHelper.saveData(
//       //         key: "workPhone", value: value["work_phone"]);
//       //     ConstanceManager.name = value["name"];
//       //     if (value["work_phone"] != false) {
//       //       ConstanceManager.workPhone = value["work_phone"].toString();
//       //     }
//       //     if (value["image_1920"] != false) {
//       //       ConstanceManager.image = value["image_1920"].toString();
//       //     }
//       //   });
//       // });
//       final response = await http.post(
//         Uri.parse(ApiConsts.baseUrl + ApiEndPoints.authenticate),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           "params": {"db": ApiConsts.db, "login": email, "password": password}
//         }),
//       );
//       if (response.statusCode == 200) {
//         // Extract cookies from response headers
//         String? rawCookie = response.headers['set-cookie'];
//         int index = rawCookie!.indexOf(';');
//         String cookie =
//             (index == -1) ? rawCookie : rawCookie.substring(0, index);
//         ConstanceManager.sessionId = cookie;
//         ConstanceManager.userId = jsonDecode(response.body)["result"]["uid"];
//         await CacheHelper.saveData(
//             key: "userId", value: ConstanceManager.userId);
//         await CacheHelper.saveData(key: "sessionId", value: cookie).then(
//           (value) async {
//             await http
//                 .post(
//               Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
//               headers: {
//                 'Content-Type': 'application/json',
//                 'Cookie': cookie,
//               },
//               body: jsonEncode(
//                 {
//                   "params": {
//                     "model": ApiModels.users,
//                     "method": ApiMethods.searchRead,
//                     "kwargs": {},
//                     "args": [
//                       [
//                         [
//                           "id",
//                           "=",
//                           jsonDecode(response.body)["result"]["uid"]
//                         ]
//                       ]
//                     ]
//                   },
//                 },
//               ),
//             )
//                 .then(
//               (res) async {
//                 var value = jsonDecode(res.body);
//                 await CacheHelper.saveData(
//                     key: "image", value: value["result"][0]["image_1920"]);
//                 await CacheHelper.saveData(key: "name", value: value["result"][0]["name"]);
//                 await CacheHelper.saveData(
//                     key: "workPhone", value: value["result"][0]["work_phone"]);
//                 ConstanceManager.name = value["result"][0]["name"];
//                 if (value["result"][0]["work_phone"] != false) {
//                   ConstanceManager.workPhone = value["result"][0]["work_phone"].toString();
//                 }
//                 if (value["result"][0]["image_1920"] != false) {
//                   ConstanceManager.image = value["result"][0]["image_1920"].toString();
//                 }
//               },
//             );
//           },
//         );
//             } else {

//         return const Right(false);
//       }
//       return const Right(true);
//     } on Exception catch (error) {
//       return Left(error);
//     }
//   }
// }
