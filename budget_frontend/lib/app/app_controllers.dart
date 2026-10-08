import 'package:budget_frontend/features/auth/controllers/auth_controller.dart';
import 'package:budget_frontend/features/auth/services/mock_auth_service.dart';
import 'package:budget_frontend/features/setup/controllers/setup_controller.dart';

final AuthController authController = AuthController(authService: MockAuthService());
final SetupController setupController = SetupController();
