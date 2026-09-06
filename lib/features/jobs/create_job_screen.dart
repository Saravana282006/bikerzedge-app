import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/jobs/jobs_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/motorcycle.dart';
import '../../widgets/common.dart';

/// Admin flow to capture a new service job (PRD US-01). Targets < 90s intake.
class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final _ownerName = TextEditingController();
  final _contact = TextEditingController();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _registration = TextEditingController();
  final _odometer = TextEditingController();
  final _year = TextEditingController();
  final _color = TextEditingController();
  final _serviceRequest = TextEditingController();

  String? _engineType;
  bool _priority = false;
  bool _submitting = false;

  @override
  void dispose() {
    for (final c in [
      _ownerName,
      _contact,
      _make,
      _model,
      _registration,
      _odometer,
      _year,
      _color,
      _serviceRequest,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = context.read<AuthBloc>().state.user!;
    setState(() => _submitting = true);
    context.read<JobsBloc>().add(
          JobCreateRequested(
            ownerName: _ownerName.text.trim(),
            contact: _contact.text.trim(),
            motorcycle: Motorcycle(
              make: _make.text.trim(),
              model: _model.text.trim(),
              registration: _registration.text.trim().toUpperCase(),
              odometer: int.tryParse(_odometer.text.trim()) ?? 0,
              year: int.tryParse(_year.text.trim()),
              color: _color.text.trim().isEmpty ? null : _color.text.trim(),
              engineType: _engineType,
            ),
            serviceRequest: _serviceRequest.text.trim(),
            priority: _priority,
            byUser: user.name,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobsBloc, JobsState>(
      listenWhen: (a, b) => a.noticeId != b.noticeId,
      listener: (context, state) {
        if (_submitting) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.notice ?? 'Job created.')),
            );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('New service job')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionHeader('Customer'),
              _field(_ownerName, 'Owner name', Icons.person_outline,
                  required: true),
              const SizedBox(height: 12),
              _field(_contact, 'Contact number', Icons.phone_outlined,
                  keyboard: TextInputType.phone, required: true),
              const SizedBox(height: 22),
              const SectionHeader('Motorcycle'),
              Row(
                children: [
                  Expanded(
                    child: _field(_make, 'Make', Icons.two_wheeler_outlined,
                        required: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(_model, 'Model', Icons.motorcycle_outlined,
                        required: true),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field(_registration, 'Registration number',
                  Icons.confirmation_number_outlined,
                  required: true,
                  textCapitalization: TextCapitalization.characters),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _field(_odometer, 'Odometer (km)', Icons.speed,
                        keyboard: TextInputType.number,
                        required: true,
                        digitsOnly: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(_year, 'Year', Icons.event_outlined,
                        keyboard: TextInputType.number, digitsOnly: true),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field(_color, 'Colour (optional)', Icons.palette_outlined),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _engineType,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Engine type',
                  prefixIcon: Icon(Icons.settings_suggest_outlined),
                ),
                hint: const Text('Select engine type'),
                items: [
                  for (final t in kEngineTypes)
                    DropdownMenuItem(value: t, child: Text(t)),
                ],
                onChanged: (v) => setState(() => _engineType = v),
              ),
              const SizedBox(height: 22),
              const SectionHeader('Service request'),
              _field(
                _serviceRequest,
                'What needs attention?',
                Icons.notes_outlined,
                required: true,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  value: _priority,
                  onChanged: (v) => setState(() => _priority = v),
                  activeThumbColor: AppColors.brandOrange,
                  title: const Text('Mark as priority',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Shows at the top of the board'),
                  secondary: const Icon(Icons.flag_outlined,
                      color: AppColors.danger),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
                  label:
                      Text(_submitting ? 'Saving…' : 'Create job (Received)'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    TextInputType? keyboard,
    int maxLines = 1,
    bool digitsOnly = false,
    TextCapitalization textCapitalization = TextCapitalization.words,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      inputFormatters:
          digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        alignLabelWithHint: maxLines > 1,
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }
}
