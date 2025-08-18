import 'dart:convert';
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
}

class PettyCashRemoteDataSource extends BasePettyCashRemoteDataSource {
  Future<List<int>> _uploadToAttachments({required List<String> photos}) async {
    List<int> list = [];
    for (var element in photos) {
      if (!element.contains(ApiConsts.imageUrl)) {
        try {
          List<int> binaryImageData = base64Decode(element);
          String format = _getImageFormat(binaryImageData);
          final res = await http.post(
            Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
            headers: {
              'Content-Type': 'application/json',
              'Connection': 'keep-alive',
              'Cookie': ConstanceManager.sessionId.toString(),
            },
            body: jsonEncode({
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
            }),
          );
          final value = jsonDecode(res.body)["result"];
          list.add(value);
        } catch (e) {
          // ignore and continue; we'll return what succeeded
        }
      }
    }
    return list;
  }

  String _getImageFormat(List<int> binary) {
    if (binary.length >= 3 &&
        binary[0] == 0xFF &&
        binary[1] == 0xD8 &&
        binary[2] == 0xFF) return 'jpg';
    if (binary.length >= 8 &&
        binary[0] == 0x89 &&
        binary[1] == 0x50 &&
        binary[2] == 0x4E &&
        binary[3] == 0x47 &&
        binary[4] == 0x0D &&
        binary[5] == 0x0A &&
        binary[6] == 0x1A &&
        binary[7] == 0x0A) return 'png';
    return 'jpg';
  }

  @override
  Future<Either<Exception, bool>> submitPettyCash({
    required PettyCashModel pettyCash,
  }) async {
    try {
      final billIds = await _uploadToAttachments(
        photos: pettyCash.billPhotosBase64,
      );

      // NOTE: Odoo model name for petty cash needs to exist server-side.
      // Replace 'crmsrt.petty_cash' with the actual model if different.
      final response = await http.post(
        Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Cookie': ConstanceManager.sessionId.toString(),
        },
        body: jsonEncode({
          "params": {
            "model": ApiModels.pettyCash,
            "method": "create",
            "kwargs": {},
            "args": [
              {
                ...pettyCash.toJson(),
                "bill_attachment_ids": billIds,
              }
            ],
          },
        }),
      );

      if (response.statusCode == 200) {
        return const Right(true);
      }
      return Left(Exception("Failed to submit petty cash: ${response.statusCode}"));
    } on Exception catch (e) {
      return Left(e);
    }
  }
}

