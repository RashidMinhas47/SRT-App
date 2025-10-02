import 'dart:convert';
import 'dart:io';
import 'package:bayanat/modules/main/domain_layer/entities/amc_ac_checklist.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
// import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class AmcCardPdf {
  static late Font arFont;
  static init() async {
    arFont = Font.ttf(
        (await rootBundle.load("assets/fonts/IBMPlexSansArabic-Regular.ttf")));
  }

  static Future<String> createPdf({
    required List<AmcAcCheckList> amcAcCheckList,
    required String propertySite,
  }) async {
    String path = (await getApplicationDocumentsDirectory()).path;
    File file = File("$path/Amc_Card.pdf");
    Document pdf = Document();
    pdf.addPage(await _createPage(
        amcAcCheckList: amcAcCheckList, propertySite: propertySite));
    Uint8List bytes = await pdf.save();
    await file.writeAsBytes(bytes);
    // OpenFile.open(file.path);
    return file.path;
  }

  static Future<Page> _createPage({
    required List<AmcAcCheckList> amcAcCheckList,
    required String propertySite,
  }) async {
    final ByteData bytes = await rootBundle.load("assets/images/logo.png");
    final Uint8List byteList = bytes.buffer.asUint8List();
    final Uint8List signture = stringToByteList(amcAcCheckList.last.signature);
    final Uint8List tenantSignture =
        stringToByteList(amcAcCheckList.last.tenantRepresentative);
    DateTime dateTime = DateTime.parse(amcAcCheckList[0].writeDate);
    dateTime = dateTime.add(const Duration(hours: 4));
    double height = PdfPageFormat.a4.height;
    double width = PdfPageFormat.a4.width;
    return pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.only(
            top: 0.05 * height,
            left: 0.05 * height,
            right: 0.05 * height,
            bottom: 0.05 * height),
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
                        child: Text("AMC CALL-OUT",
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
                  Container(
                      height: 3 / 1000 * height,
                      color: PdfColors.black,
                      width: double.infinity),
                  SizedBox(height: 0.01 * height),
                  Text("AC Complaint Log – In Details",
                      style: TextStyle(
                          fontSize: 10 / 1000 * height,
                          fontWeight: FontWeight.bold,
                          font: arFont)),
                  Column(children: [
                    SizedBox(height: 0.002 * height),
                    Container(
                      height: 0.0005 * height,
                      width: double.infinity,
                      color: PdfColors.black,
                    ),
                    SizedBox(height: 0.002 * height),
                  ]),
                  Row(children: [
                    Expanded(
                        child: Text("Date: ",
                            style: TextStyle(fontSize: 8 / 1000 * height))),
                    Expanded(
                        child: Text(DateFormat.yMd().format(dateTime),
                            style: TextStyle(fontSize: 8 / 1000 * height))),
                    Expanded(
                        child: Text("time: ",
                            style: TextStyle(fontSize: 8 / 1000 * height))),
                    Expanded(
                        child: Text(DateFormat.Hm().format(dateTime),
                            style: TextStyle(fontSize: 8 / 1000 * height))),
                  ]),
                  Column(children: [
                    SizedBox(height: 0.002 * height),
                    Container(
                      height: 0.0005 * height,
                      width: double.infinity,
                      color: PdfColors.black,
                    ),
                    SizedBox(height: 0.002 * height),
                  ]),
                  Row(children: [
                    Expanded(
                        child: Text("Property / Site:",
                            style: TextStyle(fontSize: 8 / 1000 * height))),
                    Expanded(
                        child: Text(propertySite,
                            style: TextStyle(fontSize: 8 / 1000 * height))),
                  ]),
                  Column(children: [
                    SizedBox(height: 0.002 * height),
                    Container(
                      height: 0.0005 * height,
                      width: double.infinity,
                      color: PdfColors.black,
                    ),
                    SizedBox(height: 0.002 * height),
                  ]),
                  Row(children: [
                    Expanded(
                        child: Text("Flat Number:",
                            style: TextStyle(fontSize: 8 / 1000 * height))),
                    Expanded(
                        child: Text(amcAcCheckList[0].flatNumber,
                            style: TextStyle(fontSize: 8 / 1000 * height))),
                  ]),
                  Column(children: [
                    SizedBox(height: 0.002 * height),
                    Container(
                      height: 0.0005 * height,
                      width: double.infinity,
                      color: PdfColors.black,
                    ),
                    SizedBox(height: 0.002 * height),
                  ]),
                  Row(children: [
                    Expanded(
                        child: Text("Date/Time Completed:",
                            style: TextStyle(fontSize: 8 / 1000 * height))),
                    Expanded(
                        child: Text(
                            DateFormat('yyyy-MM-dd HH:mm')
                                .format(DateTime.now())
                                .toString(),
                            style: TextStyle(fontSize: 8 / 1000 * height))),
                  ]),
                  Column(children: [
                    SizedBox(height: 0.002 * height),
                    Container(
                      height: 0.0005 * height,
                      width: double.infinity,
                      color: PdfColors.black,
                    ),
                    SizedBox(height: 0.002 * height),
                  ]),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                        "AIR CONDITIONING MAINTENANCE CHECKLIST (QUARTERLY ROUTINE)",
                        style: TextStyle(fontSize: 8 / 1000 * height)),
                  ),
                  SizedBox(height: 0.01 * height),
                ]),
                Row(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Type of AC: ",
                          style: TextStyle(fontSize: 7 / 1000 * height)),
                      SizedBox(height: 0.004 * height),
                      Text("Model Number:",
                          style: TextStyle(fontSize: 7 / 1000 * height)),
                      SizedBox(height: 0.004 * height),
                      Text("AC Serial Number:",
                          style: TextStyle(fontSize: 7 / 1000 * height)),
                      SizedBox(height: 0.004 * height),
                      Text("Location:",
                          style: TextStyle(fontSize: 7 / 1000 * height)),
                      SizedBox(height: 0.01 * height),
                      pw.TableHelper.fromTextArray(
                          data: tableData1,
                          border: pw.TableBorder.all(),
                          cellPadding: EdgeInsets.all(3 / 674 * height),
                          headerStyle: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 6 / 674 * height),
                          headerCount: 1,
                          cellStyle: TextStyle(fontSize: 5 / 674 * height),
                          tableWidth: TableWidth.max,
                          cellHeight: 0.1 / 10 * height),
                    ],
                  ),
                  Expanded(
                      child: ListView.separated(
                          direction: Axis.horizontal,
                          itemBuilder: (context, index) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(amcAcCheckList[index].acType,
                                      style: TextStyle(
                                          fontSize: 7 / 1000 * height)),
                                  SizedBox(height: 0.004 * height),
                                  Text(amcAcCheckList[index].modelNumber,
                                      style: TextStyle(
                                          fontSize: 7 / 1000 * height)),
                                  SizedBox(height: 0.004 * height),
                                  Text(amcAcCheckList[index].acSerialNumber,
                                      style: TextStyle(
                                          fontSize: 7 / 1000 * height)),
                                  SizedBox(height: 0.004 * height),
                                  Text(amcAcCheckList[index].location,
                                      style: TextStyle(
                                          fontSize: 7 / 1000 * height)),
                                  SizedBox(height: 0.01 * height),
                                  pw.TableHelper.fromTextArray(
                                    data: tableData(
                                        list: amcAcCheckList[index].list),
                                    border: pw.TableBorder.all(),
                                    cellStyle:
                                        TextStyle(fontSize: 5 / 1000 * height),
                                    cellPadding:
                                        EdgeInsets.all(3 / 1000 * height),
                                    headerStyle: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 6 / 1000 * height,
                                    ),
                                    headerCount: 1,
                                    tableWidth: TableWidth.min,
                                    cellHeight: 1.76 / 100 * height,
                                  ),
                                ],
                              ),
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 0.01 * width),
                          itemCount: amcAcCheckList.length)),
                ]),
                SizedBox(height: 0.01 * height),
                pw.TableHelper.fromTextArray(
                  data: tableData2(
                      height: height,
                      width: width,
                      attending: amcAcCheckList.last.attendingTechnician,
                      signture: tenantSignture),
                  cellStyle: TextStyle(fontSize: 5 / 1000 * height),
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 6 / 1000 * height,
                  ),
                  headerCount: 1,
                  tableWidth: TableWidth.min,
                  cellHeight: 0.5 / 100 * height,
                ),
                SizedBox(height: 0.01 * height),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Text("Comments:",
                            style: TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.04 * width),
                        Text(
                            amcAcCheckList.last.comments == ""
                                ? "-"
                                : amcAcCheckList.last.comments,
                            style: TextStyle(fontSize: 8 / 1000 * height)),
                      ]),
                      Row(children: [
                        Text("User Signture:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.04 * width),
                        Container(
                            decoration: BoxDecoration(
                              border: Border.all(),
                            ),
                            child: Padding(
                                padding: EdgeInsets.all(5 / 1000 * height),
                                child: pw.Image(pw.MemoryImage(signture),
                                    fit: pw.BoxFit.fill,
                                    height: 0.08 * height,
                                    width: 0.15 * width)))
                      ]),
                    ]),
                SizedBox(height: 0.05 * height),
                Column(children: [
                  Container(
                      height: 3 / 1000 * height,
                      color: PdfColors.black,
                      width: double.infinity),
                  SizedBox(height: 0.01 * height),
                  Text(
                      "CR. No: 1226283, VATIN: OM1100040978, P.O: Box:1635, P.C. 119, Al Amera Phase 1, Muscat, Sultanate of Oman",
                      style: TextStyle(
                        fontSize: 8 / 800 * height,
                        fontWeight: FontWeight.normal,
                      )),
                  Align(
                    alignment: Alignment.center,
                    child: Text("Sult.srtoman@gmail.com +968 94115306",
                        style: TextStyle(
                          fontSize: 8 / 800 * height,
                          fontWeight: FontWeight.normal,
                        )),
                  )
                ])
              ]);
        });
  }
}

