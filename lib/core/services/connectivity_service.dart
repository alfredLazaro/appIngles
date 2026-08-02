import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  final InternetConnection _connection = InternetConnection();

  Future<bool> hasInternet() => _connection.hasInternetAccess;
}
