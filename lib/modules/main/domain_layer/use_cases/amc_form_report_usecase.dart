import 'package:bayanat/modules/main/data_layer/models/amc_model.dart';
import 'package:dartz/dartz.dart';
import '../repsitories/base_main_repository.dart';

class AmcFormReportUseCase {
  final BaseMainRepository baseAuthRepository;
  AmcFormReportUseCase(this.baseAuthRepository);
  Future<Either<Exception, bool>>
  post({required AmcFormModel amcFormModel,required int id}) async {
    return await baseAuthRepository.amcFormReport(
        amcFormModel: amcFormModel,id: id);
  }
}
