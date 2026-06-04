import 'package:go_router/go_router.dart';
import 'package:tracker_flutter/presentation/auth/login_screen.dart';
import 'package:tracker_flutter/presentation/dashboard/dashboard_screen.dart';
import 'package:tracker_flutter/presentation/fuel/add_fuel_screen.dart';
import 'package:tracker_flutter/presentation/fuel/fuel_screen.dart';
import 'package:tracker_flutter/presentation/maintenance/add_maintenance_screen.dart';
import 'package:tracker_flutter/presentation/maintenance/maintenance_screen.dart';
import 'package:tracker_flutter/presentation/vehicles/add_vehicle_screen.dart';
import 'package:tracker_flutter/presentation/vehicles/vehicles_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/vehicles', builder: (context, state) => const VehiclesScreen()),
    GoRoute(path: '/vehicles/add', builder: (context, state) => const AddVehicleScreen()),
    GoRoute(path: '/fuel', builder: (context, state) => const FuelScreen()),
    GoRoute(path: '/fuel/add', builder: (context, state) => const AddFuelScreen()),
    GoRoute(path: '/maintenance', builder: (context, state) => const MaintenanceScreen()),
    GoRoute(path: '/maintenance/add', builder: (context, state) => const AddMaintenanceScreen()),
    GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
  ],
);
