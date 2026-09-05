import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/jobs/jobs_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/job.dart';
import '../../../data/models/photo.dart';
import '../../../data/models/user.dart';

/// Modal input flows for the mechanic workspace, kept out of the screen file.
class JobDialogs {
  JobDialogs._();

  static Future<void> editDiagnosis(
    BuildContext context,
    Job job,
    AppUser user,
  ) async {
    final ctrl = TextEditingController(text: job.diagnosis ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Diagnosis'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Describe the fault and recommended repair…',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && context.mounted) {
      context.read<JobsBloc>().add(
            JobDiagnosisSet(jobId: job.id, diagnosis: result, byUser: user.name),
          );
    }
  }

  static Future<void> addNote(
    BuildContext context,
    Job job,
    AppUser user,
  ) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add note'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Write a note…'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && context.mounted) {
      context
          .read<JobsBloc>()
          .add(JobNoteAdded(jobId: job.id, note: result, byUser: user.name));
    }
  }

  static Future<void> addPart(
    BuildContext context,
    Job job,
    AppUser user,
  ) async {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final costCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log spare part'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Part name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: const InputDecoration(labelText: 'Qty'),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        return (n == null || n < 1) ? '≥ 1' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: costCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Unit cost',
                        prefixText: '₹ ',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Log part'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      context.read<JobsBloc>().add(
            JobPartAdded(
              jobId: job.id,
              name: nameCtrl.text.trim(),
              quantity: int.tryParse(qtyCtrl.text.trim()) ?? 1,
              unitCost: double.tryParse(costCtrl.text.trim()),
              byUser: user.name,
            ),
          );
    }
  }

  static Future<void> addPhoto(
    BuildContext context,
    Job job,
    AppUser user,
  ) async {
    final captionCtrl = TextEditingController();
    var stage = PhotoStage.repair;
    var offline = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Add photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simulated camera preview (no real capture in the prototype).
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo_camera_outlined,
                          size: 34, color: AppColors.slate500),
                      SizedBox(height: 6),
                      Text('Camera preview (demo)',
                          style: TextStyle(
                              color: AppColors.slate500, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: captionCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Caption'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PhotoStage>(
                initialValue: stage,
                decoration: const InputDecoration(labelText: 'Stage'),
                items: [
                  for (final s in PhotoStage.values)
                    DropdownMenuItem(value: s, child: Text(s.label)),
                ],
                onChanged: (v) => setLocal(() => stage = v ?? stage),
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: offline,
                dense: true,
                activeThumbColor: AppColors.brandOrange,
                title: const Text('Simulate offline capture',
                    style: TextStyle(fontSize: 13)),
                subtitle: const Text('Queues to sync later',
                    style: TextStyle(fontSize: 11.5)),
                onChanged: (v) => setLocal(() => offline = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Attach'),
            ),
          ],
        ),
      ),
    );

    if (result == true && context.mounted) {
      final caption = captionCtrl.text.trim().isEmpty
          ? '${stage.label} photo'
          : captionCtrl.text.trim();
      context.read<JobsBloc>().add(
            JobPhotoAdded(
              jobId: job.id,
              caption: caption,
              stage: stage,
              byUser: user.name,
              pendingUpload: offline,
            ),
          );
    }
  }
}
