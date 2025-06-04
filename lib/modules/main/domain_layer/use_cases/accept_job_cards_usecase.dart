import 'package:dartz/dartz.dart';
// import 'package:odoo_rpc/odoo_rpc.dart';
import '../repsitories/base_main_repository.dart';

class AcceptJobCardsUseCase {
  final BaseMainRepository baseMainRepository;
  AcceptJobCardsUseCase(this.baseMainRepository);
  Future<Either<Exception, bool>> write({required int id}) async {
    return baseMainRepository.acceptJobCard(id: id);
  }
}
