import 'package:bayanat/modules/main/domain_layer/entities/job_card.dart';
import 'package:dartz/dartz.dart';

import '../repsitories/base_main_repository.dart';

// class GetJobCardsUseCase {
//   final BaseMainRepository baseMainRepository;

//   GetJobCardsUseCase(this.baseMainRepository);

//   Future<Either<Exception, List<JobCard>>> call(
//       {int limit = 100, int offset = 0}) async {
//     return baseMainRepository.getJobCards(limit: limit, offset: offset);
//   }
// }

class GetJobCardsUseCase {
  final BaseMainRepository baseMainRepository;

  GetJobCardsUseCase(this.baseMainRepository);

  Future<Either<Exception, List<JobCard>>> call({
    required int offset,
    required int limit,
  }) async {
    return baseMainRepository.getJobCards(offset: offset, limit: limit);
  }
}
