import 'package:dartz/dartz.dart';
// import 'package:odoo_rpc/odoo_rpc.dart';
import '../../data_layer/models/amc_ac_checklsit_model.dart';
import '../repsitories/base_main_repository.dart';

class SubmitAmcCardReportUseCase {
  final BaseMainRepository baseAuthRepository;
  SubmitAmcCardReportUseCase(this.baseAuthRepository);
  Future<Either<Exception, bool>> call({
    required List<AmcAcCheckListModel> amcAcCheckListModels,
    required Map<String, int> acTypesValues,
    required Map<String, int> acTypesIndex,
    required int amcCardId,
    required int buildingId,
    required List<int> flatsNumbers,
    required int numDryServices,
    required int numWetServices,
  }) async {
    return await baseAuthRepository.submitAmcCardReport(
        amcAcCheckListModels: amcAcCheckListModels,
        acTypesValues: acTypesValues,
        numDryServices: numDryServices,
        numWetServices: numWetServices,
        flatsNumbers: flatsNumbers,
        buildingId: buildingId,
        acTypesIndex: acTypesIndex,
        amcCardId: amcCardId);
  }
}
