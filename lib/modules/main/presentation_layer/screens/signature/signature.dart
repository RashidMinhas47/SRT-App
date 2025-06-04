import 'package:bayanat/core/utils/color_manager.dart';
import 'package:bayanat/core/utils/navigation_manager.dart';
import 'package:bayanat/modules/main/presentation_layer/screens/signature/preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signature/signature.dart';

class SignatureScreen extends StatefulWidget {
  final String type;
  const SignatureScreen({super.key,required this.type});

  @override
  SignatureScreenState createState() => SignatureScreenState();
}

class SignatureScreenState extends State<SignatureScreen> {
  late SignatureController controller;

  @override
  void initState() {
    super.initState();

    controller = SignatureController(
      penStrokeWidth: 5,
      penColor: ColorManager.white,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Signature(
                controller: controller,
                backgroundColor: ColorManager.black,
              ),
            ),
            buildButtons(context),
          ],
        ),
      );

  Widget buildButtons(BuildContext context) => Container(
        color: ColorManager.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildCheck(context),
            buildClear(),
          ],
        ),
      );

  Widget buildCheck(BuildContext context) => IconButton(
        iconSize: 36,
        icon: Icon(Icons.check, color: ColorManager.secondary),
        onPressed: () async {
          if (controller.isNotEmpty) {
            await exportSignature().then((value) {
              context.push(SignaturePreviewScreen(signature: value,type: widget.type,));
              controller.clear();
            });
          }
        },
      );

  Widget buildClear() => IconButton(
        iconSize: 36,
        icon: Icon(Icons.clear, color: ColorManager.error),
        onPressed: () => controller.clear(),
      );

  Future<Uint8List> exportSignature() async {
    final exportController = SignatureController(
      penStrokeWidth: 2,
      penColor: ColorManager.black,
      exportBackgroundColor: ColorManager.white,
      points: controller.points,
    );

    final signature = await exportController.toPngBytes();
    exportController.dispose();

    return signature!;
  }
}
