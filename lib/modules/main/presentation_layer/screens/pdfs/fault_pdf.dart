import 'dart:convert';
import 'dart:io';
import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:bayanat/modules/main/domain_layer/entities/job_card.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

// import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../data_layer/models/fault_model.dart';

class FaultPdf {
  static late Font arFontRegular;

  static init() async {
    arFontRegular = Font.ttf(
        (await rootBundle.load("assets/fonts/IBMPlexSansArabic-Regular.ttf")));
  }

  static int _heightOfPdf = 0;
  static int _serviceTypeIndex = 1;

  static Future<String> pdf({
    required List<FaultFormModel> faultFormModels,
    required JobCard jobCardModel,
  }) async {
    String path = (await getApplicationDocumentsDirectory()).path;
    File file = File("$path/Fault.pdf");
    Document pdf = Document();
    pdf.addPage(await _createPage1(
      jobCardModel: jobCardModel,
      faultFormModels: faultFormModels,
    ));
    int i = 0;
    _heightOfPdf = 0;
    _serviceTypeIndex = 0;
    for (var element in faultFormModels) {
      i++;
      if (element.serviceTypes != null) {
        _heightOfPdf += element.serviceTypes!.length;
        if (_heightOfPdf >= 10) {
          _serviceTypeIndex = i - 1;
          break;
        }
      }
    }
    if (_heightOfPdf >= 10) {
      pdf.addPage(await _createPage2(
        faultFormModels: faultFormModels,
      ));
    }
    // Always add signature page after report tables
    pdf.addPage(await _createSignaturePage(
      faultFormModels: faultFormModels,
    ));
    // Check if there are any photos to add
    bool hasPhotos = false;
    for (var faultFormModel in faultFormModels) {
      if ((faultFormModel.beforePhotos != null &&
              faultFormModel.beforePhotos!.isNotEmpty) ||
          (faultFormModel.afterPhotos != null &&
              faultFormModel.afterPhotos!.isNotEmpty)) {
        hasPhotos = true;
        break;
      }
    }
    // Add photo pages after signature (only if photos exist)
    if (hasPhotos) {
      for (var faultFormModel in faultFormModels) {
        if ((faultFormModel.beforePhotos != null &&
                faultFormModel.beforePhotos!.isNotEmpty) ||
            (faultFormModel.afterPhotos != null &&
                faultFormModel.afterPhotos!.isNotEmpty)) {
          pdf.addPage(await _createPagePhoto(
            faultFormModel: faultFormModel,
          ));
        }
      }
    }
    Uint8List bytes = await pdf.save();
    await file.writeAsBytes(bytes);
    // OpenFile.open(file.path);
    return file.path;
  }

