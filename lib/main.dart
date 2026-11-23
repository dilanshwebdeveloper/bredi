import 'package:flutter/material.dart';

void main() {
  runApp(const BrediErpApp());
}

class BrediErpApp extends StatefulWidget {
  const BrediErpApp({super.key});

  @override
  State<BrediErpApp> createState() => _BrediErpAppState();
}

class _BrediErpAppState extends State<BrediErpApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF176B52);
    return MaterialApp(
      title: 'B.R. Edible Oils ERP',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE7ECE9))),
        ),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        cardTheme: CardTheme(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      ),
      home: ErpShell(onThemeChanged: (dark) => setState(() => _themeMode = dark ? ThemeMode.dark : ThemeMode.light)),
    );
  }
}

class ErpShell extends StatefulWidget {
  const ErpShell({required this.onThemeChanged, super.key});
  final ValueChanged<bool> onThemeChanged;

  @override
  State<ErpShell> createState() => _ErpShellState();
}

class _ErpShellState extends State<ErpShell> {
  int _selected = 0;
  bool _dark = false;

  static const _sections = <ErpSection>[
    ErpSection('Overview', Icons.space_dashboard_outlined, 'Dashboard'),
    ErpSection('Purchasing', Icons.shopping_cart_outlined, 'Purchase management'),
    ErpSection('Production', Icons.precision_manufacturing_outlined, 'Production management'),
    ErpSection('Inventory', Icons.warehouse_outlined, 'Inventory & godowns'),
    ErpSection('Oil tanks', Icons.water_drop_outlined, 'Oil tank management'),
    ErpSection('Khali', Icons.grass_outlined, 'Khali management'),
    ErpSection('Quality control', Icons.verified_outlined, 'Quality control'),
    ErpSection('Sales & dispatch', Icons.local_shipping_outlined, 'Sales & dispatch'),
    ErpSection('GST & accounts', Icons.receipt_long_outlined, 'GST billing & accounting'),
    ErpSection('People', Icons.groups_outlined, 'Staff & attendance'),
    ErpSection('Reports', Icons.query_stats_outlined, 'Business analytics'),
    ErpSection('Administration', Icons.admin_panel_settings_outlined, 'Users & administration'),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final body = _selected == 0 ? const DashboardPage() : ModulePage(section: _sections[_selected]);
    return Scaffold(
      body: SafeArea(
        child: Row(children: [
          if (wide) _sidebar(context),
          Expanded(child: Column(children: [
            _topBar(context, wide),
            Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 220), child: KeyedSubtree(key: ValueKey(_selected), child: body))),
          ])),
        ]),
      ),
      bottomNavigationBar: wide ? null : NavigationBar(
        selectedIndex: _selected > 4 ? 0 : _selected,
        onDestinationSelected: (index) => setState(() => _selected = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: 'Purchase'),
          NavigationDestination(icon: Icon(Icons.precision_manufacturing_outlined), label: 'Production'),
          NavigationDestination(icon: Icon(Icons.warehouse_outlined), label: 'Stock'),
          NavigationDestination(icon: Icon(Icons.menu), label: 'More'),
        ],
      ),
    );
  }

  Widget _sidebar(BuildContext context) => Container(
    width: 248,
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, border: Border(right: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: .25)))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Padding(padding: EdgeInsets.fromLTRB(20, 22, 16, 22), child: BrandHeader()),
      const Divider(height: 1),
      Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12), children: [
        for (var i = 0; i < _sections.length; i++)
          Padding(padding: const EdgeInsets.only(bottom: 3), child: ListTile(
            dense: true, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            selected: _selected == i,
            selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .65),
            leading: Icon(_sections[i].icon, size: 20), title: Text(_sections[i].title, style: const TextStyle(fontSize: 13)),
            onTap: () => setState(() => _selected = i),
          )),
      ])),
      const Divider(height: 1),
      ListTile(leading: Icon(_dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined), title: Text(_dark ? 'Light appearance' : 'Dark appearance'), onTap: () { setState(() => _dark = !_dark); widget.onThemeChanged(_dark); }),
      const ListTile(leading: CircleAvatar(radius: 17, child: Icon(Icons.person_outline, size: 18)), title: Text('Administrator'), subtitle: Text('Local demonstration'), dense: true),
    ]),
  );

  Widget _topBar(BuildContext context, bool wide) => Container(
    height: 72,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: .25)))),
    child: Row(children: [
      if (!wide) const Expanded(child: BrandHeader(compact: true)) else Expanded(child: Text(_sections[_selected].subtitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
      IconButton(tooltip: 'Notifications', onPressed: () => _message('Notifications will appear here.'), icon: const Icon(Icons.notifications_none)),
      const SizedBox(width: 8),
      if (wide) const Chip(avatar: Icon(Icons.cloud_off_outlined, size: 16), label: Text('Demo mode'), visualDensity: VisualDensity.compact),
    ]),
  );

  void _message(String value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
}

class ErpSection {
  const ErpSection(this.title, this.icon, this.subtitle);
  final String title;
  final IconData icon;
  final String subtitle;
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({this.compact = false, super.key});
  final bool compact;
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 39, height: 39, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.grain, color: Colors.white)),
    const SizedBox(width: 11),
    Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(compact ? 'B.R. Edible Oils' : 'B.R. Edible Oils', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      if (!compact) const Text('FACTORY ERP', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Colors.grey)),
    ])),
  ]);
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final compact = constraints.maxWidth < 700;
    return SingleChildScrollView(padding: EdgeInsets.all(compact ? 16 : 28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, runSpacing: 12, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Factory overview', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)), const SizedBox(height: 4), const Text('A live view of your operations · Tonk, Rajasthan')]),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.calendar_today_outlined, size: 17), label: const Text('Today')),
      ]),
      const SizedBox(height: 22),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: compact ? 2 : 4, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: compact ? 1.38 : 1.75, children: const [
        MetricCard(label: 'Production today', value: '— MT', note: 'No entries recorded', icon: Icons.precision_manufacturing_outlined, color: Color(0xFF176B52)),
        MetricCard(label: 'Seed stock', value: '— KG', note: 'Across 5 godowns', icon: Icons.grain, color: Color(0xFFB7791F)),
        MetricCard(label: 'Oil in tanks', value: '— L', note: 'Capacity 175,000 L', icon: Icons.water_drop_outlined, color: Color(0xFF2775A5)),
        MetricCard(label: 'Khali stock', value: '— KG', note: 'Dedicated godown', icon: Icons.inventory_2_outlined, color: Color(0xFF7B5AA6)),
      ]),
      const SizedBox(height: 20),
      Wrap(spacing: 16, runSpacing: 16, crossAxisAlignment: WrapCrossAlignment.start, children: [
        SizedBox(width: compact ? constraints.maxWidth : (constraints.maxWidth - 16) * .59, child: _productionCard(context)),
        SizedBox(width: compact ? constraints.maxWidth : (constraints.maxWidth - 16) * .41, child: _factoryCard(context)),
      ]),
      const SizedBox(height: 20),
      _activityCard(context),
    ]));
  });

  Widget _productionCard(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [const Expanded(child: Text('Production snapshot', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))), Icon(Icons.more_horiz, color: Theme.of(context).hintColor)]),
    const SizedBox(height: 12),
    Container(height: 182, width: double.infinity, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .045), borderRadius: BorderRadius.circular(12)), child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.show_chart, size: 35, color: Color(0xFF176B52)), SizedBox(height: 8), Text('Production entries will appear here', style: TextStyle(color: Colors.grey))]))),
    const SizedBox(height: 14),
    const Row(children: [Expanded(child: _LegendDot(color: Color(0xFF176B52), label: 'Mustard oil')), Expanded(child: _LegendDot(color: Color(0xFFB7791F), label: 'Mustard Khali'))]),
  ])));

  Widget _factoryCard(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Factory configuration', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)), const SizedBox(height: 16),
    const _InfoRow(icon: Icons.factory_outlined, label: 'Daily capacity', value: '100 MT'),
    const _InfoRow(icon: Icons.precision_manufacturing_outlined, label: 'Production machines', value: '10 machines'),
    const _InfoRow(icon: Icons.schedule_outlined, label: 'Shifts', value: '2 × 12 hours'),
    const _InfoRow(icon: Icons.warehouse_outlined, label: 'Godowns', value: '5 seed · 1 Khali'),
    const _InfoRow(icon: Icons.water_drop_outlined, label: 'Oil storage', value: '7 × 25,000 L'),
    const SizedBox(height: 8),
    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: .45), borderRadius: BorderRadius.circular(10)), child: const Row(children: [Icon(Icons.info_outline, size: 17), SizedBox(width: 8), Expanded(child: Text('Mechanical extraction only · No refining or bottling', style: TextStyle(fontSize: 12)))])),
  ])));

  Widget _activityCard(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Recent activity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)), const SizedBox(height: 16), const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Your purchases, production, dispatches and stock movements will be listed here.', style: TextStyle(color: Colors.grey))))])));
}

