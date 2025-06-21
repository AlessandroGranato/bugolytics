// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bugolytics/application/providers/device_storage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddDevice extends ConsumerStatefulWidget {
  const AddDevice({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddDeviceState();
}

class _AddDeviceState extends ConsumerState<AddDevice> {
  final _formKey = GlobalKey<FormState>();
  String? _deviceIdentifier;
  var _isLoading = false;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });
    
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    _formKey.currentState!.save();
    await ref
        .read(deviceStorageProvider.notifier)
        .saveDeviceIdentifier(_deviceIdentifier!);
    
    setState(() {
      _isLoading = true;
    });
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              maxLength: 20,
              decoration: const InputDecoration(
                label: Text('Title'),
              ),
              validator: (value) {
                if (value == null) {
                  return 'Device identifier cannot be null';
                }
                return null;
              },
              onSaved: (newValue) => _deviceIdentifier = newValue!,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? Transform.scale(
                          scale: 0.75,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                            strokeWidth: 3.0,
                          ),
                        )
                      : const Text('Save device'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
