import 'package:dartz/dartz.dart';
import '../repositories/petty_cash_repository.dart';

class UploadPhoto {
  final PettyCashRepository repository;

  UploadPhoto(this.repository);

  Future<Either<Exception, String>> call(String filePath) async {
    if (filePath.trim().isEmpty) {
      return Left(Exception('File path is required'));
    }

    // Additional validation can be added here
    // e.g., file size, file type, etc.

    return await repository.uploadPhoto(filePath);
  }
}
