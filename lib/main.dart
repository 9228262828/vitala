import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final c = AppController();
  await c.load();
  runApp(Vitala(controller: c));
}

String uid() => '${DateTime
    .now()
    .microsecondsSinceEpoch}_${Random().nextInt(999999)}';

enum RecordType {
  bloodPressure,
  bloodSugar,
  weight,
  temperature,
  heartRate,
  oxygen,
  water,
  sleep,
  mood,
  note
}
extension RecordTypeX on RecordType {
  String get label =>
      switch(this){
        RecordType.bloodPressure => 'Blood Pressure', RecordType
          .bloodSugar => 'Blood Sugar', RecordType
          .weight => 'Weight', RecordType
          .temperature => 'Temperature', RecordType
          .heartRate => 'Heart Rate', RecordType
          .oxygen => 'Oxygen Level', RecordType
          .water => 'Water Intake', RecordType.sleep => 'Sleep', RecordType
          .mood => 'Mood', RecordType.note => 'General Note'
      };

  String get unit =>
      switch(this){
        RecordType.bloodPressure => 'mmHg', RecordType
          .bloodSugar => 'mg/dL', RecordType.weight => 'kg', RecordType
          .temperature => '°C', RecordType.heartRate => 'bpm', RecordType
          .oxygen => '%', RecordType.water => 'ml', RecordType
          .sleep => 'hours', RecordType.mood => '', RecordType.note => ''
      };

  IconData get icon =>
      switch(this){
        RecordType.bloodPressure => Icons.monitor_heart_outlined, RecordType
          .bloodSugar => Icons.bloodtype_outlined, RecordType.weight =>
      Icons.monitor_weight_outlined, RecordType.temperature =>
      Icons.thermostat_outlined, RecordType.heartRate =>
      Icons.favorite_outline, RecordType.oxygen => Icons.air, RecordType
          .water => Icons.water_drop_outlined, RecordType.sleep =>
      Icons.bedtime_outlined, RecordType.mood =>
      Icons.sentiment_satisfied_alt, RecordType.note => Icons.notes
      };
}

class HealthRecord {
  HealthRecord(
      {required this.id, required this.type, required this.dateTime, this.a, this.b, this.c, this.notes = '', this.extra = const{
      }});

  final String id;
  final RecordType type;
  final double? a, b, c;
  final DateTime dateTime;
  final String notes;
  final Map<String, dynamic> extra;

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'type': type.name,
        'a': a,
        'b': b,
        'c': c,
        'dateTime': dateTime.toIso8601String(),
        'notes': notes,
        'extra': extra
      };

  factory HealthRecord.fromJson(Map<String, dynamic> j)=>
      HealthRecord(id: textOf(j['id'], fallback: uid()),
          type: RecordType.values.firstWhere((e) => e.name == j['type'],
              orElse: () => RecordType.note),
          a: doubleOf(j['a']),
          b: doubleOf(j['b']),
          c: doubleOf(j['c']),
          dateTime: dateOf(j['dateTime']),
          notes: textOf(j['notes']),
          extra: mapOf(j['extra']));

  String get value =>
      switch(type){
        RecordType.bloodPressure => '${fmt(a)}/${fmt(b)} mmHg', RecordType
          .mood => '${extra['mood'] ?? 'Mood'}', RecordType
          .note => '${extra['title'] ?? 'Note'}', RecordType.sleep => '${fmt(
          a)} hours', _ => '${fmt(a)} ${type.unit}'
      };
}

class Medication {
  Medication(
      {required this.id, required this.name, required this.dosage, required this.unit, required this.frequency, required this.startDate, this.endDate, this.instructions = '', this.notes = '', this.active = true, DateTime? createdAt})
      :createdAt=createdAt ?? DateTime.now();
  final String id, name, dosage, unit, frequency, instructions, notes;
  final DateTime startDate, createdAt;
  final DateTime? endDate;
  final bool active;

  Medication copyWith({bool? active}) =>
      Medication(id: id,
          name: name,
          dosage: dosage,
          unit: unit,
          frequency: frequency,
          startDate: startDate,
          endDate: endDate,
          instructions: instructions,
          notes: notes,
          active: active ?? this.active,
          createdAt: createdAt);

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'dosage': dosage,
        'unit': unit,
        'frequency': frequency,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'instructions': instructions,
        'notes': notes,
        'active': active,
        'createdAt': createdAt.toIso8601String()
      };

  factory Medication.fromJson(Map<String, dynamic> j)=>
      Medication(id: textOf(j['id'], fallback: uid()),
          name: textOf(j['name']),
          dosage: textOf(j['dosage']),
          unit: textOf(j['unit'], fallback: 'Tablet'),
          frequency: textOf(j['frequency'], fallback: 'Once daily'),
          startDate: dateOf(j['startDate']),
          endDate: nullableDateOf(j['endDate']),
          instructions: textOf(j['instructions']),
          notes: textOf(j['notes']),
          active: j['active'] != false,
          createdAt: nullableDateOf(j['createdAt']));
}

class Intake {
  Intake(
      {required this.id, required this.medicationId, required this.name, required this.dosage, required this.takenAt});

  final String id, medicationId, name, dosage;
  final DateTime takenAt;

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'medicationId': medicationId,
        'name': name,
        'dosage': dosage,
        'takenAt': takenAt.toIso8601String()
      };

  factory Intake.fromJson(Map<String, dynamic> j)=>
      Intake(id: textOf(j['id'], fallback: uid()),
          medicationId: textOf(j['medicationId']),
          name: textOf(j['name']),
          dosage: textOf(j['dosage']),
          takenAt: dateOf(j['takenAt']));
}

class Symptom {
  Symptom(
      {required this.id, required this.name, required this.severity, required this.dateTime, this.duration = '', this.trigger = '', this.notes = ''});

  final String id, name, duration, trigger, notes;
  final int severity;
  final DateTime dateTime;

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'severity': severity,
        'dateTime': dateTime.toIso8601String(),
        'duration': duration,
        'trigger': trigger,
        'notes': notes
      };

  factory Symptom.fromJson(Map<String, dynamic> j)=>
      Symptom(id: textOf(j['id'], fallback: uid()),
          name: textOf(j['name']),
          severity: intOf(j['severity'], fallback: 1, min: 1, max: 10),
          dateTime: dateOf(j['dateTime']),
          duration: textOf(j['duration']),
          trigger: textOf(j['trigger']),
          notes: textOf(j['notes']));
}

