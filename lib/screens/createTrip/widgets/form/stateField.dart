import 'package:flutter/material.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/createTripViewmodel.dart';

class StateField extends StatelessWidget {
  final CreateTripViewModel viewModel;

  const StateField({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = viewModel.selectedCountry != null;

    return InkWell(
      onTap: !enabled
          ? null
          : () async {
              final result = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                ),
                builder: (context) {
                  return _StateSearchSheet(
                    states: viewModel.states,
                  );
                },
              );

              if (result != null) {
                viewModel.selectState(result);
              }
            },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: enabled ? AppColors.bgCard : Colors.grey.shade100,
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
            Icon(
              Icons.location_city_outlined,
              color: enabled ? AppColors.tabInactive : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                viewModel.selectedState?['name'] ??
                    (enabled ? 'State (Optional)' : 'Select country first'),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: viewModel.selectedState == null
                      ? AppColors.tabInactive
                      : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: enabled ? AppColors.tabInactive : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

class _StateSearchSheet extends StatefulWidget {
  final List<Map<String, dynamic>> states;

  const _StateSearchSheet({
    required this.states,
  });

  @override
  State<_StateSearchSheet> createState() => _StateSearchSheetState();
}

class _StateSearchSheetState extends State<_StateSearchSheet> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filteredStates = widget.states.where((state) {
      final name = (state['name'] ?? '').toString().toLowerCase();
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
                  hintText: 'Search state',
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
                itemCount: filteredStates.length,
                itemBuilder: (context, index) {
                  final state = filteredStates[index];

                  return ListTile(
                    leading: const Icon(
                      Icons.location_city_outlined,
                      color: AppColors.tabInactive,
                    ),
                    title: Text(state['name'] ?? ''),
                    onTap: () {
                      Navigator.pop(context, state);
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