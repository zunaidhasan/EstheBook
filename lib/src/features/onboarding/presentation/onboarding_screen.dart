import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/app_providers.dart';
import '../../../core/theme/eb_theme.dart';

/// First-run welcome screen (reachable at /onboarding).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _enter() {
    final name = _nameController.text.trim();
    ref.read(sessionProvider.notifier).completeOnboarding(name.isEmpty ? 'there' : name);
    context.go('/discover');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EbColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: EbColors.blush,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: EbShadows.soft,
                ),
                child: const Center(child: Text('🌸', style: TextStyle(fontSize: 44))),
              ),
              const SizedBox(height: 28),
              const Text('Welcome to EstheBook', style: EbTextStyles.h1, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                'Discover premium aesthetic clinics, compare treatments with transparent pricing, and book in three taps.',
                style: EbTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'What should we call you?',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                onSubmitted: (_) => _enter(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _enter,
                  child: const Text('Start exploring'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
