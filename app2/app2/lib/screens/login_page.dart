import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'company_selection_page.dart';

// ECRÃ DE LOGIN: RECOLHE EMAIL/PASSWORD E FAZ NAVEGAÇÃO
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// CONTROLADORES DOS CAMPOS DE TEXTO
class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

	final AuthService _auth = AuthService();

  // AÇÃO DO BOTÃO "ENTRAR"
  Future<void> _login() async {
    if (_loading) return;
    setState(() {
      _loading = true;
    });
    FocusScope.of(context).unfocus();

    // Verificar se a password é um hash bcrypt e limpar se necessário
    final password = _passwordController.text;
    if (password.startsWith('\$2y\$') || password.startsWith('\$2a\$') || password.startsWith('\$2b\$')) {
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira a password original, não o hash.'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final user = await _auth.login(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        // LOGIN OK: ENVIA PARA O DASHBOARD
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => CompanySelectionPage(user: user),
          ),
        );
      } else {
        // LOGIN FALHOU: MOSTRA SNACKBAR
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciais inválidas.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().contains('Não foi possível conectar')
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Erro de ligação: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Limpar campos ao inicializar
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fundo curvo verde-água ocupando a tela inteira
          CustomPaint(
            size: Size(size.width, size.height),
            painter: _CurvedBackgroundPainter(),
          ),

          // Conteúdo principal por cima
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Logo
                    Image.asset(
                      'images/logosemfundo.png',
                      fit: BoxFit.contain,
                      height: size.height * 0.20,
                      width: size.width * 0.55,
                    ),
                    const SizedBox(height: 40),

                    // Título
                    const Text(
                      'Bem-vindo de volta!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Faça login para continuar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Campo de email
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Campo de password
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        autofillHints: const [], // Desabilitar autofill
                        onChanged: (value) {
                          // Limpar automaticamente se detectar hash bcrypt
                          if (value.startsWith('\$2y\$') || value.startsWith('\$2a\$') || value.startsWith('\$2b\$')) {
                            _passwordController.clear();
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Botão de login
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C2C2C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Link para registo (opcional)
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Funcionalidade de registo em desenvolvimento'),
                          ),
                        );
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                                text: 'Não tem conta?\nPeça os seus dados de acesso '),
                            TextSpan(
                              text: 'aqui',
                              style: TextStyle(fontSize:16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Classe privada que desenha o fundo com curvas personalizadas
class _CurvedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint2 = Paint()
      ..color = const Color.fromARGB(183, 49, 112, 126)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.56); // começa mais acima
    path2.quadraticBezierTo(
      size.width * 0.5, size.height * 0.70,
      size.width, size.height * 0.56, // É A CURVA QUE SE EXTENDE ATE AO FUNDO
    );
    path2.lineTo(size.width, size.height); // fecha até ao fundo
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}