class Settings {
  const Settings(
      {this.mode = ThemeMode.system, this.waterGoal = 2000, this.tips = true});

  final ThemeMode mode;
  final int waterGoal;
  final bool tips;

  Settings copyWith({ThemeMode? mode, int? waterGoal, bool? tips}) =>
      Settings(mode: mode ?? this.mode,
          waterGoal: waterGoal ?? this.waterGoal,
          tips: tips ?? this.tips);

  Map<String, dynamic> toJson() =>
      {'mode': mode.name, 'waterGoal': waterGoal, 'tips': tips};

  factory Settings.fromJson(Map<String, dynamic> j)=>
      Settings(mode: ThemeMode.values.firstWhere((e) => e.name == j['mode'],
          orElse: () => ThemeMode.system),
          waterGoal: intOf(j['waterGoal'],
              fallback: 2000, min: 250, max: 10000),
          tips: j['tips'] != false);
}

double? doubleOf(dynamic v) {
  final n = v is num
      ? v.toDouble()
      : v is String
          ? double.tryParse(v.trim())
          : null;
  return n == null || !n.isFinite ? null : n;
}

int intOf(dynamic v,
    {required int fallback, int? min, int? max}) {
  final n = doubleOf(v)?.toInt();
  final clamped = (n ?? fallback).clamp(min ?? -0x7fffffff, max ?? 0x7fffffff);
  return clamped.toInt();
}

DateTime dateOf(dynamic v) => nullableDateOf(v) ?? DateTime.now();

DateTime? nullableDateOf(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  return DateTime.tryParse('$v');
}

String textOf(dynamic v, {String fallback = ''}) {
  if (v == null) return fallback;
  final s = '$v';
  return s.isEmpty ? fallback : s;
}

Map<String, dynamic> mapOf(dynamic v) {
  if (v is! Map) return {};
  final m = <String, dynamic>{};
  v.forEach((key, value) {
    if (key is String) m[key] = value;
  });
  return m;
}

class Store {
  Future<SharedPreferences> get p => SharedPreferences.getInstance();

  Future<List<T>> list<T>(String k, T Function(Map<String, dynamic>) f) async {
    try {
      final s = (await p).getString(k);
      if (s == null) return [];
      final decoded = jsonDecode(s);
      if (decoded is! List) return [];
      final items = <T>[];
      for (final e in decoded) {
        if (e is! Map) continue;
        try {
          items.add(f(mapOf(e)));
        } catch (_) {}
      }
      return items;
    } catch (_) {
      return [];
    }
  }

  Future<void> save(String k, List<Map<String, dynamic>> v) async {
    try {
      await(await p).setString(k, jsonEncode(v));
    } catch (_) {}
  }
}

class AppController extends ChangeNotifier {
  final store = Store();
  List<HealthRecord> records = [];
  List<Medication> meds = [];
  List<Intake> intakes = [];
  List<Symptom> symptoms = [];
  Settings settings = const Settings();
  bool firstSeen = true;

  Future<void> load() async {
    records = await store.list('vitala_health_records', HealthRecord.fromJson);
    meds = await store.list('vitala_medications', Medication.fromJson);
    intakes = await store.list('vitala_medication_intakes', Intake.fromJson);
    symptoms = await store.list('vitala_symptoms', Symptom.fromJson);
    try {
      final p = await store.p;
      final s = p.getString('vitala_app_settings');
      if (s != null) {
        try {
          settings = Settings.fromJson(mapOf(jsonDecode(s)));
        } catch (_) {}
      }
      firstSeen = p.getBool('vitala_first_launch') ?? false;
    } catch (_) {}
    sort();
  }

  void sort() {
    records.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    symptoms.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    intakes.sort((a, b) => b.takenAt.compareTo(a.takenAt));
  }

  Future<void> addRecord(HealthRecord r) async {
    records.add(r);
    sort();
    notifyListeners();
    await store.save(
        'vitala_health_records', records.map((e) => e.toJson()).toList());
  }

  Future<void> updateRecord(HealthRecord r) async {
    final i = records.indexWhere((e) => e.id == r.id);
    if (i >= 0) records[i] = r;
    sort();
    notifyListeners();
    await store.save(
        'vitala_health_records', records.map((e) => e.toJson()).toList());
  }

  Future<void> deleteRecord(HealthRecord r) async {
    records.removeWhere((e) => e.id == r.id);
    notifyListeners();
    await store.save(
        'vitala_health_records', records.map((e) => e.toJson()).toList());
  }

  Future<void> addMed(Medication m) async {
    meds.add(m);
    notifyListeners();
    await store.save(
        'vitala_medications', meds.map((e) => e.toJson()).toList());
  }

  Future<void> setMed(Medication m) async {
    final i = meds.indexWhere((e) => e.id == m.id);
    if (i >= 0) meds[i] = m;
    notifyListeners();
    await store.save(
        'vitala_medications', meds.map((e) => e.toJson()).toList());
  }

  Future<void> delMed(Medication m) async {
    meds.removeWhere((e) => e.id == m.id);
    notifyListeners();
    await store.save(
        'vitala_medications', meds.map((e) => e.toJson()).toList());
  }

  Future<void> taken(Medication m) async {
    intakes.add(Intake(id: uid(),
        medicationId: m.id,
        name: m.name,
        dosage: '${m.dosage} ${m.unit}',
        takenAt: DateTime.now()));
    sort();
    notifyListeners();
    await store.save(
        'vitala_medication_intakes', intakes.map((e) => e.toJson()).toList());
  }

  Future<void> addSymptom(Symptom s) async {
    symptoms.add(s);
    sort();
    notifyListeners();
    await store.save(
        'vitala_symptoms', symptoms.map((e) => e.toJson()).toList());
  }

  Future<void> delSymptom(Symptom s) async {
    symptoms.removeWhere((e) => e.id == s.id);
    notifyListeners();
    await store.save(
        'vitala_symptoms', symptoms.map((e) => e.toJson()).toList());
  }

  Future<void> setSettings(Settings s) async {
    settings = s;
    notifyListeners();
    try {
      await(await store.p).setString(
          'vitala_app_settings', jsonEncode(s.toJson()));
    } catch (_) {}
  }

  Future<void> accept() async {
    firstSeen = true;
    notifyListeners();
    try {
      await(await store.p).setBool('vitala_first_launch', true);
    } catch (_) {}
  }

