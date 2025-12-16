import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/reject_reason_controller.dart';
// model import not required directly here

class RefusePurchaseDialog extends StatefulWidget {
  const RefusePurchaseDialog({super.key});

  @override
  State<RefusePurchaseDialog> createState() => _RefusePurchaseDialogState();
}

class _RefusePurchaseDialogState extends State<RefusePurchaseDialog> {
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController otherReasonController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  bool reasonError = false;
  int? _selectedReasonId;
  bool _loadingReasons = false;

  @override
  Widget build(BuildContext context) {
    final rrCtrl = context.watch<RejectReasonController>();
    final reasons = rrCtrl.reasons;
    if (!_loadingReasons && reasons.isEmpty && !rrCtrl.isLoading) {
      // fetch once when dialog builds and we don't have reasons
      _loadingReasons = true;
      Future.microtask(() async {
        try {
          await rrCtrl.fetchReasons();
        } catch (_) {}
        if (mounted) setState(() => _loadingReasons = false);
      });
    }

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.error_outline, color: Colors.red, size: 32),
                    SizedBox(width: 12),
                    Text(
                      'Purchase Request',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please provide a reason for refusing this request:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Reason (required)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                // If reasons are loading, show a small loader. If reasons exist, show dropdown. Otherwise, fallback to free-text.
                if (_loadingReasons || rrCtrl.isLoading)
                  const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
                else if (reasons.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<int>(
                        value: _selectedReasonId,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF0F0F0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        hint: const Text('Select a reason'),
                        items: [
                          ...reasons.map((r) => DropdownMenuItem(value: r.id, child: Text(r.reason))).toList(),
                          const DropdownMenuItem(value: -1, child: Text('Other')),
                        ],
                        onChanged: (val) => setState(() {
                          _selectedReasonId = val == -1 ? -1 : val;
                          if (reasonError) reasonError = false;
                        }),
                      ),
                      if (_selectedReasonId == -1) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: otherReasonController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Enter custom reason',
                            filled: true,
                            fillColor: const Color(0xFFF0F0F0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            errorText: reasonError ? 'Reason is required' : null,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (_) {
                            if (reasonError) setState(() => reasonError = false);
                          },
                        ),
                      ]
                    ],
                  )
                else
                  TextField(
                    controller: reasonController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Example: The requested item exceeds the approved budget for this quarter.',
                      filled: true,
                      fillColor: const Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      errorText: reasonError ? 'Reason is required' : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (_) {
                      if (reasonError) setState(() => reasonError = false);
                    },
                  ),
                const SizedBox(height: 24),
                const Text(
                  'Additional Comments (optional)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: commentController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Provide any further details or context, if necessary.',
                    filled: true,
                    fillColor: const Color(0xFFF0F0F0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (reasons.isNotEmpty) {
                          if (_selectedReasonId == null) {
                            setState(() => reasonError = true);
                            return;
                          }
                          if (_selectedReasonId == -1 && otherReasonController.text.trim().isEmpty) {
                            setState(() => reasonError = true);
                            return;
                          }
                        } else {
                          if (reasonController.text.trim().isEmpty) {
                            setState(() => reasonError = true);
                            return;
                          }
                        }

                        // Prepare returned payload: include selected reason id (if any), the reason text, and the additional comment
                        int? reasonId;
                        String reasonText = '';
                        if (reasons.isNotEmpty) {
                          if (_selectedReasonId == -1) {
                            reasonId = null;
                            reasonText = otherReasonController.text.trim();
                          } else {
                            reasonId = _selectedReasonId;
                            reasonText = reasons.firstWhere((r) => r.id == _selectedReasonId).reason;
                          }
                        } else {
                          reasonId = null;
                          reasonText = reasonController.text.trim();
                        }

                        Navigator.of(context).pop({
                          'reason_id': reasonId,
                          'reason_text': reasonText,
                          'comment': commentController.text.trim(),
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B3BFF),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Submit', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    const SizedBox(width: 32),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        foregroundColor: Colors.black87,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}