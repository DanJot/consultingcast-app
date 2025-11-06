import 'package:flutter/material.dart';
import '../models/user.dart';
import 'main_navigation.dart';

// PÁGINA PRINCIPAL DO DASHBOARD - REDIRECIONA PARA A NOVA NAVEGAÇÃO
class DashboardPage extends StatelessWidget {
  final User user; 
  final int initialIndex; // 0: Home, 1: Conta Pessoal, 2: Minha Empresa

  const DashboardPage({super.key, required this.user, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    // Redireciona diretamente para a nova navegação
    return MainNavigation(user: user, initialIndex: initialIndex);
  }
}



