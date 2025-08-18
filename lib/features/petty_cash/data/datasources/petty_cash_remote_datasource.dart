import 'dart:convert';

import 'package:bayanat/core/remote/api_helper/api_constance.dart';
import 'package:bayanat/core/remote/api_helper/api_models.dart';
import 'package:bayanat/core/remote/api_helper/end_points.dart';
import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../models/petty_cash_model.dart';

abstract class PettyCashRemoteDataSource {
  Future<Either<Exception, bool>> submit(PettyCashModel model);
  Future<Either<Exception, bool>> update(PettyCashModel model);
  Future<Either<Exception, bool>> delete(int id);
  Future<Either<Exception, PettyCashModel>> getById(int id);
  Future<Either<Exception, List<PettyCashModel>>> list({int? offset, int? limit});
  Future<Either<Exception, int>> uploadAttachment(String base64Image);
}

class PettyCashRemoteDataSourceImpl implements PettyCashRemoteDataSource {
  Future<http.Response> _post(Map<String, dynamic> body) {
    return http.post(
      Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
      headers: {
        'Content-Type': 'application/json',
        'Connection': 'keep-alive',
        'Cookie': ConstanceManager.sessionId.toString(),
      },
      body: jsonEncode(body),
    );
  }

  @override
  Future<Either<Exception, bool>> submit(PettyCashModel model) async {
    try {
      final payload = {
        'params': {
          'model': ApiModels.pettyCash,
          'method': 'create',
          'kwargs': {},
          'args': [model.toJson()],
        }
      };
      final res = await _post(payload).timeout(const Duration(seconds: 60));
      if (res.statusCode == 200) return const Right(true);
      return Left(Exception('Submit failed: ${res.statusCode}'));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, bool>> update(PettyCashModel model) async {
    try {
      if (model.id == null) return Left(Exception('Missing id'));
      final payload = {
        'params': {
          'model': ApiModels.pettyCash,
          'method': 'write',
          'kwargs': {},
          'args': [model.id, model.toJson()],
        }
      };
      final res = await _post(payload).timeout(const Duration(seconds: 60));
      if (res.statusCode == 200) return const Right(true);
      return Left(Exception('Update failed: ${res.statusCode}'));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, bool>> delete(int id) async {
    try {
      final payload = {
        'params': {
          'model': ApiModels.pettyCash,
          'method': 'unlink',
          'kwargs': {},
          'args': [id],
        }
      };
      final res = await _post(payload).timeout(const Duration(seconds: 60));
      if (res.statusCode == 200) return const Right(true);
      return Left(Exception('Delete failed: ${res.statusCode}'));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, PettyCashModel>> getById(int id) async {
    try {
      final payload = {
        'params': {
          'model': ApiModels.pettyCash,
          'method': 'search_read',
          'kwargs': {},
          'args': [
            [
              ['id', '=', id]
            ]
          ],
        }
      };
      final res = await _post(payload).timeout(const Duration(seconds: 60));
      if (res.statusCode == 200) {
        final result = jsonDecode(res.body)['result'];
        if (result is List && result.isNotEmpty) {
          return Right(PettyCashModel.fromJson(result.first));
        }
        return Left(Exception('Not found'));
      }
      return Left(Exception('Fetch failed: ${res.statusCode}'));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, List<PettyCashModel>>> list({int? offset, int? limit}) async {
    try {
      final payload = {
        'params': {
          'model': ApiModels.pettyCash,
          'method': 'search_read',
          'kwargs': {
            if (limit != null) 'limit': limit,
            if (offset != null) 'offset': offset,
          },
          'args': [
            []
          ],
        }
      };
      final res = await _post(payload).timeout(const Duration(seconds: 60));
      if (res.statusCode == 200) {
        final result = jsonDecode(res.body)['result'];
        if (result is List) {
          return Right(result.map((e) => PettyCashModel.fromJson(e)).toList());
        }
      }
      return Left(Exception('List failed: ${res.statusCode}'));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, int>> uploadAttachment(String base64Image) async {
    try {
      final bytes = base64Decode(base64Image);
      final format = _getImageFormat(bytes);
      final payload = {
        'params': {
          'model': ApiModels.attachment,
          'method': 'create',
          'kwargs': {},
          'args': [
            {
              'name': 'petty_${base64Image.length}.$format',
              'datas': base64Image,
            }
          ],
        }
      };
      final res = await _post(payload).timeout(const Duration(seconds: 60));
      if (res.statusCode == 200) {
        final id = jsonDecode(res.body)['result'];
        return Right(id as int);
      }
      return Left(Exception('Upload failed: ${res.statusCode}'));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  String _getImageFormat(List<int> binary) {
    if (binary.length >= 3 && binary[0] == 0xFF && binary[1] == 0xD8 && binary[2] == 0xFF) return 'jpg';
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
}

