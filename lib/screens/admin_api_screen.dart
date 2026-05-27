import 'package:flutter/material.dart';

import '../models/maintenance_order.dart';
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
      length: 7,
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
                  Tab(text: 'Tecnicos'),
                  Tab(text: 'Ordenes'),
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
                    _MaintenanceUsersTab(api: _api, bottomPadding: bottom),
                    _MaintenanceOrdersTab(api: _api, bottomPadding: bottom),
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

class _MaintenanceUsersTab extends StatefulWidget {
  const _MaintenanceUsersTab({required this.api, required this.bottomPadding});

  final CyclixApiService api;
  final double bottomPadding;

  @override
  State<_MaintenanceUsersTab> createState() => _MaintenanceUsersTabState();
}

class _MaintenanceUsersTabState extends State<_MaintenanceUsersTab> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _future;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = widget.api.getUsers();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = widget.api.getUsers();
    });
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      await widget.api.createMaintenanceUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _passwordController.clear();
      _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tecnico de mantenimiento creado.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo crear. $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        final users = snapshot.data ?? const <Map<String, dynamic>>[];
        final technicians = users
            .where(
              (user) => user['role']?.toString().toUpperCase() == 'MAINTENANCE',
            )
            .toList();

        return ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + widget.bottomPadding),
          children: [
            _SectionPanel(
              title: 'Registrar tecnico',
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _TextInput(
                      controller: _firstNameController,
                      label: 'Nombre',
                      validator: _required,
                    ),
                    _TextInput(
                      controller: _lastNameController,
                      label: 'Apellido',
                    ),
                    _TextInput(
                      controller: _emailController,
                      label: 'Correo',
                      keyboardType: TextInputType.emailAddress,
                      validator: _emailValidator,
                    ),
                    _TextInput(
                      controller: _phoneController,
                      label: 'Telefono',
                      keyboardType: TextInputType.phone,
                    ),
                    _TextInput(
                      controller: _passwordController,
                      label: 'Contrasena',
                      obscureText: true,
                      validator: _passwordValidator,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _createUser,
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.engineering_outlined),
                        label: const Text('Crear tecnico'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            _SectionPanel(
              title: 'Tecnicos activos',
              child: snapshot.connectionState != ConnectionState.done
                  ? const Center(child: CircularProgressIndicator())
                  : technicians.isEmpty
                  ? const Text('Aun no hay usuarios de mantenimiento.')
                  : Column(
                      children: [
                        for (final user in technicians)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.build_circle_outlined),
                            title: Text(
                              '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'
                                  .trim(),
                            ),
                            subtitle: Text(user['email']?.toString() ?? ''),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _MaintenanceOrdersTab extends StatefulWidget {
  const _MaintenanceOrdersTab({required this.api, required this.bottomPadding});

  final CyclixApiService api;
  final double bottomPadding;

  @override
  State<_MaintenanceOrdersTab> createState() => _MaintenanceOrdersTabState();
}

class _MaintenanceOrdersTabState extends State<_MaintenanceOrdersTab> {
  final _formKey = GlobalKey<FormState>();
  final _issueController = TextEditingController();
  final _locationController = TextEditingController();
  final _minutesController = TextEditingController(text: '30');
  late Future<_MaintenanceAdminData> _future;
  Object? _selectedBikeId;
  Object? _selectedTechnicianId;
  String _priority = 'MEDIUM';
  String _type = 'GENERAL';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _issueController.dispose();
    _locationController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  Future<_MaintenanceAdminData> _load() async {
    final users = await widget.api.getUsers();
    final bikes = await widget.api.getBikes();
    final orders = await widget.api.getAdminMaintenanceOrders();
    return _MaintenanceAdminData(users: users, bikes: bikes, orders: orders);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    if (_selectedBikeId == null) {
      _showSnack('Selecciona una bicicleta.');
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.api.createAdminMaintenanceOrder(
        bikeId: _selectedBikeId!,
        assignedToUserId: _selectedTechnicianId,
        priority: _priority,
        type: _type,
        reportedIssue: _issueController.text.trim(),
        estimatedMinutes: int.tryParse(_minutesController.text.trim()),
        currentLocation: _locationController.text,
      );
      _issueController.clear();
      _locationController.clear();
      _minutesController.text = '30';
      _reload();
      _showSnack('Orden de mantenimiento creada.');
    } catch (e) {
      _showSnack('No se pudo crear la orden. $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_MaintenanceAdminData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done &&
            snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ListView(
            padding: EdgeInsets.fromLTRB(32, 56, 32, 24 + widget.bottomPadding),
            children: [
              const Icon(
                Icons.admin_panel_settings_outlined,
                size: 58,
                color: CyclixColors.primaryBlue,
              ),
              const SizedBox(height: 16),
              Text(
                'Modulo no disponible',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(snapshot.error.toString(), textAlign: TextAlign.center),
            ],
          );
        }

        final data = snapshot.data!;
        final technicians = data.users
            .where(
              (user) => user['role']?.toString().toUpperCase() == 'MAINTENANCE',
            )
            .toList();
        final availableBikes = data.bikes.where((bike) {
          final status = bike['estado']?.toString().toUpperCase();
          return status != 'EN_USO' && status != 'RESERVADA';
        }).toList();
        final bikeIds = availableBikes.map((bike) => bike['id']).toSet();
        final technicianIds = technicians.map((user) => user['id']).toSet();

        if (!bikeIds.contains(_selectedBikeId)) {
          _selectedBikeId = null;
        }
        if (!technicianIds.contains(_selectedTechnicianId)) {
          _selectedTechnicianId = null;
        }
        if (_selectedBikeId == null && availableBikes.isNotEmpty) {
          _selectedBikeId = availableBikes.first['id'];
        }

        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + widget.bottomPadding),
            children: [
              _SectionPanel(
                title: 'Nueva orden',
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<Object>(
                        initialValue: _selectedBikeId,
                        decoration: _inputDecoration('Bicicleta'),
                        items: [
                          for (final bike in availableBikes)
                            DropdownMenuItem<Object>(
                              value: bike['id'],
                              child: Text(
                                '${bike['codigo']} · ${bike['estado']}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedBikeId = value),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Object?>(
                        initialValue: _selectedTechnicianId,
                        decoration: _inputDecoration('Asignar tecnico'),
                        items: [
                          const DropdownMenuItem<Object?>(
                            value: null,
                            child: Text('Sin asignar por ahora'),
                          ),
                          for (final user in technicians)
                            DropdownMenuItem<Object?>(
                              value: user['id'],
                              child: Text(
                                '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'
                                    .trim(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedTechnicianId = value),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _priority,
                              decoration: _inputDecoration('Prioridad'),
                              items: const [
                                DropdownMenuItem(
                                  value: 'LOW',
                                  child: Text('Baja'),
                                ),
                                DropdownMenuItem(
                                  value: 'MEDIUM',
                                  child: Text('Media'),
                                ),
                                DropdownMenuItem(
                                  value: 'HIGH',
                                  child: Text('Alta'),
                                ),
                                DropdownMenuItem(
                                  value: 'CRITICAL',
                                  child: Text('Critica'),
                                ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _priority = value ?? 'MEDIUM'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _type,
                              decoration: _inputDecoration('Tipo'),
                              items: const [
                                DropdownMenuItem(
                                  value: 'GENERAL',
                                  child: Text('General'),
                                ),
                                DropdownMenuItem(
                                  value: 'BRAKES',
                                  child: Text('Frenos'),
                                ),
                                DropdownMenuItem(
                                  value: 'TIRES',
                                  child: Text('Llantas'),
                                ),
                                DropdownMenuItem(
                                  value: 'CHAIN',
                                  child: Text('Cadena'),
                                ),
                                DropdownMenuItem(
                                  value: 'PREVENTIVE',
                                  child: Text('Preventivo'),
                                ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _type = value ?? 'GENERAL'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _TextInput(
                        controller: _issueController,
                        label: 'Problema reportado',
                        maxLines: 3,
                        validator: _required,
                      ),
                      _TextInput(
                        controller: _locationController,
                        label: 'Ubicacion actual',
                      ),
                      _TextInput(
                        controller: _minutesController,
                        label: 'Minutos estimados',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _createOrder,
                          icon: const Icon(Icons.add_task_outlined),
                          label: const Text('Crear orden'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _SectionPanel(
                title: 'Ordenes recientes',
                child: data.orders.isEmpty
                    ? const Text('Aun no hay ordenes de mantenimiento.')
                    : Column(
                        children: [
                          for (final order in data.orders)
                            _MaintenanceOrderTile(order: order),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MaintenanceOrderTile extends StatelessWidget {
  const _MaintenanceOrderTile({required this.order});

  final MaintenanceOrder order;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.pedal_bike_outlined),
      title: Text('Orden #${order.id} · ${order.bike.codigo}'),
      subtitle: Text(
        '${_statusLabel(order.status)} · ${order.assignedTo?.fullName ?? 'Sin tecnico'}',
      ),
      trailing: Text(_priorityLabel(order.priority)),
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

class _SectionPanel extends StatelessWidget {
  const _SectionPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6EAF0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: CyclixColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: obscureText ? 1 : maxLines,
        validator: validator,
        decoration: _inputDecoration(label),
      ),
    );
  }
}

class _MaintenanceAdminData {
  const _MaintenanceAdminData({
    required this.users,
    required this.bikes,
    required this.orders,
  });

  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> bikes;
  final List<MaintenanceOrder> orders;
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE6EAF0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: CyclixColors.primaryBlue),
    ),
  );
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) return 'Campo obligatorio';
  return null;
}

String? _emailValidator(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return 'Campo obligatorio';
  if (!raw.contains('@') || !raw.contains('.')) return 'Correo invalido';
  return null;
}

String? _passwordValidator(String? value) {
  final raw = value ?? '';
  if (raw.length < 8) return 'Minimo 8 caracteres';
  return null;
}

String _statusLabel(String value) {
  return switch (value) {
    'PENDING' => 'Nuevo',
    'ASSIGNED' => 'Asignada',
    'IN_REVIEW' => 'En revision',
    'IN_REPAIR' => 'En reparacion',
    'WAITING_PARTS' => 'Esperando repuestos',
    'PAUSED' => 'Pausada',
    'FINALIZED' => 'Finalizada',
    _ => value,
  };
}

String _priorityLabel(String value) {
  return switch (value) {
    'LOW' => 'Baja',
    'MEDIUM' => 'Media',
    'HIGH' => 'Alta',
    'CRITICAL' => 'Critica',
    _ => value,
  };
}
