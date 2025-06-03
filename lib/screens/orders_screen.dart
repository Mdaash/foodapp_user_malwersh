import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const OrdersScreen({super.key, this.onBack});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildCurrentOrders() {
    // يمكنك استبدال هذا بقائمة الطلبات الحقيقية
    final currentOrders = <Map<String, dynamic>>[];
    if (currentOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('لا يوجد طلبات حالية', 
              style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            const Text('ابدأ بطلب وجبتك المفضلة الآن', 
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: currentOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final order = currentOrders[i];
        return ListTile(
          leading: const Icon(Icons.receipt_long, color: Color(0xFF00c1e8)),
          title: Text('طلب رقم ${order['id']}'),
          subtitle: Text(order['status'] ?? ''),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () {
            // يمكنك فتح تفاصيل الطلب هنا
          },
        );
      },
    );
  }

  Widget _buildPastOrders() {
    // يمكنك استبدال هذا بقائمة الطلبات السابقة
    final pastOrders = <Map<String, dynamic>>[];
    if (pastOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('لا يوجد طلبات سابقة', 
              style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            const Text('ستظهر هنا طلباتك المكتملة', 
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: pastOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final order = pastOrders[i];
        return ListTile(
          leading: const Icon(Icons.history, color: Color(0xFF00c1e8)),
          title: Text('طلب رقم ${order['id']}'),
          subtitle: Text(order['date'] ?? ''),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () {
            // يمكنك فتح تفاصيل الطلب هنا
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // عنوان الشاشة مع التبويبات
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text('الطلبات', 
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF00c1e8),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF00c1e8),
                    tabs: const [
                      Tab(text: 'الحالية'),
                      Tab(text: 'السابقة'),
                    ],
                  ),
                ],
              ),
            ),
            // المحتوى
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCurrentOrders(),
                  _buildPastOrders(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