  Future<void> clear() async {
    records.clear();
    meds.clear();
    intakes.clear();
    symptoms.clear();
    settings = const Settings();
    notifyListeners();
    try {
      final p = await store.p;
      for (final k in [
        'vitala_health_records',
        'vitala_medications',
        'vitala_medication_intakes',
        'vitala_symptoms',
        'vitala_app_settings'
      ])
        await p.remove(k);
    } catch (_) {}
  }

  double get waterToday =>
      records.where((e) =>
      e.type == RecordType.water &&
          DateUtils.isSameDay(e.dateTime, DateTime.now())).fold(
          0, (s, e) => s + (e.a ?? 0));
}

class Scope extends InheritedNotifier<AppController> {
  const Scope(
      {super.key, required AppController controller, required super.child})
      :super(notifier: controller);

  static AppController of(BuildContext c) =>
      c.dependOnInheritedWidgetOfExactType<Scope>()!.notifier!;
}

class Vitala extends StatefulWidget {
  const Vitala({super.key, required this.controller});

  final AppController controller;

  @override State<Vitala> createState() => _VitalaState();
}

class _VitalaState extends State<Vitala> {
  late ThemeMode mode;

  @override void initState() {
    super.initState();
    mode = widget.controller.settings.mode;
    widget.controller.addListener(syncThemeMode);
  }

  @override void didUpdateWidget(Vitala oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(syncThemeMode);
    mode = widget.controller.settings.mode;
    widget.controller.addListener(syncThemeMode);
  }

  void syncThemeMode() {
    final next = widget.controller.settings.mode;
    if (next == mode || !mounted) return;
    setState(() => mode = next);
  }

  @override void dispose() {
    widget.controller.removeListener(syncThemeMode);
    widget.controller.dispose();
    super.dispose();
  }

  @override Widget build(BuildContext context) =>
      Scope(controller: widget.controller,
          child: MaterialApp(debugShowCheckedModeBanner: false,
              title: 'Vitala',
              themeMode: mode,
              theme: theme(Brightness.light),
              darkTheme: theme(Brightness.dark),
              home: const Splash()));

  ThemeData theme(Brightness b) {
    final cs = ColorScheme.fromSeed(
        seedColor: const Color(0xff15977e), brightness: b);
    return ThemeData(useMaterial3: true,
        colorScheme: cs,
        scaffoldBackgroundColor: b == Brightness.dark
            ? const Color(0xff0d1514)
            : const Color(0xfff4f8f7),
        cardTheme: CardThemeData(elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22))),
        inputDecorationTheme: InputDecorationTheme(filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none)));
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  double s = .8,
      o = 0;

  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {
        s = 1;
        o = 1;
      });
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const Shell()));
    });
  }

  @override Widget build(BuildContext c) =>
      Scaffold(body: Center(child: AnimatedOpacity(opacity: o,
          duration: const Duration(milliseconds: 800),
          child: AnimatedScale(scale: s,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              child: Column(mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 110,
                        height: 110,
                        decoration: BoxDecoration(color: Theme
                            .of(c)
                            .colorScheme
                            .primary, borderRadius: BorderRadius.circular(34)),
                        child: const Icon(
                            Icons.eco, color: Colors.white, size: 58)),
                    const SizedBox(height: 20),
                    Text('Vitala', style: Theme
                        .of(c)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontWeight: FontWeight.w900)),
                    const Text('Your personal wellness journal')
                  ])))));
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;
  bool welcomeQueued = false;
  final pages = const[
    Dashboard(),
    History(),
    SizedBox(),
    Insights(),
    SettingsPage()
  ];

  @override void didChangeDependencies() {
    super.didChangeDependencies();
    final c = Scope.of(context);
    if (!c.firstSeen && !welcomeQueued) {
      welcomeQueued = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await welcome(context);
        if (mounted) welcomeQueued = false;
      });
    }
  }

  @override Widget build(BuildContext c) =>
      Scaffold(body: SafeArea(
          bottom: false, child: IndexedStack(index: i, children: pages)),
          floatingActionButton: FloatingActionButton.large(
              onPressed: () => addHub(c), child: const Icon(Icons.add)),
          floatingActionButtonLocation: FloatingActionButtonLocation
              .centerDocked,
          bottomNavigationBar: NavigationBar(selectedIndex: i,
              onDestinationSelected: (v) {
                if (v == 2)
                  addHub(c);
                else
                  setState(() => i = v);
              },
              destinations: const[
                NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
                NavigationDestination(
                    icon: Icon(Icons.history), label: 'History'),
                NavigationDestination(icon: SizedBox(width: 30), label: 'Add'),
                NavigationDestination(
                    icon: Icon(Icons.insights), label: 'Insights'),
                NavigationDestination(
                    icon: Icon(Icons.settings), label: 'Settings')
              ]));
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override Widget build(BuildContext c) {
    final x = Scope.of(c);
    final now = DateTime.now();
    final waterGoal = max(1, x.settings.waterGoal);
    return ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
        children: [
          Text(now.hour < 12 ? 'Good morning' : now.hour < 18
              ? 'Good afternoon'
              : 'Good evening', style: Theme
              .of(c)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w900)),
          Text(DateFormat('EEEE, MMM d, y').format(now)),
          const SizedBox(height: 18),
          Card(child: Padding(padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daily wellness', style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Text('Water today: ${fmt(x.waterToday)} / $waterGoal ml'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                        value: (x.waterToday / waterGoal).clamp(
                            0.0, 1.0).toDouble())
                  ]))),
          const SizedBox(height: 22),
          const Header('Today overview'),
          const SizedBox(height: 10),
          GridView.count(crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: RecordType.values.take(8).map((t) {
                final r = x.records
                    .where((e) => e.type == t)
                    .firstOrNull;
                return Card(child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => recordEditor(c, t, r: null),
                    child: Padding(padding: const EdgeInsets.all(14),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(t.icon, color: Theme
                                  .of(c)
                                  .colorScheme
                                  .primary),
                              const Spacer(),
                              Text(t.label, maxLines: 1, overflow: TextOverflow
                                  .ellipsis),
                              Text(r?.value ?? 'No record yet', maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800))
                            ]))));
              }).toList()),
          const SizedBox(height: 22),
          const Header('Recent records'),
          const SizedBox(height: 10),
          if(x.records.isEmpty)Empty(icon: Icons.health_and_safety_outlined,
              title: 'No health records yet',
              text: 'Add your first measurement or wellness entry.',
              button: 'Add record',
              tap: () => typePicker(c)) else
            ...x.records.take(5).map((r) => RecordTile(r))
        ]);
  }
}

