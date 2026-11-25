import 'package:flutter/material.dart';
import 'location.dart';
import 'models.dart';
import 'order_detail.dart';
import 'photos.dart';
import 'shared.dart';
import 'store.dart';
import 'ui.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tab == 0 ? const _BrowseTab() : const _OrdersTab(),
      bottomNavigationBar: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final active = store.bookings
              .where((b) =>
                  b.customerName == store.customerName &&
                  (b.status == BookingStatus.diajukan ||
                      b.status == BookingStatus.dikonfirmasi ||
                      b.status == BookingStatus.berjalan ||
                      b.status == BookingStatus.menungguKonfirmasi))
              .length;
          return FloatNav(
            index: _tab,
            onChanged: (i) => setState(() => _tab = i),
            items: [
              const NavItem(Icons.home_outlined, Icons.home_rounded, 'Beranda'),
              NavItem(
                Icons.receipt_long_outlined,
                Icons.receipt_long,
                'Pesanan',
                badge: active,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------- Beranda ----------

class _Promo {
  const _Promo(this.title, this.subtitle, this.category, this.photo);
  final String title;
  final String subtitle;
  final ServiceCategory category;
  final int photo;
}

const _promos = [
  _Promo('Panen butuh tenaga?', 'Buruh tani siap bantu garap lahanmu', ServiceCategory.pertanian, 35544010),
  _Promo('Renovasi tanpa ribet', 'Tukang & tim bangunan terpercaya', ServiceCategory.bangunan, 13930482),
  _Promo('Elektronik bermasalah?', 'Teknisi servis siap membantu', ServiceCategory.elektronik, 2136243),
];

class _BrowseTab extends StatefulWidget {
  const _BrowseTab();

  @override
  State<_BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<_BrowseTab> {
  String _query = '';
  ServiceCategory? _category;
  bool _onlyAvailable = false;
  int _promoIndex = 0;
  final _searchCtrl = TextEditingController();
  final _promoCtrl = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _searchCtrl.dispose();
    _promoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final r = await Navigator.of(context).push<PickedLocation>(MaterialPageRoute(
      builder: (_) => LocationPickerPage(initial: store.myLocation),
    ));
    if (r != null) store.setMyLocation(r);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final today = dateOnly(DateTime.now());
        final list = store.partners.where((p) {
          if (_category != null && p.category != _category) return false;
          final hay = '${p.name} ${p.skills} ${p.category.label}'.toLowerCase();
          if (_query.isNotEmpty && !hay.contains(_query.toLowerCase())) return false;
          if (_onlyAvailable && store.slotStatus(p.id, today) != SlotStatus.tersedia) {
            return false;
          }
          return true;
        }).toList();
        if (store.myLocation != null) {
          list.sort((a, b) => store.distanceTo(a)!.compareTo(store.distanceTo(b)!));
        }
        final cat = _category;

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _header(context),
            const SizedBox(height: 20),
            _promoCarousel(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int k = 0; k < _promos.length; k++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: k == _promoIndex ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: k == _promoIndex ? kPrimary : kBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SectionTitle('Kategori jasa'),
            ),
            _categories(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(
                    store.myLocation == null ? 'Mitra tersedia' : 'Mitra terdekat',
                    trailing: Text(
                      '${list.length} mitra',
                      style: const TextStyle(color: kMuted, fontSize: 13),
                    ),
                  ),
                  if (_onlyAvailable || cat != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_onlyAvailable)
                            Chip(
                              avatar: const Icon(
                                Icons.event_available_rounded,
                                size: 16,
                                color: kPrimary,
                              ),
                              label: const Text('Tersedia hari ini'),
                              deleteIconColor: kMuted,
                              onDeleted: () => setState(() => _onlyAvailable = false),
                            ),
                          if (cat != null)
                            Chip(
                              avatar: Icon(cat.icon, size: 16, color: cat.tint),
                              label: Text(cat.label),
                              deleteIconColor: kMuted,
                              onDeleted: () => setState(() => _category = null),
                            ),
                        ],
                      ),
                    ),
                  if (list.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded, size: 56, color: kMuted),
                            SizedBox(height: 12),
                            Text(
                              'Belum ada mitra yang cocok',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: kInk,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Coba kata kunci lain atau matikan filter "Tersedia hari ini".',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: kMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  for (final p in list) _PartnerCard(partner: p, today: today),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    final loc = store.myLocation;
    final first = store.customerName.split(' ').first;
    final pill = OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: BorderSide.none,
    );
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  shadowColor: const Color(0x33081C2E),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.arrow_back_rounded, size: 22, color: kInk),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat datang \u{1F44B}',
                        style: TextStyle(color: kMuted, fontSize: 13),
                      ),
                      Text(
                        store.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: kDisplay(20),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: kPrimary,
                  child: Text(
                    first.isEmpty ? '?' : first[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: kCardShadow,
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        hintText: 'Cari tukang, buruh tani, servis…',
                        border: pill,
                        enabledBorder: pill,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(color: kPrimary, width: 1.8),
                        ),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close_rounded, color: kMuted),
                                tooltip: 'Hapus',
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _query = '');
                                },
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Tooltip(
                  message: 'Tersedia hari ini',
                  child: Material(
                    color: _onlyAvailable ? kAccent : kPrimary,
                    borderRadius: BorderRadius.circular(20),
                    elevation: 3,
                    shadowColor: const Color(0x55081C2E),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(() => _onlyAvailable = !_onlyAvailable),
                      child: SizedBox(
                        width: 54,
                        height: 54,
                        child: Icon(
                          _onlyAvailable ? Icons.event_available_rounded : Icons.tune_rounded,
                          color: _onlyAvailable ? kDeep : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _pickLocation,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: kBorder),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: kSoftFill,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on_rounded, color: kPrimary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          loc?.address ?? 'Atur lokasimu untuk melihat jarak mitra',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: kInk),
                        ),
                      ),
                      const Text(
                        'Ubah',
                        style: TextStyle(
                          color: kPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _promoCarousel() {
    return SizedBox(
      height: 196,
      child: PageView.builder(
        controller: _promoCtrl,
        itemCount: _promos.length,
        onPageChanged: (i) => setState(() => _promoIndex = i),
        itemBuilder: (context, i) {
          final p = _promos[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Photo(id: p.photo, fallback: p.category, width: 1000),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xF2081C2E), Color(0x99081C2E), Color(0x00081C2E)],
                        stops: [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: kAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            p.category.label.toUpperCase(),
                            style: const TextStyle(
                              color: kDeep,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          p.title,
                          style: kDisplay(22, color: Colors.white, height: 1.15),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 210,
                          child: Text(
                            p.subtitle,
                            style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Lihat mitra',
                              style: TextStyle(
                                color: kAccent,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded, color: kAccent, size: 18),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _category = p.category),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _categories() {
    final values = ServiceCategory.values;
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: values.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          if (i == 0) {
            return _CategoryBubble(
              label: 'Semua',
              selected: _category == null,
              onTap: () => setState(() => _category = null),
              child: const ColoredBox(
                color: kPrimary,
                child: Center(child: Icon(Icons.apps_rounded, color: Colors.white, size: 28)),
              ),
            );
          }
          final c = values[i - 1];
          return _CategoryBubble(
            label: c.label,
            selected: _category == c,
            onTap: () => setState(() => _category = _category == c ? null : c),
            child: Photo(id: photoId(c), fallback: c, width: 300),
          );
        },
      ),
    );
  }
}

class _CategoryBubble extends StatelessWidget {
  const _CategoryBubble({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              height: 70,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: selected ? kAccent : Colors.transparent, width: 3),
                boxShadow: kCardShadow,
              ),
              child: ClipOval(child: SizedBox.expand(child: child)),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.2,
                color: selected ? kPrimary : kInk,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({required this.partner, required this.today});
  final Partner partner;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final free = store.slotStatus(partner.id, today) == SlotStatus.tersedia;
    final dist = store.distanceTo(partner);
    final verified = store.badge(partner.id) == 'Mitra Terpercaya';
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PartnerDetailPage(partnerId: partner.id),
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 176,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Photo(
                    id: photoId(partner.category, seedOf(partner.id)),
                    fallback: partner.category,
                    width: 900,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00081C2E), Color(0xE6081C2E)],
                        stops: [0.35, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Glass(
                      radius: 14,
                      opacity: 0.22,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: free ? const Color(0xFF34D399) : Colors.white54,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              free ? 'Tersedia hari ini' : 'Sibuk hari ini',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: kAccent),
                          const SizedBox(width: 3),
                          Text(
                            store.ratingText(partner.id),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: kInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 12,
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            partner.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: kDisplay(20, color: Colors.white),
                          ),
                        ),
                        if (verified)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.verified, size: 19, color: kAccent),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.skills,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: kMuted, fontSize: 13, height: 1.35),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Pill(
                        partner.category.label,
                        color: partner.category.tint,
                        icon: partner.category.icon,
                      ),
                      if (dist != null)
                        Pill(fmtDistance(dist), color: kMuted, icon: Icons.near_me),
                      if (partner.isTeam)
                        Pill('Tim ${partner.members} orang', color: kMuted, icon: Icons.group),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: rupiah(partner.rate),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: kPrimary,
                                ),
                              ),
                              const TextSpan(
                                text: ' /hari',
                                style: TextStyle(color: kMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Lihat',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Detail mitra ----------

class PartnerDetailPage extends StatelessWidget {
  const PartnerDetailPage({super.key, required this.partnerId});
  final String partnerId;

  Widget _stat(String value, String label) => Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final p = store.partner(partnerId);
        final reviews = store.reviewsOf(p.id);
        final dist = store.distanceTo(p);
        return Scaffold(
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                child: SizedBox(
                  height: 372,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Photo(
                        id: photoId(p.category, seedOf(p.id)),
                        fallback: p.category,
                        width: 1200,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x99081C2E), Color(0x00081C2E), Color(0xF2081C2E)],
                            stops: [0.0, 0.32, 1.0],
                          ),
                        ),
                      ),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Glass(
                                radius: 22,
                                onTap: () => Navigator.of(context).pop(),
                                child: const SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Icon(Icons.arrow_back_rounded, color: Colors.white),
                                ),
                              ),
                              const Spacer(),
                              Pill(
                                p.category.label,
                                color: kAccent,
                                icon: p.category.icon,
                              ),
                              const SizedBox(height: 8),
                              Text(p.name, style: kDisplay(28, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text(
                                '${p.category.label} · ${p.area}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 16),
                              Glass(
                                radius: 20,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    children: [
                                      _stat(store.ratingText(p.id), 'Rating'),
                                      _stat('${store.completedCount(p.id)}', 'Pekerjaan selesai'),
                                      _stat(dist == null ? '-' : fmtDistance(dist), 'Jarak'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            children: [
                              Pill(store.badge(p.id), icon: Icons.verified),
                              Pill(
                                p.isTeam ? 'Tim ${p.members} orang' : 'Individu',
                                color: kMuted,
                                icon: p.isTeam ? Icons.group : Icons.person,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(p.skills),
                        ],
                      ),
                    ),
                    const SectionTitle('Kalender ketersediaan'),
                    AppCard(
                      child: Column(
                        children: [
                          AvailabilityCalendar(statusOf: (d) => store.slotStatus(p.id, d)),
                          const SizedBox(height: 8),
                          const Align(alignment: Alignment.centerLeft, child: SlotLegend()),
                        ],
                      ),
                    ),
                    if (reviews.isNotEmpty) ...[
                      const SectionTitle('Ulasan'),
                      for (final r in reviews)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    for (var i = 1; i <= 5; i++)
                                      Icon(
                                        i <= r.rating!
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                    const SizedBox(width: 8),
                                    Text(r.customerName,
                                        style: const TextStyle(color: kMuted, fontSize: 12)),
                                  ],
                                ),
                                if (r.review != null) ...[
                                  const SizedBox(height: 6),
                                  Text(r.review!),
                                ],
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: kBorder)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Tarif', style: TextStyle(color: kMuted, fontSize: 12)),
                        Text(
                          '${rupiah(p.rate)}/hari',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => BookingPage(partnerId: p.id),
                        )),
                        child: const Text('Ajukan Pesanan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------- Form pemesanan ----------

class BookingPage extends StatefulWidget {
  const BookingPage({super.key, required this.partnerId});
  final String partnerId;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _notes = TextEditingController();
  DateTime _start = _tomorrow();
  int _days = 1;
  PaymentMethod _pay = PaymentMethod.digital;
  PickedLocation? _place = store.myLocation;
  bool _showLocError = false;

  static DateTime _tomorrow() {
    final t = dateOnly(DateTime.now());
    return DateTime(t.year, t.month, t.day + 1);
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = dateOnly(DateTime.now());
    final d = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: today,
      lastDate: DateTime(today.year + 1, today.month, today.day),
    );
    if (d != null) setState(() => _start = dateOnly(d));
  }

  Future<void> _pickPlace() async {
    final r = await Navigator.of(context).push<PickedLocation>(MaterialPageRoute(
      builder: (_) => LocationPickerPage(initial: _place),
    ));
    if (r != null) {
      setState(() {
        _place = r;
        _showLocError = false;
      });
      if (store.myLocation == null) store.setMyLocation(r);
    }
  }

  void _submit() {
    final place = _place;
    if (place == null) {
      setState(() => _showLocError = true);
      return;
    }
    final err = store.createBooking(
      partnerId: widget.partnerId,
      start: _start,
      days: _days,
      location: place,
      notes: _notes.text.trim(),
      payment: _pay,
    );
    if (err != null) {
      snack(context, err);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    nav.pop(); // form
    nav.pop(); // detail mitra
    messenger.showSnackBar(
      const SnackBar(content: Text('Pesanan diajukan. Menunggu respon mitra.')),
    );
  }

  Widget _payCard(PaymentMethod m, IconData icon, String sub) {
    final sel = _pay == m;
    return Expanded(
      child: AppCard(
        onTap: () => setState(() => _pay = m),
        color: sel ? kPrimary.withOpacity(0.06) : Colors.white,
        borderColor: sel ? kPrimary : kBorder,
        borderWidth: sel ? 2 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: sel ? kPrimary : kMuted),
            const SizedBox(height: 8),
            Text(m.label, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(sub, style: const TextStyle(color: kMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = store.partner(widget.partnerId);
    final conflicts = store.conflictDays(p.id, _start, _days);
    final price = p.rate * _days;
    final end = DateTime(_start.year, _start.month, _start.day + _days - 1);
    final place = _place;

    return Scaffold(
      appBar: AppBar(title: Text('Pesan ${p.name}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          const SectionTitle('Kapan?'),
          AppCard(
            child: Column(
              children: [
                InkWell(
                  onTap: _pickDate,
                  child: Row(
                    children: [
                      const Icon(Icons.event, color: kPrimary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tanggal mulai',
                                style: TextStyle(color: kMuted, fontSize: 12)),
                            Text(fmtDate(_start),
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: kMuted),
                    ],
                  ),
                ),
                const Divider(height: 28),
                Row(
                  children: [
                    const Icon(Icons.timelapse, color: kPrimary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$_days hari',
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text('s/d ${fmtDate(end)}',
                              style: const TextStyle(color: kMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: _days > 1 ? () => setState(() => _days--) : null,
                      icon: const Icon(Icons.remove),
                    ),
                    IconButton.filledTonal(
                      onPressed: _days < 30 ? () => setState(() => _days++) : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                if (conflicts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Mitra tidak tersedia pada: ${conflicts.map(fmtDate).join(', ')}. '
                      'Pilih tanggal/durasi lain.',
                      style: const TextStyle(color: Color(0xFF991B1B)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SectionTitle('Di mana?'),
          AppCard(
            padding: const EdgeInsets.all(12),
            borderColor: _showLocError ? const Color(0xFFDC2626) : kBorder,
            child: place == null
                ? InkWell(
                    onTap: _pickPlace,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          const Icon(Icons.add_location_alt_outlined, color: kPrimary),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Pilih lokasi pengerjaan (GPS / cari alamat / peta)',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (_showLocError)
                            const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
                        ],
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MiniMap(lat: place.lat, lng: place.lng),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: IconText(Icons.place, place.address, color: kInk, maxLines: 3),
                      ),
                      const SizedBox(height: 6),
                      TextButton.icon(
                        onPressed: _pickPlace,
                        icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                        label: const Text('Ubah lokasi'),
                      ),
                    ],
                  ),
          ),
          if (_showLocError)
            const Padding(
              padding: EdgeInsets.only(top: 6, left: 4),
              child: Text('Lokasi wajib dipilih.',
                  style: TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
            ),
          const SectionTitle('Catatan kebutuhan'),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Mis. cat ulang ruang tamu 4x5 m…'),
          ),
          const SectionTitle('Pembayaran'),
          Row(
            children: [
              _payCard(PaymentMethod.digital, Icons.account_balance_wallet_outlined,
                  'Via payment gateway'),
              const SizedBox(width: 10),
              _payCard(PaymentMethod.tunai, Icons.payments_outlined, 'Dicatat di aplikasi'),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Jadwal belum terkunci sampai mitra menerima pesanan. '
            'Harga dan jadwal bisa direvisi lewat catatan revisi.',
            style: TextStyle(fontSize: 12, color: kMuted),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kBorder)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Estimasi', style: TextStyle(color: kMuted, fontSize: 12)),
                    Text(rupiah(price),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: conflicts.isEmpty ? _submit : null,
                    child: const Text('Kirim Pesanan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Pesanan saya ----------

class _OrdersTab extends StatefulWidget {
  const _OrdersTab();

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  bool _history = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          bool isActive(Booking b) =>
              b.status == BookingStatus.diajukan ||
              b.status == BookingStatus.dikonfirmasi ||
              b.status == BookingStatus.berjalan ||
              b.status == BookingStatus.menungguKonfirmasi;
          final list = store.bookings
              .where((b) => b.customerName == store.customerName && isActive(b) != _history)
              .toList()
            ..sort((a, b) => b.start.compareTo(a.start));
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              const Text('Pesanan Saya',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kInk)),
              const SizedBox(height: 14),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Aktif')),
                  ButtonSegment(value: true, label: Text('Riwayat')),
                ],
                selected: {_history},
                onSelectionChanged: (s) => setState(() => _history = s.first),
              ),
              const SizedBox(height: 16),
              if (list.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 48, color: kMuted),
                      SizedBox(height: 8),
                      Text('Belum ada pesanan.', style: TextStyle(color: kMuted)),
                    ],
                  ),
                ),
              for (final b in list) BookingTile(booking: b, asPartner: false),
            ],
          );
        },
      ),
    );
  }
}
