import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/utils/color_manager.dart';

class PDFViewerScreen extends StatefulWidget {
  final String pdfPath;
  final String title;

  const PDFViewerScreen({
    Key? key,
    required this.pdfPath,
    required this.title,
  }) : super(key: key);

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isReady = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBar(
        backgroundColor: ColorManager.primary,
        elevation: 0,
        title: Text(
          widget.title,
          style: TextStyle(
            color: ColorManager.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: ColorManager.white,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isReady && _totalPages > 0)
            Container(
              margin: EdgeInsets.only(right: 16.sp),
              padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
              decoration: BoxDecoration(
                color: ColorManager.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.sp),
              ),
              child: Text(
                '$_currentPage / $_totalPages',
                style: TextStyle(
                  color: ColorManager.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return _buildErrorState();
    }

    if (_isLoading) {
      return _buildLoadingState();
    }

    return _buildPDFViewer();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.sp),
            decoration: BoxDecoration(
              color: ColorManager.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50.sp),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.primary.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 20.sp),
          Text(
            'Loading PDF...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: ColorManager.grey2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20.sp),
        padding: EdgeInsets.all(24.sp),
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(16.sp),
          boxShadow: [
            BoxShadow(
              color: ColorManager.error.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: ColorManager.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50.sp),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48.sp,
                color: ColorManager.error,
              ),
            ),
            SizedBox(height: 16.sp),
            Text(
              'Failed to Load PDF',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: ColorManager.error,
              ),
            ),
            SizedBox(height: 8.sp),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorManager.grey2,
              ),
            ),
            SizedBox(height: 20.sp),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                  _errorMessage = '';
                });
                _loadPDF();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.primary,
                foregroundColor: ColorManager.white,
                padding:
                    EdgeInsets.symmetric(horizontal: 24.sp, vertical: 12.sp),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.sp),
                ),
                elevation: 2,
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPDFViewer() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorManager.primary.withOpacity(0.05),
            ColorManager.white,
          ],
        ),
      ),
      child: PDFView(
        filePath: widget.pdfPath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: true,
        pageSnap: true,
        onRender: (pages) {
          setState(() {
            _totalPages = pages!;
            _isReady = true;
            _isLoading = false;
          });
        },
        onViewCreated: (PDFViewController pdfViewController) {
          // PDF view created successfully
        },
        onPageChanged: (int? page, int? total) {
          setState(() {
            _currentPage = page ?? 0;
          });
        },
        onError: (error) {
          setState(() {
            _hasError = true;
            _isLoading = false;
            _errorMessage = 'Error loading PDF: ${error.toString()}';
          });
        },
        onPageError: (page, error) {
          setState(() {
            _hasError = true;
            _isLoading = false;
            _errorMessage = 'Error loading page $page: ${error.toString()}';
          });
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  void _loadPDF() async {
    try {
      // Check if file exists
      final file = File(widget.pdfPath);
      if (!await file.exists()) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _errorMessage = 'PDF file not found at the specified path.';
        });
        return;
      }

      // Check file size
      final fileSize = await file.length();
      if (fileSize == 0) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _errorMessage = 'PDF file is empty or corrupted.';
        });
        return;
      }

      // File exists and has content, PDFView will handle the rest
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = 'Error accessing PDF file: ${e.toString()}';
      });
    }
  }
}
