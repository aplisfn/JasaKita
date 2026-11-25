import 'package:flutter/material.dart';

import 'art.dart';
import 'models.dart';

// ---------------------------------------------------------------------------
// Foto asli dari Pexels (lisensi bebas pakai, termasuk di aplikasi).
// Dimuat lewat internet. Selama memuat / jika gagal, otomatis tampil
// ilustrasi kategori sebagai cadangan, jadi layar tidak pernah kosong.
// Untuk mengganti foto: ubah angka ID di bawah (ID ada di URL pexels.com/photo/ID).
// ---------------------------------------------------------------------------

String pexelsUrl(int id, {int width = 800}) =>
    'https://images.pexels.com/photos/$id/pexels-photo-$id.jpeg?auto=compress&cs=tinysrgb&w=$width';

const Map<ServiceCategory, List<int>> _photoIds = {
  ServiceCategory.pertanian: [235731, 32954649, 35544010, 31203928],
  ServiceCategory.bangunan: [13930482, 13944023, 36073765, 6509862],
  ServiceCategory.angkut: [16392127],
  ServiceCategory.elektronik: [2136243, 10699355, 12741836, 6754846],
  ServiceCategory.lainnya: [8853536, 3939920],
};

/// Foto hero layar awal (digeser otomatis) + ilustrasi cadangannya.
const heroPhotoIds = [35544010, 13930482, 2136243];
const heroFallbacks = [
  ServiceCategory.pertanian,
  ServiceCategory.bangunan,
  ServiceCategory.elektronik,
];

/// Angka stabil dari teks (supaya mitra yang sama selalu dapat foto yang sama).
int seedOf(String s) => s.codeUnits.fold<int>(0, (a, b) => (a * 31 + b) & 0x7fffffff);

int photoId(ServiceCategory c, [int seed = 0]) {
  final list = _photoIds[c]!;
  return list[seed % list.length];
}

/// Foto yang memudar masuk di atas ilustrasi cadangan.
class Photo extends StatelessWidget {
  const Photo({
    super.key,
    required this.id,
    required this.fallback,
    this.width = 800,
    this.alignment = Alignment.center,
  });

  final int id;
  final ServiceCategory fallback;
  final int width;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CategoryScene(fallback, borderRadius: 0),
        Image.network(
          pexelsUrl(id, width: width),
          fit: BoxFit.cover,
          alignment: alignment,
          gaplessPlayback: true,
          frameBuilder: (context, child, frame, sync) {
            if (sync) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: child,
            );
          },
          errorBuilder: (context, error, stack) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
