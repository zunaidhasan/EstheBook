import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/booking/presentation/booking_flow_screen.dart';
import '../../features/booking/presentation/booking_success_screen.dart';
import '../../features/bookings_dashboard/presentation/bookings_dashboard_screen.dart';
import '../../features/clinics/presentation/clinic_profile_screen.dart';
import '../../features/discovery/presentation/discovery_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/shell/eb_shell.dart';

/// Route names for typed navigation.
const String routeOnboarding = 'onboarding';
const String routeDiscovery = 'discovery';
const String routeClinicProfile = 'clinic';
const String routeBookingFlow = 'booking';
const String routeBookingSuccess = 'booking-success';
const String routeBookingsDashboard = 'bookings';

final ebRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/discover',
    routes: [
      GoRoute(
        path: '/onboarding',
        name: routeOnboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => EbShell(child: child),
        routes: [
          GoRoute(
            path: '/discover',
            name: routeDiscovery,
            builder: (context, state) => const DiscoveryScreen(),
            routes: [
              GoRoute(
                path: 'clinic/:id',
                name: routeClinicProfile,
                builder: (context, state) => ClinicProfileScreen(
                  clinicId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'book',
                    name: routeBookingFlow,
                    builder: (context, state) => BookingFlowScreen(
                      clinicId: state.pathParameters['id']!,
                      preselectedTreatmentId: state.uri.queryParameters['treatment'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/bookings',
            name: routeBookingsDashboard,
            builder: (context, state) => const BookingsDashboardScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/booking/success',
        name: routeBookingSuccess,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return BookingSuccessScreen(
            appointmentId: extra?['appointmentId'] as String?,
          );
        },
      ),
    ],
  );
});
