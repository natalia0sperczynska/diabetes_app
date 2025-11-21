import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/dexcom_api/dexcom_home.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _codeController = TextEditingController();
  bool _isAuthLaunched = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dexcomHome = context.watch<DexcomHome>();

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dexcomHome.welcomeMessage,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 30),

              if (dexcomHome.isLoading) const CircularProgressIndicator(),

              if (dexcomHome.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    dexcomHome.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 30),

              if (!_isAuthLaunched && dexcomHome.dexcomValues.isEmpty)
                FilledButton.icon(
                  onPressed: dexcomHome.isLoading
                      ? null
                      : () async {
                    await dexcomHome.launchDexcomAuth();
                    setState(() {
                      _isAuthLaunched = true;
                    });
                  },
                  icon: const Icon(Icons.login),
                  label: const Text("1. Launch Dexcom Login"),
                ),

              if (_isAuthLaunched && dexcomHome.dexcomValues.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "Redirected to GitHub Page. Copy the 'code' from the browser URL.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),

              if (_isAuthLaunched && dexcomHome.dexcomValues.isEmpty) ...[
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: "Paste Authorization Code",
                    border: OutlineInputBorder(),
                    helperText: "Example code segment: ?code=XYZ123...",
                  ),
                  enabled: !dexcomHome.isLoading,
                ),
                const SizedBox(height: 20),

                FilledButton.icon(
                  onPressed: dexcomHome.isLoading
                      ? null
                      : () {
                    dexcomHome.loadDexcomData(_codeController.text.trim());
                  },
                  icon: const Icon(Icons.cloud_download),
                  label: const Text("2. Submit Code & Get Data"),
                ),
              ],

              const SizedBox(height: 30),

              if (dexcomHome.dexcomValues.isNotEmpty)
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: dexcomHome.dexcomValues.length,
                    itemBuilder: (context, index) {
                      final value = dexcomHome.dexcomValues[index];
                      final time = dexcomHome.dexcomTimes[index];
                      return ListTile(
                        leading: const Icon(Icons.medical_services_outlined, color: Colors.green),
                        title: Text("Glucose: $value mg/dL"),
                        subtitle: Text(time.toLocal().toString()),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}