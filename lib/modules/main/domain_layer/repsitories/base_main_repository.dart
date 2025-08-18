import 'package:dartz/dartz.dart';
import '../../data_layer/models/amc_ac_checklsit_model.dart';
import '../../data_layer/models/amc_model.dart';
import '../../data_layer/models/fault_model.dart';
import '../entities/amc_building.dart';
import '../entities/amc_card.dart';
import '../entities/job_card.dart';
import '../entities/product.dart';
import '../entities/spare.dart';

abstract class BaseMainRepository {
  Future<Either<Exception, bool>> amcFormReport(
      {required AmcFormModel amcFormModel, required int id});

  Future<Either<Exception, bool>> acceptJobCard({required int id});

  Future<Either<Exception, bool>> ignoreJobCard({required int id});

  Future<Either<Exception, bool>> faultReport({
    required FaultFormModel formModel,
    required int id,
  });
//
  Future<Either<Exception, List<JobCard>>> getJobCards({
    required int offset,
    required int limit,
    int maxRetries = 15,
    Duration retryDelay = const Duration(seconds: 0),
  });
  // Future<Either<Exception, List<JobCard>>> getJobCards();
//
  Future<Either<Exception, List<AmcCard>>> getAmcCards();

  Future<Either<Exception, List<FaultFormModel>>> getFaultReport(
      {required int jobCardId, required bool isComplaint});

  Future<Either<Exception, List<AmcBuilding>>> getAmcBuildings(
      {required int amcCardId});

  Future<Either<Exception, String>> getPDF({
    required int jobCardId,
    required String pdfType,
  });

  Future<Either<Exception, bool>> submitAmcCardReport(
      {required List<AmcAcCheckListModel> amcAcCheckListModels,
      required Map<String, int> acTypesValues,
      required Map<String, int> acTypesIndex,
      required int amcCardId,
      required int buildingId,
      required int numDryServices,
      required List<int> flatsNumbers,
      required int numWetServices});

  Future<Either<Exception, List<Product>>> getProducts();

  Future<Either<Exception, List<Spare>>> getSpares();

  Future<Either<Exception, int>> saveFaultData({
    required FaultFormModel formModel,
    required int id,
  });

  Future<Either<Exception, bool>> updateFaultData({
    required FaultFormModel formModel,
    required int id,
  });

  Future<Either<Exception, bool>> deleteFaultData({
    required FaultFormModel formModel,
    required int id,
  });
}
