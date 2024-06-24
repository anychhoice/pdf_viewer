import 'dart:io';

import 'package:chakre_pdf_viewer/src/zoom.dart';
import 'package:flutter/widgets.dart';

class PDFPage extends StatefulWidget {
  final String? imgPath;
  final int num;
  final Function(double)? onZoomChanged;
  final int? zoomSteps;
  final double? minScale;
  final double? maxScale;
  final double? panLimit;
  PDFPage(
    this.imgPath,
    this.num, {
    this.onZoomChanged,
    this.zoomSteps = 3,
    this.minScale = 1.0,
    this.maxScale = 5.0,
    this.panLimit = 1.0,
  });

  @override
  _PDFPageState createState() => _PDFPageState();
}

class _PDFPageState extends State<PDFPage> {
  ImageProvider? provider;
  ImageStream? _resolver;
  ImageStreamListener? _listener;
  bool _repainting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repaint();
  }

  @override
  void didUpdateWidget(PDFPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imgPath != widget.imgPath) {
      _repaint();
    }
  }

  _isRepainting() => _repainting;

  _repaint() async {
    if (_repainting) await Future.doWhile(() => _isRepainting());
    _repainting = true;
    if (_resolver != null && _listener != null)
      _resolver!.removeListener(_listener!);
    if (provider != null) provider!.evict();
    provider = FileImage(File(widget.imgPath!), scale: widget.maxScale ?? 1.0);
    _resolver = provider!.resolve(createLocalImageConfiguration(context));
    _listener = ImageStreamListener((imgInfo, alreadyPainted) {
      if (mounted && !alreadyPainted) setState(() {});
    });
    _resolver!.addListener(_listener!);
    _repainting = false;
  }

  @override
  void dispose() {
    if (_resolver != null && _listener != null) {
      _resolver!.removeListener(_listener!);
    }
    provider!.evict();
    super.dispose();
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
          child: Image(image: provider!),
        ));
  }
}
