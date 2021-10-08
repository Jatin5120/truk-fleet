import 'package:truk_fleet/driver/models/driver_model.dart';
import 'package:truk_fleet/models/user_model.dart';

class RegisterInterface {
  void registerUser(DriverModel model) {}
  void registerAgent(UserModel model) {}
  Future<void> registerDriver(DriverModel model) async {}
}