class History extends StatelessWidget {
  const History({super.key});

  @override Widget build(BuildContext c) {
    final x = Scope.of(c);
    return ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
        children: [
          Text('History', style: Theme
              .of(c)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          NavCard(Icons.monitor_heart_outlined, 'Health records',
              '${x.records.length} saved entries', () {
                if (!c.mounted) return;
                Navigator.push(c,
                    MaterialPageRoute(builder: (_) => const RecordsPage()));
              }),
          NavCard(Icons.medication_outlined, 'Medications', '${x.meds
              .where((e) => e.active)
              .length} active', () {
                if (!c.mounted) return;
                Navigator.push(
                    c, MaterialPageRoute(builder: (_) => const MedsPage()));
              }),
          NavCard(Icons.sick_outlined, 'Symptoms journal',
              '${x.symptoms.length} logged', () {
                if (!c.mounted) return;
                Navigator.push(c,
                    MaterialPageRoute(builder: (_) => const SymptomsPage()));
              })
        ]);
  }
}

class Insights extends StatelessWidget {
  const Insights({super.key});

  @override Widget build(BuildContext c) {
    final x = Scope.of(c);
    final week = DateTime.now().subtract(const Duration(days: 7));
    return ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
        children: [
          Text('Insights', style: Theme
              .of(c)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w900)),
          const Text('Based only on your saved local records.'),
          const SizedBox(height: 18),
          GridView.count(crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                Stat('Total records', '${x.records.length}', Icons.folder),
                Stat('This week', '${x.records
                    .where((e) => e.dateTime.isAfter(week))
                    .length}', Icons.date_range),
                Stat(
                    'Water today', '${fmt(x.waterToday)} ml', Icons.water_drop),
                Stat('Active meds', '${x.meds
                    .where((e) => e.active)
                    .length}', Icons.medication),
                Stat('Symptoms/week', '${x.symptoms
                    .where((e) => e.dateTime.isAfter(week))
                    .length}', Icons.sick),
                Stat('Taken today', '${x.intakes
                    .where((e) =>
                    DateUtils.isSameDay(e.takenAt, DateTime.now()))
                    .length}', Icons.check_circle)
              ]),
          const SizedBox(height: 22),
          Card(child: Padding(padding: const EdgeInsets.all(18),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Theme
                        .of(c)
                        .colorScheme
                        .primary),
                    const SizedBox(width: 10),
                    const Expanded(child: Text(
                        'Insights are based only on your saved records and are not medical advice.'))
                  ])))
        ]);
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override Widget build(BuildContext c) {
    final x = Scope.of(c);
    return ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
        children: [
          Text('Settings', style: Theme
              .of(c)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          const Header('Appearance'),
          Card(child: Column(children: ThemeMode.values.map((m) =>
              RadioListTile(value: m,
                  groupValue: x.settings.mode,
                  title: Text(
                      '${m.name[0].toUpperCase()}${m.name.substring(1)} mode'),
                  onChanged: (v) {
                    if (v != null) x.setSettings(x.settings.copyWith(mode: v));
                  })).toList())),
          const SizedBox(height: 18),
          const Header('Preferences'),
          Card(child: Column(children: [
            ListTile(leading: const Icon(Icons.water_drop),
                title: const Text('Default water goal'),
                subtitle: Text('${x.settings.waterGoal} ml'),
                onTap: () => waterGoal(c)),
            SwitchListTile(value: x.settings.tips,
                onChanged: (v) => x.setSettings(x.settings.copyWith(tips: v)),
                title: const Text('Show wellness tips'))
          ])),
          const SizedBox(height: 18),
          const Header('Data management'),
          Card(child: ListTile(leading: const Icon(Icons.delete_sweep),
              title: const Text('Clear all data'),
              onTap: () => clearAll(c))),
          const SizedBox(height: 18),
          const Header('About'),
          Card(child: Column(children: [
            const ListTile(leading: CircleAvatar(child: Icon(Icons.eco)),
                title: Text('Vitala'),
                subtitle: Text('Version 1.0.0 • Offline')),
            ListTile(title: const Text('Medical disclaimer'),
                leading: const Icon(Icons.health_and_safety),
                onTap: () => legal(c, 'Medical Disclaimer', disclaimer)),
            ListTile(title: const Text('Privacy policy'),
                leading: const Icon(Icons.privacy_tip),
                onTap: () => legal(c, 'Privacy Policy', privacy)),
            ListTile(title: const Text('Terms and conditions'),
                leading: const Icon(Icons.description),
                onTap: () => legal(c, 'Terms and Conditions', terms))
          ]))
        ]);
  }
}

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final q = TextEditingController();
  RecordType? f;

  @override void dispose() {
    q.dispose();
    super.dispose();
  }

  @override Widget build(BuildContext c) {
    final x = Scope.of(c);
    final list = x.records.where((r) =>
    (f == null || r.type == f) && (q.text.isEmpty ||
        ('${r.type.label} ${r.value} ${r.notes}').toLowerCase().contains(
            q.text.toLowerCase()))).toList();
    return Scaffold(appBar: AppBar(title: const Text('Health records')),
        body: Column(children: [
          Padding(padding: const EdgeInsets.all(16),
              child: TextField(controller: q,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search records'))),
          SizedBox(height: 44,
              child: ListView(scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    ChoiceChip(label: const Text('All'),
                        selected: f == null,
                        onSelected: (_) => setState(() => f = null)),
                    const SizedBox(width: 8),
                    ...RecordType.values.map((t) =>
                        Padding(padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(label: Text(t.label),
                                selected: f == t,
                                onSelected: (_) => setState(() => f = t))))
                  ])),
          const SizedBox(height: 8),
          Expanded(child: list.isEmpty ? const Empty(icon: Icons.search_off,
              title: 'No records found',
              text: 'Add a record or change your search.') : ListView(
              padding: const EdgeInsets.all(16),
              children: list.map((r) => RecordTile(r)).toList()))
        ]),
        floatingActionButton: FloatingActionButton(
            onPressed: () => typePicker(c), child: const Icon(Icons.add)));
  }
}

class RecordTile extends StatelessWidget {
  const RecordTile(this.r, {super.key});

  final HealthRecord r;