  static Future<Page> _createPage1({
    required List<FaultFormModel> faultFormModels,
    required JobCard jobCardModel,
  }) async {
    final ByteData bytes = await rootBundle.load("assets/images/logo.png");
    final Uint8List byteList = bytes.buffer.asUint8List();
    DateTime dateTime = DateTime.parse(jobCardModel.writeDate);
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              "MAINTENANCE RE PORT - ${faultFormModels.last.reportType == "FAULT REPORT" ? "FAULT" : "COMPLETED"}",
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
                                font: arFontRegular)),
                        SizedBox(height: 0.01 * height),
                      ]),
                    ]),
                    Container(
                        height: 3 / 1000 * height,
                        color: PdfColors.black,
                        width: double.infinity),
                    SizedBox(height: 0.01 * height),
                    Row(children: [
                      Text("Job Card:",
                          style: pw.TextStyle(
                              color: PdfColors.red,
                              fontSize: 7 / 750 * height)),
                      SizedBox(width: 0.02 * width),
                      Expanded(
                          child: Text(jobCardModel.jobCardNumber,
                              style: pw.TextStyle(
                                  color: PdfColors.redAccent700,
                                  fontSize: 7 / 650 * height))),
                    ]),
                    SizedBox(height: 0.01 * height),
                    Container(
                      padding: EdgeInsets.all(2 / 1000 * height),
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: PdfColors.black, width: 0.001 * width)),
                      child: Row(children: [
                        Text("Customer Name:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.02 * width),
                        Expanded(
                            child: Text(jobCardModel.customerName[1],
                                style: pw.TextStyle(
                                    fontSize: 8 / 1000 * height,
                                    font: arFontRegular))),
                        Text("Complaint Name:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.02 * width),
                        Expanded(
                            child: Text(jobCardModel.complaintNumber,
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height))),
                        Text("Date: ",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.02 * width),
                        Expanded(
                            child: Text(DateFormat.yMd().format(dateTime),
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height))),
                      ]),
                    ),
                    Container(
                      padding: EdgeInsets.all(2 / 1000 * height),
                      decoration: pw.BoxDecoration(
                          border: pw.Border.symmetric(
                        vertical: pw.BorderSide(
                            color: PdfColors.black, width: 0.001 * width),
                      )),
                      child: Row(children: [
                        Text("Area:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.02 * width),
                        Expanded(
                            child: Text(jobCardModel.location,
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height))),
                        Text("W. No:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.02 * width),
                        Expanded(
                            child: Text(jobCardModel.buildingNumber,
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height))),
                        Text("H. No:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.02 * width),
                        Expanded(
                            child: Text(jobCardModel.flatNumber,
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height))),
                      ]),
                    ),
                    Container(
                      padding: EdgeInsets.all(2 / 1000 * height),
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: PdfColors.black, width: 0.001 * width)),
                      child: Row(children: [
                        Text("Phone:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.02 * width),
                        Expanded(
                            child: Text(jobCardModel.phoneNumber,
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height))),
                        Text("Work Status:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.02 * width),
                        Expanded(
                            child: Text(
                                faultFormModels.last.reportType ==
                                        "COMPLETION REPORT"
                                    ? "COMPLETION REPORT"
                                    : "FAULT REPORT",
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height))),
                      ]),
                    ),
                    Container(
                      padding: EdgeInsets.all(2 / 1000 * height),
                      decoration: pw.BoxDecoration(
                          border: pw.Border.symmetric(
                        vertical: pw.BorderSide(
                            color: PdfColors.black, width: 0.001 * width),
                      )),
                      child: Row(children: [
                        Text("User Name:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.02 * width),
                        Expanded(
                            child: Text(ConstanceManager.name ?? "",
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height))),
                        Text("Technician 1:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.02 * width),
                        Expanded(
                            child: Text(faultFormModels.last.technician1,
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height))),
                        Text("Technician 2:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.02 * width),
                        Expanded(
                            child: Text(faultFormModels.last.technician2,
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height))),
                      ]),
                    ),
                    Container(
                      padding: EdgeInsets.all(2 / 1000 * height),
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: PdfColors.black, width: 0.001 * width)),
                      child: Row(children: [
                        Text("HRS:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.02 * width),
                        Expanded(child: Text("")),
                        Text("TIME IN:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.02 * width),
                        Expanded(
                            child: Text(DateFormat.Hm().format(dateTime),
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height))),
                        Text("TIME OUT:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.02 * width),
                        Expanded(
                            child: Text(DateFormat.Hm().format(DateTime.now()),
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height))),
                      ]),
                    ),
                    Container(
                      padding: EdgeInsets.all(2 / 1000 * height),
                      decoration: pw.BoxDecoration(
                          border: pw.Border.symmetric(
                        vertical: pw.BorderSide(
                            color: PdfColors.black, width: 0.001 * width),
                      )),
                      child: Row(children: [
                        Text("Vehicle No:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.02 * width),
                        Expanded(child: Text("")),
                        Text("KMS:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.02 * width),
                        Expanded(child: Text("")),
                      ]),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(2 / 1000 * height),
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: PdfColors.black, width: 0.001 * width)),
                      child: Center(
                          child: Text("Type of Service",
                              style:
                                  pw.TextStyle(fontSize: 8 / 1000 * height))),
                    ),
                    Container(
                      padding: EdgeInsets.all(2 / 1000 * height),
                      decoration: pw.BoxDecoration(
                          border: pw.Border.symmetric(
                        vertical: pw.BorderSide(
                            color: PdfColors.black, width: 0.001 * width),
                      )),
                      child: Row(children: [
                        Text("M/S:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.04 * width),
                        Container(
                            height: 10 / 1000 * height,
                            width: 10 / 1000 * height,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.black,
                                    width: 0.001 * width),
                                shape: BoxShape.rectangle)),
                        Expanded(child: SizedBox(width: 0.02 * width)),
                        //////
                        Text("R/S:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.04 * width),
                        Container(
                            height: 10 / 1000 * height,
                            width: 10 / 1000 * height,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.black,
                                    width: 0.001 * width),
                                shape: BoxShape.rectangle)),
                        Expanded(child: SizedBox(width: 0.02 * width)),
                        /////
                        Text("F/U:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.04 * width),
                        Container(
                            height: 10 / 1000 * height,
                            width: 10 / 1000 * height,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.black,
                                    width: 0.001 * width),
                                shape: BoxShape.rectangle)),
                        Expanded(child: SizedBox(width: 0.02 * width)),
                      ]),
                    ),
                    Container(
                      padding: EdgeInsets.all(2 / 1000 * height),
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: PdfColors.black, width: 0.001 * width)),
                      child: Row(children: [
                        Text("C/O:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.04 * width),
                        Container(
                            height: 10 / 1000 * height,
                            width: 10 / 1000 * height,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.black,
                                    width: 0.001 * width),
                                shape: BoxShape.rectangle)),
                        Expanded(child: SizedBox(width: 0.02 * width)),
                        //////
                        Text("INSP:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.04 * width),
                        Container(
                            height: 10 / 1000 * height,
                            width: 10 / 1000 * height,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.black,
                                    width: 0.001 * width),
                                shape: BoxShape.rectangle)),
                        Expanded(child: SizedBox(width: 0.02 * width)),
                        //////
                        Text("R/C:",
                            style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                        SizedBox(width: 0.04 * width),
                        Container(
                            height: 10 / 1000 * height,
                            width: 10 / 1000 * height,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.black,
                                    width: 0.001 * width),
                                shape: BoxShape.rectangle)),
                        Expanded(child: SizedBox(width: 0.02 * width)),
                      ]),
                    ),
                    Container(
                      padding: EdgeInsets.all(2 / 1000 * height),
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: PdfColors.black, width: 0.001 * width)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Chargeable:",
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height)),
                            SizedBox(width: 0.02 * width),
                            Text("Y",
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height)),
                            SizedBox(width: 0.02 * width),
                            Container(
                                height: 10 / 1000 * height,
                                width: 10 / 1000 * height,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                        color: PdfColors.black,
                                        width: 0.001 * width),
                                    shape: BoxShape.rectangle)),
                            Expanded(child: SizedBox(width: 0.02 * width)),
                            Text("N",
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height)),
                            SizedBox(width: 0.02 * width),
                            Container(
                                height: 10 / 1000 * height,
                                width: 10 / 1000 * height,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                        color: PdfColors.black,
                                        width: 0.001 * width),
                                    shape: BoxShape.rectangle)),
                            Expanded(child: SizedBox(width: 0.02 * width)),
                          ]),
                    ),
                    SizedBox(height: 0.005 * height),
                  ],
                ),
                Text(
                    "M/S = Major Service, R/S = Routine Service, F/U = Follow up, C/O = Call Out, INSP = Inspection, R/C = Repeat Call",
                    style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                SizedBox(height: 0.005 * height),
                pw.TableHelper.fromTextArray(
                  data: tableData(
                      list: faultFormModels,
                      flag: true,
                      width: width,
                      height: height),
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8 / 1000 * height),
                  headerCount: 1,
                  cellStyle: TextStyle(
                    fontSize: 7 / 1000 * height,
                  ),
                  tableWidth: TableWidth.max,
                ),
                // Only show signature on first page if there's enough space (less than 10 entries)
                // Otherwise, signature will be shown on the dedicated signature page
                _heightOfPdf < 10
                    ? Column(children: [
                        SizedBox(height: 0.01 * height),
                        Text(
                            "*Comments as follows : C =Completed, I/P = In Progress, F/U = To be followed up, U/O = Under Observation, A/P = Awaiting Approval",
                            style: pw.TextStyle(fontSize: 7 / 1000 * height)),
                        SizedBox(height: 0.01 * height),
                        Container(
                          padding: EdgeInsets.all(2 / 1000 * height),
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                  color: PdfColors.black,
                                  width: 0.001 * width)),
                          child: Row(children: [
                            Text("Total Units:",
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height)),
                            SizedBox(width: 0.02 * width),
                            Expanded(
                                child: Text(faultFormModels.length.toString(),
                                    style: pw.TextStyle(
                                        fontSize: 8 / 1000 * height))),
                            Text("Attd. Units:",
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height)),
                            SizedBox(width: 0.02 * width),
                            Expanded(child: Text("")),
                            Text("Comp. Units:",
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height)),
                            SizedBox(width: 0.02 * width),
                            Expanded(child: Text("")),
                          ]),
                        ),
                        Container(
                          padding: EdgeInsets.all(2 / 1000 * height),
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                  color: PdfColors.black,
                                  width: 0.001 * width)),
                          child: Row(children: [
                            Text("Pend. Units:",
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height)),
                            SizedBox(width: 0.02 * width),
                            Expanded(child: Text("")),
                            Text("MWS Involved:",
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height)),
                            SizedBox(width: 0.02 * width),
                            Expanded(child: Text("")),
                            Text("JC No :",
                                style:
                                    pw.TextStyle(fontSize: 8 / 1000 * height)),
                            SizedBox(width: 0.02 * width),
                            Expanded(child: Text("")),
                          ]),
                        ),
                        SizedBox(height: 0.01 * height),
                        Row(children: [
                          Text("Comments:",
                              style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                          SizedBox(width: 0.04 * width),
                          pw.Expanded(
                              child: Text(faultFormModels.last.comment!,
                                  style: pw.TextStyle(
                                      fontSize: 8 / 1000 * height))),
                        ]),
                        SizedBox(height: 0.01 * height),
                      ])
                    : Container(),
                Expanded(
                  child: SizedBox(),
                ),
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

  static Future<Page> _createPage2({
    required List<FaultFormModel> faultFormModels,
  }) async {
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
                _heightOfPdf >= 10
                    ? pw.TableHelper.fromTextArray(
                        data: tableData(
                            list: faultFormModels,
                            flag: false,
                            width: width,
                            height: height),
                        border: pw.TableBorder.all(),
                        headerCount: 1,
                        // cellPadding: EdgeInsets.zero,
                        headerStyle: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8 / 1000 * height),
                        cellStyle: TextStyle(
                          fontSize: 7 / 1000 * height,
                        ),
                        tableWidth: TableWidth.max,
                      )
                    : Container(),
                SizedBox(height: 0.01 * height),
                Text(
                    "*Comments as follows : C =Completed, I/P = In Progress, F/U = To be followed up, U/O = Under Observation, A/P = Awaiting Approval",
                    style: pw.TextStyle(fontSize: 7 / 1000 * height)),
                SizedBox(height: 0.01 * height),
                Container(
                  padding: EdgeInsets.all(2 / 1000 * height),
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                          color: PdfColors.black, width: 0.001 * width)),
                  child: Row(children: [
                    Text("Total Units:",
                        style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                    SizedBox(width: 0.02 * width),
                    Expanded(
                        child: Text(faultFormModels.length.toString(),
                            style: pw.TextStyle(fontSize: 8 / 1000 * height))),
                    Text("Attd. Units:",
                        style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                    SizedBox(width: 0.02 * width),
                    Expanded(child: Text("")),
                    Text("Comp. Units:",
                        style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                    SizedBox(width: 0.02 * width),
                    Expanded(child: Text("")),
                  ]),
                ),
                Container(
                  padding: EdgeInsets.all(2 / 1000 * height),
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                          color: PdfColors.black, width: 0.001 * width)),
                  child: Row(children: [
                    Text("Pend. Units:",
                        style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                    SizedBox(width: 0.02 * width),
                    Expanded(child: Text("")),
                    Text("MWS Involved:",
                        style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                    SizedBox(width: 0.02 * width),
                    Expanded(child: Text("")),
                    Text("JC No :",
                        style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                    SizedBox(width: 0.02 * width),
                    Expanded(child: Text("")),
                  ]),
                ),
                SizedBox(height: 0.01 * height),
                Row(children: [
                  Text("Comments:",
                      style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                  SizedBox(width: 0.04 * width),
                  pw.Expanded(
                      child: Text(faultFormModels.last.comment!,
                          style: pw.TextStyle(fontSize: 8 / 1000 * height)))
                ]),
                Expanded(
                  child: SizedBox(),
                ),
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

  static Future<Page> _createSignaturePage({
    required List<FaultFormModel> faultFormModels,
  }) async {
    final Uint8List signture =
        stringToByteList(faultFormModels.last.signaturePhoto);
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
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                SizedBox(height: 0.02 * height),
                Text(
                    "*Comments as follows : C =Completed, I/P = In Progress, F/U = To be followed up, U/O = Under Observation, A/P = Awaiting Approval",
                    style: pw.TextStyle(fontSize: 7 / 1000 * height)),
                SizedBox(height: 0.02 * height),
                Container(
                  padding: EdgeInsets.all(2 / 1000 * height),
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                          color: PdfColors.black, width: 0.001 * width)),
                  child: Row(children: [
                    Text("Total Units:",
                        style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                    SizedBox(width: 0.02 * width),
                    Expanded(
                        child: Text(faultFormModels.length.toString(),
                            style: pw.TextStyle(fontSize: 8 / 1000 * height))),
                    Text("Attd. Units:",
                        style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                    SizedBox(width: 0.02 * width),
                    Expanded(child: Text("")),
                    Text("Comp. Units:",
                        style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                    SizedBox(width: 0.02 * width),
                    Expanded(child: Text("")),
                  ]),
                ),
                Container(
                  padding: EdgeInsets.all(2 / 1000 * height),
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                          color: PdfColors.black, width: 0.001 * width)),
                  child: Row(children: [
                    Text("Pend. Units:",
                        style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                    SizedBox(width: 0.02 * width),
                    Expanded(child: Text("")),
                    Text("MWS Involved:",
                        style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                    SizedBox(width: 0.02 * width),
                    Expanded(child: Text("")),
                    Text("JC No :",
                        style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                    SizedBox(width: 0.02 * width),
                    Expanded(child: Text("")),
                  ]),
                ),
                SizedBox(height: 0.02 * height),
                Row(children: [
                  Text("Comments:",
                      style: pw.TextStyle(fontSize: 8 / 1000 * height)),
                  SizedBox(width: 0.04 * width),
                  pw.Expanded(
                      child: Text(faultFormModels.last.comment!,
                          style: pw.TextStyle(fontSize: 8 / 1000 * height))),
                ]),
                SizedBox(height: 0.02 * height),
                if (signture.isNotEmpty)
                  Row(children: [
                    Text("Customer Signture:",
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
                                height: 0.12 * height,
                                width: 0.15 * width)))
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

  static Future<Page> _createPagePhoto({
    required FaultFormModel faultFormModel,
  }) async {
    List<List<Uint8List>> beforePhotos = [];
    List<List<Uint8List>> afterPhotos = [];
    double height = PdfPageFormat.a4.height;
    double width = PdfPageFormat.a4.width;
    if (faultFormModel.beforePhotosMemory != null &&
        faultFormModel.beforePhotosMemory!.isNotEmpty) {
      beforePhotos
          .add(stringsListToByteList(faultFormModel.beforePhotosMemory!));
    }
    if (faultFormModel.afterPhotosMemory != null &&
        faultFormModel.afterPhotosMemory!.isNotEmpty) {
      afterPhotos.add(stringsListToByteList(faultFormModel.afterPhotosMemory!));
    }
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
                ListView.separated(
                    itemBuilder: (context, index) => Column(children: [
                          beforePhotos.isNotEmpty
                              ? Column(children: [
                                  Text(
                                      "Before Photos Complaint no ${index + 1}",
                                      style: TextStyle(
                                          fontSize: 9 / 1000 * height)),
                                  SizedBox(height: 0.005 * height),
                                  Wrap(
                                    children: beforePhotos[index]
                                        .map((image) {
                                          return Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(),
                                              ),
                                              child: Padding(
                                                  padding: EdgeInsets.all(
                                                      5 / 1000 * height),
                                                  child: pw.Image(
                                                      pw.MemoryImage(image),
                                                      fit: pw.BoxFit.fill,
                                                      height: 0.16 * height,
                                                      width: 0.147 * width)));
                                        })
                                        .toList()
                                        .take(5)
                                        .toList(),
                                  ),
                                  SizedBox(height: 0.005 * height),
                                  beforePhotos[index].length > 5
                                      ? Wrap(
                                          children: beforePhotos[index]
                                              .skip(5)
                                              .map((image) {
                                            return Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(),
                                                ),
                                                child: Padding(
                                                    padding: EdgeInsets.all(
                                                        5 / 1000 * height),
                                                    child: pw.Image(
                                                        pw.MemoryImage(image),
                                                        fit: pw.BoxFit.fill,
                                                        height: 0.16 * height,
                                                        width: 0.147 * width)));
                                          }).toList(),
                                        )
                                      : Container(),
                                ])
                              : Container(),
                          SizedBox(height: 0.005 * height),
                          afterPhotos.isNotEmpty
                              ? Column(children: [
                                  Text("After Photos Complaint no ${index + 1}",
                                      style: TextStyle(
                                          fontSize: 9 / 1000 * height)),
                                  SizedBox(height: 0.005 * height),
                                  Wrap(
                                    children: afterPhotos[index]
                                        .map((image) {
                                          return Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(),
                                              ),
                                              child: Padding(
                                                  padding: EdgeInsets.all(
                                                      5 / 1000 * height),
                                                  child: pw.Image(
                                                      pw.MemoryImage(image),
                                                      fit: pw.BoxFit.fill,
                                                      height: 0.16 * height,
                                                      width: 0.147 * width)));
                                        })
                                        .toList()
                                        .take(5)
                                        .toList(),
                                  ),
                                  SizedBox(height: 0.005 * height),
                                  afterPhotos[index].length > 5
                                      ? Wrap(
                                          children: afterPhotos[index]
                                              .skip(5)
                                              .map((image) {
                                            return Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(),
                                                ),
                                                child: Padding(
                                                    padding: EdgeInsets.all(
                                                        5 / 1000 * height),
                                                    child: pw.Image(
                                                        pw.MemoryImage(image),
                                                        fit: pw.BoxFit.fill,
                                                        height: 0.16 * height,
                                                        width: 0.147 * width)));
                                          }).toList(),
                                        )
                                      : Container(),
                                ])
                              : Container(),
                        ]),
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 0.001 * height),
                    itemCount: beforePhotos.length),
                Expanded(
                  child: SizedBox(),
                ),
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

