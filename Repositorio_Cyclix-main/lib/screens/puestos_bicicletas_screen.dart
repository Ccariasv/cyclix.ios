import 'package:flutter/material.dart';

import '../models/bike_info.dart';
import '../services/cyclix_api_service.dart';
import '../theme/cyclix_colors.dart';
import '../widgets/cyclix_header.dart';
import 'bike_detail_screen.dart';

class PuestosBicicletasScreen extends StatefulWidget {
  const PuestosBicicletasScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<PuestosBicicletasScreen> createState() =>
      _PuestosBicicletasScreenState();
}

class _PuestosBicicletasScreenState extends State<PuestosBicicletasScreen> {
  final CyclixApiService _api = CyclixApiService();
  late Future<List<Map<String, dynamic>>> _stations = _api.getStations();
  Object? _selectedStationId;
  Future<List<Map<String, dynamic>>>? _bikes;

  Future<void> _selectStation(Map<String, dynamic> station) async {
    setState(() {
      _selectedStationId = station['id'];
      _bikes = _api.getBikesByStation(station['id'], onlyAvailable: true);
    });
  }

  Future<void> _reload() async {
    setState(() {
      _stations = _api.getStations();
      if (_selectedStationId != null) {
        _bikes = _api.getBikesByStation(
          _selectedStationId!,
          onlyAvailable: true,
        );
      }
    });
    await _stations;
    await _bikes;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    final content = SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 24 + bottom),
          children: [
            Text(
              'Puestos y bicicletas',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _stations,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) return Text(snapshot.error.toString());

                final stations = snapshot.data ?? [];
                if (stations.isEmpty) {
                  return const Text('No hay puestos activos disponibles.');
                }

                return Column(
                  children: stations
                      .map(
                        (station) => _StationTile(
                          station: station,
                          selected: station['id'] == _selectedStationId,
                          onTap: () => _selectStation(station),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            if (_bikes != null) ...[
              Text(
                'Bicicletas disponibles',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _bikes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  final bikes = snapshot.data ?? [];
                  if (bikes.isEmpty) {
                    return const Text(
                      'Este puesto no tiene bicis disponibles.',
                    );
                  }

                  return Column(
                    children: bikes
                        .map(
                          (bike) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.pedal_bike,
                              color: CyclixColors.primaryBlue,
                            ),
                            title: Text(
                              '${bike['marca'] ?? ''} ${bike['modelo'] ?? ''}'
                                  .trim(),
                            ),
                            subtitle: Text(
                              '#${bike['id']} · ${bike['tipo']} · ${bike['estado']}',
                            ),
                            trailing: Text('Q.${bike['precioPorHora']}/h'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BikeDetailScreen(
                                  bike: BikeInfo.fromJson(bike),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );

    if (widget.embeddedInShell) {
      return ColoredBox(color: CyclixColors.backgroundWhite, child: content);
    }

    return Scaffold(
      backgroundColor: CyclixColors.backgroundWhite,
      appBar: const CyclixHeader(showBack: true),
      body: content,
    );
  }
}

class _StationTile extends StatelessWidget {
  const _StationTile({
    required this.station,
    required this.selected,
    required this.onTap,
  });

  final Map<String, dynamic> station;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: selected
            ? CyclixColors.primaryBlue.withValues(alpha: 0.08)
            : CyclixColors.cardGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? CyclixColors.primaryBlue : const Color(0xFFE6EAF0),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.storefront, color: CyclixColors.primaryBlue),
        title: Text(station['nombre']?.toString() ?? 'Puesto'),
        subtitle: Text(
          '${station['direccion'] ?? ''}\nDisponibles: ${station['capacidadDisponible']}/${station['capacidadTotal']}',
        ),
        isThreeLine: true,
      ),
    );
  }
}
