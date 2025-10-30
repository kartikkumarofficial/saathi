import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/user_model.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/homescreen.dart';
import '../presentation/screens/main_scaffold.dart';

class AuthController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Observable user model
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  // Text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// -------------------- SIGN UP --------------------
  Future<void> signUp() async {
    isLoading.value = true;
    try {
      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user == null) {
        throw 'Sign up failed. Please try again.';
      }

      await supabase.from('users').insert({
        'id': response.user!.id,
        'email': emailController.text.trim(),
        'full_name': nameController.text.trim(),
        'profile_image':
        'https://api.dicebear.com/6.x/pixel-art/png?seed=${emailController.text.trim()}',
      });

      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      Get.offAll(() => HomePage());
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// -------------------- LOGIN --------------------
  Future<void> logIn() async {
    isLoading.value = true;
    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user == null) throw 'Login failed. Invalid credentials.';

      emailController.clear();
      passwordController.clear();

      await fetchUserAndNavigate(response.user!.id);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// -------------------- FETCH USER --------------------
  Future<void> fetchUserAndNavigate(String userId) async {
    try {
      print('[DEBUG] Fetching user data for ID: $userId');

      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      print('[DEBUG] Supabase response: $response');

      user.value = UserModel.fromJson(response);

      Get.offAll(() => MainScaffold());
    } catch (e) {
      print('[ERROR] fetchUserAndNavigate failed: $e');
      Get.snackbar(
        'Error',
        'Could not retrieve user details. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.offAll(() => const LoginScreen());
    }
  }

  /// -------------------- GOOGLE SIGN IN --------------------
  Future<void> signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback/',
      );

      supabase.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        if (session != null) {
          print("✅ Google sign-in success: ${session.user.id}");
          await insertUserIfNew(session.user);
          await fetchUserAndNavigate(session.user.id);
        }
      });
    } catch (e) {
      print('❌ Error signing in: $e');
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// -------------------- INSERT USER IF NEW --------------------
  Future<void> insertUserIfNew(User user) async {
    final existing = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (existing == null) {
      await supabase.from('users').insert({
        'id': user.id,
        'email': user.email,
        'full_name': user.userMetadata?['full_name'] ?? 'Anonymous',
        'profile_image': user.userMetadata?['avatar_url'] ??
            'https://api.dicebear.com/6.x/pixel-art/png?seed=${user.email}',
      });
    }
  }

  /// -------------------- LOGOUT --------------------
  Future<void> logOut() async {
    try {
      isLoading.value = true;
      await supabase.auth.signOut();
      print('✅ User signed out successfully');
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      print('❌ Error signing out: $e');
      Get.snackbar(
        'Logout Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
