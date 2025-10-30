import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/user_model.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/main_scaffold.dart';
import '../presentation/screens/role_selection_screen.dart';

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

  // --------------------------------------------------------
  // SIGN UP
  // --------------------------------------------------------
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
        'role': 'wanderer', // default until user picks one
        'profile_image':
        'https://api.dicebear.com/6.x/pixel-art/png?seed=${emailController.text.trim()}',
      });

      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      // go to role selection after signup
      Get.offAll(() => RoleSelectionScreen());
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

  // --------------------------------------------------------
  // LOGIN
  // --------------------------------------------------------
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



  // --------------------------------------------------------
  // UPDATE ROLE
  // --------------------------------------------------------
  Future<void> updateUserRole(String role) async {
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) throw "User not logged in";

      // Update on server first
      final res = await supabase.from('users').update({'role': role}).eq('id', uid);

      // Optionally check res for errors; Supabase client usually throws on error
      // Now update local reactive user immutably using copyWith
      final current = user.value;
      if (current != null) {
        user.value = current.copyWith(role: role);
      } else {
        // If local 'user' not loaded, fetch from Supabase and set
        final fresh = await getUserFromSupabase(uid);
        if (fresh != null) {
          user.value = fresh.copyWith(role: role);
        }
      }
      user.refresh();

      print("✅ Role updated successfully: $role");
    } catch (e) {
      print("❌ Error updating role: $e");
      rethrow;
    }
  }



  // --------------------------------------------------------
  // FETCH USER
  // --------------------------------------------------------
  Future<void> fetchUserAndNavigate(String userId) async {
    try {
      final Map<String, dynamic> response =
      await supabase.from('users').select().eq('id', userId).single() as Map<String, dynamic>;

      user.value = UserModel.fromJson(response);
      user.refresh();

      // Navigate based on role
      if (user.value!.role == null || user.value!.role!.isEmpty) {
        Get.offAll(() => RoleSelectionScreen());
      } else {
        Get.offAll(() => MainScaffold());
      }
    } catch (e) {
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

  Future<UserModel?> getUserFromSupabase(String id) async {
    try {
      final Map<String, dynamic> response =
      await supabase.from('users').select().eq('id', id).single() as Map<String, dynamic>;
      return UserModel.fromJson(response);
    } catch (e) {
      print('[ERROR] getUserFromSupabase: $e');
      return null;
    }
  }


  // --------------------------------------------------------
  // GOOGLE SIGN-IN
  // --------------------------------------------------------
  Future<void> signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback/',
      );

      supabase.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        if (session != null) {
          await insertUserIfNew(session.user);
          await fetchUserAndNavigate(session.user.id);
        }
      });
    } catch (e) {
      Get.snackbar(
        'Error signing in',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // --------------------------------------------------------
  // INSERT USER IF NEW
  // --------------------------------------------------------
  Future<void> insertUserIfNew(User user) async {
    final existing =
    await supabase.from('users').select().eq('id', user.id).maybeSingle();

    if (existing == null) {
      await supabase.from('users').insert({
        'id': user.id,
        'email': user.email,
        'full_name': user.userMetadata?['full_name'] ?? 'Anonymous',
        'role': 'wanderer',
        'profile_image': user.userMetadata?['avatar_url'] ??
            'https://api.dicebear.com/6.x/pixel-art/png?seed=${user.email}',
      });
    }
  }

  // --------------------------------------------------------
  // LOGOUT
  // --------------------------------------------------------
  Future<void> logOut() async {
    try {
      isLoading.value = true;
      await supabase.auth.signOut();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
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