  @override Widget build(BuildContext c) =>
      Padding(padding: const EdgeInsets.only(bottom: 9),
          child: Card(child: ListTile(
              leading: CircleAvatar(child: Icon(r.type.icon)),
              title: Text(r.type.label),
              subtitle: Text('${r.value} • ${date(r.dateTime)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => details(c, r))));
}

class MedsPage extends StatelessWidget {
  const MedsPage({super.key});

  @override Widget build(BuildContext c) {
    final x = Scope.of(c);
    return Scaffold(appBar: AppBar(title: const Text('Medications')),
        body: x.meds.isEmpty ? Empty(icon: Icons.medication_outlined,
            title: 'No medications added',
            text: 'Save medication details and intake logs.',
            button: 'Add medication',
            tap: () => medEditor(c)) : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Header('Active medications'),
              ...x.meds.where((e) => e.active).map((m) => MedTile(m)),
              const SizedBox(height: 18),
              const Header('Previous medications'),
              ...x.meds.where((e) => !e.active).map((m) => MedTile(m)),
              if(x.intakes.isNotEmpty)...[
                const SizedBox(height: 18),
                const Header('Recent intake log'),
                ...x.intakes.take(8).map((i) =>
                    Card(child: ListTile(
                        leading: const Icon(Icons.check_circle),
                        title: Text(i.name),
                        subtitle: Text('${i.dosage} • ${date(i.takenAt)}'))))
              ]
            ]),
        floatingActionButton: FloatingActionButton(
            onPressed: () => medEditor(c), child: const Icon(Icons.add)));
  }
}

class MedTile extends StatelessWidget {
  const MedTile(this.m, {super.key});

  final Medication m;

  @override Widget build(BuildContext c) {
    final x = Scope.of(c);
    return Card(child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.medication)),
        title: Text(m.name),
        subtitle: Text('${m.dosage} ${m.unit} • ${m.frequency}'),
        trailing: PopupMenuButton<String>(onSelected: (v) async {
          if (v == 'taken') x.taken(m);
          if (v == 'toggle') x.setMed(m.copyWith(active: !m.active));
          if (v == 'delete' && await confirm(
              c, 'Delete medication?', 'This medication will be removed.') ==
              true) {
            if (!c.mounted) return;
            x.delMed(m);
          }
        },
            itemBuilder: (_) =>
            [
              if(m.active)const PopupMenuItem(
                  value: 'taken', child: Text('Mark as taken')),
              PopupMenuItem(value: 'toggle',
                  child: Text(m.active ? 'Mark inactive' : 'Mark active')),
              const PopupMenuItem(value: 'delete', child: Text('Delete'))
            ])));
  }
}

class SymptomsPage extends StatelessWidget {
  const SymptomsPage({super.key});

  @override
  Widget build(BuildContext c) {
    final x = Scope.of(c);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptoms journal'),
      ),
      body: x.symptoms.isEmpty
          ? Empty(
        icon: Icons.sick,
        title: 'No symptoms logged',
        text: 'Add symptom, severity, duration and notes.',
        button: 'Add symptom',
        tap: () => symptomEditor(c),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: x.symptoms
            .map<Widget>(
              (s) => Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${s.severity}'),
              ),
              title: Text(s.name),
              subtitle: Text(
                '${severity(s.severity)} • ${date(s.dateTime)}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  if (await confirm(
                    c,
                    'Delete symptom?',
                    'This entry will be removed.',
                  ) ==
                      true) {
                    if (!c.mounted) return;
                    x.delSymptom(s);
                  }
                },
              ),
            ),
          ),
        )
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => symptomEditor(c),
        child: const Icon(Icons.add),
      ),
    );
  }}

class Header extends StatelessWidget {
  const Header(this.text, {super.key});

  final String text;

  @override Widget build(BuildContext c) =>
      Padding(padding: const EdgeInsets.only(bottom: 8),
          child: Text(text, style: Theme
              .of(c)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w900)));
}

class Empty extends StatelessWidget {
  const Empty(
      {super.key, required this.icon, required this.title, required this.text, this.button, this.tap});

  final IconData icon;
  final String title, text;
  final String? button;
  final VoidCallback? tap;

  @override Widget build(BuildContext c) =>
      Center(child: Padding(padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 34, child: Icon(icon, size: 34)),
                const SizedBox(height: 14),
                Text(title, textAlign: TextAlign.center, style: Theme
                    .of(c)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(text, textAlign: TextAlign.center),
                if(button != null)...[
                  const SizedBox(height: 14),
                  FilledButton(onPressed: tap, child: Text(button!))
                ]
              ])));
}

class NavCard extends StatelessWidget {
  const NavCard(this.icon, this.title, this.sub, this.tap, {super.key});

  final IconData icon;
  final String title, sub;
  final VoidCallback tap;

  @override Widget build(BuildContext c) =>
      Padding(padding: const EdgeInsets.only(bottom: 10),
          child: Card(child: ListTile(contentPadding: const EdgeInsets.all(15),
              leading: CircleAvatar(child: Icon(icon)),
              title: Text(
                  title, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(sub),
              trailing: const Icon(Icons.chevron_right),
              onTap: tap)));
}

class Stat extends StatelessWidget {
  const Stat(this.label, this.value, this.icon, {super.key});

  final String label, value;
  final IconData icon;

  @override Widget build(BuildContext c) =>
      Card(child: Padding(padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Theme
                    .of(c)
                    .colorScheme
                    .primary),
                const Spacer(),
                Text(label),
                Text(value, maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme
                        .of(c)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900))
              ])));
}

Future<void> welcome(BuildContext c) async {
  if (!c.mounted) return;
  final x = Scope.of(c);
  final accepted = await showDialog<bool>(context: c,
      barrierDismissible: false,
      builder: (d) =>
          AlertDialog(icon: const Icon(Icons.health_and_safety, size: 42),
              title: const Text('Welcome to Vitala'),
              content: const Text(
                  'Vitala works offline and stores data on this device. It is not a substitute for medical advice, diagnosis, or treatment.'),
              actions: [FilledButton(onPressed: () {
                Navigator.pop(d, true);
              }, child: const Text('I Understand'))
              ]));
  if (accepted == true && c.mounted) await x.accept();
}

