import 'package:flutter/material.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/createTripViewmodel.dart';

class CountryField extends StatelessWidget {
  final CreateTripViewModel viewModel;

  const CountryField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: viewModel.isLoadingCountries
          ? null
          : () async {
              final result = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                builder: (context) {
                  return _CountrySearchSheet(countries: viewModel.countries);
                },
              );

              if (result != null) {
                viewModel.selectCountry(result);
              }
            },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 5,
              offset: const Offset(0,4),
            ),
          ],
        ),
        child: Row(
          children: [
            viewModel.selectedCountry == null
                ? const Icon(
                    Icons.public_outlined,
                    color: AppColors.tabInactive,
                    size: 20,
                  )
                : Text(
                    viewModel.selectedCountry?['emoji'] ?? '🏳️',
                    style: const TextStyle(fontSize: 20),
                  ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                viewModel.selectedCountry?['name'] ?? 'Select country',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: viewModel.selectedCountry == null
                      ? AppColors.tabInactive
                      : AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.tabInactive),
          ],
        ),
      ),
    );
  }
}

class _CountrySearchSheet extends StatefulWidget {
  final List<Map<String, dynamic>> countries;

  const _CountrySearchSheet({required this.countries});

  @override
  State<_CountrySearchSheet> createState() => _CountrySearchSheetState();
}

class _CountrySearchSheetState extends State<_CountrySearchSheet> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filteredCountries = widget.countries.where((country) {
      final name = (country['name'] ?? '').toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 12),

            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search country',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: filteredCountries.length,
                itemBuilder: (context, index) {
                  final country = filteredCountries[index];

                  return ListTile(
                    leading: Text(
                      country['emoji'] ?? '🏳️',
                      style: const TextStyle(fontSize: 22),
                    ),
                    title: Text(country['name'] ?? ''),
                    onTap: () {
                      Navigator.pop(context, country);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
