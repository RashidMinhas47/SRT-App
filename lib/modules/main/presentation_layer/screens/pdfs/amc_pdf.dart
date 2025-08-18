import 'dart:io';
import 'package:bayanat/modules/main/data_layer/models/amc_model.dart';
import 'package:bayanat/modules/main/presentation_layer/screens/pdfs/amc_card_pdf.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
// import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../data_layer/models/spare_c_model.dart';
import 'package:pdf/widgets.dart';

class AmcPdf {
  static late Font arFont;
  static init() async {
    arFont = Font.ttf(
        (await rootBundle.load("assets/fonts/IBMPlexSansArabic-Regular.ttf")));
  }

  static Future<String> createPdf({
    required AmcFormModel amcFormModel,
    required String flatNumber,
  }) async {
    String path = (await getApplicationDocumentsDirectory()).path;
    File file = File("$path/Amc.pdf");
    Document pdf = Document();
    pdf.addPage(await _createPage1(
      amcFormModel: amcFormModel,
      flatNumber: flatNumber,
    ));
    pdf.addPage(await _createPage2(
      amcFormModel: amcFormModel,
    ));
    Uint8List bytes = await pdf.save();
    await file.writeAsBytes(bytes);
    // OpenFile.open(file.path);
    return file.path;
  }

