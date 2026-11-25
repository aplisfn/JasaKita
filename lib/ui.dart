import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models.dart';

// ---------------------------------------------------------------------------
// Design tokens: "Segar & profesional" - navy dalam, teal cerah, aksen amber.
// Nama konstanta lama dipertahankan agar semua layar ikut berubah otomatis.
// ---------------------------------------------------------------------------
const kDeep = Color(0xFF081C2E); // navy pekat (overlay foto, nav)
const kPrimary = Color(0xFF08776D); // teal (tombol, ikon, harga)
const kPrimaryDark = Color(0xFF065A53);
const kAccent = Color(0xFFFFB627); // amber cerah (CTA & sorotan)
const kSage = Color(0xFFA8E6D8); // mint lembut untuk aksen di atas gelap
const kBg = Color(0xFFF4F7FA); // putih kebiruan
const kSurface = Color(0xFFFFFFFF);
const kBorder = Color(0xFFE2E8F0);
const kInk = Color(0xFF0B1B2B);
const kMuted = Color(0xFF5A6B7D);
const kSoftFill = Color(0xFFE3F4F1);

const kGradient = LinearGradient(
  colors: [Color(0xFF081C2E), Color(0xFF0B6E66)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// Bayangan lembut kebiruan untuk kartu.
const kCardShadow = [
  BoxShadow(color: Color(0x1A081C2E), blurRadius: 24, offset: Offset(0, 10)),
];

/// Font judul (Sora: geometris, modern) supaya tidak terkesan "template".
TextStyle kDisplay(
  double size, {
  Color color = kInk,
  FontWeight weight = FontWeight.w700,
  double height = 1.15,
}) =>
    GoogleFonts.sora(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kPrimary,
    brightness: Brightness.light,
  ).copyWith(
    primary: kPrimary,
    onPrimary: Colors.white,
    secondary: kAccent,
    surface: kSurface,
    onSurface: kInk,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
      .apply(bodyColor: kInk, displayColor: kInk);
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: c, width: w),
      );
  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: kBg,
    splashFactory: InkRipple.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: kBg,
      foregroundColor: kInk,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: kDisplay(21),
    ),
    dividerTheme: const DividerThemeData(color: kBorder, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: kMuted),
      prefixIconColor: kPrimary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: border(kBorder),
      enabledBorder: border(kBorder),
      focusedBorder: border(kPrimary, 1.8),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 54),
        foregroundColor: kPrimary,
        side: const BorderSide(color: kBorder, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: kSoftFill,
      checkmarkColor: kPrimary,
      side: const BorderSide(color: kBorder),
      labelStyle: const TextStyle(color: kInk, fontSize: 13, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: const Color(0x22081C2E),
      height: 68,
      indicatorColor: kSage,
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? kPrimary : kMuted,
          )),
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? kDeep : kMuted,
          )),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: kDeep,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: kPrimary),
  );
}

void snack(BuildContext c, String m) {
  ScaffoldMessenger.of(c)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(m),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
}

/// Kartu putih membulat dengan border tipis.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.borderColor = kBorder,
    this.borderWidth = 1,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(22);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: r, boxShadow: kCardShadow),
      child: Material(
        color: color ?? Colors.white,
        borderRadius: r,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: r,
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: kDisplay(20),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.color = kPrimary, this.icon});
  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar(this.category, {super.key, this.size = 52});
  final ServiceCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: category.tint.withOpacity(0.14),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(category.icon, color: category.tint, size: size * 0.5),
    );
  }
}

/// Baris ikon + teks kecil.
class IconText extends StatelessWidget {
  const IconText(this.icon, this.text, {super.key, this.color = kMuted, this.maxLines = 1});
  final IconData icon;
  final String text;
  final Color color;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

/// Animasi muncul halus (fade + naik sedikit). `delayMs` untuk efek berurutan.
class Reveal extends StatelessWidget {
  const Reveal({super.key, required this.child, this.delayMs = 0});
  final Widget child;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    final total = 550 + delayMs;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delayMs / total, 1.0, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0).toDouble(),
        child: Transform.translate(offset: Offset(0, (1 - v) * 22), child: child),
      ),
    );
  }
}

class NavItem {
  const NavItem(this.icon, this.selectedIcon, this.label, {this.badge = 0});
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int badge;
}

/// Bottom navigation melayang berbentuk kapsul gelap (terinspirasi referensi SKOG).
class FloatNav extends StatelessWidget {
  const FloatNav({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
  });

  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: kDeep,
            borderRadius: BorderRadius.circular(36),
            boxShadow: const [
              BoxShadow(color: Color(0x55081C2E), blurRadius: 26, offset: Offset(0, 12)),
            ],
          ),
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: _FloatNavButton(
                    item: items[i],
                    selected: i == index,
                    onTap: () => onChanged(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatNavButton extends StatelessWidget {
  const _FloatNavButton({required this.item, required this.selected, required this.onTap});
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      selected ? item.selectedIcon : item.icon,
      size: 22,
      color: selected ? kDeep : kSage,
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: selected ? 54 : 40,
            height: 34,
            decoration: BoxDecoration(
              color: selected ? kSage : Colors.transparent,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Center(
              child: item.badge > 0
                  ? Badge(label: Text('${item.badge}'), child: icon)
                  : icon,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              height: 1.1,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected ? Colors.white : kSage,
            ),
          ),
        ],
      ),
    );
  }
}

/// Panel kaca buram (glassmorphism) untuk di atas foto.
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.radius = 20,
    this.onTap,
    this.opacity = 0.16,
    this.blur = 16,
  });

  final Widget child;
  final double radius;
  final VoidCallback? onTap;
  final double opacity;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: r,
            border: Border.all(color: Colors.white.withOpacity(0.26)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(onTap: onTap, borderRadius: r, child: child),
          ),
        ),
      ),
    );
  }
}
