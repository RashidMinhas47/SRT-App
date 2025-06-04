import 'package:dartz/dartz.dart';
// import 'package:odoo_rpc/odoo_rpc.dart';
import '../../data_layer/models/fault_model.dart';
import '../repsitories/base_main_repository.dart';

class GetFaultUseCase {
  final BaseMainRepository baseMainRepository;
  GetFaultUseCase(this.baseMainRepository);
  Future<Either<Exception, List<FaultFormModel>>> get(
      {required int jobCardId,required bool isComplaint}) async {
    return baseMainRepository.getFaultReport(jobCardId: jobCardId,isComplaint: isComplaint);
  }
}
