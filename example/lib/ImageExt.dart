import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
Widget ImageView(
    {@required String imageUrl,
      String placeHolder,
      String suffix="png",
      double size = 0,
      bool useCrop = false,
      double height = 0,
      Color color,
      BoxFit fit = BoxFit.contain,
      double borderWidth = 0.0,
      Color borderColor = Colors.white,
      alignment: Alignment.topCenter}) {
  assert(borderWidth >= 0.0, "滚啊😡");
  if (size > 0 && height == 0) {
    height = size;
  }
  if (borderWidth > 0) {
    size -= borderWidth * 2;
    height -= borderWidth * 2;
  }
  var img;
  if(Uri.parse(imageUrl).host.isEmpty){
    img= ImageViewLocal(placeHolder: placeHolder,suffix: suffix,size: size,height: height,color: color,borderColor: borderColor,borderWidth: borderWidth,alignment: alignment,
        useCrop: useCrop,fit: fit,localFile: false);
  }else{
    img = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      alignment: alignment,
      height: height,
      width: size,
      color: color,
      memCacheWidth:size.toInt(), memCacheHeight:height.toInt(),
      filterQuality: FilterQuality.high,
      imageBuilder: (c, ImageProvider imageProvider) {
        Completer<ui.Image> completer = new Completer<ui.Image>();
        imageProvider.resolve(new ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, bool _){
          completer.complete(info.image);
        }));
        return FutureBuilder<ui.Image>(
            future: completer.future,
            builder: (context,snap){
              final image =(snap?.connectionState==ConnectionState.done)? snap?.data:null;
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image:()sync* {
                      if(size != null &&size > 0 && size != double.infinity && height != null &&height > 0){
                        if(image!=null){
                          final iw=image.width.toInt();
                          final ih=image.height.toInt();
                          final sw = size.toDouble();
                          final sh = height.toDouble();
                          var aspectRatio = iw / ih;
                          var scale = 0.0;
                          if (iw > 0 && ih > 0) {
                            if (iw * sh > sw * ih) {
                              scale = (sw * ih / iw) / ih;
                            } else if (iw * sh < sw * ih) {
                              scale = (sh * iw / ih) / iw;
                            } else {
                              scale = sw / iw;
                            }
                          }
                          yield ResizeImage.resizeIfNeeded((iw * scale).toInt(),(ih * scale).toInt(),imageProvider);
                        }else{
                          yield ResizeImage.resizeIfNeeded(size.toInt(),height.toInt(),imageProvider);
                        }
                        yield imageProvider;
                      }else{
                        yield imageProvider;
                      }
                    }().last,
                    fit: fit,
                  ),
                ),
              );
            });
      },
      errorWidget: (c, s, o) {
        return Image(
          image: AssetImage(
            placeHolder == null || placeHolder.replaceAll(" ", "") == ""
                ? "assets/images/icon_placeholder.png"
                : "assets/images/$placeHolder.$suffix",
          ),
          height: height,
          width: size,
          fit: fit,
          alignment: alignment,
          color: color,
        );
      },
      placeholder: (c, s) {
        return Image(
          image: AssetImage(
            placeHolder == null || placeHolder == ""
                ? "assets/images/icon_placeholder.png"
                : "assets/images/$placeHolder.$suffix",
          ),
          height: height,
          width: size,
          fit: fit,
          alignment: alignment,
          color: color,
        );
      },
    );
  }



  var min = size;
  if (min > height) {
    min = height;
  }
  Widget finalWidget = SizedBox(
    height: useCrop ? min : height,
    width: useCrop ? min : size,
    child: useCrop
        ? ClipRRect(
      child: img,
      borderRadius: BorderRadius.all(Radius.circular(min)),
    )
        : img,
  );

  if (borderWidth > 0) {
    final w = useCrop ? min : size + (borderWidth * 2);
    final h = useCrop ? min : height + (borderWidth * 2);
    return Container(
      constraints:
      BoxConstraints(minHeight: h, maxHeight: h, minWidth: w, maxWidth: w),
      decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius:
          BorderRadius.all(Radius.circular(min + (borderWidth * 2)))),
      child: Center(
        child: finalWidget,
      ),
    );
  } else {
    return finalWidget;
  }
}

/**
 * @params localFile 本地文件与资产文件
 */

Widget ImageViewLocal(
    {@required String placeHolder,
      String suffix="png",
      double size = 0,
      bool useCrop = false,
      double height = 0,
      Color color,
      bool localFile = false,
      Future<Uint8List> future,
      Uint8List uint8list,
      BoxFit fit = BoxFit.contain,
      double borderWidth = 0.0,
      Color borderColor = Colors.white,
      alignment: Alignment.topCenter}) {
  assert(borderWidth >= 0.0, "滚啊😡");
  assert((uint8list != null) ? (future == null) : true, "滚啊滚啊😡");
  if (size > 0 && height == 0) {
    height = size;
  }
  if (borderWidth > 0) {
    size -= borderWidth * 2;
    height -= borderWidth * 2;
  }
  var min = size;
  if (min > height) {
    min = height;
  }

  if (future != null) {
    return FutureBuilder<Uint8List>(
      future: future,
      builder: (c, snap) {
        final img = snap?.data ?? null;
        final done = snap?.connectionState == ConnectionState.done;
        if (done) {
          return ImageViewLocal(
              placeHolder: placeHolder,
              size: size,
              useCrop: useCrop,
              height: height,
              color: color,
              localFile: localFile,
              future: null,
              uint8list: img,
              fit: fit,
              borderWidth: borderWidth,
              borderColor: borderColor,
              alignment: alignment);
        } else {
          return ImageViewLocal(
              placeHolder: placeHolder,
              size: size,
              useCrop: useCrop,
              height: height,
              color: color,
              localFile: localFile,
              future: null,
              fit: fit,
              borderWidth: borderWidth,
              borderColor: borderColor,
              alignment: alignment);
        }
      },
    );
  } else {
    final img = uint8list != null
        ? (Image.memory(
      uint8list,
      height: height,
      width: size,
      fit: fit,
      alignment: alignment,
      cacheWidth:size.toInt(), cacheHeight:height.toInt(),
      color: color,
    ))
        : (localFile
        ? Image.file(
      File(placeHolder),
      height: height,
      width: size,
      fit: fit,
      alignment: alignment,
      cacheWidth:size.toInt(), cacheHeight:height.toInt(),
      color: color,
    )
        : Image(
      image: AssetImage(
        placeHolder == null || placeHolder == ""
            ? "assets/images/icon_placeholder.png"
            : "assets/images/$placeHolder.$suffix",
      ),
      height: height,
      width: size,
      fit: fit,
      alignment: alignment,
      color: color,
    ));
    Widget finalWidget = SizedBox(
      height: useCrop ? min : height,
      width: useCrop ? min : size,
      child: useCrop
          ? ClipRRect(
        child: img,
        borderRadius: BorderRadius.all(Radius.circular(min)),
      )
          : img,
    );
    if (borderWidth > 0) {
      final w = useCrop ? min : size + (borderWidth * 2);
      final h = useCrop ? min : height + (borderWidth * 2);
      return Container(
        constraints: BoxConstraints(
            minHeight: h, maxHeight: h, minWidth: w, maxWidth: w),
        decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: borderWidth + 1),
            borderRadius:
            BorderRadius.all(Radius.circular(min + (borderWidth * 2)))),
        child: Center(
          child: finalWidget,
        ),
      );
    } else {
      return finalWidget;
    }
  }
}
