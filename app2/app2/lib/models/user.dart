// MODELO DE UTILIZADOR: DADOS ESSENCIAIS DO UTILIZADOR NA APP
class User {
  final String id;
  final String email;
  final String name;

  const User({
    required this.id,
    required this.email,
    required this.name,
  });

  // CONVERTE MAP (BD/JSON) -> USER
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'].toString(),
      email: map['email'] ?? '',
      name: map['name'] ?? '',
    );
  }

  // CONVERTE USER -> MAP (ÚTIL PARA INSERÇÃO/ENVIO)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }
}