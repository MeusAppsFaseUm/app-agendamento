import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/cliente.dart';
import '../services/database_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({Key? key}) : super(key: key);

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _atendimentoController = TextEditingController();
  final _instagramController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _facebookController = TextEditingController();

  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvarCliente() async {
    if (_formKey.currentState!.validate()) {
      try {
        final cliente = Cliente(
          nome: _nomeController.text,
          email: _emailController.text,
          telefone: _telefoneController.text,
          atendimento: _atendimentoController.text,
          fotoPath: _imagePath,
          instagram: _instagramController.text.isNotEmpty 
            ? _instagramController.text 
            : null,
          whatsapp: _whatsappController.text.isNotEmpty 
            ? _whatsappController.text 
            : null,
          facebook: _facebookController.text.isNotEmpty 
            ? _facebookController.text 
            : null,
          dataCadastro: DateTime.now(),
        );

        await DatabaseService.insertCliente(cliente);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente cadastrado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          _limparFormulario();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao cadastrar cliente: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _limparFormulario() {
    _nomeController.clear();
    _emailController.clear();
    _telefoneController.clear();
    _atendimentoController.clear();
    _instagramController.clear();
    _whatsappController.clear();
    _facebookController.clear();
    setState(() {
      _imagePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cadastro de Cliente',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Foto do cliente
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: _imagePath != null
                          ? Image.file(
                              File(_imagePath!),
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Dados pessoais
              CustomTextField(
                label: 'Nome Completo',
                controller: _nomeController,
                prefixIcon: Icons.person_rounded,
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_rounded,
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Telefone',
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_rounded,
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'ATENDIMENTO',
                hintText: 'Ex: Barbearia do João, Consultório Dr. Silva',
                controller: _atendimentoController,
                prefixIcon: Icons.business_rounded,
              ),
              const SizedBox(height: 30),

              // Redes sociais
              const Text(
                'Redes Sociais (Opcional)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),

              CustomTextField(
                label: 'Instagram',
                controller: _instagramController,
                prefixIcon: Icons.photo_camera_rounded,
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'WhatsApp',
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.chat_rounded,
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Facebook',
                controller: _facebookController,
                prefixIcon: Icons.facebook_rounded,
              ),
              const SizedBox(height: 40),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Limpar',
                      onPressed: _limparFormulario,
                      color: Colors.grey[400],
                      textColor: Colors.black87,
                      icon: Icons.clear_rounded,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: CustomButton(
                      text: 'Salvar',
                      onPressed: _salvarCliente,
                      icon: Icons.save_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
