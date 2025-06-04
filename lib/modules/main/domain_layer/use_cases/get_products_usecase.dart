import 'package:dartz/dartz.dart';
// import 'package:odoo_rpc/odoo_rpc.dart';
import '../entities/product.dart';
import '../repsitories/base_main_repository.dart';

class GetProductsUseCase {
  final BaseMainRepository baseAuthRepository;
  GetProductsUseCase(this.baseAuthRepository);
  Future<Either<Exception, List<Product>>>
  get() async {
    return await baseAuthRepository.getProducts();
  }
}
