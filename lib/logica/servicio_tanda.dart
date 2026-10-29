import '../modelos/tanda.dart';
import '../modelos/cierre_ronda.dart';
import '../modelos/historial_ronda.dart';
import 'resultado_aportacion.dart';
import 'resultado_cierre.dart';

class ServicioTanda {
  final Tanda tanda;
  final List<HistorialRonda> historial = [];

  ServicioTanda(this.tanda);

  bool haTerminado() => tanda.turnoActual >= tanda.ordenTurnos.length;

  bool puedeCerrarRonda() {
    return tanda.participantes.every((p) => tanda.aportacionesRondaActual.contains(p.id));
  }

  ResultadoAportacion registrarAportacion(String idParticipante) {
    if (haTerminado()) return ResultadoAportacion.tandaTerminada;
    
    final esParticipante = tanda.participantes.any((p) => p.id == idParticipante);
    if (!esParticipante) return ResultadoAportacion.participanteInvalido;
    
    final yaAporto = tanda.aportacionesRondaActual.contains(idParticipante);
    if (yaAporto) return ResultadoAportacion.yaAporto;
    
    tanda.aportacionesRondaActual.add(idParticipante);
    return ResultadoAportacion.registrada;
  }

  CierreRonda cerrarRondaYAvanzar() {
    if (!puedeCerrarRonda()) {
      return CierreRonda(ResultadoCierre.faltanAportaciones, null);
    }
    
    final idBeneficiario = tanda.ordenTurnos[tanda.turnoActual];
    final beneficiario = tanda.participantes.firstWhere((p) => p.id == idBeneficiario);
    
    beneficiario.yaRecibioTurno = true;
    
    historial.add(
      HistorialRonda(
        numeroRonda: tanda.turnoActual + 1,
        nombreBeneficiario: beneficiario.nombre,
        fechaCierre: DateTime.now(),
      ),
    );

    tanda.aportacionesRondaActual.clear();
    tanda.turnoActual++;
    
    return CierreRonda(ResultadoCierre.rondaCerrada, beneficiario);
  }
}