Future<void> addHub(BuildContext c) async {
  if (!c.mounted) return;
  final action = await showModalBottomSheet<String>(context: c,
        showDragHandle: true,
        builder: (s) =>
            SafeArea(child: Padding(padding: const EdgeInsets.all(18),
                child: Wrap(spacing: 10,
                    runSpacing: 10,
                    children: [
                      ActionChip(avatar: const Icon(Icons.monitor_heart),
                          label: const Text('Health record'),
                          onPressed: () {
                            Navigator.pop(s, 'record');
                          }),
                      ActionChip(avatar: const Icon(Icons.medication),
                          label: const Text('Medication'),
                          onPressed: () {
                            Navigator.pop(s, 'medication');
                          }),
                      ActionChip(avatar: const Icon(Icons.sick),
                          label: const Text('Symptom'),
                          onPressed: () {
                            Navigator.pop(s, 'symptom');
                          }),
                      ActionChip(avatar: const Icon(Icons.water_drop),
                          label: const Text('Quick 250 ml'),
                          onPressed: () {
                            Navigator.pop(s, 'water');
                          })
                    ]))));
  if (!c.mounted) return;
  if (action == 'record') await typePicker(c);
  if (action == 'medication') await medEditor(c);
  if (action == 'symptom') await symptomEditor(c);
  if (action == 'water') {
    await Scope.of(c).addRecord(HealthRecord(id: uid(),
        type: RecordType.water,
        dateTime: DateTime.now(),
        a: 250));
  }
}

Future<void> typePicker(BuildContext c) async {
  if (!c.mounted) return;
  final type = await showModalBottomSheet<RecordType>(context: c,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (s) {
          final maxHeight = MediaQuery.of(s).size.height * .75;
          return SafeArea(child: Padding(padding: const EdgeInsets.all(18),
              child: ConstrainedBox(constraints: BoxConstraints(
                  maxHeight: maxHeight),
                  child: GridView.count(shrinkWrap: true,
                      crossAxisCount: 2,
                      childAspectRatio: 2.2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: RecordType.values.map((t) =>
                          FilledButton.tonalIcon(onPressed: () {
                            Navigator.pop(s, t);
                          },
                              icon: Icon(t.icon),
                              label: Text(t.label, maxLines: 2))).toList()))));
        });
  if (type != null && c.mounted) await recordEditor(c, type);
}

Future<void> recordEditor(BuildContext c, RecordType type,
    {HealthRecord? r}) async
{
  if (!c.mounted) return;
  final x = Scope.of(c),
      key = GlobalKey<FormState>(),
      a = TextEditingController(text: r?.a?.toString() ?? ''),
      b = TextEditingController(text: r?.b?.toString() ?? ''),
      cc = TextEditingController(text: r?.c?.toString() ?? ''),
      notes = TextEditingController(text: r?.notes ?? ''),
      title = TextEditingController(text: '${r?.extra['title'] ?? ''}');
  DateTime dt = r?.dateTime ?? DateTime.now();
  String mood = '${r?.extra['mood'] ?? 'Good'}',
      ctx = '${r?.extra['context'] ??
          (type == RecordType.bloodSugar ? 'Fasting' : 'Resting')}';
  try {
    await showModalBottomSheet<void>(context: c,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (s) =>
            StatefulBuilder(builder: (c, set) =>
                Padding(padding: EdgeInsets.fromLTRB(18, 0, 18, MediaQuery
                    .of(c)
                    .viewInsets
                    .bottom + 20),
                    child: SingleChildScrollView(child: Form(key: key,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${r == null ? 'Add' : 'Edit'} ${type.label}',
                                  style: Theme
                                      .of(c)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w900)),
                              const SizedBox(height: 14),
                              if(type == RecordType.note)field(
                                  title, 'Title') else
                                if(type ==
                                    RecordType.mood)DropdownButtonFormField(
                                    value: mood,
                                    items: [
                                      'Very Bad',
                                      'Bad',
                                      'Neutral',
                                      'Good',
                                      'Great'
                                    ].map((e) =>
                                        DropdownMenuItem(
                                            value: e, child: Text(e))).toList(),
                                    onChanged: (v) => set(() => mood = v!),
                                    decoration: const InputDecoration(
                                        labelText: 'Mood')) else
                                  ...[
                                    number(a, type == RecordType.bloodPressure
                                        ? 'Systolic'
                                        : type.label, type.unit,
                                        max: type == RecordType.oxygen
                                            ? 100
                                            : null),
                                    if(type == RecordType.bloodPressure)number(
                                        b, 'Diastolic', 'mmHg'),
                                    if(type == RecordType.bloodPressure)number(
                                        cc, 'Pulse (optional)', 'bpm',
                                        optional: true)
                                  ],
                              if(type == RecordType.bloodSugar ||
                                  type == RecordType.heartRate)...[
                                const SizedBox(height: 10),
                                DropdownButtonFormField(value: ctx,
                                    items: (type == RecordType.bloodSugar ? [
                                      'Fasting',
                                      'Before meal',
                                      'After meal',
                                      'Random',
                                      'Bedtime'
                                    ] : [
                                      'Resting',
                                      'Walking',
                                      'Exercise',
                                      'After exercise'
                                    ])
                                        .map((e) =>
                                        DropdownMenuItem(
                                            value: e, child: Text(e)))
                                        .toList(),
                                    onChanged: (v) =>
                                        set(() => ctx = v!),
                                    decoration: const InputDecoration(
                                        labelText: 'Context'))
                              ],
                              const SizedBox(height: 10),
                              ListTile(leading: const Icon(Icons.event),
                                  title: const Text('Date and time'),
                                  subtitle: Text(date(dt)),
                                  onTap: () async {
                                    final first = DateTime(2000);
                                    final last = DateTime.now().add(
                                        const Duration(days: 1));
                                    final initial = dt.isBefore(first)
                                        ? first
                                        : dt.isAfter(last)
                                            ? last
                                            : dt;
                                    final d = await showDatePicker(context: c,
                                        firstDate: first,
                                        lastDate: last,
                                        initialDate: initial);
                                    if (d == null || !c.mounted) return;
                                    final t = await showTimePicker(
                                        context: c, initialTime: TimeOfDay
                                        .fromDateTime(dt));
                                    if (t != null && c.mounted) set(() =>
                                    dt = DateTime(d.year, d.month, d.day, t.hour,
                                        t.minute));
                                  }),
                              const SizedBox(height: 10),
                              TextFormField(controller: notes,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                      labelText: 'Notes (optional)')),
                              const SizedBox(height: 14),
                              SizedBox(width: double.infinity,
                                  child: FilledButton(onPressed: () async {
                                    if (!(key.currentState?.validate() ?? false))
                                      return;
                                    final n = HealthRecord(id: r?.id ?? uid(),
                                        type: type,
                                        dateTime: dt,
                                        a: doubleOf(a.text),
                                        b: doubleOf(b.text),
                                        c: doubleOf(cc.text),
                                        notes: notes.text.trim(),
                                        extra: {
                                          if(type == RecordType.mood)'mood': mood,
                                          if(type ==
                                              RecordType.note)'title': title.text
                                              .trim(),
                                          if(type == RecordType.bloodSugar ||
                                              type == RecordType
                                                  .heartRate)'context': ctx
                                        });
                                    if (r == null)
                                      await x.addRecord(n);
                                    else
                                      await x.updateRecord(n);
                                    if (!s.mounted) return;

                                    FocusScope.of(s).unfocus();

                                    Navigator.of(s).pop();
                                  }, child: const Text('Save record')))
                            ]))))));
  } finally {
    a.dispose();
    b.dispose();
    cc.dispose();
    notes.dispose();
    title.dispose();
  }
}

