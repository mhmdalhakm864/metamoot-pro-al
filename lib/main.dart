import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MetaMootProALApp());
}

class MetaMootProALApp extends StatelessWidget {
  const MetaMootProALApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0D0D0D);
    const purple = Color(0xFF7B2FFF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ميتاموت برو AL',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        primaryColor: purple,
        colorScheme: ColorScheme.dark(
          primary: purple,
          background: bgColor,
          onPrimary: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        textTheme: GoogleFonts.cairoTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bgColor,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // القيم الابتدائية (يمكن تعديلها لاحقاً أو حفظها محلياً)
  double _cash = 100000.0; // الكاش
  double _inventory = 50000.0; // قيمة المخزون
  double _salesToday = 0.0; // مبيعات اليوم

  final NumberFormat _nf = NumberFormat.decimalPattern('ar'); // صيغة عرض الأرقام بالعربي

  // معادلة سعر السهم المطلوبة: (الكاش + المخزون) / 1000
  double get _sharePrice {
    final assets = _cash + _inventory;
    return assets / 1000.0;
  }

  void _testSale() {
    const saleAmount = 1000.0;
    const costOfGoods = 700.0;

    if (_inventory < costOfGoods) {
      // إن لم يكف المخزون، نعرض رسالة
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('المخزون غير كافٍ لإتمام تجربة البيع')),
      );
      return;
    }

    setState(() {
      _cash += saleAmount;
      _inventory -= costOfGoods;
      _salesToday += saleAmount;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت تجربة البيع بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7B2FFF);
    const cardBg = Color(0xFF121212);
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ميتاموت برو AL', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (!isWide)
            Builder(builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              );
            }),
        ],
      ),
      endDrawer: _buildDrawer(context),
      body: Row(
        children: [
          if (isWide) _buildSideBar(), // شريط جانبي ثابت على الشاشات الكبيرة
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // البطاقات الثلاث
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _infoCard('الصندوق', '${_nf.format(_cash)} ر.س', Icons.account_balance_wallet, cardBg)),
                      const SizedBox(width: 12),
                      Expanded(child: _infoCard('سعر السهم', '${_nf.format(_sharePrice)} ر.س', Icons.show_chart, cardBg)),
                      const SizedBox(width: 12),
                      Expanded(child: _infoCard('مبيعات اليوم', '${_nf.format(_salesToday)} ر.س', Icons.shopping_cart, cardBg)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // زر تجربة البيع
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: purple),
                        onPressed: _testSale,
                        icon: const Icon(Icons.shopping_bag),
                        label: const Text('تجربة بيع'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                        onPressed: () {
                          // إعادة ضبط القيم (اختياري للاختبار)
                          setState(() {
                            _cash = 100000.0;
                            _inventory = 50000.0;
                            _salesToday = 0.0;
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة ضبط'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // عرض تفصيلي للمخزون والبيانات
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('تفاصيل المتجر', style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Text('قيمة المخزون: ${_nf.format(_inventory)} ر.س', style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 6),
                        Text('النقدية: ${_nf.format(_cash)} ر.س', style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 6),
                        Text('سعر السهم (حسب المعادلة): ${_nf.format(_sharePrice)} ر.س', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: purple,
        icon: const Icon(Icons.sell),
        label: const Text('تجربة بيع سريعة'),
        onPressed: _testSale,
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon, Color bg) {
    const purple = Color(0xFF7B2FFF);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: purple.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: purple),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    // القائمة اليمنى (endDrawer) بالعربي
    return Drawer(
      backgroundColor: const Color(0xFF0D0D0D),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF7B2FFF)),
            child: const Center(child: Text('القائمة', style: TextStyle(color: Colors.white, fontSize: 22))),
          ),
          _drawerTile(context, 'الرئيسية', Icons.home, () {
            Navigator.pop(context);
          }),
          _drawerTile(context, 'الموظفين', Icons.person, () {
            Navigator.pop(context);
            _openSimplePage(context, 'الموظفين');
          }),
          _drawerTile(context, 'الكاميرات', Icons.videocam, () {
            Navigator.pop(context);
            _openSimplePage(context, 'الكاميرات');
          }),
          _drawerTile(context, 'الفروع', Icons.store, () {
            Navigator.pop(context);
            _openSimplePage(context, 'الفروع');
          }),
          _drawerTile(context, 'الحساب', Icons.account_balance, () {
            Navigator.pop(context);
            _openSimplePage(context, 'الحساب');
          }),
          _drawerTile(context, 'الرسائل', Icons.message, () {
            Navigator.pop(context);
            _openSimplePage(context, 'الرسائل');
          }),
          _drawerTile(context, 'الإعدادات', Icons.settings, () {
            Navigator.pop(context);
            _openSimplePage(context, 'الإعدادات');
          }),
        ],
      ),
    );
  }

  Widget _drawerTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    const purple = Color(0xFF7B2FFF);
    return ListTile(
      leading: Icon(icon, color: purple),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  void _openSimplePage(BuildContext context, String title) {
    Navigator.of(context).push(MaterialPageRoute(builder: (c) => SimplePage(title: title)));
  }

  Widget _buildSideBar() {
    // شريط جانبي بديل للـ endDrawer على الشاشات الكبيرة
    return Container(
      width: 220,
      color: const Color(0xFF0F0F0F),
      child: Column(
        children: [
          Container(height: 80, color: const Color(0xFF7B2FFF), child: const Center(child: Text('القائمة', style: TextStyle(color: Colors.white, fontSize: 20)))),
          _sideBarItem('الرئيسية', Icons.home, () {}),
          _sideBarItem('الموظفين', Icons.person, () {}),
          _sideBarItem('الكاميرات', Icons.videocam, () {}),
          _sideBarItem('الفروع', Icons.store, () {}),
          _sideBarItem('الحساب', Icons.account_balance, () {}),
          _sideBarItem('الرسائل', Icons.message, () {}),
          _sideBarItem('الإعدادات', Icons.settings, () {}),
        ],
      ),
    );
  }

  Widget _sideBarItem(String title, IconData icon, VoidCallback onTap) {
    const purple = Color(0xFF7B2FFF);
    return ListTile(
      leading: Icon(icon, color: purple),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}

class SimplePage extends StatelessWidget {
  final String title;
  const SimplePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('واجهة $title ستُطوّر لاحقاً', style: const TextStyle(color: Colors.white))),
    );
  }
}
