import 'package:bayanat/modules/main/domain_layer/entities/spare.dart';
import 'package:dartz/dartz.dart';
// import 'package:odoo_rpc/odoo_rpc.dart';
import '../repsitories/base_main_repository.dart';

class GetSparesUseCase {
  final BaseMainRepository baseAuthRepository;
  GetSparesUseCase(this.baseAuthRepository);
  Future<Either<Exception, List<Spare>>>
  get() async {
    return await baseAuthRepository.getSpares();
  }
}
