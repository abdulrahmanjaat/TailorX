import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/customer.dart';
import '../../providers/language_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_spacing.dart';

class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key});

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final firestoreService = FirestoreService();
    final maxWidth = AppSpacing.responsiveMaxWidth(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 640;
    final horizontalPadding = isTablet ? AppSpacing.lg : AppSpacing.md;

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getText('All Customers', 'تمام گاہک')),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppSpacing.sm,
                    horizontalPadding,
                    AppSpacing.xs,
                  ),
                  child: SearchBar(
                    controller: _searchController,
                    leading: const Icon(Icons.search),
                    hintText: languageProvider.getText(
                      'Search by name or phone',
                      'نام یا فون سے تلاش کریں',
                    ),
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value.trim());
                    },
                    trailing: [
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Customer>>(
                    stream: firestoreService.getCustomers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            languageProvider.getText(
                              'Failed to load customers',
                              'گاہک لوڈ کرنے میں ناکامی',
                            ),
                          ),
                        );
                      }
                      var customers = snapshot.data ?? [];
                      if (_searchQuery.isNotEmpty) {
                        final query = _searchQuery.toLowerCase();
                        customers =
                            customers
                                .where(
                                  (c) =>
                                      c.name.toLowerCase().contains(query) ||
                                      c.phone.toLowerCase().contains(query),
                                )
                                .toList();
                      }
                      if (customers.isEmpty) {
                        return _EmptyState(languageProvider: languageProvider);
                      }
                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: AppSpacing.sm,
                        ),
                        itemCount: customers.length,
                        separatorBuilder:
                            (_, __) => SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          return Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(AppSpacing.md),
                              title: Text(
                                customer.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: AppSpacing.xs),
                                  Text(
                                    '${languageProvider.getText('Phone: ', 'فون: ')}${customer.phone}',
                                  ),
                                  SizedBox(height: AppSpacing.xs * 0.75),
                                  Text(
                                    '${languageProvider.getText('Measurements: ', 'پیمائش: ')}${customer.measurements.length}',
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/customer-details',
                                  arguments: customer.id,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.languageProvider});

  final LanguageProvider languageProvider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              languageProvider.getText(
                'No customers found. Start by adding a measurement.',
                'کوئی گاہک نہیں ملا۔ پیمائش شامل کریں۔',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
