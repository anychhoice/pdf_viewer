import 'dart:io';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_advanced_networkimage/zoomable.dart';

class PDFPage extends StatefulWidget {
  final String imgPath;
  final int num;
  final Function(double) onZoomChanged;
  final int zoomSteps;
  final double minScale;
  final double maxScale;
  final double panLimit;
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
  ImageProvider provider;
  ImageStream _resolver;
  ImageStreamListener _listener;

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

  _repaint() {
    provider = FileImage(File(widget.imgPath));
    _resolver = provider.resolve(createLocalImageConfiguration(context));
    _listener = ImageStreamListener((imgInfo, alreadyPainted) {
      if (!alreadyPainted) setState(() {});
    });
    _resolver.addListener(_listener);
  }

  @override
  void dispose() {
    if(_resolver != null && _listener != null) {
      _resolver.removeListener(_listener);
      provider.evict();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: null,
        child: ZoomableWidget(
          onZoomChanged: widget.onZoomChanged,
          zoomSteps: widget.zoomSteps ?? 3,
          minScale: widget.minScale ?? 1.0,
          panLimit: widget.panLimit ?? 1.0,
          maxScale: widget.maxScale ?? 5.0,
          child: Image(image: provider),
        ));
  }
}
