import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/company.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  final User user;
  final Company? selectedCompany;

  const HomePage({super.key, required this.user, this.selectedCompany});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(183, 49, 112, 126),
        foregroundColor: Colors.white,
        title: Text('Bem-vindo, ${user.name}'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.menu, color: Colors.white, size: 24),
              color: Colors.white,
              elevation: 10,
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (String value) {
                _handleMenuSelection(context, value);
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'faturacao',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(183, 49, 112, 126).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.attach_money,
                            color: Color.fromARGB(183, 49, 112, 126),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Faturação Mensal',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'iuc',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(183, 49, 112, 126).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.receipt,
                            color: Color.fromARGB(183, 49, 112, 126),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Emitir IUC',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'imi',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(183, 49, 112, 126).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.home,
                            color: Color.fromARGB(183, 49, 112, 126),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Emitir IMI',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'declaracoes',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(183, 49, 112, 126).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.description,
                            color: Color.fromARGB(183, 49, 112, 126),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Declarações',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(183, 49, 112, 126),
              Color.fromARGB(100, 49, 112, 126),
              Colors.white,
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card do utilizador
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: const Color.fromARGB(183, 49, 112, 126).withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(183, 49, 112, 126),
                                Color.fromARGB(200, 49, 112, 126),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(183, 49, 112, 126).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.transparent,
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name.isNotEmpty ? user.name : 'Utilizador',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(183, 49, 112, 126)),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                user.email,
                                style: const TextStyle(color: Colors.grey, fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Cards de funcionalidades
                _buildFeatureCard(
                  context,
                  'Faturação Mensal',
                  'Consulte e gere faturas mensais',
                  Icons.attach_money,
                  () => _handleMenuSelection(context, 'faturacao'),
                ),
                const SizedBox(height: 12),
                
                _buildFeatureCard(
                  context,
                  'Emitir IUC',
                  'Gere o Imposto Único de Circulação',
                  Icons.receipt,
                  () => _handleMenuSelection(context, 'iuc'),
                ),
                const SizedBox(height: 12),
                
                _buildFeatureCard(
                  context,
                  'Emitir IMI',
                  'Gere o Imposto Municipal sobre Imóveis',
                  Icons.home,
                  () => _handleMenuSelection(context, 'imi'),
                ),
                const SizedBox(height: 12),
                
                _buildFeatureCard(
                  context,
                  'Declarações',
                  'Aceda às suas declarações fiscais',
                  Icons.description,
                  () => _handleMenuSelection(context, 'declaracoes'),
                ),
                const SizedBox(height: 20),
                
                // Botão de logout
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                      BoxShadow(
                        color: const Color.fromARGB(183, 49, 112, 126).withOpacity(0.1),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color.fromARGB(183, 49, 112, 126).withOpacity(0.1),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.logout,
                                  color: Color.fromARGB(183, 49, 112, 126),
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Terminar sessão',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(183, 49, 112, 126),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: const Color.fromARGB(183, 49, 112, 126).withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(183, 49, 112, 126),
                        Color.fromARGB(200, 49, 112, 126),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(183, 49, 112, 126).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.transparent,
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(183, 49, 112, 126),
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(183, 49, 112, 126).withOpacity(0.1),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color.fromARGB(183, 49, 112, 126),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    String message = '';
    switch (value) {
      case 'faturacao':
        message = 'Faturação Mensal selecionada';
        break;
      case 'iuc':
        message = 'Emitir IUC selecionado';
        break;
      case 'imi':
        message = 'Emitir IMI selecionado';
        break;
      case 'declaracoes':
        message = 'Declarações selecionadas';
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromARGB(183, 49, 112, 126),
      ),
    );
  }
}
