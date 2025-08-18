import 'package:bayanat/modules/main/data_layer/models/amc_ac_checklsit_model.dart';
import 'package:bayanat/modules/main/data_layer/models/fault_model.dart';
import 'package:bayanat/modules/main/domain_layer/entities/amc_building.dart';
import 'package:bayanat/modules/main/domain_layer/entities/amc_card.dart';
import 'package:bayanat/modules/main/domain_layer/entities/job_card.dart';
import 'package:dartz/dartz.dart';
// import 'package:odoo_rpc/odoo_rpc.dart';
import '../../domain_layer/entities/product.dart';
import '../../domain_layer/entities/spare.dart';
import '../../domain_layer/repsitories/base_main_repository.dart';
import '../data_sources/main_remote_data_sources.dart';
import '../models/amc_model.dart';

class MainRepository extends BaseMainRepository {
  BaseMainRemoteDataSource baseMainRemoteDataSource;

  MainRepository(this.baseMainRemoteDataSource);

  @override
  Future<Either<Exception, bool>> amcFormReport(
      {required AmcFormModel amcFormModel, required int id}) async {
    return baseMainRemoteDataSource.amcFormReport(
        amcFormModel: amcFormModel, id: id);
  }

  @override
  Future<Either<Exception, List<JobCard>>> getJobCards({
    required int limit,
    required int offset,
    int maxRetries = 15,
    Duration retryDelay = const Duration(seconds: 0),
  }) async {
    return baseMainRemoteDataSource.getJobCards(
      limit: limit,
      offset: offset,
    );
  }

  // @override
  // Future<Either<Exception, List<JobCard>>> getJobCards() async {
  //   return baseMainRemoteDataSource.getJobCards();
  // }

  @override
  Future<Either<Exception, List<FaultFormModel>>> getFaultReport(
      {required int jobCardId, required bool isComplaint}) async {
    return baseMainRemoteDataSource.getFaultReport(
        jobCardId: jobCardId, isComplaint: isComplaint);
  }

  @override
  Future<Either<Exception, bool>> acceptJobCard({required int id}) async {
    return baseMainRemoteDataSource.acceptJobCard(id: id);
  }

  @override
  Future<Either<Exception, bool>> ignoreJobCard({required int id}) async {
    return baseMainRemoteDataSource.ignoreJobCard(id: id);
  }

  @override
  Future<Either<Exception, String>> getPDF({
    required int jobCardId,
    required String pdfType,
  }) async {
    return baseMainRemoteDataSource.getPDF(
        jobCardId: jobCardId, pdfType: pdfType);
  }

  @override
  Future<Either<Exception, bool>> faultReport({
    required FaultFormModel formModel,
    required int id,
  }) async {
    return baseMainRemoteDataSource.faultReport(
        formModel: formModel, jobCardId: id);
  }

  @override
  Future<Either<Exception, int>> saveFaultData({
    required FaultFormModel formModel,
    required int id,
  }) async {
    return baseMainRemoteDataSource.saveFaultData(
      formModel: formModel,
      jobCardId: id,
    );
  }

  @override
  Future<Either<Exception, bool>> updateFaultData({
    required FaultFormModel formModel,
    required int id,
  }) async {
    return baseMainRemoteDataSource.updateFaultData(
      formModel: formModel,
      jobCardId: id,
    );
  }

  @override
  Future<Either<Exception, bool>> deleteFaultData({
    required FaultFormModel formModel,
    required int id,
  }) async {
    return baseMainRemoteDataSource.deleteFaultData(
      formModel: formModel,
      jobCardId: id,
    );
  }

  @override
  Future<Either<Exception, List<AmcCard>>> getAmcCards() async {
    return baseMainRemoteDataSource.getAmcCards();
  }

  @override
  Future<Either<Exception, List<AmcBuilding>>> getAmcBuildings(
      {required int amcCardId}) async {
    return baseMainRemoteDataSource.getAmcBuilding(amcCardId: amcCardId);
  }

  @override
  Future<Either<Exception, bool>> submitAmcCardReport(
      {required List<AmcAcCheckListModel> amcAcCheckListModels,
      required Map<String, int> acTypesValues,
      required Map<String, int> acTypesIndex,
      required int amcCardId,
      required List<int> flatsNumbers,
      required int buildingId,
      required int numWetServices,
      required int numDryServices}) async {
    return baseMainRemoteDataSource.submitAmcCardReport(
        amcAcCheckListModels: amcAcCheckListModels,
        acTypesIndex: acTypesIndex,
        buildingId: buildingId,
        numDryServices: numDryServices,
        flatsNumbers: flatsNumbers,
        numWetServices: numWetServices,
        acTypesValues: acTypesValues,
        amcCardId: amcCardId);
  }

  @override
  Future<Either<Exception, List<Product>>> getProducts() async {
    return baseMainRemoteDataSource.getProducts();
  }

  @override
  Future<Either<Exception, List<Spare>>> getSpares() async {
    return baseMainRemoteDataSource.getSpares();
  }
}
