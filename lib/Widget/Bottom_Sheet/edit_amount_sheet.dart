import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Theme/app_theme.dart';

class EditAmountSheet extends StatefulWidget {
  final double currentAmount;
  final String merchantTitle;
  final Future<bool> Function(double newAmount) onSave;

  const EditAmountSheet({
    super.key,
    required this.currentAmount,
    required this.merchantTitle,
    required this.onSave,
  });

  static Future<double?> show(
    BuildContext context, {
    required double currentAmount,
    required String merchantTitle,
    required Future<bool> Function(double newAmount) onSave,
  }) {
    final colors = AppThemeManager.colors;
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: colors.isDark ? 0.70 : 0.45),
      builder: (ctx) => EditAmountSheet(
        currentAmount: currentAmount,
        merchantTitle: merchantTitle,
        onSave: onSave,
      ),
    );
  }

  @override
  State<EditAmountSheet> createState() => _EditAmountSheetState();
}

class _EditAmountSheetState extends State<EditAmountSheet> {
  late final TextEditingController _controller;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentAmount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  Future<void> _handleSave() async {
    final rawText = _controller.text.trim();
    final parsed = double.tryParse(rawText);

    if (parsed == null || parsed <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid amount greater than ₹0';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.onSave(parsed);
      if (mounted) {
        if (success) {
          Navigator.of(context).pop(parsed);
        } else {
          setState(() {
            _isSaving = false;
            _errorMessage = 'Failed to update transaction amount';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: bottomInset + 24,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: colors.border, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: colors.isDark ? 0.5 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.edit_rounded,
                    color: colors.accent,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Amount',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.merchantTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.border),
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                  iconSize: 18,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  tooltip: 'Close',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Amount Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _errorMessage != null ? colors.error : colors.border,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Text(
                  '₹',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: colors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      color: colors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        fontFamily: 'Google Sans',
                        color: colors.textMuted,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: colors.error,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textSecondary,
                    side: BorderSide(color: colors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.isDark ? Colors.black : Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

