import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:provider/provider.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'chronometer_view.dart';
import 'barcode_scanner.dart';

class Timekeeping extends StatelessWidget {
  const Timekeeping({Key? key}) : super(key: key);

  Future<bool> _isUserAuthorized(String userId) async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.fetchAndActivate();

      final String authorizedUsersJson =
          remoteConfig.getString('timekeeping_authorized_users');
      print("config: " + authorizedUsersJson);
      final List<String> authorizedUsers = authorizedUsersJson.split(',');

      return authorizedUsers.contains(userId);
    } catch (e) {
      print('Error checking timekeeping authorization: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userResource = Provider.of<UserResource>(context);
    final user = userResource.value;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<bool>(
      future: _isUserAuthorized(user.id.toString()),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data != true) {
          return const SizedBox.shrink();
        }

        return Expanded(
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Времеизмерване',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChronometerView()),
                          );
                        },
                        icon: const Icon(Icons.timer),
                        label: const Text('Хронометър'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const BarcodeScanner()),
                          );
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Отчитане'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
