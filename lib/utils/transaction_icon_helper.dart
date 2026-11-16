import 'package:flutter/material.dart';

class TransactionIconHelper {
  /// Mendapatkan icon yang sesuai dengan kata/sumber transaksi
  static IconData getIcon(String source, bool isIncome) {
    final s = source.toLowerCase().trim();

    // Makanan & Minuman
    if (s.contains('makan') ||
        s.contains('food') ||
        s.contains('resto') ||
        s.contains('restoran') ||
        s.contains('warung') ||
        s.contains('bakso') ||
        s.contains('mie') ||
        s.contains('nasi') ||
        s.contains('kuliner') ||
        s.contains('sarapan') ||
        s.contains('snack') ||
        s.contains('jajan') ||
        s.contains('dinner') ||
        s.contains('lunch') ||
        s.contains('ayam') ||
        s.contains('roti') ||
        s.contains('kue')) {
      return Icons.restaurant_outlined;
    }

    if (s.contains('kopi') ||
        s.contains('coffee') ||
        s.contains('minum') ||
        s.contains('drink') ||
        s.contains('cafe') ||
        s.contains('kafe') ||
        s.contains('teh') ||
        s.contains('tea') ||
        s.contains('boba') ||
        s.contains('jus') ||
        s.contains('juice') ||
        s.contains('air mineral')) {
      return Icons.local_cafe_outlined;
    }

    // Bensin & Bahan Bakar
    if (s.contains('bensin') ||
        s.contains('bbm') ||
        s.contains('pertamax') ||
        s.contains('pertalite') ||
        s.contains('solar') ||
        s.contains('spbu') ||
        s.contains('fuel') ||
        s.contains('gas')) {
      return Icons.local_gas_station_outlined;
    }

    // Transportasi & Kendaraan
    if (s.contains('transport') ||
        s.contains('ojek') ||
        s.contains('gojek') ||
        s.contains('grab') ||
        s.contains('maxim') ||
        s.contains('indrive') ||
        s.contains('ongkir') ||
        s.contains('motor') ||
        s.contains('mobil') ||
        s.contains('parkir') ||
        s.contains('tol') ||
        s.contains('kereta') ||
        s.contains('krl') ||
        s.contains('mrt') ||
        s.contains('lrt') ||
        s.contains('bus') ||
        s.contains('angkot') ||
        s.contains('taxi') ||
        s.contains('taksi') ||
        s.contains('tiket pesawat') ||
        s.contains('pesawat')) {
      return Icons.directions_car_outlined;
    }

    // Belanja & Kebutuhan
    if (s.contains('belanja') ||
        s.contains('shop') ||
        s.contains('pasar') ||
        s.contains('supermarket') ||
        s.contains('indomaret') ||
        s.contains('alfamart') ||
        s.contains('mall') ||
        s.contains('toko') ||
        s.contains('beli') ||
        s.contains('sembako') ||
        s.contains('shopee') ||
        s.contains('tokopedia') ||
        s.contains('lazada') ||
        s.contains('tiktok shop')) {
      return Icons.shopping_bag_outlined;
    }

    // Gaji & Pendapatan
    if (s.contains('gaji') ||
        s.contains('salary') ||
        s.contains('upah') ||
        s.contains('honor') ||
        s.contains('pendapatan') ||
        s.contains('proyek') ||
        s.contains('project') ||
        s.contains('freelance') ||
        s.contains('lembur') ||
        s.contains('income')) {
      return Icons.payments_outlined;
    }

    // Bonus, Hadiah & THR
    if (s.contains('bonus') ||
        s.contains('thr') ||
        s.contains('hadiah') ||
        s.contains('gift') ||
        s.contains('kado') ||
        s.contains('reward') ||
        s.contains('angpao') ||
        s.contains('tips') ||
        s.contains('tip')) {
      return Icons.card_giftcard_outlined;
    }

    // Tagihan & Utilitas
    if (s.contains('listrik') || s.contains('pln') || s.contains('token')) {
      return Icons.bolt_outlined;
    }
    if (s.contains('air') || s.contains('pdam')) {
      return Icons.water_drop_outlined;
    }
    if (s.contains('internet') ||
        s.contains('wifi') ||
        s.contains('indihome') ||
        s.contains('biznet') ||
        s.contains('first media') ||
        s.contains('pulsa') ||
        s.contains('kuota') ||
        s.contains('paket data') ||
        s.contains('telkomsel') ||
        s.contains('indosat') ||
        s.contains('xl') ||
        s.contains('smartfren') ||
        s.contains('tri')) {
      return Icons.wifi_outlined;
    }
    if (s.contains('tagihan') ||
        s.contains('bill') ||
        s.contains('iuran') ||
        s.contains('pajak') ||
        s.contains('cicilan') ||
        s.contains('bpjs') ||
        s.contains('asuransi') ||
        s.contains('sewa')) {
      return Icons.receipt_long_outlined;
    }

    // Kesehatan & Obat
    if (s.contains('obat') ||
        s.contains('sehat') ||
        s.contains('kesehatan') ||
        s.contains('dokter') ||
        s.contains('apotek') ||
        s.contains('rs') ||
        s.contains('rumah sakit') ||
        s.contains('klinik') ||
        s.contains('medis') ||
        s.contains('vitamin') ||
        s.contains('periksa')) {
      return Icons.medical_services_outlined;
    }

    // Pendidikan & Belajar
    if (s.contains('sekolah') ||
        s.contains('kuliah') ||
        s.contains('pendidikan') ||
        s.contains('kursus') ||
        s.contains('buku') ||
        s.contains('spp') ||
        s.contains('ujian') ||
        s.contains('les') ||
        s.contains('bimbel') ||
        s.contains('wisuda') ||
        s.contains('seragam')) {
      return Icons.school_outlined;
    }

    // Hiburan & Rekreasi
    if (s.contains('game') ||
        s.contains('gaming') ||
        s.contains('top up') ||
        s.contains('diamond') ||
        s.contains('hiburan') ||
        s.contains('bioskop') ||
        s.contains('cinema') ||
        s.contains('nonton') ||
        s.contains('netflix') ||
        s.contains('spotify') ||
        s.contains('youtube') ||
        s.contains('liburan') ||
        s.contains('holiday') ||
        s.contains('wisata') ||
        s.contains('rekreasi') ||
        s.contains('jalan-jalan')) {
      return Icons.sports_esports_outlined;
    }

    // Pakaian & Fashion
    if (s.contains('baju') ||
        s.contains('celana') ||
        s.contains('pakaian') ||
        s.contains('sepatu') ||
        s.contains('sandal') ||
        s.contains('tas') ||
        s.contains('jaket') ||
        s.contains('laundry') ||
        s.contains('fashion')) {
      return Icons.checkroom_outlined;
    }

    // Sedekah, Donasi & Keagamaan
    if (s.contains('sedekah') ||
        s.contains('zakat') ||
        s.contains('infaq') ||
        s.contains('donasi') ||
        s.contains('amal') ||
        s.contains('masjid') ||
        s.contains('gereja') ||
        s.contains('qurban') ||
        s.contains('sumbangan')) {
      return Icons.volunteer_activism_outlined;
    }

    // Investasi & Tabungan
    if (s.contains('investasi') ||
        s.contains('saham') ||
        s.contains('reksadana') ||
        s.contains('kripto') ||
        s.contains('crypto') ||
        s.contains('trading') ||
        s.contains('emas') ||
        s.contains('gold') ||
        s.contains('deposito')) {
      return Icons.trending_up_outlined;
    }
    if (s.contains('tabungan') ||
        s.contains('nabung') ||
        s.contains('celengan') ||
        s.contains('simpanan')) {
      return Icons.savings_outlined;
    }

    // Bisnis & Penjualan
    if (s.contains('jual') ||
        s.contains('jualan') ||
        s.contains('dagang') ||
        s.contains('usaha') ||
        s.contains('bisnis') ||
        s.contains('omset') ||
        s.contains('profit') ||
        s.contains('laba')) {
      return Icons.storefront_outlined;
    }

    // Rumah Tangga
    if (s.contains('rumah') ||
        s.contains('kos') ||
        s.contains('kontrakan') ||
        s.contains('perabot') ||
        s.contains('dapur')) {
      return Icons.home_outlined;
    }

    // Default Fallback
    return isIncome ? Icons.account_balance_wallet_outlined : Icons.receipt_outlined;
  }
}
