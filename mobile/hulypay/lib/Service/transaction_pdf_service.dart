import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Generates professional PDF receipt documents for transactions.
class TransactionPdfService {
  TransactionPdfService._();

  /// Generate a detailed PDF receipt and return the file path.
  static Future<String> generateReceipt({
    required String merchantTitle,
    required String displayAmount,
    required String status,
    required String dateTime,
    required String paymentMethod,
    required String referenceId,
    String? upiTransactionId,
    String? upiId,
    String? category,
    String? provider,
    String? currency,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? transactionType,
    String? createdAt,
    bool isIncome = false,
  }) async {
    final pdf = pw.Document();

    // Load logo as image bytes
    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/logo/Logo-Dark.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {}

    // Status colors
    final sUpper = status.toUpperCase();
    final isPending = sUpper == 'PENDING' || sUpper == 'INITIATED' || sUpper == 'PAYMENT_INITIATED';
    final isFailed = sUpper == 'FAILED';
    final isCancelled = sUpper == 'CANCELLED';

    final PdfColor statusColor = isCancelled
        ? const PdfColor.fromInt(0xFFFF9F0A)
        : (isFailed
            ? const PdfColor.fromInt(0xFFFF453A)
            : (isPending
                ? const PdfColor.fromInt(0xFFE5A93C)
                : const PdfColor.fromInt(0xFF30D158)));

    final statusLabel = isCancelled
        ? 'CANCELLED'
        : (isFailed
            ? 'FAILED'
            : (isPending ? 'PENDING' : 'CONFIRMED'));

    final PdfColor accentBlue = const PdfColor.fromInt(0xFF007AFF);
    final PdfColor darkBg = const PdfColor.fromInt(0xFF101013);
    final PdfColor cardBg = const PdfColor.fromInt(0xFF161619);
    final PdfColor borderColor = const PdfColor.fromInt(0xFF2A2A30);
    final PdfColor textWhite = const PdfColor.fromInt(0xFFEEEEEE);
    final PdfColor textDim = const PdfColor.fromInt(0xFF8E8E93);
    final PdfColor textMuted = const PdfColor.fromInt(0xFF6B6B70);

    final now = DateTime.now();
    final generatedAt =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Container(
            width: double.infinity,
            height: double.infinity,
            color: darkBg,
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // ── HEADER ──
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          if (logoImage != null)
                            pw.Container(
                              width: 36,
                              height: 36,
                              margin: const pw.EdgeInsets.only(right: 10),
                              child: pw.Image(logoImage),
                            ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Huly Pay',
                                style: pw.TextStyle(
                                  color: textWhite,
                                  fontSize: 22,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                'Transaction Receipt',
                                style: pw.TextStyle(
                                  color: textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: pw.BoxDecoration(
                              color: statusColor.shade(0.15),
                              borderRadius: pw.BorderRadius.circular(6),
                              border: pw.Border.all(color: statusColor, width: 0.8),
                            ),
                            child: pw.Text(
                              statusLabel,
                              style: pw.TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            'Generated: $generatedAt',
                            style: pw.TextStyle(
                              color: textMuted,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 20),

                  // ── DIVIDER ──
                  pw.Container(
                    height: 1,
                    color: borderColor,
                  ),

                  pw.SizedBox(height: 24),

                  // ── AMOUNT HERO SECTION ──
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          isIncome ? 'Amount Received' : 'Amount Paid',
                          style: pw.TextStyle(
                            color: textMuted,
                            fontSize: 11,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          displayAmount,
                          style: pw.TextStyle(
                            color: isFailed
                                ? const PdfColor.fromInt(0xFFFF453A)
                                : textWhite,
                            fontSize: 42,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          isIncome
                              ? 'From: $merchantTitle'
                              : 'To: $merchantTitle',
                          style: pw.TextStyle(
                            color: textWhite,
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          dateTime,
                          style: pw.TextStyle(
                            color: textDim,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 28),

                  // ── TRANSACTION DETAILS CARD ──
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: cardBg,
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: borderColor, width: 0.8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'TRANSACTION DETAILS',
                          style: pw.TextStyle(
                            color: textMuted,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        pw.SizedBox(height: 14),

                        _buildDetailRow('Transaction ID', referenceId, textWhite, textDim),
                        _buildDivider(borderColor),

                        if (upiTransactionId != null && upiTransactionId.isNotEmpty) ...[
                          _buildDetailRow('UPI Ref / UTR', upiTransactionId, textWhite, textDim),
                          _buildDivider(borderColor),
                        ],

                        _buildDetailRow('Payment Method', paymentMethod, textWhite, textDim),
                        _buildDivider(borderColor),

                        if (provider != null && provider.isNotEmpty) ...[
                          _buildDetailRow('Payment Provider', _formatProvider(provider), textWhite, textDim),
                          _buildDivider(borderColor),
                        ],

                        if (upiId != null && upiId.isNotEmpty) ...[
                          _buildDetailRow('Payee UPI ID', upiId, textWhite, textDim),
                          _buildDivider(borderColor),
                        ],

                        _buildDetailRow('Payment Status', statusLabel, statusColor, textDim),
                        _buildDivider(borderColor),

                        if (transactionType != null && transactionType.isNotEmpty) ...[
                          _buildDetailRow('Transaction Type', transactionType, textWhite, textDim),
                          _buildDivider(borderColor),
                        ],

                        _buildDetailRow('Currency', currency ?? 'INR', textWhite, textDim),
                        _buildDivider(borderColor),

                        if (category != null && category.isNotEmpty) ...[
                          _buildDetailRow('Category', category, accentBlue, textDim),
                          _buildDivider(borderColor),
                        ],

                        _buildDetailRow('Date & Time', dateTime, textWhite, textDim),

                        if (createdAt != null && createdAt.isNotEmpty) ...[
                          _buildDivider(borderColor),
                          _buildDetailRow('Created At', createdAt, textWhite, textDim),
                        ],
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 16),

                  // ── LOCATION DETAILS CARD ──
                  if (latitude != null && longitude != null)
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(20),
                      decoration: pw.BoxDecoration(
                        color: cardBg,
                        borderRadius: pw.BorderRadius.circular(12),
                        border: pw.Border.all(color: borderColor, width: 0.8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'PAYMENT LOCATION',
                            style: pw.TextStyle(
                              color: textMuted,
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          pw.SizedBox(height: 14),
                          _buildDetailRow(
                            'GPS Coordinates',
                            '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                            textWhite,
                            textDim,
                          ),
                          _buildDivider(borderColor),
                          _buildDetailRow(
                            'Accuracy',
                            '±${accuracy != null ? accuracy.toStringAsFixed(1) : "5.0"} meters',
                            textWhite,
                            textDim,
                          ),
                          _buildDivider(borderColor),
                          _buildDetailRow(
                            'Google Maps',
                            'maps.google.com/?q=$latitude,$longitude',
                            accentBlue,
                            textDim,
                          ),
                        ],
                      ),
                    ),

                  pw.Spacer(),

                  // ── FOOTER ──
                  pw.Container(
                    height: 1,
                    color: borderColor,
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'This receipt was generated digitally by Huly Pay.',
                            style: pw.TextStyle(
                              color: textMuted,
                              fontSize: 8,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'This is a computer-generated document and does not require a signature.',
                            style: pw.TextStyle(
                              color: textMuted,
                              fontSize: 7,
                              fontStyle: pw.FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      pw.Text(
                        'Huly Pay v1.0',
                        style: pw.TextStyle(
                          color: textMuted,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    // Save the PDF to a temporary file
    final dir = await getTemporaryDirectory();
    final sanitizedMerchant = merchantTitle.replaceAll(RegExp(r'[^a-zA-Z0-9_\- ]'), '').trim();
    final fileName = 'HulyPay_Receipt_${sanitizedMerchant}_${now.millisecondsSinceEpoch}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  static pw.Widget _buildDetailRow(
    String label,
    String value,
    PdfColor valueColor,
    PdfColor labelColor,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                color: labelColor,
                fontSize: 10,
              ),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                color: valueColor,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDivider(PdfColor color) {
    return pw.Container(
      height: 0.5,
      color: color,
      margin: const pw.EdgeInsets.symmetric(vertical: 1),
    );
  }

  static String _formatProvider(String provider) {
    switch (provider.toUpperCase()) {
      case 'GOOGLE_PAY':
        return 'Google Pay';
      case 'AMAZON_PAY':
        return 'Amazon Pay';
      case 'PHONEPE':
        return 'PhonePe';
      case 'BHIM':
        return 'BHIM UPI';
      default:
        return provider;
    }
  }
}