  static Future<Page> _createPage1(
      {required AmcFormModel amcFormModel, required String flatNumber}) async {
    final ByteData bytes = await rootBundle.load("assets/images/logo.png");
    final Uint8List byteList = bytes.buffer.asUint8List();
    DateTime dateTime = DateTime.parse(amcFormModel.writeDate!);
    double height = PdfPageFormat.a4.height;
    double width = PdfPageFormat.a4.width;
    return pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.only(top: 0.05 * height,left: 0.05 * height,right: 0.05 * height,bottom: 0.05 * height),
        orientation: pw.PageOrientation.portrait,
        build: (pw.Context context) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Align(
                      alignment: Alignment.center,
                      child: pw.Image(pw.MemoryImage(byteList),
                          fit: pw.BoxFit.fill,
                          height: 0.13 * height,
                          width: 0.18 * width),
                    ),
                    Column(children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                            "AMC REPORT",
                            style: pw.TextStyle(
                                fontSize: 8 / 550 * height,
                                fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 0.01 * height),
                      Text(
                          "Specialized in maintenance and repair of air conditioning, electricity, plumbing, carpentry and painting",
                          style: TextStyle(
                            fontSize: 8 / 800 * height,
                            fontWeight: FontWeight.normal,
                          )),
                      Text(
                          "صيانة وتصليح اجهزة التكييف ، الكهرباء ، السباكة ، نجارة والصبغ",
                          textDirection: pw.TextDirection.rtl,
                          style: TextStyle(
                              fontSize: 9 / 800 * height,
                              fontFallback: [pw.Font.courier()],
                              fontWeight: FontWeight.bold,
                              font: arFont)),
                      SizedBox(height: 0.01 * height),
                    ]),
                  ]),
                  Container(height: 3 / 1000 * height , color: PdfColors.black,width: double.infinity),
                  SizedBox(height: 0.01 * height),

                  Text("AC Complaint Log – In Details",
                      style: TextStyle(
                        fontSize: 7/800*height,
                        fontWeight: FontWeight.bold,
                          font: arFont
                      )),
                  Column(children: [
                    SizedBox(height: 0.002*height),
                    Container(
                      height: 0.0005*height,
                      width: double.infinity,
                      color: PdfColors.blue600,
                    ),
                    SizedBox(height: 0.002*height),
                  ]),
                  Row(children: [
                    Expanded(
                        child:
                            Text("Date: ", style: TextStyle(fontSize: 6/800*height))),
                    Expanded(
                        child: Text(DateFormat.yMd().format(dateTime),
                            style: TextStyle(fontSize: 6/800*height))),
                    Expanded(
                        child:
                            Text("time: ", style: TextStyle(fontSize: 6/800*height))),
                    Expanded(
                        child: Text(DateFormat.Hm().format(dateTime),
                            style: TextStyle(fontSize: 6/800*height))),
                  ]),
                  Column(children: [
                    SizedBox(height: 0.002*height),
                    Container(
                      height: 0.0005*height,
                      width: double.infinity,
                      color: PdfColors.blue600,
                    ),
                    SizedBox(height: 0.002*height),
                  ]),
                  Row(children: [
                    Expanded(
                        child: Text("Property / Site:",
                            style: TextStyle(fontSize: 6/800*height))),
                    Expanded(
                        child: Text(amcFormModel.propertySite,
                            style: TextStyle(fontSize: 6/800*height))),
                  ]),
                  Column(children: [
                    SizedBox(height: 0.002*height),
                    Container(
                      height: 0.0005*height,
                      width: double.infinity,
                      color: PdfColors.blue600,
                    ),
                    SizedBox(height: 0.002*height),
                  ]),
                  Row(children: [
                    Expanded(
                        child: Text("Flat Number:",
                            style: TextStyle(fontSize: 6/800*height))),
                    Expanded(
                        child:
                            Text(flatNumber, style: TextStyle(fontSize: 6/800*height))),
                  ]),
                  Column(children: [
                    SizedBox(height: 0.002*height),
                    Container(
                      height: 0.0005*height,
                      width: double.infinity,
                      color: PdfColors.blue600,
                    ),
                    SizedBox(height: 0.002*height),
                  ]),
                  Row(children: [
                    Expanded(
                        child: Text("Date/Time Completed:",
                            style: TextStyle(fontSize: 6/800*height))),
                    Expanded(
                        child: Text(
                            DateFormat('yyyy-MM-dd HH:mm')
                                .format(DateTime.now())
                                .toString(),
                            style: TextStyle(fontSize: 6/800*height))),
                  ]),
                  Column(children: [
                    SizedBox(height: 0.002*height),
                    Container(
                      height: 0.0005*height,
                      width: double.infinity,
                      color: PdfColors.blue600,
                    ),
                    SizedBox(height: 0.002*height),
                  ]),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                        "AIR CONDITION MAINTENANCE CHECKLIST (BREAKDOWN CALLS)",
                        style: TextStyle(
                          fontSize: 5/800*height,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  SizedBox(height: 0.002*height),
                ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Type of AC: ",
                                style: TextStyle(fontSize: 6/800*height)),
                            SizedBox(height: 0.002*height),
                            Text("Brand:", style: TextStyle(fontSize: 6/800*height)),
                            SizedBox(height: 0.002*height),
                            Text("Tonnage:", style: TextStyle(fontSize: 6/800*height)),
                            SizedBox(height: 0.002*height),
                            Text("Model Number:",
                                style: TextStyle(fontSize: 6/800*height)),
                            SizedBox(height: 0.002*height),
                            Text("AC Serial Number",
                                style: TextStyle(fontSize: 6/800*height)),
                            SizedBox(height: 0.002*height),
                            Text("Compressor Number:",
                                style: TextStyle(fontSize: 6/800*height)),
                            SizedBox(height: 0.002*height),
                            Text("Work Status:",
                                style: TextStyle(fontSize: 6/800*height)),
                            SizedBox(height: 0.002*height),
                            Text("Location:", style: TextStyle(fontSize: 6/800*height)),
                            // SizedBox(height: 1.h),
                            // pw.Table.fromTextArray(
                            //     data: checkListHeader,
                            //     border: pw.TableBorder.all(),
                            //     cellPadding: EdgeInsets.all(3/800*height),
                            //     headerStyle:
                            //     pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 7/800*height),
                            //     headerCount: 1,
                            //     cellStyle: TextStyle(fontSize: 6/800*height),
                            //     tableWidth: TableWidth.min,
                            //     cellHeight: 0.1.h),
                            SizedBox(height: 0.01*height),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(amcFormModel.acType,
                                style: TextStyle(fontSize: 6/800*height)),
                            SizedBox(height: 0.002*height),
                            Text(amcFormModel.brand,
                                style: TextStyle(fontSize: 6/800*height)),
                            SizedBox(height: 0.002*height),
                            Text(amcFormModel.tonnage.toString(),
                                style: TextStyle(fontSize: 6/800*height)),
                            SizedBox(height: 0.002*height),
                            Text(amcFormModel.modelNumber,
                                style: TextStyle(fontSize: 6/800*height)),
                            SizedBox(height: 0.002*height),
                            Text(amcFormModel.acSerialNumber,
                                style: TextStyle(fontSize: 6/800*height)),
                            SizedBox(height: 0.002*height),
                            Text(
                                amcFormModel.compressorNumber == ""
                                    ? "-"
                                    : amcFormModel.compressorNumber,
                                style: TextStyle(fontSize: 6/800*height)),
                            SizedBox(height: 0.002*height),
                            Text(
                                amcFormModel.workStatus == null ||
                                        amcFormModel.workStatus == ""
                                    ? "-"
                                    : amcFormModel.workStatus!,
                                style: TextStyle(fontSize: 6/800*height)),
                            SizedBox(height: 0.002*height),
                            Text(amcFormModel.location,
                                style: TextStyle(fontSize: 6/800*height)),
                            // SizedBox(height: 1.h),
                            // pw.Table.fromTextArray(
                            //     data: tableData(
                            //         list: amcFormModel.list),
                            //     border: pw.TableBorder.all(),
                            //   cellPadding: EdgeInsets.all(3/800*height),
                            //   cellStyle: TextStyle(fontSize: 6/800*height),
                            //   headerStyle: pw.TextStyle(
                            //         fontWeight: pw.FontWeight.bold,fontSize: 7/800*height,),
                            //     headerCount: 1,
                            //     tableWidth: TableWidth.min,
                            //     cellHeight: 1.958.h,
                            // ),
                            SizedBox(height: 0.01*height),
                          ],
                        ),
                      )
                    ]),
                pw.TableHelper.fromTextArray(
                    data: tableData(list: amcFormModel.list),
                    border: pw.TableBorder.all(),
                    cellPadding: EdgeInsets.all(3/650*height),
                    headerStyle: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 7/650*height),
                    headerCount: 1,
                    cellStyle: TextStyle(fontSize: 6/650*height,font: arFont),
                    tableWidth: TableWidth.min,
                    cellHeight: 0.1/10*height),
                SizedBox(height: 0.01*height),
                Row(children: [
                  Text("Comments:", style: TextStyle(fontSize: 7/800*height)),
                  SizedBox(width: 0.004*width),
                  Text(
                      amcFormModel.comments == "" ? "-" : amcFormModel.comments,
                      style: TextStyle(fontSize: 7/800*height)),
                ]),
                Expanded(child: SizedBox(),),
                Column(
                    children: [
                      Container(height: 3 / 1000 * height , color: PdfColors.black,width: double.infinity),
                      SizedBox(height: 0.01 * height),
                      Text(
                          "CR. No: 1226283, VATIN: OM1100040978, P.O: Box:1635, P.C. 119, Al Amera Phase 1, Muscat, Sultanate of Oman",
                          style: TextStyle(
                            fontSize: 8 / 800 * height,
                            fontWeight: FontWeight.normal,
                          )),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                            "Sult.srtoman@gmail.com +968 94115306",
                            style: TextStyle(
                              fontSize: 8 / 800 * height,
                              fontWeight: FontWeight.normal,
                            )
                        ),
                      )
                    ]
                )
              ]);
        });
  }

  static Future<Page> _createPage2({required AmcFormModel amcFormModel}) async {
    final Uint8List signture = stringToByteList(amcFormModel.signature!);
    final Uint8List tenantSignture =
        stringToByteList(amcFormModel.tenantRepresentative);
    double height = PdfPageFormat.a4.height;
    double width = PdfPageFormat.a4.width;
    return pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.only(top: 0.05 * height,left: 0.05 * height,right: 0.05 * height,bottom: 0.05 * height),
        orientation: pw.PageOrientation.portrait,
        build: (pw.Context context) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 0.01*height),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  pw.TableHelper.fromTextArray(
                    data: tableData2(
                        list: amcFormModel.sparesC ?? []),
                    border: pw.TableBorder.all(),
                    cellStyle: TextStyle(fontSize: 5/800*height),
                    headerStyle: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 6/800*height),
                    headerCount: 1,
                    tableWidth: TableWidth.min,
                    cellHeight: 0.1/100*height
                  ),
                  SizedBox(width: 0.05*width),
                  pw.TableHelper.fromTextArray(
                    data: tableData3(
                      width: width,height: height,
                        attending: amcFormModel.attendingTechnician,
                        signture: tenantSignture),
                    cellStyle: TextStyle(fontSize: 6/800*height),
                    border: pw.TableBorder.all(),
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 7/800*height,
                    ),
                    headerCount: 1,
                    tableWidth: TableWidth.min,
                    cellHeight: 0.5/100*height,
                  ),
                  SizedBox(width: 0.05*width),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("User Signture:",
                            style: pw.TextStyle(fontSize: 8/800*height)),
                        SizedBox(height: 0.01*height),
                        Container(
                            decoration: BoxDecoration(
                              border: Border.all(),
                            ),
                            child: Padding(
                                padding: EdgeInsets.all(5/800*height),
                                child: pw.Image(pw.MemoryImage(signture),
                                    fit: pw.BoxFit.fill,
                                    height: 0.1*height,
                                    width: 0.1*width)))
                      ])
                ]),
                Expanded(child: SizedBox(),),
                Column(
                    children: [
                      Container(height: 3 / 1000 * height , color: PdfColors.black,width: double.infinity),
                      SizedBox(height: 0.01 * height),
                      Text(
                          "CR. No: 1226283, VATIN: OM1100040978, P.O: Box:1635, P.C. 119, Al Amera Phase 1, Muscat, Sultanate of Oman",
                          style: TextStyle(
                            fontSize: 8 / 800 * height,
                            fontWeight: FontWeight.normal,
                          )),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                            "Sult.srtoman@gmail.com +968 94115306",
                            style: TextStyle(
                              fontSize: 8 / 800 * height,
                              fontWeight: FontWeight.normal,
                            )
                        ),
                      )
                    ]
                )
              ]);
        });
  }
}

