import 'package:flutter/material.dart';
import '../../admin/presentation/admin_page.dart';
import '../../user/presentation/user_page.dart';

class LoginPageClean extends StatefulWidget {
  const LoginPageClean({super.key});

  @override
  State<LoginPageClean> createState() => _LoginPageCleanState();
}

class _LoginPageCleanState extends State<LoginPageClean> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController regNameController = TextEditingController();
  final TextEditingController regPasswordController = TextEditingController();
  final PageController _pageController = PageController(initialPage: 0);

  int _pageIndex = 0;
  bool _remember = false;
  bool _regAccepted = false;

  // validation states
  bool _loginError = false;
  bool _loginUsernameError = false;
  bool _loginPasswordError = false;
  bool _regNameError = false;
  bool _regPasswordError = false;

  @override
  void initState() {
    super.initState();
    regNameController.addListener(_onRegChanged);
    regPasswordController.addListener(_onRegChanged);
    emailController.addListener(_onLoginChanged);
    passwordController.addListener(_onLoginChanged);
  }

  void _onRegChanged() {
    if (mounted) {
      if (regNameController.text.trim().isNotEmpty) _regNameError = false;
      if (regPasswordController.text.trim().isNotEmpty)
        _regPasswordError = false;
      setState(() {});
    }
  }

  void _onLoginChanged() {
    if (mounted) {
      if (emailController.text.trim().isNotEmpty) _loginUsernameError = false;
      if (passwordController.text.trim().isNotEmpty)
        _loginPasswordError = false;
      if (_loginError) _loginError = false;
      setState(() {});
    }
  }

  void login() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // basic validation
    _loginUsernameError = email.isEmpty;
    _loginPasswordError = password.isEmpty;
    if (_loginUsernameError || _loginPasswordError) {
      _loginError = true;
      setState(() {});
      return;
    }

    if (email == "admin" && password == "123") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPage()),
      );
    } else if (email == "user" && password == "123") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserPage()),
      );
    } else {
      _loginError = true;
      _loginUsernameError = true;
      _loginPasswordError = true;
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login gagal")));
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscure = false,
    bool error = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: error ? Colors.red : null),
        prefixIcon: icon != null
            ? Icon(icon, color: error ? Colors.red : Colors.grey.shade600)
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(
            color: error ? Colors.red : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(
            color: error ? Colors.red : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    regNameController.dispose();
    regPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bgregislogin.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(color: const Color.fromRGBO(0, 0, 0, 0.4)),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final segWidth = constraints.maxWidth;
                          return Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Stack(
                              children: [
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 250),
                                  left: _pageIndex == 0 ? 6 : segWidth / 2 + 6,
                                  top: 6,
                                  bottom: 6,
                                  width: segWidth / 2 - 24,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF021427),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        const BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.2),
                                          offset: Offset(0, 4),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () =>
                                            _pageController.animateToPage(
                                              0,
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                            ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          child: Text(
                                            'Login',
                                            style: TextStyle(
                                              color: _pageIndex == 0
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () =>
                                            _pageController.animateToPage(
                                              1,
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                            ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          child: Text(
                                            'Register',
                                            style: TextStyle(
                                              color: _pageIndex == 1
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        height: 240,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (i) => setState(() => _pageIndex = i),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField(
                                  controller: emailController,
                                  hint: 'Username',
                                  icon: Icons.person_outline,
                                  error: _loginUsernameError,
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: passwordController,
                                  hint: 'Password',
                                  icon: Icons.lock_outline,
                                  obscure: true,
                                  error: _loginPasswordError,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _remember,
                                      tristate: false,
                                      onChanged: (v) => setState(
                                        () => _remember = v ?? false,
                                      ),
                                    ),
                                    const Text('Remember me'),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text('Forgot Password?'),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField(
                                  controller: regNameController,
                                  hint: 'Create your username',
                                  icon: Icons.person_outline,
                                  error: _regNameError,
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: regPasswordController,
                                  hint: 'Create your password',
                                  icon: Icons.lock_outline,
                                  obscure: true,
                                  error: _regPasswordError,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      value: _regAccepted,
                                      tristate: false,
                                      onChanged: (v) => setState(
                                        () => _regAccepted = v ?? false,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'I acknowledge and accept the Terms and Conditions',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      Builder(
                        builder: (context) {
                          final bool isRegisterEnabled = _pageIndex == 1
                              ? regNameController.text.trim().isNotEmpty &&
                                    regPasswordController.text
                                        .trim()
                                        .isNotEmpty &&
                                    _regAccepted
                              : true;

                          final ButtonStyle btnStyle = ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>((
                                  states,
                                ) {
                                  if (_pageIndex == 1)
                                    return isRegisterEnabled
                                        ? const Color(0xFF021427)
                                        : Colors.grey.shade400;
                                  return const Color(0xFF021427);
                                }),
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 18),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            elevation: WidgetStateProperty.resolveWith<double>(
                              (states) => (isRegisterEnabled || _pageIndex == 0)
                                  ? 8.0
                                  : 0.0,
                            ),
                            shadowColor: WidgetStateProperty.all(
                              const Color.fromRGBO(0, 0, 0, 0.3),
                            ),
                          );

                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _pageIndex == 0
                                  ? login
                                  : (isRegisterEnabled
                                        ? () {
                                            if (regNameController.text
                                                .trim()
                                                .isEmpty)
                                              _regNameError = true;
                                            if (regPasswordController.text
                                                .trim()
                                                .isEmpty)
                                              _regPasswordError = true;
                                            if (!_regAccepted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Please accept Terms',
                                                  ),
                                                ),
                                              );
                                            }
                                            setState(() {});
                                          }
                                        : null),
                              style: btnStyle,
                              child: Text(
                                _pageIndex == 0 ? 'Login' : 'Register',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
