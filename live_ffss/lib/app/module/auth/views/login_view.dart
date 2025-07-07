import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/utils/validators.dart';
import 'package:live_ffss/app/module/auth/controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('login'.tr),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight -
                  48, // 48 for padding
            ),
            child: IntrinsicHeight(
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),

                    // App logo or name
                    Icon(
                      Icons.lock_outline,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 32),

                    // id field
                    TextFormField(
                      controller: controller.idController,
                      decoration: InputDecoration(
                        labelText: 'id'.tr,
                        prefixIcon: const Icon(Icons.person_outline),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: controller.passwordController,
                      decoration: InputDecoration(
                        labelText: 'password'.tr,
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 32),

                    // Login button
                    Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator()
                              : Text('login'.tr),
                        )),

                    // Error message
                    Obx(() => controller.errorMessage.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              controller.errorMessage.value,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const SizedBox.shrink()),

                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
