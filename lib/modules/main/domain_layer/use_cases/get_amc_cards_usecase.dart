import 'package:dartz/dartz.dart';

import '../entities/amc_card.dart';
import '../repsitories/base_main_repository.dart';

class GetAmcCardsUseCase {
  final BaseMainRepository baseMainRepository;
  GetAmcCardsUseCase(this.baseMainRepository);
  Future<Either<Exception, List<AmcCard>>> call() async {
    return baseMainRepository.getAmcCards();
  }
}