List<String> headers = [
  "TYPE",
  "MAKE",
  "MODEL",
  "SR. NO",
  "LOCATION",
  "TYPE SERVICE",
  "QTY",
  "DESCRIPTION"
];

Uint8List stringToByteList(String encodedImage) {
  final decodedBytes = base64Decode(encodedImage);
  return Uint8List.fromList(decodedBytes);
}

List<Uint8List> stringsListToByteList(List<String> encodedImages) {
  List<Uint8List> photos = [];
  for (String encodedImage in encodedImages) {
    photos.add(stringToByteList(encodedImage));
  }
  return photos;
}

List<List<dynamic>> tableData(
    {required List<FaultFormModel> list,
    required bool flag,
    required double width,
    required double height}) {
  List<List<dynamic>> tableData = [];
  tableData.add(headers);
  int i = 0;
  for (var element in list) {
    if ((i >= FaultPdf._serviceTypeIndex && !flag) ||
        (i < FaultPdf._serviceTypeIndex && flag) ||
        (FaultPdf._heightOfPdf < 10 && flag)) {
      if (element.serviceTypes != null && element.serviceTypes!.length == 1) {
        tableData.add([
          Container(
            width: 0.08 * width,
            child: Text(element.subCategory,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 7 / 1000 * height,
                )),
          ),
          Container(
            width: 0.08 * width,
            child: Text(element.make,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 7 / 1000 * height,
                )),
          ),
          Container(
            width: 0.08 * width,
            child: Text(element.model,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 7 / 1000 * height,
                )),
          ),
          Container(
            width: 0.08 * width,
            child: Text(element.serialNumber,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 7 / 1000 * height,
                )),
          ),
          Container(
            width: 0.08 * width,
            child: Text(element.location,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 7 / 1000 * height,
                )),
          ),
          Container(
              width: 0.25 * width,
              child: Text(element.serviceTypes![0].serviceTypeName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    font: FaultPdf.arFontRegular,
                    fontSize: 7 / 1000 * height,
                  ))),
          Container(
              width: 0.08 * width,
              child: Text("${element.serviceTypes![0].quantity}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    font: FaultPdf.arFontRegular,
                    fontSize: 7 / 1000 * height,
                  ))),
          Container(
            width: 0.1 * width,
            child: Text(element.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 7 / 1000 * height,
                )),
          ),
        ]);
      } else if (element.serviceTypes != null &&
          element.serviceTypes!.isNotEmpty) {
        tableData.add([
          Container(
            width: 0.08 * width,
            child: Text(element.subCategory,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 7 / 1000 * height,
                )),
          ),
          Container(
            width: 0.08 * width,
            child: Text(element.make,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 7 / 1000 * height,
                )),
          ),
          Container(
            width: 0.08 * width,
            child: Text(element.model,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 7 / 1000 * height,
                )),
          ),
          Container(
            width: 0.08 * width,
            child: Text(element.serialNumber,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 7 / 1000 * height,
                )),
          ),
          Container(
            width: 0.08 * width,
            child: Text(element.location,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 7 / 1000 * height,
                )),
          ),
          Container(
              width: 0.25 * width,
              child: Text(element.serviceTypes![0].serviceTypeName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    font: FaultPdf.arFontRegular,
                    fontSize: 7 / 1000 * height,
                  ))),
          Container(
              width: 0.08 * width,
              child: Text("${element.serviceTypes![0].quantity}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    font: FaultPdf.arFontRegular,
                    fontSize: 7 / 1000 * height,
                  ))),
          Container(
            width: 0.1 * width,
            child: Text(element.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 7 / 1000 * height,
                )),
          ),
        ]);
        for (int index = 1; index < element.serviceTypes!.length; index++) {
          tableData.add([
            "",
            "",
            "",
            "",
            "",
            Container(
                width: 0.25 * width,
                child: Text(element.serviceTypes![index].serviceTypeName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      font: FaultPdf.arFontRegular,
                      fontSize: 7 / 1000 * height,
                    ))),
            Container(
                width: 0.08 * width,
                child: Text("${element.serviceTypes![index].quantity}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      font: FaultPdf.arFontRegular,
                      fontSize: 7 / 1000 * height,
                    ))),
            ""
          ]);
        }
      }
    }
    i++;
  }
  return tableData;
}
