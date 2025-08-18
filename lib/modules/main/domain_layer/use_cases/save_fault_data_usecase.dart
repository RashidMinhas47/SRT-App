import 'package:bayanat/modules/main/data_layer/models/fault_model.dart';
import 'package:dartz/dartz.dart';
// import 'package:odoo_rpc/odoo_rpc.dart';
import '../repsitories/base_main_repository.dart';

class SaveFaultDataUseCase {
  final BaseMainRepository baseAuthRepository;

  SaveFaultDataUseCase(this.baseAuthRepository);

  Future<Either<Exception, int>> save({
    required FaultFormModel formModel,
    required int id,
  }) async {
    return await baseAuthRepository.saveFaultData(
        formModel: formModel, id: id,);
  }
}
