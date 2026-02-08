import 'package:flutter/material.dart';
import '../../../services/libre_credentials_service.dart';
import '../../../services/libre_service.dart';

class LibreSettingsScreen extends StatefulWidget {
  const LibreSettingsScreen({super.key});

  @override
  State<LibreSettingsScreen> createState() => _LibreSettingsScreenState();
}

class _LibreSettingsScreenState extends State<LibreSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isTestingConnection = false;
  bool _hasExistingCredentials = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadExistingCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingCredentials() async {
    setState(() => _isLoading = true);

    final credentials = await LibreCredentialsService.getCredentials();

    if (credentials != null) {
      setState(() {
        _emailController.text = credentials.email;
        _passwordController.text = credentials.password;
        _hasExistingCredentials = true;
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveCredentials() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await LibreCredentialsService.saveCredentials(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('LibreLinkUp credentials saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _hasExistingCredentials = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving credentials: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isTestingConnection = true);

    try {
      final result = await LibreService.testConnection(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isTestingConnection = false);
    }
  }

  Future<void> _deleteCredentials() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete LibreLinkUp Credentials'),
        content: const Text(
          'Are you sure you want to delete your saved LibreLinkUp login credentials?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await LibreCredentialsService.deleteCredentials();

      if (mounted) {
        setState(() {
          _emailController.clear();
          _passwordController.clear();
          _hasExistingCredentials = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('LibreLinkUp credentials deleted'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LibreLinkUp Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Information',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Enter your LibreLinkUp account credentials. '
                              'This is the account you use in the LibreLinkUp app to follow someone\'s glucose data. '
                              'Your data is stored securely on your device.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Setup Requirements',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '1. The sensor wearer must share their data via the FreeStyle Libre app\n'
                              '2. You must accept the invitation in the LibreLinkUp app\n'
                              '3. Use the same email and password you use in LibreLinkUp',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_hasExistingCredentials)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'LibreLinkUp account is connected',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your LibreLinkUp email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your LibreLinkUp password',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(
                                () => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: _isTestingConnection ? null : _testConnection,
                      icon: _isTestingConnection
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.wifi_tethering),
                      label: Text(
                        _isTestingConnection ? 'Testing...' : 'Test Connection',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveCredentials,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Credentials'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_hasExistingCredentials)
                      TextButton.icon(
                        onPressed: _deleteCredentials,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete Saved Credentials'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
