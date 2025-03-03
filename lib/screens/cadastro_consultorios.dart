import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
    final XFile? imagemSelecionada =
        await picker.pickImage(source: ImageSource.gallery);

    if (imagemSelecionada != null) {
      setState(() {
        _imagem = File(imagemSelecionada.path);
      });
    }
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
      // Upload da imagem para o Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('consultorios/$fileName.jpg');
      await ref.putFile(_imagem!);
      String imageUrl = await ref.getDownloadURL();

      // Salvar dados no Firestore
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastrar Consultório')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _imagem != null
                ? Image.file(_imagem!, height: 150)
                : ElevatedButton(
                    onPressed: _selecionarImagem,
                    child: Text('Selecionar Imagem'),
                  ),
            SizedBox(height: 10),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome do Consultório'),
            ),
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _salvarConsultorio,
                    child: Text('Cadastrar'),
                  ),
          ],
        ),
      ),
    );
  }
}
