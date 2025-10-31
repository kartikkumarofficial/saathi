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

  final Rx<UserModel?> user = Rx<UserModel?>(null);

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

      if (response.user == null) throw 'Sign up failed. Please try again.';

      await supabase.from('users').insert({
        'id': response.user!.id,
        'email': emailController.text.trim(),
        'full_name': nameController.text.trim(),
        'role': 'wanderer',
        'profile_image':
        'https://api.dicebear.com/6.x/pixel-art/png?seed=${emailController.text.trim()}',
      });

      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      Get.offAll(() => RoleSelectionScreen());
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
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
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
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

      await supabase.from('users').update({'role': role}).eq('id', uid);

      final current = user.value;
      if (current != null) {
        user.value = current.copyWith(role: role);
      } else {
        final fresh = await getUserFromSupabase(uid);
        if (fresh != null) user.value = fresh.copyWith(role: role);
      }

      user.refresh();
      Get.snackbar('Success', 'Your role has been updated to $role!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      print("❌ Error updating role: $e");
      rethrow;
    }
  }

  // --------------------------------------------------------
  // FETCH USER & NAVIGATE
  // --------------------------------------------------------
  Future<void> fetchUserAndNavigate(String userId) async {
    try {
      final response =
      await supabase.from('users').select().eq('id', userId).single();

      user.value = UserModel.fromJson(response);
      user.refresh();

      if (user.value!.role == null || user.value!.role!.isEmpty) {
        Get.offAll(() => RoleSelectionScreen());
      } else {
        Get.offAll(() => MainScaffold());
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not retrieve user details. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      Get.offAll(() => const LoginScreen());
    }
  }

  Future<UserModel?> getUserFromSupabase(String id) async {
    try {
      final response =
      await supabase.from('users').select().eq('id', id).single();
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
      Get.snackbar('Error signing in', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

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
      Get.snackbar('Logout Failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // --------------------------------------------------------
  // RESTORE SESSION
  // --------------------------------------------------------
  Future<void> restoreSession() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      await fetchUserAndNavigate(currentUser.id);
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }

  // --------------------------------------------------------
  // UPDATE PROFILE
  // --------------------------------------------------------
  Future<void> updateUserProfile({
    String? fullName,
    String? email,
    String? profileImage,
  }) async {
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) throw "User not logged in";

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (email != null) updates['email'] = email;
      if (profileImage != null) updates['profile_image'] = profileImage;

      await supabase.from('users').update(updates).eq('id', uid);

      user.value = user.value?.copyWith(
        name: fullName ?? user.value!.name,
        email: email ?? user.value!.email,
        avatarUrl: profileImage ?? user.value!.avatarUrl,
      );

      user.refresh();

      Get.snackbar('Profile Updated',
          'Your profile information has been updated successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }
}
