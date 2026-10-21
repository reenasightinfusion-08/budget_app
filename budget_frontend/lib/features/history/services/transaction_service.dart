import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/network/api_client.dart';
import 'package:budget_frontend/features/categories/models/category_registry.dart';
import 'package:budget_frontend/features/history/models/history_transaction_model.dart';
import 'package:budget_frontend/features/history/models/month_summary_model.dart';

class TransactionEntry {
  final String type; // 'income' or 'expense'
  final int amountPaise;
  final String categoryKey;
  final String note;
  final String date;
  final String today;

  const TransactionEntry({
    required this.type,
    required this.amountPaise,
    required this.categoryKey,
    required this.note,
    required this.date,
    required this.today,
  });

  Map<String, dynamic> toMap() => {
    'type': type,
    'amount': amountPaise,
    'category': categoryKey,
    'note': note,
    'date': date,
  };
}

class TransactionService {
  TransactionService(this.client);

  final ApiClient client;

  /// Normalizes user-input transaction data into a verified [TransactionEntry].
  static TransactionEntry prepareEntry({
    required double amount,
    required String transactionType,
    required String category,
    required String note,
    required DateTime entryDate,
    String? defaultExpenseKey,
  }) {
    final paise = (amount * 100).round();
    final isIncome = transactionType.trim().toLowerCase() == 'income';
    final type = isIncome ? 'income' : 'expense';
    final catModel = CategoryRegistry.find(category, type);
    final categoryKey =
        catModel?.key ?? (isIncome ? 'salary' : (defaultExpenseKey ?? 'food'));
    final now = DateTime.now();

    return TransactionEntry(
      type: type,
      amountPaise: paise,
      categoryKey: categoryKey,
      note: note,
      date: AppFormatters.dateForApi(entryDate),
      today: AppFormatters.dateForApi(now),
    );
  }

  /// Creates a single transaction from a prepared [TransactionEntry].
  Future<void> createTransactionEntry(TransactionEntry entry) =>
      createTransaction(
        type: entry.type,
        amountPaise: entry.amountPaise,
        category: entry.categoryKey,
        note: entry.note,
        date: entry.date,
        today: entry.today,
      );

  /// Creates a single transaction (manual spend or income).
  ///
  /// [amountPaise] is in paise (e.g. ₹1800 -> 180000).
  /// [type] must be 'expense' or 'income'.
  /// [category] must be the key (e.g. 'food', 'bills', 'salary', 'freelance').
  /// [date] and [today] are formatted as 'YYYY-MM-DD'.
  Future<void> createTransaction({
    required String type,
    required int amountPaise,
    required String category,
    String note = '',
    required String date,
    required String today,
  }) async {
    await client.post('/transactions', {
      'type': type,
      'amount': amountPaise,
      'category': category,
      'note': note,
      'date': date,
      'today': today,
    });
  }

  /// Saves multiple transactions at once via `POST /api/transactions/bulk`.
  ///
  /// Used for saving entries reviewed on the Smart add review screen.
  /// [entries] max 80 items. Each item must have:
  /// - `type`: 'income' or 'expense'
  /// - `amount`: paise integer
  /// - `category`: active category key
  /// - `note`: string (max 40)
  /// - `date`: 'YYYY-MM-DD'
  Future<String> bulkTransactions({
    String? importId,
    required String today,
    required List<Map<String, dynamic>> entries,
  }) async {
    final res = await client.postFull('/transactions/bulk', {
      if (importId != null && importId.isNotEmpty) 'importId': importId,
      'today': today,
      'entries': entries,
    });
    return res['message'] as String? ?? '${entries.length} transactions added';
  }

  /// Lists transactions newest first, supporting type filter, search query, and pagination.
  Future<List<HistoryTransactionModel>> getTransactions({
    String? type,
    String? q,
    String? before,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (type != null && type.isNotEmpty) queryParams['type'] = type;
    if (q != null && q.trim().isNotEmpty) queryParams['q'] = q.trim();
    if (before != null && before.isNotEmpty) queryParams['before'] = before;
    if (limit != null) queryParams['limit'] = limit.toString();

    final queryString = queryParams.isNotEmpty
        ? '?${Uri(queryParameters: queryParams).query}'
        : '';

    final data = await client.get('/transactions$queryString');
    final list = data['transactions'] as List<dynamic>? ?? [];
    final items = list
        .whereType<Map<String, dynamic>>()
        .map((item) => HistoryTransactionModel.fromJson(item))
        .toList();

    // Ensure most recent transactions are always at the top
    items.sort((a, b) {
      final dateCmp = b.date.compareTo(a.date);
      if (dateCmp != 0) return dateCmp;
      if (b.createdAt != null && a.createdAt != null) {
        return b.createdAt!.compareTo(a.createdAt!);
      }
      return 0;
    });

    return items;
  }

  /// Deletes a transaction by id.
  Future<void> deleteTransaction(String id) async {
    await client.delete('/transactions/$id');
  }

  /// Fetches monthly summary data for Home, Budget, and Insights.
  /// Defaults [month] to current local 'YYYY-MM' and [today] to 'YYYY-MM-DD'.
  Future<MonthSummaryModel> getTransactionSummary({
    String? month,
    String? today,
  }) async {
    final now = DateTime.now();
    final effectiveMonth = month ?? AppFormatters.monthForApi(now);
    final effectiveToday = today ?? AppFormatters.dateForApi(now);

    final data = await client.get(
      '/transactions/summary?month=$effectiveMonth&today=$effectiveToday',
    );
    return MonthSummaryModel.fromJson(data);
  }
}