Widget field(TextEditingController c, String label) =>
    TextFormField(controller: c,
        decoration: InputDecoration(labelText: label),
        validator: (v) =>
        v == null || v
            .trim()
            .isEmpty ? 'Required' : null);

Widget number(TextEditingController c, String label, String unit,
    {bool optional = false, double? max}) =>
    Padding(padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(controller: c,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: label, suffixText: unit),
            validator: (v) {
              if (optional && (v == null || v.isEmpty)) return null;
              final n = double.tryParse(v ?? '');
              if (n == null) return 'Enter a valid number';
              if (!n.isFinite) return 'Enter a valid number';
              if (n < 0) return 'Cannot be negative';
              if (max != null && n > max) return 'Maximum is $max';
              return null;
            }));

Future<void> details(BuildContext c, HealthRecord r) async {
  if (!c.mounted) return;
  await Navigator.push<void>(c, MaterialPageRoute(builder: (d) =>
        Scaffold(appBar: AppBar(title: Text(r.type.label),
            actions: [
              IconButton(onPressed: () => recordEditor(d, r.type, r: r),
                  icon: const Icon(Icons.edit)),
              IconButton(onPressed: () async {
                final x = Scope.of(d);
                if (await confirm(
                    d, 'Delete record?', 'This record will be removed.') ==
                    true) {
                  if (!d.mounted) return;
                  await x.deleteRecord(r);
                  if (d.mounted) Navigator.pop(d);
                }
              }, icon: const Icon(Icons.delete))
            ]),
            body: ListView(padding: const EdgeInsets.all(18),
                children: [
                  Card(child: Padding(padding: const EdgeInsets.all(24),
                      child: Column(children: [
                        Icon(r.type.icon, size: 44),
                        const SizedBox(height: 12),
                        Text(r.value, style: Theme
                            .of(d)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900))
                      ]))),
                  Card(child: Padding(padding: const EdgeInsets.all(18),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${date(r.dateTime)}'),
                            if(r.notes.isNotEmpty)...[
                              const SizedBox(height: 10),
                              Text('Notes: ${r.notes}')
                            ],
                            ...r.extra.entries.map((e) =>
                                Padding(padding: const EdgeInsets.only(top: 8),
                                    child: Text('${e.key}: ${e.value}')))
                          ])))
                ]))));
}

Future<void> medEditor(BuildContext c) async {
  if (!c.mounted) return;
  final x = Scope.of(c),
      key = GlobalKey<FormState>(),
      name = TextEditingController(),
      dose = TextEditingController(),
      notes = TextEditingController();
  String unit = 'Tablet',
      freq = 'Once daily';
  DateTime start = DateTime.now();
  try {
    await showModalBottomSheet<void>(context: c,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (s) =>
            StatefulBuilder(builder: (c, set) =>
                Padding(padding: EdgeInsets.fromLTRB(18, 0, 18, MediaQuery
                    .of(c)
                    .viewInsets
                    .bottom + 20),
                    child: SingleChildScrollView(child: Form(key: key,
                        child: Column(children: [
                          field(name, 'Medication name'),
                          const SizedBox(height: 10),
                          field(dose, 'Dosage'),
                          const SizedBox(height: 10),
                          DropdownButtonFormField(value: unit,
                              items: [
                                'Tablet',
                                'Capsule',
                                'ml',
                                'mg',
                                'Drops',
                                'Injection',
                                'Other'
                              ]
                                  .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => set(() => unit = v!),
                              decoration: const InputDecoration(
                                  labelText: 'Unit')),
                          const SizedBox(height: 10),
                          DropdownButtonFormField(value: freq,
                              items: [
                                'Once daily',
                                'Twice daily',
                                'Three times daily',
                                'Every 6 hours',
                                'Every 8 hours',
                                'Every 12 hours',
                                'As needed',
                                'Custom'
                              ]
                                  .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => set(() => freq = v!),
                              decoration: const InputDecoration(
                                  labelText: 'Frequency')),
                          const SizedBox(height: 10),
                          ListTile(title: const Text('Start date'),
                              subtitle: Text(DateFormat.yMMMd().format(start)),
                              onTap: () async {
                                final d = await showDatePicker(context: c,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    initialDate: start);
                                if (d != null && c.mounted) set(() => start = d);
                              }),
                          TextFormField(controller: notes,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                  labelText: 'Notes (optional)')),
                          const SizedBox(height: 14),
                          SizedBox(width: double.infinity,
                              child: FilledButton(onPressed: () async {
                                if (!(key.currentState?.validate() ?? false))
                                  return;
                                await x.addMed(Medication(id: uid(),
                                    name: name.text.trim(),
                                    dosage: dose.text.trim(),
                                    unit: unit,
                                    frequency: freq,
                                    startDate: start,
                                    notes: notes.text.trim()));
                                if (!s.mounted) return;

                                FocusScope.of(s).unfocus();

                                Navigator.of(s).pop();
                              }, child: const Text('Add medication')))
                        ]))))));
  } finally {
    name.dispose();
    dose.dispose();
    notes.dispose();
  }
}

