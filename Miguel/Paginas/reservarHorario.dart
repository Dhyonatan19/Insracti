import 'package:flutter/material.dart';
import 'package:primeiro_app/tema.dart'; // ajuste o caminho conforme sua pasta

class ReservarHorario extends StatefulWidget {
  const ReservarHorario({super.key});

  @override
  State<ReservarHorario> createState() => _ReservarHorarioState();
}

class _Slot {
  final String hora;
  final String status; // 'livre', 'reservado' ou 'fila'
  final String info;

  _Slot({required this.hora, required this.status, required this.info});
}

class _ReservarHorarioState extends State<ReservarHorario> {
  int _diaSelecionado = 0;
  final List<String> _dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];

  // Dados de exemplo — sem backend ainda, é só a tela. Os horários não
  // mudam de fato ao trocar de dia (isso entra quando o back estiver pronto).
  final List<_Slot> _slots = [
    _Slot(hora: '08:00', status: 'reservado', info: 'Prof. Ana Beatriz'),
    _Slot(hora: '09:00', status: 'livre', info: 'Disponível'),
    _Slot(hora: '10:00', status: 'reservado', info: 'Prof. Carlos Menezes'),
    _Slot(hora: '11:00', status: 'livre', info: 'Disponível'),
    _Slot(hora: '14:00', status: 'fila', info: '2 pessoas na fila'),
    _Slot(hora: '15:00', status: 'livre', info: 'Disponível'),
    _Slot(hora: '16:00', status: 'reservado', info: 'Prof. Diego Alves'),
  ];

  _Slot? _slotEscolhido;
  int _confirmacoes = 0;
  bool _enviando = false;
  bool _enviado = false;

  void _escolherSlot(_Slot slot) {
    setState(() {
      _slotEscolhido = slot;
      _confirmacoes = 0;
      _enviando = false;
      _enviado = false;
    });
  }

  Future<void> _enviarSolicitacao() async {
    setState(() => _enviando = true);
    for (var i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 380));
      if (!mounted) return;
      setState(() => _confirmacoes = i + 1);
    }
    if (!mounted) return;
    setState(() {
      _enviando = false;
      _enviado = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPapel,
      appBar: appBarInsspiract(context, 'Reservar horário'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Escolha um horário livre',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: corTintaSuave),
            ),
            const SizedBox(height: 12),
            _tabsDeDia(),
            const SizedBox(height: 12),
            ..._slots.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _linhaSlot(s),
                )),
            if (_slotEscolhido != null) ...[
              const SizedBox(height: 6),
              _painelConfirmacao(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tabsDeDia() {
    return Row(
      children: List.generate(_dias.length, (i) {
        final selecionado = i == _diaSelecionado;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < _dias.length - 1 ? 6 : 0),
            child: OutlinedButton(
              onPressed: () => setState(() => _diaSelecionado = i),
              style: OutlinedButton.styleFrom(
                backgroundColor: selecionado ? corAzul : Colors.white,
                foregroundColor: selecionado ? Colors.white : corTintaSuave,
                side: BorderSide(color: selecionado ? corAzul : corLinha, width: 1.4),
                padding: const EdgeInsets.symmetric(vertical: 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
              ),
              child: Text(_dias[i], style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }),
    );
  }

  Widget _linhaSlot(_Slot slot) {
    final livre = slot.status == 'livre';
    final escolhido = _slotEscolhido == slot;

    Widget chip;
    switch (slot.status) {
      case 'livre':
        chip = chipInsspiract('Livre', cor: corVerde, fundo: const Color(0xFFE4F7EC));
        break;
      case 'fila':
        chip = chipInsspiract('Em fila', cor: corAvisoTexto, fundo: corAvisoFundo);
        break;
      default:
        chip = chipInsspiract('Reservado', cor: corAzul, fundo: const Color(0xFFE9F1FB));
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: livre ? () => _escolherSlot(slot) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: escolhido ? corLaranja : corLinha, width: 1.4),
            color: escolhido ? const Color(0xFFFFF8EF) : Colors.white,
          ),
          child: Row(
            children: [
              SizedBox(width: 62, child: Text(slot.hora, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: corTinta))),
              Expanded(child: Text(slot.info, style: const TextStyle(fontSize: 12, color: corTintaSuave))),
              chip,
            ],
          ),
        ),
      ),
    );
  }

  Widget _painelConfirmacao() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: corLaranjaClaro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _enviado ? 'Enviado — aguardando confirmações' : 'Solicitar reserva das ${_slotEscolhido!.hora}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: corTinta),
          ),
          const SizedBox(height: 10),
          const Text('Confirmações da secretaria (RF14)', style: TextStyle(fontSize: 11.5, color: corTintaSuave)),
          const SizedBox(height: 6),
          Row(
            children: List.generate(3, (i) {
              final ativo = i < _confirmacoes;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                  height: 6,
                  decoration: BoxDecoration(color: ativo ? corLaranja : corLinha, borderRadius: BorderRadius.circular(4)),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          const Text('A reserva só é efetivada após 3 confirmações.', style: TextStyle(fontSize: 11, color: corTintaSuave)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: (_enviando || _enviado) ? null : _enviarSolicitacao,
              style: ElevatedButton.styleFrom(
                backgroundColor: corLaranja,
                disabledBackgroundColor: corLaranjaClaro,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
              child: _enviando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                    )
                  : Text(
                      _enviado ? 'Enviado' : 'Enviar solicitação',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
