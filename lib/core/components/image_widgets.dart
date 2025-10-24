import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/color_palette.dart';

/// Image source types
enum ImageSource {
  asset,
  assetIcons,
  network,
  file,
  memory,
}

/// Base image widget with multiple source types
class BaseImage extends StatelessWidget {
  final String? assetPath;
  final String? networkUrl;
  final String? filePath;
  final Uint8List? memoryBytes;
  final ImageSource source;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Alignment? alignment;
  final bool showLoadingIndicator;
  final Color? loadingColor;
  final double? loadingSize;
  final Color? iconColors;

  const BaseImage({
    super.key,
    this.assetPath,
    this.networkUrl,
    this.filePath,
    this.memoryBytes,
    required this.source,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.padding,
    this.margin,
    this.alignment,
    this.showLoadingIndicator = true,
    this.loadingColor,
    this.loadingSize,
    this.iconColors,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = _buildImageWidget();
    
    if (padding != null || margin != null || borderRadius != null || boxShadow != null) {
      imageWidget = Container(
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: boxShadow,
          color: backgroundColor,
        ),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildImageWidget() {
    switch (source) {
      case ImageSource.asset:
        return _buildAssetImage();
      case ImageSource.network:
        return _buildNetworkImage();
      case ImageSource.file:
        return _buildFileImage();
      case ImageSource.memory:
        return _buildMemoryImage();
      case ImageSource.assetIcons:
        return _buildAssetIconsImage();
    }
  }

  Widget _buildAssetImage() {
    if (assetPath == null) {
      return _buildErrorWidget();
    }
    
    return Image.asset(
      assetPath!,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      alignment: alignment ?? Alignment.center,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildAssetIconsImage() {
    if (assetPath == null) {
      return _buildErrorWidget();
    }

    return Image.asset(
      assetPath!,
      width: width,
      height: height,
      alignment: alignment ?? Alignment.center,
      color: iconColors,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildNetworkImage() {
    if (networkUrl == null || networkUrl!.isEmpty) {
      return _buildErrorWidget();
    }

    return CachedNetworkImage(
      imageUrl: networkUrl!,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      alignment: alignment ?? Alignment.center,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildFileImage() {
    if (filePath == null) {
      return _buildErrorWidget();
    }

    return Image.file(
      File(filePath!),
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      alignment: alignment ?? Alignment.center,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildMemoryImage() {
    if (memoryBytes == null) {
      return _buildErrorWidget();
    }

    return Image.memory(
      memoryBytes!,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      alignment: alignment ?? Alignment.center,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) {
      return placeholder!;
    }

    if (showLoadingIndicator) {
      return Container(
        width: width,
        height: height,
        color: backgroundColor ?? Colors.grey[200],
        child: Center(
          child: SizedBox(
            width: loadingSize ?? 24,
            height: loadingSize ?? 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                loadingColor ?? ColorPalette.primary,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[200],
      child: const Icon(
        Icons.image,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[200],
      child: const Icon(
        Icons.error_outline,
        color: Colors.grey,
      ),
    );
  }
}

/// Asset image widget
class AssetImageWidget extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Alignment? alignment;

  const AssetImageWidget({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.padding,
    this.margin,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return BaseImage(
      assetPath: assetPath,
      source: ImageSource.asset,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      padding: padding,
      margin: margin,
      alignment: alignment,
    );
  }
}

/// Network image widget
class NetworkImageWidget extends StatelessWidget {
  final String networkUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Alignment? alignment;
  final bool showLoadingIndicator;
  final Color? loadingColor;
  final double? loadingSize;

  const NetworkImageWidget({
    super.key,
    required this.networkUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.padding,
    this.margin,
    this.alignment,
    this.showLoadingIndicator = true,
    this.loadingColor,
    this.loadingSize,
  });

  @override
  Widget build(BuildContext context) {
    return BaseImage(
      networkUrl: networkUrl,
      source: ImageSource.network,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      padding: padding,
      margin: margin,
      alignment: alignment,
      showLoadingIndicator: showLoadingIndicator,
      loadingColor: loadingColor,
      loadingSize: loadingSize,
    );
  }
}

/// File image widget
class FileImageWidget extends StatelessWidget {
  final String filePath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Alignment? alignment;

  const FileImageWidget({
    super.key,
    required this.filePath,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.padding,
    this.margin,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return BaseImage(
      filePath: filePath,
      source: ImageSource.file,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      padding: padding,
      margin: margin,
      alignment: alignment,
    );
  }
}

/// Memory image widget
class MemoryImageWidget extends StatelessWidget {
  final Uint8List memoryBytes;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Alignment? alignment;

  const MemoryImageWidget({
    super.key,
    required this.memoryBytes,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.padding,
    this.margin,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return BaseImage(
      memoryBytes: memoryBytes,
      source: ImageSource.memory,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      padding: padding,
      margin: margin,
      alignment: alignment,
    );
  }
}

/// Circular image widget
class CircularImageWidget extends StatelessWidget {
  final String? assetPath;
  final String? networkUrl;
  final String? filePath;
  final Uint8List? memoryBytes;
  final ImageSource source;
  final double size;
  final double borderWidth;
  final Color? borderColor;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool showLoadingIndicator;
  final Color? loadingColor;
  final double? loadingSize;

  const CircularImageWidget({
    super.key,
    this.assetPath,
    this.networkUrl,
    this.filePath,
    this.memoryBytes,
    required this.source,
    required this.size,
    this.borderWidth = 0,
    this.borderColor,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.boxShadow,
    this.padding,
    this.margin,
    this.showLoadingIndicator = true,
    this.loadingColor,
    this.loadingSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + (borderWidth * 2),
      height: size + (borderWidth * 2),
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? ColorPalette.primary,
                width: borderWidth,
              )
            : null,
        boxShadow: boxShadow,
      ),
      child: ClipOval(
        child: BaseImage(
          assetPath: assetPath,
          networkUrl: networkUrl,
          filePath: filePath,
          memoryBytes: memoryBytes,
          source: source,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: placeholder,
          errorWidget: errorWidget,
          backgroundColor: backgroundColor,
          showLoadingIndicator: showLoadingIndicator,
          loadingColor: loadingColor,
          loadingSize: loadingSize,
        ),
      ),
    );
  }
}

/// Avatar image widget
class AvatarImageWidget extends StatelessWidget {
  final String? assetPath;
  final String? networkUrl;
  final String? filePath;
  final Uint8List? memoryBytes;
  final ImageSource source;
  final double size;
  final double borderWidth;
  final Color? borderColor;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool showLoadingIndicator;
  final Color? loadingColor;
  final double? loadingSize;

  const AvatarImageWidget({
    super.key,
    this.assetPath,
    this.networkUrl,
    this.filePath,
    this.memoryBytes,
    required this.source,
    this.size = 50,
    this.borderWidth = 2,
    this.borderColor,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.boxShadow,
    this.padding,
    this.margin,
    this.showLoadingIndicator = true,
    this.loadingColor,
    this.loadingSize,
  });

  @override
  Widget build(BuildContext context) {
    return CircularImageWidget(
      assetPath: assetPath,
      networkUrl: networkUrl,
      filePath: filePath,
      memoryBytes: memoryBytes,
      source: source,
      size: size,
      borderWidth: borderWidth,
      borderColor: borderColor,
      placeholder: placeholder,
      errorWidget: errorWidget,
      backgroundColor: backgroundColor,
      boxShadow: boxShadow,
      padding: padding,
      margin: margin,
      showLoadingIndicator: showLoadingIndicator,
      loadingColor: loadingColor,
      loadingSize: loadingSize,
    );
  }
}

/// Cached image widget with advanced caching
class CachedImageWidget extends StatelessWidget {
  final String networkUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Alignment? alignment;
  final bool showLoadingIndicator;
  final Color? loadingColor;
  final double? loadingSize;
  final Duration? fadeInDuration;
  final Duration? fadeOutDuration;
  final String? cacheKey;

  const CachedImageWidget({
    super.key,
    required this.networkUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.padding,
    this.margin,
    this.alignment,
    this.showLoadingIndicator = true,
    this.loadingColor,
    this.loadingSize,
    this.fadeInDuration,
    this.fadeOutDuration,
    this.cacheKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        color: backgroundColor,
      ),
      child: CachedNetworkImage(
        imageUrl: networkUrl,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        alignment: alignment ?? Alignment.center,
        cacheKey: cacheKey,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
        fadeInDuration: fadeInDuration ?? const Duration(milliseconds: 300),
        fadeOutDuration: fadeOutDuration ?? const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) {
      return placeholder!;
    }

    if (showLoadingIndicator) {
      return Container(
        width: width,
        height: height,
        color: backgroundColor ?? Colors.grey[200],
        child: Center(
          child: SizedBox(
            width: loadingSize ?? 24,
            height: loadingSize ?? 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                loadingColor ?? ColorPalette.primary,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[200],
      child: const Icon(
        Icons.image,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[200],
      child: const Icon(
        Icons.error_outline,
        color: Colors.grey,
      ),
    );
  }
}

/// Image with fallback widget
class ImageWithFallback extends StatelessWidget {
  final String? assetPath;
  final String? networkUrl;
  final String? filePath;
  final Uint8List? memoryBytes;
  final ImageSource source;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget fallbackWidget;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Alignment? alignment;

  const ImageWithFallback({
    super.key,
    this.assetPath,
    this.networkUrl,
    this.filePath,
    this.memoryBytes,
    required this.source,
    this.width,
    this.height,
    this.fit,
    required this.fallbackWidget,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.padding,
    this.margin,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return BaseImage(
      assetPath: assetPath,
      networkUrl: networkUrl,
      filePath: filePath,
      memoryBytes: memoryBytes,
      source: source,
      width: width,
      height: height,
      fit: fit,
      errorWidget: fallbackWidget,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      padding: padding,
      margin: margin,
      alignment: alignment,
    );
  }
}
