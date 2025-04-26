// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

enum AuthFormFieldType { EMAIL, USERNAME, PASSWORD }

class AuthFormField extends StatelessWidget {
  const AuthFormField({
    super.key,
    required this.icon,
    required this.fieldName,
    this.controller,
    this.validator,
    required this.onSaved,
    required this.authFormFieldType,
  });

  final Icon icon;
  final String fieldName;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final AuthFormFieldType authFormFieldType;

  @override
  Widget build(BuildContext context) {
    var keyboardType = switch (authFormFieldType) {
      AuthFormFieldType.EMAIL => TextInputType.emailAddress,
      _ => TextInputType.text,
    };
    return Container(
      height: 50,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.onPrimary,
              Theme.of(context).colorScheme.onPrimary.withOpacity(0.1)
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(
            color: Colors.transparent,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  label: Text(fieldName),
                ),
                obscureText: authFormFieldType == AuthFormFieldType.PASSWORD ? true : false,
                validator: validator,
                onSaved: onSaved,
                keyboardType: keyboardType,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
