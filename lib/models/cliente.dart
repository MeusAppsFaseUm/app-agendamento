class Cliente {
  int? id;
  String nome;
  String email;
  String telefone;
  String atendimento;
  String? fotoPath;
  String? instagram;
  String? whatsapp;
  String? facebook;
  DateTime dataCadastro;

  Cliente({
    this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.atendimento,
    this.fotoPath,
    this.instagram,
    this.whatsapp,
    this.facebook,
    required this.dataCadastro,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'atendimento': atendimento,
      'fotoPath': fotoPath,
      'instagram': instagram,
      'whatsapp': whatsapp,
      'facebook': facebook,
      'dataCadastro': dataCadastro.millisecondsSinceEpoch,
    };
  }

  static Cliente fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      telefone: map['telefone'],
      atendimento: map['atendimento'],
      fotoPath: map['fotoPath'],
      instagram: map['instagram'],
      whatsapp: map['whatsapp'],
      facebook: map['facebook'],
      dataCadastro: DateTime.fromMillisecondsSinceEpoch(map['dataCadastro']),
    );
  }
}
