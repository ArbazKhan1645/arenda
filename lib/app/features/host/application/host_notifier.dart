import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../home/data/datasources/mock_home_datasource.dart';
import '../../home/domain/entities/listing_entity.dart';

part 'host_notifier.g.dart';

// ── State ──────────────────────────────────────────────────────────────────

sealed class HostState {
  const HostState();
}

final class HostLoading extends HostState {
  const HostLoading();
}

final class HostLoaded extends HostState {
  const HostLoaded({
    required this.myListings,
    required this.earningsThisMonth,
    required this.totalEarnings,
    required this.pendingBookingsCount,
    required this.completedBookingsCount,
    required this.preferredPayoutMethod,
    required this.payoutAccountNumber,
    required this.isIdVerified,
    required this.localCurrency,
  });

  final List<ListingEntity> myListings;
  final double earningsThisMonth;
  final double totalEarnings;
  final int pendingBookingsCount;
  final int completedBookingsCount;
  final String? preferredPayoutMethod;
  final String? payoutAccountNumber;
  final bool isIdVerified;
  final String localCurrency;
}

final class HostError extends HostState {
  const HostError(this.message);
  final String message;
}

// ── Payout method data ─────────────────────────────────────────────────────

class PayoutMethod {
  const PayoutMethod({
    required this.type,
    required this.label,
    required this.icon,
    this.accountNumber,
    this.bankName,
    this.isDefault = false,
  });

  final String type; // 'mtn_momo' | 'orange_money' | 'wave' | 'bank' | 'cash'
  final String label;
  final String icon;
  final String? accountNumber;
  final String? bankName;
  final bool isDefault;
}

// ── Notifier ───────────────────────────────────────────────────────────────

@Riverpod(keepAlive: false)
class HostNotifier extends _$HostNotifier {
  @override
  HostState build() => const HostLoading();

  Future<void> load(String hostId) async {
    state = const HostLoading();
    await Future.delayed(const Duration(milliseconds: 600));

    final listings = MockHomeDataSource.getHostListings(hostId);

    // Mock earnings calculation
    final earningsThisMonth = listings.length * 1800.0;
    final totalEarnings = listings.length * 14500.0;

    state = HostLoaded(
      myListings: listings,
      earningsThisMonth: earningsThisMonth,
      totalEarnings: totalEarnings,
      pendingBookingsCount: 3,
      completedBookingsCount: 28,
      preferredPayoutMethod: 'MTN MoMo',
      payoutAccountNumber: '024 XXX XXXX',
      isIdVerified: true,
      localCurrency: 'GHS',
    );
  }

  void updatePayoutPreferences({
    required String method,
    required String accountNumber,
    String? bankName,
    String? currency,
  }) {
    final current = state;
    if (current is! HostLoaded) return;
    state = HostLoaded(
      myListings: current.myListings,
      earningsThisMonth: current.earningsThisMonth,
      totalEarnings: current.totalEarnings,
      pendingBookingsCount: current.pendingBookingsCount,
      completedBookingsCount: current.completedBookingsCount,
      preferredPayoutMethod: method,
      payoutAccountNumber: accountNumber,
      isIdVerified: current.isIdVerified,
      localCurrency: currency ?? current.localCurrency,
    );
  }
}
