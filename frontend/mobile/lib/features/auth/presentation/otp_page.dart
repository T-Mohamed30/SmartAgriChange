import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String phone;
  const OtpPage({super.key, required this.phone});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final otpController = TextEditingController();

  void _verifyOtp() async {
    final success = await ref.read(verifyOtpProvider).call(widget.phone, otpController.text);
    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP incorrect')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text('Vérification OTP', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text('Un code a été envoyé au ${widget.phone}'),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Code OTP'),
              ),
              ElevatedButton(onPressed: _verifyOtp, child: const Text("Valider")),
            ],
          ),
        ),
      ),
    );
  }
}