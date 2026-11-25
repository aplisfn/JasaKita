import 'dart:async';

import 'package:flutter/material.dart';
import 'customer.dart';
import 'models.dart';
import 'partner.dart';
import 'photos.dart';
import 'store.dart';
import 'ui.dart';

/// Nama aplikasi belum diputuskan (lihat slide 18) — ganti di sini.
const appName = 'JasaKita';

void main() => runApp(const JasaApp());

class JasaApp extends StatelessWidget {
  const JasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const RoleGate(),
    );
  }
}

/// Layar awal: foto sinematik yang bergeser otomatis + pilih peran.
/// (Login sungguhan menyusul setelah backend dipilih.)
class RoleGate extends StatefulWidget {
  const RoleGate({super.key});

  @override
  State<RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<RoleGate> {
  int _i = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() => _i = (_i + 1) % heroPhotoIds.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Widget _roleButton({
    required IconData icon,
    required String title,
    required String sub,
    required Widget page,
    required bool primary,
  }) {
    final fg = primary ? kDeep : Colors.white;
    final row = Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primary ? kDeep : Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: primary ? kAccent : Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: fg, fontSize: 16.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(color: fg.withOpacity(0.78), fontSize: 12.5),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_rounded, color: fg),
        ],
      ),
    );
    if (primary) {
      return Material(
        color: kAccent,
        borderRadius: BorderRadius.circular(24),
        elevation: 8,
        shadowColor: kAccent.withOpacity(0.5),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _open(page),
          child: row,
        ),
      );
    }
    return Glass(radius: 24, onTap: () => _open(page), child: row);
  }

  Widget _trust(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: kSage),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDeep,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1100),
            layoutBuilder: (current, previous) => Stack(
              fit: StackFit.expand,
              children: [...previous, if (current != null) current],
            ),
            child: SizedBox.expand(
              key: ValueKey(_i),
              child: _KenBurns(id: heroPhotoIds[_i], fallback: heroFallbacks[_i]),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x99081C2E),
                  Color(0x14081C2E),
                  Color(0xE6081C2E),
                  Color(0xFF081C2E),
                ],
                stops: [0.0, 0.28, 0.66, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, c) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: c.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Reveal(
                            child: Row(
                              children: [
                                Glass(
                                  radius: 16,
                                  child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Icon(Icons.handshake_rounded, color: kAccent, size: 26),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(appName, style: kDisplay(22, color: Colors.white)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Reveal(
                            delayMs: 150,
                            child: Glass(
                              radius: 20,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF34D399),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${store.partners.length} mitra siap kerja · ${ServiceCategory.values.length} kategori',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Reveal(
                            delayMs: 250,
                            child: Text(
                              'Jasa terbaik,\ndekat denganmu.',
                              style: kDisplay(40, color: Colors.white, height: 1.08),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Reveal(
                            delayMs: 350,
                            child: const Text(
                              'Cari tukang, buruh tani, hingga servis elektronik. Pesan, pantau lewat foto, beres.',
                              style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.45),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              for (int k = 0; k < heroPhotoIds.length; k++)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(right: 6),
                                  width: k == _i ? 24 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: k == _i ? kAccent : Colors.white38,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Reveal(
                            delayMs: 450,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final cat in ServiceCategory.values)
                                  Glass(
                                    radius: 20,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(cat.icon, size: 15, color: kSage),
                                          const SizedBox(width: 6),
                                          Text(
                                            cat.label,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          Reveal(
                            delayMs: 550,
                            child: _roleButton(
                              icon: Icons.search_rounded,
                              title: 'Cari jasa sekarang',
                              sub: 'Masuk sebagai Pelanggan',
                              page: const CustomerShell(),
                              primary: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Reveal(
                            delayMs: 650,
                            child: _roleButton(
                              icon: Icons.engineering_rounded,
                              title: 'Saya mitra jasa',
                              sub: 'Kelola pesanan, jadwal & progres',
                              page: const PartnerShell(),
                              primary: false,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              _trust(Icons.verified_rounded, 'Mitra terpercaya'),
                              _trust(Icons.photo_camera_rounded, 'Pantau lewat foto'),
                              _trust(Icons.payments_rounded, 'Bayar digital / tunai'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Foto yang perlahan membesar (efek sinematik "Ken Burns").
class _KenBurns extends StatelessWidget {
  const _KenBurns({required this.id, required this.fallback});
  final int id;
  final ServiceCategory fallback;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 1.14),
      duration: const Duration(seconds: 9),
      curve: Curves.linear,
      child: Photo(id: id, fallback: fallback, width: 1200),
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
    );
  }
}
