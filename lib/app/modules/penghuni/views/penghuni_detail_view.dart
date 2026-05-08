import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../repositories/repository_factory.dart';
import '../../../../repositories/tagihan_repository.dart';
import '../models/penghuni_model.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/penghuni_detail_header.dart';
import 'widgets/info_penghuni_card.dart';
import 'widgets/data_pribadi_card.dart';
import 'widgets/kontak_darurat_card.dart';
import 'widgets/informasi_kamar_card.dart';
import 'widgets/informasi_kontrak_card.dart';
import 'widgets/history_pembayaran_card.dart';
import 'widgets/penghuni_detail_helpers.dart';

class PenghuniDetailView extends StatefulWidget {
  const PenghuniDetailView({super.key});

  @override
  State<PenghuniDetailView> createState() => _PenghuniDetailViewState();
}

class _PenghuniDetailViewState extends State<PenghuniDetailView> {
  static final TagihanRepository _tagihanRepo =
      RepositoryFactory.instance.tagihanRepository;
  PenghuniModel? _penghuni;

  @override
  void initState() {
    super.initState();
    // Simpan arguments di initState agar tidak hilang saat rebuild
    _penghuni = Get.arguments as PenghuniModel?;
  }

  @override
  Widget build(BuildContext context) {
    // Handle null case
    if (_penghuni == null) {
      return const EmptyStateWidget();
    }

    // Gunakan variabel lokal non-nullable untuk memudahkan akses
    final penghuni = _penghuni!;
    final billingFuture = PenghuniDetailHelpers.loadBillingHistory(
      penghuni,
      _tagihanRepo,
    );
    final contractBadge = PenghuniDetailHelpers.getContractBadge(penghuni);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header
            const PenghuniDetailHeader(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Card Info Penghuni
                    InfoPenghuniCard(
                      penghuni: penghuni,
                      contractBadge: contractBadge,
                    ),

                    const SizedBox(height: 16),

                    // Card Data Pribadi
                    DataPribadiCard(penghuni: penghuni),

                    const SizedBox(height: 16),

                    // Card Kontak Darurat
                    KontakDaruratCard(penghuni: penghuni),

                    const SizedBox(height: 16),

                    // Card Informasi Kamar
                    InformasiKamarCard(penghuni: penghuni),

                    const SizedBox(height: 16),

                    // Card Informasi Kontrak
                    InformasiKontrakCard(
                      penghuni: penghuni,
                      onContractUpdated: (updatedPenghuni) {
                        setState(() {
                          _penghuni = updatedPenghuni;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Card History Pembayaran
                    HistoryPembayaranCard(billingFuture: billingFuture),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
