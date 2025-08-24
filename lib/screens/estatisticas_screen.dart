import 'package:flutter/material.dart';
import '../models/agendamento.dart';
import '../services/database_service.dart';

class EstatisticasScreen extends StatefulWidget {
  const EstatisticasScreen({Key? key}) : super(key: key);

  @override
  State<EstatisticasScreen> createState() => _EstatisticasScreenState();
}

class _EstatisticasScreenState extends State<EstatisticasScreen> {
  List<Agendamento> _agendamentos = [];
  String _periodoSelecionado = 'Hoje';
  
  final Map<String, int> _estatisticasDia = {};
  final Map<String, int> _estatisticasSemana = {};
  final Map<String, int> _estatisticasMes = {};

  @override
  void initState() {
    super.initState();
    _carregarEstatisticas();
  }

  Future<void> _carregarEstatisticas() async {
    _agendamentos = await DatabaseService.getAgendamentos();
    _calcularEstatisticas();
  }

  void _calcularEstatisticas() {
    final hoje = DateTime.now();
    final inicioSemana = hoje.subtract(Duration(days: hoje.weekday - 1));
    final inicioMes = DateTime(hoje.year, hoje.month, 1);

    _estatisticasDia.clear();
    _estatisticasSemana.clear();
    _estatisticasMes.clear();

    for (var agendamento in _agendamentos) {
      final dataAgendamento = agendamento.dataHora;
      
      // Estatísticas do dia
      if (_isSameDay(dataAgendamento, hoje)) {
        _estatisticasDia[agendamento.status] = 
          (_estatisticasDia[agendamento.status] ?? 0) + 1;
      }
      
      // Estatísticas da semana
      if (dataAgendamento.isAfter(inicioSemana.subtract(const Duration(days: 1))) &&
          dataAgendamento.isBefore(hoje.add(const Duration(days: 1)))) {
        _estatisticasSemana[agendamento.status] = 
          (_estatisticasSemana[agendamento.status] ?? 0) + 1;
      }
      
      // Estatísticas do mês
      if (dataAgendamento.isAfter(inicioMes.subtract(const Duration(days: 1))) &&
          dataAgendamento.isBefore(hoje.add(const Duration(days: 1)))) {
        _estatisticasMes[agendamento.status] = 
          (_estatisticasMes[agendamento.status] ?? 0) + 1;
      }
    }

    setState(() {});
  }

  bool _isSameDay(DateTime data1, DateTime data2) {
    return data1.year == data2.year &&
           data1.month == data2.month &&
           data1.day == data2.day;
  }

  Map<String, int> _getEstatisticasAtual() {
    switch (_periodoSelecionado) {
      case 'Hoje':
        return _estatisticasDia;
      case 'Semana':
        return _estatisticasSemana;
      case 'Mês':
        return _estatisticasMes;
      default:
        return _estatisticasDia;
    }
  }

  int _getTotalAgendamentos() {
    final estatisticas = _getEstatisticasAtual();
    return estatisticas.values.fold(0, (sum, value) => sum + value);
  }

  @override
  Widget build(BuildContext context) {
    final estatisticasAtual = _getEstatisticasAtual();
    final total = _getTotalAgendamentos();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Estatísticas',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seletor de período
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: ['Hoje', 'Semana', 'Mês'].map((periodo) {
                  final isSelected = _periodoSelecionado == periodo;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _periodoSelecionado = periodo;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black87 : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          periodo,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 30),

            // Total de agendamentos
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.black87, Colors.grey],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    total.toString(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Total de Agendamentos $_periodoSelecionado',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Cards de estatísticas por status
            const Text(
              'Por Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),

            // Layout responsivo para os cards
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusCard(
                            'Agendados',
                            estatisticasAtual['agendado'] ?? 0,
                            Icons.schedule_rounded,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatusCard(
                            'Concluídos',
                            estatisticasAtual['concluido'] ?? 0,
                            Icons.check_circle_rounded,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusCard(
                            'Cancelados',
                            estatisticasAtual['cancelado'] ?? 0,
                            Icons.cancel_rounded,
                            Colors.red,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatusCard(
                            'Taxa de Sucesso',
                            _calcularTaxaSucesso(estatisticasAtual),
                            Icons.trending_up_rounded,
                            Colors.orange,
                            isPercentage: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),

            // Horários mais movimentados
            const Text(
              'Horários Mais Movimentados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: _buildHorariosMaisMovimentados(),
              ),
            ),
            const SizedBox(height: 30),

            // Resumo semanal
            const Text(
              'Resumo dos Últimos 7 Dias',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: _buildResumoSemanal(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    String titulo,
    int valor,
    IconData icone,
    Color cor, {
    bool isPercentage = false,
  }) {
    return Container(
      height: 120, // Altura fixa para evitar overflow
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icone,
              color: cor,
              size: 20,
            ),
          ),
          Text(
            isPercentage ? '$valor%' : valor.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  int _calcularTaxaSucesso(Map<String, int> estatisticas) {
    final total = estatisticas.values.fold(0, (sum, value) => sum + value);
    if (total == 0) return 0;
    final concluidos = estatisticas['concluido'] ?? 0;
    return ((concluidos / total) * 100).round();
  }

  List<Widget> _buildHorariosMaisMovimentados() {
    final horariosCount = <int, int>{};
    
    for (var agendamento in _agendamentos) {
      final hora = agendamento.dataHora.hour;
      horariosCount[hora] = (horariosCount[hora] ?? 0) + 1;
    }

    final horariosOrdenados = horariosCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (horariosOrdenados.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Nenhum agendamento encontrado',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }

    return horariosOrdenados.take(5).map((entry) {
      final hora = entry.key;
      final count = entry.value;
      final maxCount = horariosOrdenados.first.value;
      final porcentagem = maxCount > 0 ? (count / maxCount) : 0.0;

      return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                '${hora.toString().padLeft(2, '0')}:00',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: porcentagem,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 30,
              child: Text(
                count.toString(),
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildResumoSemanal() {
    final diasSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final hoje = DateTime.now();
    final resumoSemana = <String, int>{};

    for (int i = 6; i >= 0; i--) {
      final dia = hoje.subtract(Duration(days: i));
      final diaSemana = diasSemana[dia.weekday - 1];
      final count = _agendamentos.where((agendamento) =>
        _isSameDay(agendamento.dataHora, dia)).length;
      resumoSemana[diaSemana] = count;
    }

    final maxCount = resumoSemana.values.isNotEmpty 
      ? resumoSemana.values.reduce((a, b) => a > b ? a : b) 
      : 0;

    return resumoSemana.entries.map((entry) {
      final dia = entry.key;
      final count = entry.value;
      final porcentagem = maxCount > 0 ? (count / maxCount) : 0.0;

      return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                dia,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Container(
                height: 25,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: porcentagem,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.black87, Colors.grey],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 30,
              child: Text(
                count.toString(),
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
