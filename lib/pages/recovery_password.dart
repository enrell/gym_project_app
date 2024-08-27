import 'package:flutter/material.dart';
import 'package:gym_project_app/components/button.dart';
import 'package:gym_project_app/components/textfield.dart';

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({super.key});

  @override
  _PasswordRecoveryPageState createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isCodeSent = false;

  void recoverPassword(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement actual password recovery logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enviando email de recuperação...')),
      );
      // Simulate email sent and show code confirmation form
      setState(() {
        isCodeSent = true;
      });
    }
  }

  void confirmCode(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement actual code confirmation logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verificando código...')),
      );
      // Here you would typically verify the code and navigate to a password reset page
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isCodeSent ? 'Confirmar Código' : 'Recuperação de Senha',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isCodeSent
                        ? 'Insira o código de verificação enviado para o seu email.'
                        : 'Insira seu email para receber as instruções de recuperação de senha.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  if (!isCodeSent)
                    MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu email';
                        }
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return 'Por favor, insira um email válido';
                        }
                        return null;
                      },
                    )
                  else
                    MyTextField(
                      controller: codeController,
                      hintText: 'Código de Verificação',
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o código de verificação';
                        }
                        if (value.length != 6) {
                          return 'O código deve ter 6 dígitos';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 24),
                  Button(
                    onTap: () => isCodeSent
                        ? confirmCode(context)
                        : recoverPassword(context),
                    text: isCodeSent
                        ? 'Verificar Código'
                        : 'Enviar Email de Recuperação',
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isCodeSent ? 'Não recebeu o código?' : 'Lembrou sua senha?',
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          if (isCodeSent) {
                            setState(() {
                              isCodeSent = false;
                            });
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Text(isCodeSent ? 'Reenviar' : 'Voltar para o login'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}