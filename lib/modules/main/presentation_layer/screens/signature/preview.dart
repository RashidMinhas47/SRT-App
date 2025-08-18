import 'dart:io';
import 'dart:typed_data';
import 'package:bayanat/core/utils/navigation_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../../core/services/dep_injection.dart';
import '../../bloc/main_bloc.dart';

class SignaturePreviewScreen extends StatelessWidget {
  final Uint8List signature;
  final String type;

  const SignaturePreviewScreen({
    super.key,
    required this.signature,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    MainBloc bloc = sl();
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            leading: const CloseButton(),
            centerTitle: true,
            actions: [
              IconButton(
                  icon: const Icon(Icons.done),
                  onPressed: () async {
                    // await storeSignature().then((value) {
                    final time =
                        DateTime.now().toIso8601String().replaceAll('.', ':');
                    final name = 'signature_$time.png';
                    await uint8ListToFile(
                        fileName: name, uint8list: signature).then((value) {
                      bloc.add(AddSigntureEvent(signturePhoto: value,type: type));
                      context.pop();
                      context.pop();
                      context.pop();
                    });
                    //});
                  }),
              SizedBox(width: 8.sp),
            ],
          ),
          body: Center(
            child: Image.memory(signature, width: double.infinity),
          ),
        );
      },
    );
  }

  // Future<String> storeSignature() async {
  //   final status = await Permission.storage.status;
  //   if (!status.isGranted) {
  //     await Permission.storage.request();
  //   }
  //   final time = DateTime.now().toIso8601String().replaceAll('.', ':');
  //   final name = 'signature_$time.png';
  //   final result = await ImageGallerySaver.saveImage(signature, name: name);
  //   final isSuccess = await result['isSuccess'];
  //   if (isSuccess) {
  //     defaultToast(msg: 'Saved to signature folder');
  //   } else {
  //     errorToast(msg: "Failed to save signature");
  //   }
  //   return name;
  // }

// Future<File> uint8ListToFile(
//       {required Uint8List uint8list, required String fileName}) async {
//     final permDir = await getApplicationDocumentsDirectory();
//     final file = File('${permDir.path}/$fileName');
//     await file.writeAsBytes(uint8list);
//     return file;
//   }

  Future<File> uint8ListToFile(
      {required Uint8List uint8list, required String fileName}) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(uint8list);
    return file;
  }
}
