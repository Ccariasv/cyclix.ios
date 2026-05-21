import 'package:flutter/material.dart';

import '../services/cyclix_api_service.dart';
import '../theme/cyclix_colors.dart';
import '../widgets/cyclix_header.dart';

class AdminApiScreen extends StatefulWidget {
  const AdminApiScreen({super.key});

  @override
  State<AdminApiScreen> createState() => _AdminApiScreenState();
}

class _AdminApiScreenState extends State<AdminApiScreen> {
  final CyclixApiService _api = CyclixApiService();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: CyclixColors.backgroundWhite,
        appBar: const CyclixHeader(showBack: true),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Usuarios'),
                  Tab(text: 'Bicicletas'),
                  Tab(text: 'Tarifas'),
                  Tab(text: 'Festivos'),
                  Tab(text: 'Planes'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _ApiList(
                      future: _api.getUsers(),
                      titleBuilder: (item) =>
                          '${item['firstName'] ?? ''} ${item['lastName'] ?? ''}'
                              .trim(),
                      subtitleBuilder: (item) =>
                          '${item['email']} · ${item['role']} · ${item['status']}',
                      bottomPadding: bottom,
                    ),
                    _ApiList(
                      future: _api.getBikes(),
                      titleBuilder: (item) =>
                          '${item['marca'] ?? ''} ${item['modelo'] ?? ''}'
                              .trim(),
                      subtitleBuilder: (item) =>
                          '#${item['id']} · ${item['codigo']} · ${item['estado']}',
                      bottomPadding: bottom,
                    ),
                    _ApiList(
                      future: _api.getPricingRules(),
                      titleBuilder: (item) => item['name']?.toString() ?? '',
                      subtitleBuilder: (item) =>
                          'Q.${item['baseFare']} incluye ${item['includedMinutes']} min · Extra Q.${item['extraFarePerBlock']}/${item['extraBlockMinutes']} min',
                      bottomPadding: bottom,
                    ),
                    _ApiList(
                      future: _api.getHolidays(),
                      titleBuilder: (item) => item['name']?.toString() ?? '',
                      subtitleBuilder: (item) =>
                          '${item['holidayDate']} · ${item['active'] == true ? 'Activo' : 'Inactivo'}',
                      bottomPadding: bottom,
                    ),
                    _ApiList(
                      future: _api.getSubscriptionPlans(),
                      titleBuilder: (item) => item['name']?.toString() ?? '',
                      subtitleBuilder: (item) =>
                          'Q.${item['monthlyPrice']} · ${item['includedHours']} horas · ${item['active'] == true ? 'Activo' : 'Inactivo'}',
                      bottomPadding: bottom,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApiList extends StatelessWidget {
  const _ApiList({
    required this.future,
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.bottomPadding,
  });

  final Future<List<Map<String, dynamic>>> future;
  final String Function(Map<String, dynamic>) titleBuilder;
  final String Function(Map<String, dynamic>) subtitleBuilder;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ListView(
            padding: const EdgeInsets.all(32),
            children: [
              const SizedBox(height: 60),
              const Icon(
                Icons.admin_panel_settings_outlined,
                size: 58,
                color: CyclixColors.primaryBlue,
              ),
              const SizedBox(height: 16),
              Text(
                'No disponible con tu usuario',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                snapshot.error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: CyclixColors.instructionGray),
              ),
            ],
          );
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) return const Center(child: Text('Sin registros.'));

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomPadding),
          itemCount: items.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(titleBuilder(item)),
              subtitle: Text(subtitleBuilder(item)),
            );
          },
        );
      },
    );
  }
}