List<List<String>> checkListHeader = [
  [
    'S/no',
    'Checklist',
    'check',
  ], // Header row
  ['1', 'Blower Motor – Measure Amperage & Voltage for proper operation', ''],
  ['2', 'Thermostat – test for proper operation, calibrate and level', ''],
  ['3', 'Clean existing air filter (as needed)', ''],
  ['4', 'Bearing – inspect for weak and lubricate', ''],
  ['5', 'Inspect Indoor Coil', ''],
  ['6', 'Condensate Drain – Flush and treat with anti-algae', ''],
  ['7', 'Inspect Condenser Coil', ''],
  ['8', 'Refrigerant – Monitor Operating pressures', ''],
  ['9', 'Safety Devices – Inspect for proper operation', ''],
  [
    '10',
    'Electrical Disconnect Box – Inspect for proper rating and safe installation',
    ''
  ],
  ['11', 'Electrical Wiring – inspect and tighten connections', ''],
  ['12', 'Test/inspect contactors for burned/pitted contacts', ''],
  ['13', 'Inspect electrical for exposed wiring', ''],
  ['14', 'Inspect and test capacitors', ''],
  ['15', 'Inspect fan Blade', ''],
  ['16', 'Clean Condenser Coil and Remove debris (Indoor)', ''],
  ['17', 'Clean Condenser Coil and Remove debris (Outdoor)', ''],
  ['18', 'Measure supply/return temperature differential', ''],
  ['19', 'Inspect duct work energy loss (if applicable)', ''],
  [
    '20',
    'Compressor – monitor, measure amperage & volt draw and wiring connection',
    ''
  ],
  [
    '21',
    'Check condensate drain and pan and determine if any discrepancies',
    ''
  ],
];
List<List<String>> tableData({required List<int> list}) {
  for (int i = 0; i < list.length; i++) {
    checkListHeader[list[i]][2] = 'true';
  }
  return checkListHeader;
}

List<String> attendingHeader = [
  "Attending Technician",
  "Tenant Representative",
  "BIPL Personal - in - Charge",
];

List<List<dynamic>> tableData3({
  required String attending,
  required Uint8List signture,
  required double height,
  required double width,
}) {
  List<List<dynamic>> tableData = [];
  tableData.add(attendingHeader);
  tableData.add([
    attending,
    Center(
        child: Padding(
            padding: pw.EdgeInsets.all(1/800*height),
            child: pw.Image(pw.MemoryImage(signture),
                fit: pw.BoxFit.fill, height: 0.1*height, width: 0.1*width))),
  ]);
  return tableData;
}

List<List<String>> tableData2(
    {required List<SpareCModel> list}) {
  List<List<String>> tableData2 = [];
  if (list.isNotEmpty) {
    tableData2.add(['Spares and Consumables', 'Qty']);
    for (var element in list) {
        tableData2.add([element.spareName, element.quantity.toString()]);
    }
  }
  return tableData2;
}