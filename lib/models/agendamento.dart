class Agendamento {
  int? id;
  int clienteId;
  DateTime dataHora;
  String servico;
  String status; // 'agendado', 'concluido', 'cancelado'
  String? observacoes;

  Agendamento({
    this.id,
    required this.clienteId,
    required this.dataHora,
    required this.servico,
    this.status = 'agendado',
    this.observacoes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clienteId': clienteId,
      'dataHora': dataHora.millisecondsSinceEpoch,
      'servico': servico,
      'status': status,
      'observacoes': observacoes,
    };
  }

  static Agendamento fromMap(Map<String, dynamic> map) {
    return Agendamento(
      id: map['id'],
      clienteId: map['clienteId'],
      dataHora: DateTime.fromMillisecondsSinceEpoch(map['dataHora']),
      servico: map['servico'],
      status: map['status'],
      observacoes: map['observacoes'],
    );
  }
}
