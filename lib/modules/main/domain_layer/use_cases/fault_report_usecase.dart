import 'package:bayanat/modules/main/data_layer/models/fault_model.dart';
import 'package:dartz/dartz.dart';
// import 'package:odoo_rpc/odoo_rpc.dart';

import '../repsitories/base_main_repository.dart';

class FaultReportUseCase {
  final BaseMainRepository baseAuthRepository;

  FaultReportUseCase(this.baseAuthRepository);

  Future<Either<Exception, bool>> post({
    required FaultFormModel formModel,
    required int id,
  }) async {
    return await baseAuthRepository.faultReport(
      formModel: formModel,
      id: id,
    );
  }
}
