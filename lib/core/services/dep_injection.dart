import 'package:get_it/get_it.dart';
// import 'package:odoo_rpc/odoo_rpc.dart';
import '../../modules/authentication/data_layer/data_sources/auth_remote_data_sources.dart';
import '../../modules/authentication/data_layer/repositories/auth_repository.dart';
import '../../modules/authentication/domain_layer/repsitories/base_auth_repository.dart';
import '../../modules/authentication/presentation_layer/bloc/auth_bloc.dart';
import '../../modules/main/data_layer/data_sources/main_remote_data_sources.dart';
import '../../modules/main/data_layer/repositories/main_repository.dart';
import '../../modules/main/domain_layer/repsitories/base_main_repository.dart';
import '../../modules/main/presentation_layer/bloc/main_bloc.dart';
import '../../modules/petty_cash/data_layer/data_sources/petty_cash_remote_data_source.dart';
import '../../modules/petty_cash/data_layer/repositories/petty_cash_repository.dart';
import '../../modules/petty_cash/domain_layer/repositories/base_petty_cash_repository.dart';
import '../../modules/petty_cash/domain_layer/use_cases/submit_petty_cash_usecase.dart';
import '../../modules/petty_cash/presentation_layer/bloc/petty_cash_bloc.dart';
import '../../modules/petty_cash/presentation_layer/bloc/pending_bills_bloc.dart';

final sl = GetIt.instance;

class ServiceLocator {
  Future<void> init() async {
    /// auth
    BaseAuthRemoteDataSource baseAuthRemoteDataSource = AuthRemoteDataSource();
    sl.registerLazySingleton<BaseAuthRemoteDataSource>(
        () => baseAuthRemoteDataSource); // added line to register the interface
    //sl.registerLazySingleton(() => baseAuthRemoteDataSource);

    BaseAuthRepository baseAuthRepository = AuthRepository(sl());
    sl.registerLazySingleton(() => baseAuthRepository);

    /// main

    BaseMainRemoteDataSource baseMainRemoteDataSource = MainRemoteDataSource();
    sl.registerLazySingleton(() => baseMainRemoteDataSource);

    BaseMainRepository baseMainRepository = MainRepository(sl());
    sl.registerLazySingleton(() => baseMainRepository);

    /// petty cash
    // PettyCashRemoteDataSource pettyRemote = PettyCashRemoteDataSource();
    // sl.registerLazySingleton<BasePettyCashRemoteDataSource>(() => pettyRemote);
    // sl.registerLazySingleton<PettyCashRemoteDataSource>(() => pettyRemote);
    // BasePettyCashRepository pettyRepo = PettyCashRepository(sl());
    // sl.registerLazySingleton<BasePettyCashRepository>(() => pettyRepo);
    // SubmitPettyCashUseCase pettyUseCase = SubmitPettyCashUseCase(sl());
    // sl.registerLazySingleton(() => pettyUseCase);

    /// blocs
    AuthBloc authBloc = AuthBloc(AuthInitial());
    sl.registerLazySingleton(() => authBloc);

    MainBloc mainBloc = MainBloc(MainInitial());
    sl.registerLazySingleton(() => mainBloc);

    // PettyCashBloc pettyBloc = PettyCashBloc(submitUseCase: sl());
    // sl.registerLazySingleton(() => pettyBloc);

    // PendingBillsBloc pendingBillsBloc =
    //     PendingBillsBloc(remoteDataSource: sl());
    // sl.registerLazySingleton(() => pendingBillsBloc);

    /// odoo
    // ConstanceManager.sessionId = await CacheHelper.getData(key: "sessionId");
    // ConstanceManager.userId = await CacheHelper.getData(key: "userId");
    // ConstanceManager.partnerId = await CacheHelper.getData(key: "partnerId");
    // ConstanceManager.companyId = await CacheHelper.getData(key: "companyId");
    // ConstanceManager.userLogin = await CacheHelper.getData(key: "userLogin");
    // ConstanceManager.userName = await CacheHelper.getData(key: "userName");
    // ConstanceManager.userLang = await CacheHelper.getData(key: "userLang");
    // ConstanceManager.userTz = await CacheHelper.getData(key: "userTz");
    // ConstanceManager.isSystem = await CacheHelper.getData(key: "isSystem");
    // ConstanceManager.serverVersion = await CacheHelper.getData(key: "serverVersion");
    // if(ConstanceManager.sessionId != null) {
    //   OdooSession odooSession = OdooSession(
    //     id: ConstanceManager.sessionId!,
    //     userId: ConstanceManager.userId!,
    //     partnerId: ConstanceManager.partnerId!,
    //     companyId: ConstanceManager.companyId!,
    //     userLogin: ConstanceManager.userLogin!,
    //     userName: ConstanceManager.userName!,
    //     userLang: ConstanceManager.userLang!,
    //     userTz: ConstanceManager.userTz!,
    //     isSystem: ConstanceManager.isSystem!,
    //     dbName: ApiConsts.db,
    //     serverVersion: ConstanceManager.serverVersion!);
    //   OdooClient client = OdooClient(
    //       ApiConsts.baseUrl, odooSession);
    //   sl.registerLazySingleton(() => client);
    // }else {
    //   OdooClient client = OdooClient(
    //       ApiConsts.baseUrl,);
    //   sl.registerLazySingleton(() => client);
    // }
  }
}
