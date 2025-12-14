import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/main');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade400,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 20),
                          onPressed: () => context.go('/login'),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 20),
                        _buildHeader(),
                        const SizedBox(height: 40),
                        _buildForm(),
                        const SizedBox(height: 24),
                        _buildTermsCheckbox(),
                        const SizedBox(height: 32),
                        _buildSignUpButton(),
                        const SizedBox(height: 24),
                        _buildDivider(),
                        const SizedBox(height: 24),
                        _buildSocialButtons(),
                        const SizedBox(height: 32),
                        _buildLoginLink(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C5CE7).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 24),
        const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign up to get started',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          hint: 'Enter your email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Email is required';
            if (!value!.contains('@')) return 'Enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _usernameController,
          label: 'Username',
          hint: 'Choose a username',
          icon: Icons.alternate_email,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Username is required';
            if (value!.length < 3) return 'Username must be at least 3 characters';
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Create a strong password',
          icon: Icons.lock_outline,
          isPassword: true,
          obscureText: _obscurePassword,
          onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Password is required';
            if (value!.length < 6) return 'Password must be at least 6 characters';
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          hint: 'Re-enter your password',
          icon: Icons.lock_outline,
          isPassword: true,
          obscureText: _obscureConfirmPassword,
          onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please confirm your password';
            if (value != _passwordController.text) return 'Passwords do not match';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: isTablet ? 15 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: isPassword && obscureText,
                validator: validator,
                style: TextStyle(fontSize: isTablet ? 18 : 16),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: isTablet ? 18 : 16,
                  ),
                  prefixIcon: Icon(
                    icon, 
                    color: const Color(0xFF6C5CE7), 
                    size: isTablet ? 26 : 22,
                  ),
                  suffixIcon: isPassword
                      ? IconButton(
                          icon: Icon(
                            obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: Colors.grey.shade400,
                            size: isTablet ? 26 : 22,
                          ),
                          onPressed: onToggleVisibility,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 20, 
                    vertical: isTablet ? 22 : 18,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) => setState(() => _acceptTerms = value ?? false),
            activeColor: const Color(0xFF6C5CE7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _acceptTerms = !_acceptTerms),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                children: const [
                  TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: Color(0xFF6C5CE7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: Color(0xFF6C5CE7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            return Container(
              width: double.infinity,
              height: isTablet ? 64 : 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                ),
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.4),
                    blurRadius: isTablet ? 25 : 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLoading ? null : _register,
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            height: isTablet ? 28 : 24,
                            width: isTablet ? 28 : 24,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        _buildSocialButton(
          label: 'Continue with Google',
          icon: Icons.g_mobiledata,
          onPressed: _registerWithGoogle,
          colors: [Colors.white, Colors.white],
          textColor: const Color(0xFF2D3436),
          borderColor: Colors.grey.shade300,
        ),
        const SizedBox(height: 12),
        _buildSocialButton(
          label: 'Continue with Apple',
          icon: Icons.apple,
          onPressed: _registerWithApple,
          colors: [const Color(0xFF000000), const Color(0xFF000000)],
          textColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required List<Color> colors,
    required Color textColor,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null ? Border.all(color: borderColor) : null,
        boxShadow: borderColor == null
            ? [
                BoxShadow(
                  color: colors[0].withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/login'),
          child: const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF6C5CE7),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  void _register() {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      context.read<AuthBloc>().add(RegisterRequested(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
      ));
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms and conditions')),
      );
    }
  }

  void _registerWithGoogle() {
    // Implement Google registration
  }

  void _registerWithApple() {
    // Implement Apple registration
  }
}