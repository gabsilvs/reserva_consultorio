// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print("Usuário logado: \${userCredential.user?.email}");
      Navigator.pushReplacementNamed(
          context, '/home'); // Redireciona para a home após login
    } catch (e) {
      print("Erro ao fazer login: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        // 🔹 Permite rolagem para evitar overflow
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // 🔹 Evita que a coluna ocupe toda a tela
            children: [
              Image.asset('lib/assets/logo.png', width: 250, height: 250),
              SizedBox(height: 20),
              Text(
                "Bem-vindo ao Reserva Consultório",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'E-mail'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
