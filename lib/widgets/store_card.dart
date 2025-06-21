import 'package:flutter/material.dart';
import '../models/store_model.dart';

class StoreCard extends StatelessWidget {
  final StoreModel store;
  final Function()? onTap;
  final bool isCompact;

  const StoreCard({
    super.key,
    required this.store,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: ListTile(
          title: Text(store.name),
          subtitle: Text('Location: ${store.location}'),
          trailing: isCompact ? null : Icon(Icons.info_outline),
        ),
      ),
    );
  }
}
