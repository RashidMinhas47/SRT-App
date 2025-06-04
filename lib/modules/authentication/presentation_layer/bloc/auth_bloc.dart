import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/dep_injection.dart';
import '../../../../core/utils/constance_manager.dart';
import '../../../../core/utils/navigation_manager.dart';
import '../../../main/presentation_layer/components/components.dart';
import '../../../main/presentation_layer/screens/main_screen.dart';
import '../../data_layer/data_sources/auth_remote_data_sources.dart';
import '../../domain_layer/use_cases/login_with_email_and_pass_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static AuthBloc get(BuildContext context) =>
      BlocProvider.of<AuthBloc>(context);

  bool visibility = true;
  IconData suffix = Icons.visibility_off;
  TextInputType type = TextInputType.visiblePassword;

  void changeVisibility() {
    visibility = !visibility;
    suffix = !visibility ? Icons.visibility : Icons.visibility_off;
    type = !visibility ? TextInputType.text : TextInputType.visiblePassword;
  }

  AuthBloc(AuthInitial authInitial) : super(AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      if (event is ChangeVisibilityEvent) {
        changeVisibility();
        emit(ChangeVisibilityState(isVisible: visibility));
      } else if (event is LoginEvent) {
        emit(const LoginLoadingAuthState());

        final result = await LoginWithEmailAndPassUseCase(sl()).call(
          email: event.userName,
          password: event.password,
        );

        await result.fold((l) {
          errorToast(msg: "Access Denied");
          emit(const LoginErrorAuthState());
        }, (r) async {
          if (r) {
            defaultToast(msg: "Accepted");

            final cookie = ConstanceManager.sessionId;
            final userId = ConstanceManager.userId;

            event.context.pushAndRemove(const JobCardScreen());

            // 🔁 Fetch profile in background
            unawaited(sl<BaseAuthRemoteDataSource>()
                .fetchUserProfile(cookie!, userId!));
          } else {
            errorToast(msg: "Access Denied");
          }

          emit(LoginSuccessfulAuthState(context: event.context));
        });
      }
    });
  }
}

// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../../../core/services/dep_injection.dart';
// import '../../../../core/utils/navigation_manager.dart';
// import '../../../main/presentation_layer/components/components.dart';
// import '../../../main/presentation_layer/screens/main_screen.dart';
// import '../../domain_layer/use_cases/login_with_email_and_pass_usecase.dart';

// part 'auth_event.dart';
// part 'auth_state.dart';

// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   static AuthBloc get(BuildContext context) =>
//       BlocProvider.of<AuthBloc>(context);

//   bool visibility = true;
//   IconData suffix = Icons.visibility_off;
//   TextInputType type = TextInputType.visiblePassword;
//   void changeVisibility() {
//     visibility = !visibility;
//     suffix = !visibility ? Icons.visibility : Icons.visibility_off;
//     type = !visibility ? TextInputType.text : TextInputType.visiblePassword;
//   }

//   AuthBloc(AuthInitial authInitial) : super(AuthInitial()) {
//     on<AuthEvent>((event, emit) async {
//       if (event is ChangeVisibilityEvent) {
//         changeVisibility();
//         emit(ChangeVisibilityState(isVisible: visibility));
//       } else if (event is LoginEvent) {
//         emit(const LoginLoadingAuthState());
//         final result = await LoginWithEmailAndPassUseCase(sl()).call(
//           email: event.userName,
//           password: event.password,
//         );
//         await result.fold((l) {
//           errorToast(msg: "Access Denied");
//           emit(const LoginErrorAuthState());
//         }, (r) async {
//           if (r) {
//             defaultToast(msg: "Accepted");
//             event.context.pushAndRemove(const JobCardScreen());
//           } else {
//             errorToast(msg: "Access Denied");
//           }
//           emit(LoginSuccessfulAuthState(context: event.context));
//         });
//       }
//     });
//   }
// }
