import 'package:dartz/dartz.dart';
// import 'package:odoo_rpc/odoo_rpc.dart';
import '../repsitories/base_main_repository.dart';

class GetPDFUseCase {
  final BaseMainRepository baseMainRepository;
  GetPDFUseCase(this.baseMainRepository);
  Future<Either<Exception, String>> get({required int jobCardId,required String pdfType,}) async {
    return baseMainRepository.getPDF(jobCardId: jobCardId, pdfType: pdfType);
  }
}
