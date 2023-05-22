import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/features/auth/application/bloc.dart';
import 'package:hooks/src/features/common/domain/constants.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/utils/utils.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        final fToast = ToastUtils.of(context);
        if (state.isLoggedIn) {
          Navigator.pop(context);
          ToastUtils.showInfoToast(fToast, 'Logged in successfully!');
        }
      },
      builder: (BuildContext context, AuthState state) {
        return SimpleDialog(
          surfaceTintColor: theme.scaffoldBackgroundColor,
          children: <Widget>[
            if (state.status == AuthStatus.loading)
              const SizedBox(
                height: 36,
                width: 36,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              )
            else if (!state.isLoggedIn) ...<Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: TextField(
                  controller: usernameController,
                  cursorColor: AppColors.primary,
                  autocorrect: false,
                  style: const TextStyle(color: AppColors.grey7),
                  decoration: const InputDecoration(
                    hintText: 'Username',
                    hintStyle: TextStyle(color: AppColors.grey5),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: TextField(
                  controller: passwordController,
                  cursorColor: AppColors.primary,
                  obscureText: true,
                  autocorrect: false,
                  style: const TextStyle(color: AppColors.grey7),
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: AppColors.grey5),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (state.status == AuthStatus.failure)
                const Padding(
                  padding: EdgeInsets.only(left: 18, right: 6),
                  child: Text(
                    Constants.loginErrorMessage,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ButtonBar(
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<AuthBloc>().add(const AuthEvent.init());
                      },
                      child: const Text(
                        'Cancel',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final username = usernameController.text;
                        final password = passwordController.text;
                        if (username.isNotEmpty && password.isNotEmpty) {
                          context.read<AuthBloc>().add(
                            AuthEvent.login(
                              username: username,
                              password: password,
                            ),
                          );
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          AppColors.primary,
                        ),
                      ),
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
