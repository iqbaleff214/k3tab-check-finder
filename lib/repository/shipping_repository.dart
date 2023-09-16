import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:k3tab_2023/model/shipping_model.dart';
import 'package:k3tab_2023/util/sql_helper.dart';

class ShippingRepository extends ChangeNotifier {
  final String _table = "lists";

  List<Shipping> _list = [];

  UnmodifiableListView<Shipping> get list => UnmodifiableListView(_list);

  Shipping find(int id) => _list.firstWhere((element) => element.id == id);

  Future<void> load() async {
    final db = await SQLHelper.db();
    try {
      var shippingList = await db.query(_table, orderBy: "updated_at DESC", );
      for (var shipping in shippingList) {
        _list.add(Shipping.fromJson(shipping));
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      notifyListeners();
      db.close();
    }
  }

  Future<void> add(Shipping item) async {
    final db = await SQLHelper.db();
    try {
      item.id = await db.insert(_table, item.toJson());
      _list.add(item);
    } catch (e) {
      throw Exception(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> progress(int id, double progress) async {
    final db = await SQLHelper.db();
    try {
      var current = DateTime.now();
      var index = _list.indexWhere((element) => element.id == id);
      await db.update(_table, {'progress': progress, 'updated_at': current.toString()}, where: "id = ?", whereArgs: [id]);
      _list[index].progress = progress;
      _list[index].updatedAt = current;
    } catch (e) {
      throw Exception(e);
    } finally {
      notifyListeners();
    }
  }

  void delete(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete(_table, where: "id = ?", whereArgs: [id]);
      _list = _list.where((i) => i.id != id).toList();
    } catch (e) {
      throw Exception(e);
    } finally {
      notifyListeners();
    }
  }
}