class MetricCard extends StatelessWidget {
  const MetricCard({required this.label, required this.value, required this.note, required this.icon, required this.color, super.key});
  final String label, value, note;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Row(children: [Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor))), Icon(icon, size: 19, color: color)]),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(note, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor))]),
  ])));
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon; final String label, value;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 13), child: Row(children: [Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 10), Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor))), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))]));
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color; final String label;
  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 7), Text(label, style: const TextStyle(fontSize: 12))]);
}

class ModulePage extends StatelessWidget {
  const ModulePage({required this.section, super.key});
  final ErpSection section;
  static const modules = {
    'Purchase management': 'Supplier records, purchase orders, seed receipts, weighment slips and payment tracking.',
    'Production management': 'Machine-wise and shift-wise seed consumption, oil and Khali outputs, efficiency and wastage.',
    'Inventory & godowns': 'Stock ledger and transfers for five seed godowns and one dedicated Khali godown. KG is the base unit.',
    'Oil tank management': 'Seven tanks, each with a nominal capacity of 25,000 litres. Configure oil density for KG/L conversion.',
    'Khali management': 'Record production by-product, godown stock, sales, dispatches and reports.',
    'Quality control': 'Raw seed checks and batch-wise oil quality, rejection and quality records.',
    'Sales & dispatch': 'Customer records, orders, invoices, Rajasthan/interstate dispatch and manual weighbridge slips.',
    'GST billing & accounting': 'GST invoice workflows and TallyPrime export are not active until implemented and verified. IRNs require an authorized integration.',
    'Staff & attendance': 'Employee records, shifts, check-in/out, leave, overtime and payroll workflows.',
    'Business analytics': 'Production, purchase, sales, valuation, efficiency, attendance, expense and profitability reports.',
    'Users & administration': 'Company profile, role permissions, audit trail, data backup and notification settings.',
  };
  @override
  Widget build(BuildContext context) {
    final details = modules[section.subtitle] ?? 'Operational records and reports for this module.';
    return SingleChildScrollView(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(section.icon, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 12), Expanded(child: Text(section.subtitle, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)))]),
      const SizedBox(height: 8), Text(details, style: TextStyle(color: Theme.of(context).hintColor, height: 1.5)),
      const SizedBox(height: 24),
      Card(child: Padding(padding: const EdgeInsets.all(26), child: Center(child: Column(children: [Icon(Icons.construction_outlined, size: 38, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 14), const Text('Module setup required', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)), const SizedBox(height: 8), const Text('This module is a navigation placeholder. Connect Firebase and implement validated transaction workflows before recording live business data.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, height: 1.5)), const SizedBox(height: 16), const Chip(label: Text('Demonstration only'))])))),
      const SizedBox(height: 20),
      const Card(child: Padding(padding: EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Company profile', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height: 14), Text('B.R. Edible Oils Pvt. Ltd.'), SizedBox(height: 5), Text('F-2 & 3, RIICO Industrial Area, Tonk, Rajasthan – 304001, India', style: TextStyle(color: Colors.grey)), SizedBox(height: 5), Text('GSTIN 08AAECB3374K1ZH  ·  FSSAI 12221999000180', style: TextStyle(color: Colors.grey))]))),
    ]));
  }
}
