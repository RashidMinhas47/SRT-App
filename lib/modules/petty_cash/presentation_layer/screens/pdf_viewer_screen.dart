import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:open_file_safe_plus/open_file_safe_plus.dart';

import '../../../../core/utils/color_manager.dart';
import '../../data_layer/data_sources/petty_cash_remote_data_source.dart';

class PDFViewerScreen extends StatefulWidget {
  final String requestId;
  final String requestTitle;

  const PDFViewerScreen({
    super.key,
    required this.requestId,
    required this.requestTitle,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  bool _isLoading = true;
  bool _isDownloading = false;
  String? _pdfPath;
  String? _errorMessage;
  final PettyCashRemoteDataSource _dataSource = PettyCashRemoteDataSource();

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  Future<void> _loadPDF() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await _dataSource.downloadPettyCashPDF(widget.requestId);
      result.fold(
        (exception) {
          setState(() {
            _isLoading = false;
            _errorMessage = exception.toString();
          });
        },
        (pdfBytes) async {
          await _saveAndDisplayPDF(Uint8List.fromList(pdfBytes));
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _saveAndDisplayPDF(Uint8List pdfBytes) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/petty_cash_${widget.requestId}.pdf');
      await file.writeAsBytes(pdfBytes);

      setState(() {
        _pdfPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to save PDF: $e';
      });
    }
  }

  Future<void> _downloadPDF() async {
    try {
      setState(() {
        _isDownloading = true;
      });

      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to download PDF'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isDownloading = false;
        });
        return;
      }

      // Get downloads directory
      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = Directory('/storage/emulated/0/Download');
      } else {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      if (downloadsDirectory == null || !await downloadsDirectory.exists()) {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      // Download PDF
      final result = await _dataSource.downloadPettyCashPDF(widget.requestId);
      result.fold(
        (exception) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download failed: ${exception.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (pdfBytes) async {
          try {
            final fileName =
                'petty_cash_${widget.requestId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
            final file = File('${downloadsDirectory!.path}/$fileName');
            await file.writeAsBytes(Uint8List.fromList(pdfBytes));

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF downloaded to: ${file.path}'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save PDF: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<void> _openPDF() async {
    if (_pdfPath != null) {
      try {
        final result = await OpenFileSafePlus.open(_pdfPath!);
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to open PDF: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.requestTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: ColorManager.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_pdfPath != null) ...[
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: _openPDF,
              tooltip: 'Open PDF',
            ),
            IconButton(
              icon: _isDownloading
                  ? SizedBox(
                      width: 20.sp,
                      height: 20.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.download),
              onPressed: _isDownloading ? null : _downloadPDF,
              tooltip: 'Download PDF',
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.red,
            ),
            SizedBox(height: 16.sp),
            Text(
              'Error Loading PDF',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8.sp),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.sp),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16.sp),
            ElevatedButton(
              onPressed: _loadPDF,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_pdfPath != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 128.sp,
              color: ColorManager.primary,
            ),
            SizedBox(height: 24.sp),
            Text(
              'PDF Generated Successfully',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: ColorManager.primary,
              ),
            ),
            SizedBox(height: 16.sp),
            Text(
              'Petty Cash Request: ${widget.requestId}',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 32.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _openPDF,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                        horizontal: 24.sp, vertical: 12.sp),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _downloadPDF,
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                        horizontal: 24.sp, vertical: 12.sp),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return const Center(
      child: Text('No PDF to display'),
    );
  }
}
