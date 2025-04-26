import 'package:bugolytics/application/providers/auth_service_provider.dart';
import 'package:bugolytics/application/widgets/auth_form_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return AuthScreenState();
  }
}

class AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _isLoading = false;

  var _usernameEntered = '';
  var _passwordEntered = '';
  var _emailEntered = '';
  var _confirmPasswordEntered = '';

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _switchMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void submit(AuthService authService) async {
    setState(() {
      _isLoading = true;
    });
    print(_formKey.currentState!.validate());
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    _formKey.currentState!.save();
    print(_usernameEntered);
    print(_passwordEntered);
    print(_emailEntered);
    print(_confirmPasswordEntered);
    try {
      if (_isLogin) {
        await _performLogin(authService, _usernameEntered, _passwordEntered);
      } else {
        await _performRegistration(
            authService, _usernameEntered, _emailEntered, _passwordEntered);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration success. You can login now!'),
              duration: Duration(seconds: 3),
            ),
          );
          setState(() {
            _isLogin = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _performLogin(
      AuthService authService, String username, String password) async {
    await authService.login(username, password);
  }

  Future<void> _performRegistration(AuthService authService, String username,
      String email, String password) async {
    await authService.register(username, email, password, null);
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authServiceProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
          title: const Text("Authentication"),
          backgroundColor: const Color.fromARGB(255, 87, 108, 214),
          foregroundColor: Theme.of(context).colorScheme.onPrimary),
      body: Stack(
        children: [
          Container(
            color: const Color.fromARGB(255, 87, 108, 214),
          ),
          Column(
            children: [
              Expanded(
                flex: 30,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Spacer(
                        flex: 5,
                      ),
                      Text(
                        _isLogin ? 'Welcome back' : 'Register',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge!
                            .copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold),
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                      Text(
                        _isLogin
                            ? 'Login into your account'
                            : 'Create your account',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      const Spacer(
                        flex: 2,
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 45,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.15,
                        vertical: screenHeight * 0.01),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AuthFormField(
                            authFormFieldType: AuthFormFieldType.USERNAME,
                            icon: const Icon(Icons.person),
                            fieldName: 'username',
                            validator: (value) {
                              if (value == null || value.trim().length < 4) {
                                return 'Username must be at least 4 characters long';
                              }
                              return null;
                            },
                            onSaved: (newValue) => _usernameEntered = newValue!,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          if (!_isLogin)
                            AuthFormField(
                              authFormFieldType: AuthFormFieldType.EMAIL,
                              icon: const Icon(Icons.email),
                              fieldName: 'email address',
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Insert a valid email address';
                                }
                                return null;
                              },
                              onSaved: (newValue) => _emailEntered = newValue!,
                            ),
                          SizedBox(height: screenHeight * 0.01),
                          AuthFormField(
                            authFormFieldType: AuthFormFieldType.PASSWORD,
                            icon: const Icon(Icons.lock),
                            fieldName: 'password',
                            controller: _passwordController,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long';
                              }
                              return null;
                            },
                            onSaved: (newValue) => _passwordEntered = newValue!,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          if (!_isLogin)
                            AuthFormField(
                              authFormFieldType: AuthFormFieldType.PASSWORD,
                              icon: const Icon(Icons.lock),
                              fieldName: 'confirm password',
                              controller: _confirmPasswordController,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                if (value != _passwordController.text) {
                                  return 'Password mismatch';
                                }
                                return null;
                              },
                              onSaved: (newValue) =>
                                  _confirmPasswordEntered = newValue!,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 25,
                child: Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                submit(authService);
                              },
                        child: _isLoading
                            ? Transform.scale(
                                scale: 0.75,
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                  strokeWidth: 3.0,
                                ),
                              )
                            : Text(_isLogin ? 'LOGIN' : 'REGISTER'),
                      ),
                      RichText(
                        text: TextSpan(
                          text: _isLogin
                              ? 'Don' 't you have an account?  '
                              : 'already have an account?  ',
                          children: [
                            TextSpan(
                                text: _isLogin ? 'Sign up' : 'Login',
                                style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _switchMode();
                                  }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
