import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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

  void _addAmount(double increment) {
    final current = double.tryParse(_controller.text.trim()) ?? 0.0;
    final updated = (current + increment).clamp(0.01, 1000000.0);
    setState(() {
      _controller.text = updated.toStringAsFixed(2);
      _errorMessage = null;
    });
  }

  void _roundAmount() {
    final current = double.tryParse(_controller.text.trim()) ?? 0.0;
    final updated = current.ceilToDouble();
    setState(() {
      _controller.text = updated.toStringAsFixed(2);
      _errorMessage = null;
    });
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
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: bottomInset + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF141416),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFF282830), width: 1.5),
        ),
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
                color: const Color(0xFF383842),
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
                  color: const Color(0xFF007AFF).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.edit_rounded,
                    color: Color(0xFF007AFF),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Amount',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.merchantTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Google Sans',
                        color: Color(0xFF8E8E93),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Color(0xFF8E8E93)),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Amount Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B20),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _errorMessage != null
                    ? const Color(0xFFFF453A)
                    : const Color(0xFF2C2C34),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '₹',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: Colors.white,
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
                    style: const TextStyle(
                      fontFamily: 'Google Sans',
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        fontFamily: 'Google Sans',
                        color: Color(0xFF555560),
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (_controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _controller.clear()),
                    child: const Icon(
                      Icons.cancel_rounded,
                      color: Color(0xFF8E8E93),
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontFamily: 'Google Sans',
                color: Color(0xFFFF453A),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Quick Increment Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickChip('+₹50', () => _addAmount(50)),
                const SizedBox(width: 8),
                _buildQuickChip('+₹100', () => _addAmount(100)),
                const SizedBox(width: 8),
                _buildQuickChip('+₹500', () => _addAmount(500)),
                const SizedBox(width: 8),
                _buildQuickChip('Round Up', _roundAmount),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8E8E93),
                    side: const BorderSide(color: Color(0xFF2C2C34)),
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
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
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

  Widget _buildQuickChip(String label, VoidCallback onTap) {
    return Material(
      color: const Color(0xFF1E1E24),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF282830)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Google Sans',
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
