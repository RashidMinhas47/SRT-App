import 'package:dartz/dartz.dart';
// import 'package:odoo_rpc/odoo_rpc.dart';
import '../repsitories/base_main_repository.dart';

class IgnoreJobCardsUseCase {
  final BaseMainRepository baseMainRepository;
  IgnoreJobCardsUseCase(this.baseMainRepository);
  Future<Either<Exception, bool>> write({required int id}) async {
    return baseMainRepository.ignoreJobCard(id: id);
  }
}
