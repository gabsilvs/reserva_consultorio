import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'login_screen.dart';

class CadastroConsultorioScreen extends StatefulWidget {
  @override
  _CadastroConsultorioScreenState createState() => _CadastroConsultorioScreenState();
}

class _CadastroConsultorioScreenState extends State<CadastroConsultorioScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  File? _imagem;
  bool _isLoading = false;

  Future<void> _selecionarImagem() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagemSelecionada = await picker.pickImage(source: ImageSource.gallery);

    if (imagemSelecionada != null) {
      setState(() {
        _imagem = File(imagemSelecionada.path);
      });
    }
  }

  void _removerImagem() {
    setState(() {
      _imagem = null;
    });
  }

  Future<void> _salvarConsultorio() async {
    if (_nomeController.text.isEmpty || _descricaoController.text.isEmpty || _imagem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos e selecione uma imagem!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('consultorios/$fileName.jpg');
      await ref.putFile(_imagem!);
      String imageUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('consultorios').add({
        'nome': _nomeController.text,
        'descricao': _descricaoController.text,
        'imagemUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Consultório cadastrado com sucesso!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Consultório'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _selecionarImagem,
                child: _imagem != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: 350, // Mantém a altura fixa da imagem
                              width: double.infinity, // Usa toda a largura disponível
                              child: Image.file(
                                _imagem!,
                                fit: BoxFit.cover, // Preenche sem distorcer
                              ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: IconButton(
                              icon: Icon(Icons.cancel, color: Colors.red, size: 30),
                              onPressed: _removerImagem,
                            ),
                          ),
                        ],
                      )
                    : Container(
                        height: 350, // Mantém o tamanho fixo quando não há imagem
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(Icons.add_a_photo, color: Colors.grey[700], size: 50),
                        ),
                      ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome do Consultório',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _descricaoController,
                maxLines: 3, // Permite mais espaço para descrição
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvarConsultorio,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.teal,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Cadastrar', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
