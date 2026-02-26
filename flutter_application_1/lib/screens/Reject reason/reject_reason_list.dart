import '../../l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/reject_reason_controller.dart';
import '../../models/reject_reason.dart';
import 'package:flutter_application_1/widgets/standard_header.dart';

class RejectReasonListPage extends StatefulWidget {
  const RejectReasonListPage({super.key});

  @override
  State<RejectReasonListPage> createState() => _RejectReasonListPageState();
}

class _RejectReasonListPageState extends State<RejectReasonListPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureLoaded());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _ensureLoaded() async {
    final ctrl = context.read<RejectReasonController>();
    if (!_initialLoadDone) {
      _initialLoadDone = true;
      await ctrl.fetchReasons();
    }
  }

  Future<void> _openEditDialog({RejectReason? reason}) async {
    final ctrl = context.read<RejectReasonController>();
    final loc = AppLocalizations.of(context)!;
    final formKey = GlobalKey<FormState>();
    final reasonCtrl = TextEditingController(text: reason?.reason ?? '');
    final descCtrl = TextEditingController(text: reason?.description ?? '');
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(reason == null
                ? loc.addRejectReason
                : loc.editRejectReason),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: reasonCtrl,
                    autofocus: true,
                    maxLength: 64,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: loc.rejectReasonLabel,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? loc.fieldsRequired : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: InputDecoration(
                      labelText: loc.descriptionOptional,
                      hintText: loc.rejectReasonHint,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                child: Text(loc.cancel),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setStateDialog(() => isSubmitting = true);
                        try {
                          if (reason == null) {
                            await ctrl.createReason(
                                reason: reasonCtrl.text.trim(),
                                description: descCtrl.text.trim());
                          } else {
                            await ctrl.updateReason(
                                id: reason.id,
                                reason: reasonCtrl.text.trim(),
                                description: descCtrl.text.trim());
                          }
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(loc.saved)));
                          }
                        } catch (e) {
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${loc.error}: $e')));
                        } finally {
                          if (mounted)
                            setStateDialog(() => isSubmitting = false);
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(loc.save,
                        style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );

    reasonCtrl.dispose();
    descCtrl.dispose();
  }

  Future<void> _confirmDelete(int id) async {
    final ctrl = context.read<RejectReasonController>();
    final loc = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.deleteRejectReason),
        content: Text(loc.deleteRejectReasonConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(loc.cancel)),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(loc.delete)),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ctrl.deleteReason(id);
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('${loc.error}: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<RejectReasonController>();
    final list = ctrl.reasons;
    final filter = _searchCtrl.text.toLowerCase();
    final filtered = list
        .where((r) =>
            r.reason.toLowerCase().contains(filter) ||
            (r.description ?? '').toLowerCase().contains(filter))
        .toList();
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: StandardHeader(
        title: loc.rejectReasons,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: loc.searchRejectReasons,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFFF7F3FF),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _ensureLoaded(),
                  icon: const Icon(Icons.refresh, color: Color(0xFF6F4DBF)),
                  tooltip: loc.refresh,
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(loc.addRejectReason),
                  onPressed: () => _openEditDialog(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 224, 223, 227)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (ctrl.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (ctrl.errorMessage != null)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(ctrl.errorMessage!,
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        onPressed: () => ctrl.fetchReasons(),
                        child: Text(loc.retry)),
                  ],
                ),
              )
            else if (filtered.isEmpty)
              Expanded(
                  child: Center(
                      child: Text(loc.noRejectReasons)))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final r = filtered[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.reason,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Text(r.description ?? '-',
                                      style: const TextStyle(
                                          color: Colors.black54)),
                                  const SizedBox(height: 8),
                                  Text(
                                      'Updated: ${r.updatedAt != null ? DateFormat('dd-MM-yyyy HH:mm').format(r.updatedAt!) : '-'}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.teal),
                                    onPressed: () =>
                                        _openEditDialog(reason: r)),
                                IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _confirmDelete(r.id)),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

