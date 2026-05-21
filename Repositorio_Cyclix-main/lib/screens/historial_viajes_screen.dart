import 'package:flutter/material.dart';

import '../services/cyclix_api_service.dart';
import '../theme/cyclix_colors.dart';
import '../widgets/cyclix_header.dart';

class HistorialViajesScreen extends StatefulWidget {
  const HistorialViajesScreen({super.key});

  @override
  State<HistorialViajesScreen> createState() => _HistorialViajesScreenState();
}

class _HistorialViajesScreenState extends State<HistorialViajesScreen> {
  final CyclixApiService _api = CyclixApiService();
  late Future<List<Map<String, dynamic>>> _future = _api.getMyTrips();

  Future<void> _reload() async {
    setState(() => _future = _api.getMyTrips());
    await _future;
  }

  String _money(Object? value) {
    final number = num.tryParse(value?.toString() ?? '');
    return 'Q.${(number ?? 0).toStringAsFixed(2)}';
  }

  String _duration(Object? value) {
    final seconds = int.tryParse(value?.toString() ?? '') ?? 0;
    if (seconds == 0) return 'En curso';
    return '${(seconds / 60).ceil()} min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyclixColors.backgroundWhite,
      appBar: const CyclixHeader(showBack: true),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _reload,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _StateMessage(
                  icon: Icons.error_outline,
                  title: 'No se pudo cargar el historial',
                  message: snapshot.error.toString(),
                );
              }

              final trips = snapshot.data ?? [];
              if (trips.isEmpty) {
                return const _StateMessage(
                  icon: Icons.route_outlined,
                  title: 'Sin viajes todavía',
                  message: 'Cuando termines un alquiler aparecerá aquí.',
                );
              }

              return ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  24 + MediaQuery.paddingOf(context).bottom,
                ),
                itemCount: trips.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CyclixColors.cardGrey,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE6EAF0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.pedal_bike,
                              color: CyclixColors.primaryBlue,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Bicicleta #${trip['bikeId']}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            _StatusBadge(status: trip['status']?.toString()),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _InfoLine(
                          label: 'Inicio',
                          value: trip['startedAt']?.toString() ?? 'Sin fecha',
                        ),
                        _InfoLine(
                          label: 'Duración',
                          value: _duration(trip['durationSeconds']),
                        ),
                        _InfoLine(
                          label: 'Distancia',
                          value:
                              '${num.tryParse(trip['distanceKm']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'} km',
                        ),
                        _InfoLine(
                          label: 'Total',
                          value: _money(
                            trip['walletChargedAmount'] ?? trip['totalAmount'],
                          ),
                          strong: true,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: strong ? FontWeight.bold : FontWeight.w500,
              color: strong ? CyclixColors.accentGreen : CyclixColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final active = status == 'ACTIVE';
    return Chip(
      label: Text(active ? 'Activo' : status ?? 'Viaje'),
      backgroundColor: active
          ? CyclixColors.primaryBlue.withValues(alpha: 0.12)
          : CyclixColors.accentGreen.withValues(alpha: 0.12),
      labelStyle: TextStyle(
        color: active ? CyclixColors.primaryBlue : CyclixColors.accentGreen,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 80),
        Icon(icon, size: 58, color: CyclixColors.primaryBlue),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: CyclixColors.instructionGray),
        ),
      ],
    );
  }
}