List<List<String>> tableData1 = [
  ["S/No ", "AC Serial Number"],
  ["1", "Check and adjust thermostat"],
  ["2", "Check the condenser coil to determine if it needs cleaning"],
  ["3", "Check all the connections of electrical wiring and controls"],
  ["4", "Check blower belt wear, tension & adjust (if applicable)"],
  ["5", "Check voltage & amperage draw on all motors (with meter)"],
  ["6", "Check compressor contactor"],
  ["7", "Visual inspection of compressor and check amp draw"],
  ["8", "Check start capacitor and potential relay"],
  ["9", "Check pressure switch cut-out setting"],
  ["10", "Replace air filter or clean the re-usable type filter"],
  ["11", "Install gauges and check operating pressures"],
  ["12", "Check refrigerant level and advice if adjustment is necessary"],
  ["13", "Check Condensate drain and pan and determine if any discrepancies"],
  ["14", "Check expansion valve and coil temperature"],
  ["15", "Lubricates parts as needed"],
  ["16", "Check evaporator coil and advise if dirty or if it needs cleaning"],
  [
    "17",
    "Check the shape that the total system is in and advise the client /Customer discrepancies"
  ]
];
List<List<dynamic>> tableData({required List<int> list}) {
  List<List<dynamic>> check = [
    ['check'],
    [''],
    [''],
    [''],
    [''],
    [''],
    [''],
    [''],
    [''],
    [''],
    [''],
    [''],
    [''],
    [''],
    [''],
    [''],
    [''],
    [''],
  ];
  for (int i = 0; i < list.length; i++) {
    check[list[i]][0] = 'true';
  }
  return check;
}

List<String> headers = [
  "Attending Technician",
  "Tenant Representative",
  "BIPL Personal - in - Charge",
];
List<List<dynamic>> tableData2({
  required String attending,
  required double height,
  required double width,
  required Uint8List signture,
}) {
  List<List<dynamic>> tableData = [];
  tableData.add(headers);
  tableData.add([
    attending,
    Padding(
        padding: pw.EdgeInsets.all(5 / 1000 * height),
        child: pw.Image(pw.MemoryImage(signture),
            fit: pw.BoxFit.fill, height: 0.08 * height, width: 0.1 * width)),
  ]);
  return tableData;
}

Uint8List stringToByteList(String encodedImage) {
  final decodedBytes = base64Decode(encodedImage);
  return Uint8List.fromList(decodedBytes);
}
