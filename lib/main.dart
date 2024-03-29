import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get_ip_address/get_ip_address.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    /// Initialize Ip Address
    var ipAddress = IpAddress(type: RequestType.json);

    /// Get the IpAddress based on requestType.
    dynamic data = await ipAddress.getIpAddress();
    print(data.toString());
    runApp(App(
      ipAddress: data,
    ));
  } on IpAddressException catch (exception) {
    /// Handle the exception.
    print(exception.message);
  }

  // runApp(const MyApp());
}
class App extends StatelessWidget {
  dynamic ipAddress;
  App({super.key, required this.ipAddress});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(ipAddress.toString()),
        ),
      ),
    );
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Referral App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String referralLink = "No referral link yet";

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
  }

  Future<void> initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink.listen((event) {
      // Handle dynamic link data
      handleDynamicLink(event);
    }).onError((e) {
      // Handle error
      log("Error processing dynamic link: ${e.message}");
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (data != null) {
      // Handle initial link data
      handleDynamicLink(data);
    }
  }

  void handleDynamicLink(PendingDynamicLinkData dynamicLink) {
    final Uri deepLink = dynamicLink.link;

    // Extract referral parameters or any other relevant data
    // For example, you could use deepLink.queryParameters to get custom referral data
    String? referralParameter = deepLink.queryParameters['referral'];

    // Navigate to the appropriate screen based on the referral parameters
    navigateToReferralScreen(referralParameter);
  }

  void navigateToReferralScreen(String? referralParameter) {
    // Implement navigation logic to the referral screen
    // For simplicity, we'll just print the parameter for demonstration purposes
    print("Navigating to referral screen with parameter: $referralParameter");
  }

  String createReferralLink() {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://com.example.flutter_dynamic_link',
      link: Uri.parse('https://com.example.flutter_dynamic_link/referral?referral=12345'),
      androidParameters: const AndroidParameters(
        packageName: 'com.example.flutter_dynamic_link',
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.example.flutterDynamicLink',
        appStoreId: '123456789',
      ),
    );

    final Uri dynamicUrl = parameters.link;
    return dynamicUrl.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Referral Link:',
            ),
            Text(
              referralLink,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String newReferralLink = createReferralLink();
                setState(() {
                  referralLink = newReferralLink;
                });
              },
              child: const Text('Generate Referral Link'),
            ),
          ],
        ),
      ),
    );
  }
}
