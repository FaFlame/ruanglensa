import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController regEmailController = TextEditingController();
  final TextEditingController regPasswordController = TextEditingController();
  final PageController _pageController = PageController(initialPage: 0);

  int _pageIndex = 0;
  bool _remember = false;
  bool _regAccepted = false;
  bool _isLoading = false;

  // validation states
  bool _loginEmailError = false;
  bool _loginPasswordError = false;
  bool _regEmailError = false;
  bool _regPasswordError = false;

  // hint texts
  String _emailHint = 'Email';
  String _passwordHint = 'Password';

  static const Color _errorBorderColor = Color(0xFFFF2C2C);
  static const Color _errorPlaceholderColor = Color(0xFFEE6B6E);

  // ── Ganti dengan email admin yang terdaftar di Firebase Auth ──
  static const String _adminEmail = 'adminrl@gmail.com';

  @override
  void initState() {
    super.initState();
    regEmailController.addListener(_onRegChanged);
    regPasswordController.addListener(_onRegChanged);
    emailController.addListener(_onLoginChanged);
    passwordController.addListener(_onLoginChanged);
  }

  void _onRegChanged() {
    if (!mounted) return;
    if (regEmailController.text.trim().isNotEmpty) _regEmailError = false;
    if (regPasswordController.text.trim().isNotEmpty) _regPasswordError = false;
    setState(() {});
  }

  void _onLoginChanged() {
    if (!mounted) return;
    if (emailController.text.trim().isNotEmpty) {
      _loginEmailError = false;
      _emailHint = 'Email';
    }
    if (passwordController.text.trim().isNotEmpty) {
      _loginPasswordError = false;
      _passwordHint = 'Password';
    }
    setState(() {});
  }

  //  LOGIN  →  Firebase Auth langsung pakai email
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        if (email.isEmpty) {
          _loginEmailError = true;
          _emailHint = 'Please enter your email';
        }
        if (password.isEmpty) {
          _loginPasswordError = true;
          _passwordHint = 'Please enter your password';
        }
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null || !mounted) return;

      // Cek role dari Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final role = doc.data()?['role'] ?? 'user';

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('LOGIN ERROR CODE: ${e.code} | MSG: ${e.message}');
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _loginEmailError = true;
            emailController.clear();
            _emailHint = 'Email not found';
            break;
          case 'wrong-password':
          case 'invalid-credential':
            _loginPasswordError = true;
            passwordController.clear();
            _passwordHint = 'Incorrect Password';
            break;
          case 'invalid-email':
            _loginEmailError = true;
            emailController.clear();
            _emailHint = 'Invalid email format';
            break;
          case 'user-disabled':
            _loginEmailError = true;
            emailController.clear();
            _emailHint = 'Account disabled';
            break;
          case 'too-many-requests':
            _loginPasswordError = true;
            _passwordHint = 'Too many attempts, try later';
            break;
          default:
            _loginEmailError = true;
            _loginPasswordError = true;
            emailController.clear();
            passwordController.clear();
            _emailHint = 'Incorrect Email';
            _passwordHint = 'Incorrect Password';
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login gagal: ${e.message}')));
      }
    } catch (e) {
      print('LOGIN ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  //  REGISTER  →  Firebase Auth  →  simpan ke Firestore

  Future<void> register() async {
    final email = regEmailController.text.trim();
    final password = regPasswordController.text.trim();

    bool hasError = false;
    if (email.isEmpty) {
      _regEmailError = true;
      hasError = true;
    }
    if (password.isEmpty) {
      _regPasswordError = true;
      hasError = true;
    }
    if (!_regAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept Terms and Conditions')),
      );
      hasError = true;
    }
    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Buat akun di Firebase Auth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user;
      if (user == null) return;

      // Simpan data awal ke Firestore — profil lengkap diisi nanti di halaman profil
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': email,
        'username': '',
        'nama': '',
        'bio': '',
        'alamat': '',
        'no_telp': '',
        'tgl_lahir': null,
        'foto_profil': '',
        'role': 'user',
        'level': 1,
        'level_points': 0,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful, please imput login again'),
        ),
      );

      // Bersihkan form & arahkan ke tab Login
      regEmailController.clear();
      regPasswordController.clear();
      setState(() {
        _regAccepted = false;
        _regEmailError = false;
        _regPasswordError = false;
      });

      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } on FirebaseAuthException catch (e) {
      print('REGISTER ERROR CODE: ${e.code} | MSG: ${e.message}');
      String msg = 'Registrasi gagal';
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'Email sudah terdaftar';
          _regEmailError = true;
          regEmailController.clear();
          break;
        case 'invalid-email':
          msg = 'Format email tidak valid';
          _regEmailError = true;
          regEmailController.clear();
          break;
        case 'weak-password':
          msg = 'Password terlalu lemah (min. 6 karakter)';
          _regPasswordError = true;
          regPasswordController.clear();
          break;
        default:
          msg = e.message ?? msg;
      }
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  //  TEXT FIELD BUILDER

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscure = false,
    bool error = false,
    TextInputType? keyboardType,
  }) {
    final hintLower = hint.toLowerCase();
    final bool effectiveError =
        error ||
        hintLower.contains('incorrect') ||
        hintLower.contains('please enter') ||
        hintLower.contains('invalid') ||
        hintLower.contains('not found') ||
        hintLower.contains('disabled') ||
        hintLower.contains('attempts');

    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: effectiveError ? _errorPlaceholderColor : null,
          fontWeight: effectiveError ? FontWeight.w600 : null,
        ),
        prefixIcon: icon != null
            ? Icon(
                icon,
                color: effectiveError
                    ? _errorBorderColor
                    : Colors.grey.shade600,
              )
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
            color: effectiveError ? _errorBorderColor : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(
            color: effectiveError ? _errorBorderColor : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    regEmailController.dispose();
    regPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

   
  //  BUILD
   
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
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Segmented tab Login / Register ──
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
                                  top: 0,
                                  bottom: 0,
                                  width: segWidth / 2 - 24,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF021427),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: const [
                                        BoxShadow(
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

                      const SizedBox(height: 8),

                      // ── Form PageView ──
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: bottomInset > 0 ? 180 : 220,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (i) => setState(() => _pageIndex = i),
                          children: [
                            // ── Login Form ──
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField(
                                  controller: emailController,
                                  hint: _emailHint,
                                  icon: Icons.email_outlined,
                                  error: _loginEmailError,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 10),
                                _buildTextField(
                                  controller: passwordController,
                                  hint: _passwordHint,
                                  icon: Icons.lock_outline,
                                  obscure: true,
                                  error: _loginPasswordError,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Checkbox(
                                      value: _remember,
                                      tristate: false,
                                      checkColor: Colors.white,
                                      fillColor:
                                          WidgetStateProperty.resolveWith<
                                            Color?
                                          >(
                                            (states) =>
                                                states.contains(
                                                  WidgetState.selected,
                                                )
                                                ? const Color(0xFF011229)
                                                : null,
                                          ),
                                      onChanged: (v) => setState(
                                        () => _remember = v ?? false,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text('Remember me'),
                                    const Spacer(),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        foregroundColor: const Color(
                                          0xFF003A87,
                                        ),
                                      ),
                                      onPressed: () async {
                                        final emailCtrl =
                                            TextEditingController();
                                        await showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Reset Password'),
                                            content: TextField(
                                              controller: emailCtrl,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              decoration: const InputDecoration(
                                                hintText: 'Masukkan email kamu',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text('Batal'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  final e = emailCtrl.text
                                                      .trim();
                                                  if (e.isEmpty) return;
                                                  Navigator.pop(ctx);
                                                  try {
                                                    await FirebaseAuth.instance
                                                        .sendPasswordResetEmail(
                                                          email: e,
                                                        );
                                                    if (mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Email reset password telah dikirim',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  } on FirebaseAuthException catch (
                                                    err
                                                  ) {
                                                    if (mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            err.message ??
                                                                'Gagal kirim email reset',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: const Text('Kirim'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: const Text('Forgot Password?'),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // ── Register Form ──
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField(
                                  controller: regEmailController,
                                  hint: 'Insert your email',
                                  icon: Icons.email_outlined,
                                  error: _regEmailError,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: regPasswordController,
                                  hint: 'Insert your password',
                                  icon: Icons.lock_outline,
                                  obscure: true,
                                  error: _regPasswordError,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Checkbox(
                                      value: _regAccepted,
                                      tristate: false,
                                      checkColor: Colors.white,
                                      fillColor:
                                          WidgetStateProperty.resolveWith<
                                            Color?
                                          >(
                                            (states) =>
                                                states.contains(
                                                  WidgetState.selected,
                                                )
                                                ? const Color(0xFF011229)
                                                : null,
                                          ),
                                      onChanged: (v) => setState(
                                        () => _regAccepted = v ?? false,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'I acknowledge and accept the Terms and Conditions',
                                        style: TextStyle(
                                          color: _regAccepted
                                              ? const Color(0xFF011229)
                                              : const Color(0xFFA7A9AD),
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

                      const SizedBox(height: 6),

                      // ── Action Button ──
                      Builder(
                        builder: (context) {
                          final bool isRegisterEnabled = _pageIndex == 1
                              ? regEmailController.text.trim().isNotEmpty &&
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
                                  if (_pageIndex == 1) {
                                    return isRegisterEnabled
                                        ? const Color(0xFF021427)
                                        : Colors.grey.shade400;
                                  }
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
                              onPressed: _isLoading
                                  ? null
                                  : (_pageIndex == 0
                                        ? login
                                        : (isRegisterEnabled
                                              ? register
                                              : null)),
                              style: btnStyle,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
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
