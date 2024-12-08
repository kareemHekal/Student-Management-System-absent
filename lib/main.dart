import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // For checking internet connection
import 'firbase/firebase_options.dart';
import 'homeScreen.dart';
import 'dart:io';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isConnected = false;
  bool _firebaseInitialized = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkConnectionAndFirebase();
  }

  // Function to check Firebase and Internet connection
  Future<void> _checkConnectionAndFirebase() async {
    try {
      // Check network connection type
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        setState(() {
          _isConnected = false;
          _errorMessage = 'No internet connection. Please check your network.';
        });
        return;
      }

      // Confirm actual internet access by pinging a reliable server (like Google)
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        setState(() {
          _isConnected = false;
          _errorMessage = 'No internet connection. Please check your network.';
        });
        return;
      }

      // Firebase is already initialized in the main method
      setState(() {
        _isConnected = true;
        _firebaseInitialized = true;
      });
    } catch (error) {
      setState(() {
        _isConnected = false;
        _errorMessage = 'Failed to check connection or initialize Firebase: $error';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: !_isConnected || !_firebaseInitialized
          ? ConnectionErrorPage(
        errorMessage: _errorMessage.isNotEmpty
            ? _errorMessage
            : 'Checking connection...',
        onRetry: _checkConnectionAndFirebase,
      )
          : const Homescreen(),
    );
  }
}

// Error Page to display when there's no connection or Firebase fails
class ConnectionErrorPage extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ConnectionErrorPage({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Error'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 100,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                errorMessage,
                style: const TextStyle(fontSize: 18, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
