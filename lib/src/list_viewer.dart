import 'package:chakre_pdf_viewer/chakre_pdf_viewer.dart';
import 'package:flutter/material.dart';

class PDFListViewer extends StatefulWidget {
  final PDFDocument document;
  final bool preload;
  final double? loadingPageHeight;
  final Function(double)? onZoomChanged;
  final int? zoomSteps;
  final double? minScale;
  final double? maxScale;
  final double? panLimit;

  /// Shows PDF of multiple pages in list mode
  PDFListViewer({
    Key? key,
    required this.document,
    this.preload = false,
    this.onZoomChanged,
    this.loadingPageHeight = 400,
    this.zoomSteps = 3,
    this.minScale = 1.0,
    this.maxScale = 5.0,
    this.panLimit = 1.0,
  }) : super(key: key);

  @override
  _PDFListViewerState createState() => _PDFListViewerState();
}

class _PDFListViewerState extends State<PDFListViewer> {
  bool _preloaded = false;
  List<Image?>? _images;

  @override
  void initState() {
    super.initState();
    _images = List<Image?>.filled(widget.document.count!, null, growable: true);
    if (widget.preload) {
      Future.delayed(Duration.zero, () async {
        await widget.document.preloadImages();
        _images = widget.document.images;
        _preloaded = true;
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    for (var i = 0; i < _images!.length; i++) {
      _images![i]!.image.evict();
      _images![i] = null;
    }
    _images = null;
    widget.document.clearImageCache();
    widget.document.clearFileCache();
    super.dispose();
  }

  Future<Image?>? _loadPage(int index) async {
    if (index < 0 || index >= _images!.length) return null;
    if (_images![index] != null) return _images![index];
    final data = await widget.document.getImage(page: index + 1);
    _images![index] = data;
    return _images![index];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: null,
        child: CustomZoomableWidget(
          onZoomChanged: widget.onZoomChanged,
          zoomSteps: widget.zoomSteps ?? 3,
          minScale: widget.minScale ?? 1.0,
          panLimit: widget.panLimit ?? 1.0,
          maxScale: widget.maxScale ?? 5.0,
          autoCenter: true,
          child: _getViewer(),
        ));
  }

  Widget _getViewer() {
    return widget.preload
        ? _preloaded
            ? ListView.builder(
                itemCount: widget.document.count,
                itemBuilder: (context, index) {
                  return _images![index]!;
                })
            : Center(
                child: CircularProgressIndicator(),
              )
        : ListView.builder(
            itemCount: widget.document.count,
            itemBuilder: (context, index) => FutureBuilder(future: () async {
              return await _loadPage(index);
            }(), builder: (context, snapShot) {
              if (snapShot.hasData) {
                return snapShot.data as Image;
              } else {
                return Container(
                  height: widget.loadingPageHeight,
                  width: double.maxFinite,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            }),
          );
  }
}
