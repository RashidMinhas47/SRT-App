import 'package:dartz/dartz.dart';

import '../entities/amc_building.dart';
import '../repsitories/base_main_repository.dart';

class GetAmcBuildingsUseCase {
  final BaseMainRepository baseMainRepository;
  GetAmcBuildingsUseCase(this.baseMainRepository);
  Future<Either<Exception, List<AmcBuilding>>> call({required int amcCardId}) async {
    return baseMainRepository.getAmcBuildings(amcCardId: amcCardId);
  }
}
