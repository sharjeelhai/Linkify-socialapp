import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UniversalImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const UniversalImage({
    required this.imageUrl, super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('UniversalImage: imageUrl = $imageUrl');

    // Normalize possible local paths
    String? localPath;
    if (imageUrl.startsWith('file://')) {
      localPath = imageUrl.replaceFirst('file://', '');
    } else if (imageUrl.startsWith('/') || imageUrl.contains('/data/')) {
      // absolute path saved without file:// prefix
      localPath = imageUrl;
    }

    // If local path candidate, check existence synchronously (fast)
    if (localPath != null) {
      try {
        final file = File(localPath);
        final exists = file.existsSync();
        debugPrint(
          'UniversalImage: local file path detected. exists=$exists, path=$localPath',
        );

        if (exists) {
          Widget fileWidget = Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stack) {
              debugPrint(
                'UniversalImage: Image.file error: $error (path=$localPath)',
              );
              return _errorWidget();
            },
          );
          if (borderRadius != null) {
            return ClipRRect(borderRadius: borderRadius!, child: fileWidget);
          }
          return fileWidget;
        } else {
          // show a helpful missing-file placeholder (with message)
          return _missingFileWidget(localPath);
        }
      } catch (e) {
        debugPrint('UniversalImage: error checking local file: $e');
        // fall through to network/data
      }
    }

    // Network http(s)
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      Widget net = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (c, u) => _loadingWidget(),
        errorWidget: (c, u, e) {
          debugPrint('UniversalImage: CachedNetworkImage error: $e (url: $u)');
          return _errorWidget();
        },
      );
      if (borderRadius != null) {
        return ClipRRect(borderRadius: borderRadius!, child: net);
      }
      return net;
    }

    // data: base64
    if (imageUrl.startsWith('data:')) {
      try {
        final comma = imageUrl.indexOf(',');
        final base64Str = imageUrl.substring(comma + 1);
        final bytes = base64Decode(base64Str);
        Widget mem = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (c, e, s) {
            debugPrint('UniversalImage: Image.memory error: $e');
            return _errorWidget();
          },
        );
        if (borderRadius != null) {
          return ClipRRect(borderRadius: borderRadius!, child: mem);
        }
        return mem;
      } catch (e) {
        debugPrint('UniversalImage: data URI decode failed: $e');
        return _errorWidget();
      }
    }

    debugPrint('UniversalImage: Unsupported imageUrl format: $imageUrl');
    return _errorWidget();
  }

  Widget _loadingWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _errorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
      ),
    );
  }

  // Shown when local path was detected but file missing
  Widget _missingFileWidget(String path) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.broken_image, color: Colors.grey, size: 40),
            const SizedBox(height: 8),
            Text(
              'Local file not found',
              style: const TextStyle(color: Colors.grey),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 6),
              Text(
                path,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
