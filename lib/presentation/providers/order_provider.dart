import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/data/repositories/order_repository.dart';
import 'package:by_arena/domain/models/order.dart';

final myOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final repo = ref.read(orderRepositoryProvider);
  return repo.getMyOrders();
});

final orderDetailProvider = FutureProvider.family<Order, String>((ref, id) async {
  final repo = ref.read(orderRepositoryProvider);
  return repo.getOrderDetail(id);
});