Future<void> symptomEditor(BuildContext c) async {
  if (!c.mounted) return;
  final x = Scope.of(c),
      key = GlobalKey<FormState>(),
      name = TextEditingController(),
      duration = TextEditingController(),
      trigger = TextEditingController(),
      notes = TextEditingController();
  int sev = 3;
  try {
    await showModalBottomSheet<void>(context: c,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (s) =>
            StatefulBuilder(builder: (c, set) =>
                Padding(padding: EdgeInsets.fromLTRB(18, 0, 18, MediaQuery
                    .of(c)
                    .viewInsets
                    .bottom + 20),
                    child: SingleChildScrollView(child: Form(key: key,
                        child: Column(children: [
                          field(name, 'Symptom name'),
                          const SizedBox(height: 10),
                          Text('Severity: $sev/10 (${severity(sev)})'),
                          Slider(value: sev.toDouble(),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              onChanged: (v) => set(() => sev = v.round())),
                          TextFormField(controller: duration,
                              decoration: const InputDecoration(
                                  labelText: 'Duration (optional)')),
                          const SizedBox(height: 10),
                          TextFormField(controller: trigger,
                              decoration: const InputDecoration(
                                  labelText: 'Possible trigger (optional)')),
                          const SizedBox(height: 10),
                          TextFormField(controller: notes,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                  labelText: 'Notes (optional)')),
                          const SizedBox(height: 14),
                          SizedBox(width: double.infinity,
                              child: FilledButton(onPressed: () async {
                                if (!(key.currentState?.validate() ?? false))
                                  return;
                                await x.addSymptom(Symptom(id: uid(),
                                    name: name.text.trim(),
                                    severity: sev,
                                    dateTime: DateTime.now(),
                                    duration: duration.text.trim(),
                                    trigger: trigger.text.trim(),
                                    notes: notes.text.trim()));
                                if (!s.mounted) return;

                                FocusScope.of(s).unfocus();

                                Navigator.of(s).pop();
                              }, child: const Text('Add symptom')))
                        ]))))));
  } finally {
    name.dispose();
    duration.dispose();
    trigger.dispose();
    notes.dispose();
  }
}

Future<void> waterGoal(BuildContext c) async {
  if (!c.mounted) return;
  final x = Scope.of(c),
      t = TextEditingController(text: '${x.settings.waterGoal}');
  int? v;
  try {
    v = await showDialog<int>(context: c,
        builder: (d) =>
            AlertDialog(title: const Text('Water goal'),
                content: TextField(controller: t,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(suffixText: 'ml')),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(d),
                      child: const Text('Cancel')),
                  FilledButton(onPressed: () {
                    final n = int.tryParse(t.text);
                    if (n != null && n >= 250 && n <= 10000) Navigator.pop(d, n);
                  }, child: const Text('Save'))
                ]));
  } finally {
    t.dispose();
  }
  if (v != null && c.mounted) x.setSettings(x.settings.copyWith(waterGoal: v));
}

Future<void> clearAll(BuildContext c) async {
  if (!c.mounted) return;
  final x = Scope.of(c);
  if (await confirm(c, 'Clear all data?',
      'This permanently deletes all local records, medications and symptoms.',
      label: 'Clear all') == true) {
    if (!c.mounted) return;
    await x.clear();
    if (c.mounted) ScaffoldMessenger.of(c).showSnackBar(
        const SnackBar(content: Text('All local data cleared')));
  }
}

Future<bool?> confirm(BuildContext c, String title, String msg,
    {String label = 'Delete'}) {
  if (!c.mounted) return Future<bool?>.value();
  return showDialog<bool>(context: c,
        builder: (d) =>
            AlertDialog(title: Text(title),
                content: Text(msg),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(d, false),
                      child: const Text('Cancel')),
                  FilledButton(onPressed: () => Navigator.pop(d, true),
                      child: Text(label))
                ]));
}

void legal(BuildContext c, String title,
    List<MapEntry<String, String>> sections) {
  if (!c.mounted) return;
  Navigator.push(c, MaterialPageRoute(builder: (_) =>
        Scaffold(appBar: AppBar(title: Text(title)),
            body: ListView(padding: const EdgeInsets.all(18),
                children: sections.map((e) =>
                    Card(child: Padding(padding: const EdgeInsets.all(18),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.key, style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 17)),
                              const SizedBox(height: 7),
                              Text(e.value)
                            ])))).toList()))));
}
const privacy = [
  MapEntry('Introduction', 'Vitala is an offline personal wellness journal.'),
  MapEntry('Local data storage',
      'Measurements, medications, symptoms, notes and preferences are stored locally with SharedPreferences and are not sent to a server.'),
  MapEntry('No accounts or collection',
      'There is no login, account registration, tracking, analytics, advertising, or third-party sharing.'),
  MapEntry('No cloud synchronization',
      'This version does not provide cloud backup. Removing the app or clearing storage may remove your data.'),
  MapEntry('Data deletion',
      'Delete individual entries or use Clear All Data in Settings.'),
  MapEntry('Children’s privacy',
      'The app is not directed to children below the minimum legal age.'),
  MapEntry('Contact and changes',
      'Policy updates and developer contact details are available through the app store listing.'),
  MapEntry('Last updated', 'July 22, 2026')
];
const terms = [
  MapEntry('Acceptance', 'Using Vitala means you accept these terms.'),
  MapEntry('Purpose', 'Vitala is for personal record keeping only.'),
  MapEntry('No medical services',
      'The app does not diagnose, treat, prescribe, or recommend medication or dosage.'),
  MapEntry('User responsibility',
      'You are responsible for entered data and decisions based on it.'),
  MapEntry('Local storage and loss',
      'The developer cannot restore data lost after uninstalling, clearing storage, or device failure.'),
  MapEntry('Liability',
      'To the extent allowed by law, the developer is not liable for medical decisions or indirect loss.'),
  MapEntry('Last updated', 'July 22, 2026')
];
const disclaimer = [
  MapEntry('Not a medical provider',
      'Vitala is not a healthcare provider, medical device, emergency service, or professional consultation service.'),
  MapEntry('No diagnosis or treatment',
      'The app does not diagnose disease, interpret values medically, prescribe medication, or recommend dosage.'),
  MapEntry('Seek professional advice',
      'Consult a qualified healthcare professional about symptoms, measurements, medication, or health decisions.'),
  MapEntry('Emergencies',
      'In an emergency, contact your local emergency services immediately.'),
  MapEntry('Personal record keeping only',
      'Vitala only records and organizes information you enter.')
];

String fmt(double? n) =>
    n == null || !n.isFinite ? '-' : n == n.roundToDouble() ? n.toStringAsFixed(0) : n
        .toStringAsFixed(1);

String date(DateTime d) =>
    '${DateFormat.yMMMd().format(d)} • ${DateFormat.jm().format(d)}';

String severity(int n) => n <= 3 ? 'Mild' : n <= 6 ? 'Moderate' : 'Severe';
extension FirstOrNull<T> on Iterable<T>{
  T? get firstOrNull {
    final i = iterator;
    return i.moveNext() ? i.current : null;
  }
}
