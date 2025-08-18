import 'package:dartz/dartz.dart';

/// A simple domain-level abstraction for uploading a bill image and getting back
/// an attachment ID. The repository will handle actual transport/storage.
abstract class UploadImageUseCase {
  Future<Either<Exception, int>> call(String base64Image);
}

