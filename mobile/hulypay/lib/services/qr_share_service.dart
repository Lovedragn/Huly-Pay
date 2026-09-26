import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Service responsible for picking a QR image and sharing it via the native Android Sharesheet.
///
/// Flow:
/// HulyPay Dashboard -> Upload QR button -> Amount Page -> Select QR Image ->
/// Native Android Sharesheet opens -> User selects Google Pay or another app ->
/// Android delivers image to selected app.
///
/// NOTE:
/// - Does NOT decode or scan the QR code.
/// - Does NOT construct upi://pay intent.
/// - Does NOT hard-code or bypass Google Pay.
/// - Preserves original uncompressed image quality for the recipient app.
class QrShareService {
  static const MethodChannel _channel = MethodChannel('com.hulypay/share_image');

  static final List<String> _supportedImageExtensions = [
    'png',
    'jpg',
    'jpeg',
    'webp',
    'bmp',
    'gif',
    'heic',
    'heif',
  ];

  /// Opens the device photo/gallery picker to pick an uncompressed QR image.
  /// Returns null if cancelled or invalid.
  static Future<XFile?> pickQrImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) {
        debugPrint('[HulyPay] User cancelled image selection');
        return null;
      }

      final String filePath = pickedFile.path;
      final String fileName = pickedFile.name;
      final String extension = filePath.contains('.')
          ? filePath.split('.').last.toLowerCase().split('?').first
          : '';

      if (extension.isNotEmpty && !_supportedImageExtensions.contains(extension)) {
        debugPrint('[HulyPay] Selected file is not an image: $fileName');
        if (context.mounted) {
          _showSnackBar(
            context,
            'Selected file is not an image. Please select a valid QR image.',
            isError: true,
          );
        }
        return null;
      }

      debugPrint('[HulyPay] QR image selected');
      return pickedFile;
    } catch (e) {
      debugPrint('[HulyPay] Error picking image from gallery: $e');
      if (context.mounted) {
        _showSnackBar(
          context,
          'Could not access gallery. Please try again.',
          isError: true,
        );
      }
      return null;
    }
  }

  /// Launches the native Android Sharesheet with ACTION_SEND and EXTRA_STREAM.
  static Future<bool> shareQrImage({
    required BuildContext context,
    required String filePath,
    double? amount,
    String? note,
    String? title,
  }) async {
    if (!kIsWeb && defaultTargetPlatform != TargetPlatform.android) {
      if (context.mounted) {
        _showSnackBar(
          context,
          'QR image sharing is optimized for Android devices.',
          isError: false,
        );
      }
    }

    try {
      debugPrint('[HulyPay] Preparing image for sharing');

      if (!kIsWeb && !filePath.startsWith('content://')) {
        final localFile = File(filePath);
        if (!await localFile.exists()) {
          debugPrint('[HulyPay] Image file not accessible on filesystem: $filePath');
          if (context.mounted) {
            _showSnackBar(
              context,
              'Could not access the selected image file.',
              isError: true,
            );
          }
          return false;
        }
      }

      debugPrint('[HulyPay] Opening Android Sharesheet');

      String? shareText;
      if (amount != null && amount > 0) {
        shareText = '₹${amount.toStringAsFixed(2)}';
        if (note != null && note.trim().isNotEmpty) {
          shareText += ' - ${note.trim()}';
        }
      }

      final bool? launched = await _channel.invokeMethod<bool>('shareImage', {
        'imagePath': filePath,
        'title': title ?? 'Share QR image',
        'text': ?shareText,
      });

      if (launched == true) {
        debugPrint('[HulyPay] Share intent launched');
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      debugPrint('[HulyPay] PlatformException sharing image: ${e.code} - ${e.message}');
      if (!context.mounted) return false;

      if (e.code == 'NO_APPS') {
        _showSnackBar(
          context,
          'No compatible application found to share the QR image.',
          isError: true,
        );
      } else if (e.code == 'URI_RESOLUTION_FAILED' || e.code == 'FILE_NOT_FOUND') {
        _showSnackBar(
          context,
          'Could not resolve image for sharing. Please try another image.',
          isError: true,
        );
      } else {
        _showSnackBar(
          context,
          'Unable to open Sharesheet: ${e.message ?? 'Unknown error'}',
          isError: true,
        );
      }
      return false;
    } catch (e) {
      debugPrint('[HulyPay] Unexpected error sharing QR image: $e');
      if (context.mounted) {
        _showSnackBar(
          context,
          'Failed to share QR image. Please try again.',
          isError: true,
        );
      }
      return false;
    }
  }

  /// Opens the device photo picker and immediately triggers the Android Sharesheet.
  static Future<void> pickAndShareQrImage(BuildContext context) async {
    final picked = await pickQrImage(context);
    if (picked != null && context.mounted) {
      await shareQrImage(context: context, filePath: picked.path);
    }
  }

  static void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Google Sans',
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        backgroundColor: isError ? const Color(0xFFD93025) : const Color(0xFF1E1E24),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
