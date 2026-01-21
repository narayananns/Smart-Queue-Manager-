import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:flutter_facebook_auth/flutter_facebook_auth.dart";
import "package:email_otp/email_otp.dart";

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isOtpSent = false;
  bool _isEmailVerified = false;
  bool _isSendingOtp = false; // Loading state variable

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: h * 0.4,
            child: Container(
              color: Colors.deepPurple,
              child: Center(
                child: Text(
                  "Create Account!\n Join Us Today",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: h * 0.03,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: h * 0.7,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Sign Up to Get Started",
                        style: TextStyle(
                          fontSize: h * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Enter Your Details",
                        style: TextStyle(
                          fontSize: h * 0.02,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: h * 0.02),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: "Username",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      SizedBox(height: h * 0.015),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: _isEmailVerified,
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.email),
                          suffixIcon: _isEmailVerified
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : _isSendingOtp
                              ? Transform.scale(
                                  scale: 0.5,
                                  child: const CircularProgressIndicator(),
                                )
                              : TextButton(
                                  onPressed: () async {
                                    if (_emailController.text.isEmpty) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Enter email first"),
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    setState(() {
                                      _isSendingOtp = true;
                                    });

                                    EmailOTP.config(
                                      appName: "Smart Queue Manager",
                                      otpType: OTPType.numeric,
                                      emailTheme: EmailTheme.v1,
                                      otpLength: 6,
                                    );

                                    final bool result = await EmailOTP.sendOTP(
                                      email: _emailController.text,
                                    );
                                    if (!context.mounted) return;

                                    setState(() {
                                      _isSendingOtp = false;
                                    });

                                    if (result) {
                                      setState(() {
                                        _isOtpSent = true;
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("OTP Sent!"),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Failed to send OTP"),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text("Verify"),
                                ),
                        ),
                      ),
                      if (_isOtpSent && !_isEmailVerified) ...[
                        SizedBox(height: h * 0.015),
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          onChanged: (val) async {
                            if (val.length == 6) {
                              if (EmailOTP.verifyOTP(otp: val) == true) {
                                setState(() {
                                  _isEmailVerified = true;
                                  _isOtpSent = false;
                                });
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Invalid OTP"),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: "Enter OTP",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.verified_user),
                            counterText: "",
                          ),
                        ),
                      ],
                      if (_isEmailVerified) ...[
                        SizedBox(height: h * 0.015),
                        const TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: "OTP Verified",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.verified_user),
                            suffixIcon: Chip(
                              label: Text(
                                "Verified",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: h * 0.015),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: h * 0.015),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: h * 0.02),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            // Handle signup logic here
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(fontSize: h * 0.025),
                          ),
                        ),
                      ),
                      SizedBox(height: h * 0.02),
                      _buildLoginLink(),
                      SizedBox(height: h * 0.02),
                      _buildDivider(),
                      SizedBox(height: h * 0.02),
                      _buildSocialLogin(),
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

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? "),
        GestureDetector(
          onTap: () {
            Navigator.pop(context); // Go back to Login
          },
          child: const Text(
            "Log In",
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[400])),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text("Or SignUp With"),
        ),
        Expanded(child: Divider(color: Colors.grey[400])),
      ],
    );
  }

  Future<void> _googleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        // Successful login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logged in as ${googleUser.email}')),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google Sign-In Error: $error')));
      }
    }
  }

  Future<void> _facebookLogin() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        // Successful login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged in with Facebook')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Facebook Sign-In Status: ${result.status}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Facebook Sign-In Error: $e')));
      }
    }
  }

  Widget _buildSocialLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google Button
        GestureDetector(
          onTap: _googleLogin,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.google, color: Colors.red),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Facebook Button
        GestureDetector(
          onTap: _facebookLogin,
          child: const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFF1877F2), // Facebook Brand Color
            child: FaIcon(FontAwesomeIcons.facebookF, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
