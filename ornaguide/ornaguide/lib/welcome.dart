import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'signup.dart';
import 'login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins', // Using a modern font
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF0E9B81),
          brightness: Brightness.light,
        ),
      ),
      home: WelcomePage(),
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isArabic = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLanguage() {
    setState(() {
      _isArabic = !_isArabic;
    });
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Translation map
    final Map<String, Map<String, String>> translations = {
      'en': {
        'welcome': 'WELCOME',
        'tagline': 'Begin your journey with us',
        'login': 'LOG IN',
        'noAccount': "Don't have an account?",
        'signup': 'Sign Up',
      },
      'ar': {
        'welcome': 'أهلاً بك',
        'tagline': 'ابدأ رحلتك معنا',
        'login': 'تسجيل الدخول',
        'noAccount': 'ليس لديك حساب؟',
        'signup': 'إنشاء حساب',
      }
    };

    // Current language
    final String lang = _isArabic ? 'ar' : 'en';
    final TextDirection textDirection = _isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Dark Overlay
          Container(
            height: screenHeight,
            width: screenWidth,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://i.imgur.com/QAK9tm3.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradient Overlay for better text visibility
          Container(
            height: screenHeight,
            width: screenWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Language Toggle Button - keeping position fixed at the top left
          Positioned(
            top: 40,
            left: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.language,
                          color: Colors.white,
                          size: 24,
                        ),
                        Positioned(
                          bottom: 0,
                          child: Text(
                            _isArabic ? 'EN' : 'AR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: _toggleLanguage,
                    tooltip: _isArabic ? 'Switch to English' : 'التبديل إلى العربية',
                  ),
                ),
              ),
            ),
          ),

          // Animated Content
          FadeTransition(
            opacity: _fadeInAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SafeArea(
                child: Center(
                  child: Directionality(
                    textDirection: textDirection,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: screenHeight * 0.05),

                            // Logo with drop shadow
                            Container(
                              height: 220,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 15,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.network(
                                  'https://i.imgur.com/Ki3imCv.png',
                                  height: 220,
                                ),
                              ),
                            ),

                            SizedBox(height: 40),

                            // Welcome Text with Subtle Animation - Making Arabic text size equal to English
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  Colors.white,
                                  Color(0xFF0E9B81).withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: Text(
                                translations[lang]!['welcome']!,
                                style: TextStyle(
                                  fontSize: 42, // Same size for both languages
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: _isArabic ? 0 : 3.0,
                                  color: Colors.white,
                                  fontFamily: _isArabic ? 'Tajawal' : 'Poppins',
                                ),
                              ),
                            ),

                            SizedBox(height: 20),

                            // Brief tagline
                            Text(
                              translations[lang]!['tagline']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: _isArabic ? 0 : 0.5,
                                fontFamily: _isArabic ? 'Tajawal' : 'Poppins',
                              ),
                            ),

                            SizedBox(height: 60),

                            // Login Button with Glassmorphism effect
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF0E9B81).withOpacity(0.8),
                                        Color(0xFF0E9B81),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF0E9B81).withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) =>
                                                LoginPage(),
                                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                              // Simple bottom-to-top animation without fade
                                              var begin = Offset(0.0, 1.0);
                                              var end = Offset.zero;

                                              // Use a custom curve for smoother motion
                                              var curve = Curves.easeOutQuad;

                                              var tween = Tween(begin: begin, end: end).chain(
                                                  CurveTween(curve: curve)
                                              );

                                              return SlideTransition(
                                                position: animation.drive(tween),
                                                child: child,
                                              );
                                            },
                                            // Longer duration for smoother animation
                                            transitionDuration: Duration(milliseconds: 700),
                                          )
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      minimumSize: Size(double.infinity, 56),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (_isArabic)
                                          Icon(
                                            Icons.arrow_back_rounded,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        if (_isArabic) SizedBox(width: 12),
                                        Text(
                                            translations[lang]!['login']!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: _isArabic ? 0 : 1.2,
                                              color: Colors.white,
                                              fontFamily: _isArabic ? 'Tajawal' : 'Poppins',
                                            )
                                        ),
                                        if (!_isArabic) SizedBox(width: 12),
                                        if (!_isArabic)
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 30),

                            // Sign Up Text with improved styling
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  translations[lang]!['noAccount']!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.9),
                                    fontFamily: _isArabic ? 'Tajawal' : 'Poppins',
                                  ),
                                ),
                                SizedBox(width: 5),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) =>
                                              signUpPage(auth: auth),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            // Simple bottom-to-top animation without fade
                                            var begin = Offset(0.0, 1.0);
                                            var end = Offset.zero;

                                            // Use a custom curve for smoother motion
                                            var curve = Curves.easeOutQuad;

                                            var tween = Tween(begin: begin, end: end).chain(
                                                CurveTween(curve: curve)
                                            );

                                            return SlideTransition(
                                              position: animation.drive(tween),
                                              child: child,
                                            );
                                          },
                                          // Longer duration for smoother animation
                                          transitionDuration: Duration(milliseconds: 700),
                                        )
                                    );
                                  },
                                  child: Text(
                                    translations[lang]!['signup']!,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF1AE3A4),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      decorationThickness: 1.5,
                                      fontFamily: _isArabic ? 'Tajawal' : 'Poppins',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
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