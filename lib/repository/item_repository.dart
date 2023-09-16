import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:k3tab_2023/model/item_model.dart';
import 'package:k3tab_2023/util/sql_helper.dart';

class ItemRepository extends ChangeNotifier {
  final String _table = "items";

  List<Item> _list = [];

  UnmodifiableListView<Item> get list => UnmodifiableListView(_list);

  Item find(int id) => _list.firstWhere((element) => element.id == id);

  Future<void> load(int id) async {
    final db = await SQLHelper.db();
    _list = [];
    try {
      var itemList = await db.query(_table,
          orderBy: "item_number ASC", where: "list_id = ?", whereArgs: [id]);
      for (var item in itemList) {
        _list.add(Item.fromJson(item));
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> add(Item item) async {
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

  Future<void> addNote(int id, String note) async {
    final db = await SQLHelper.db();
    try {
      var index = _list.indexWhere((element) => element.id == id);
      await db.update(_table, {'note': note}, where: "id = ?", whereArgs: [id]);
      _list[index].note = note;
    } catch (e) {
      throw Exception(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> toggle(int id) async {
    final db = await SQLHelper.db();
    try {
      var index = _list.indexWhere((element) => element.id == id);
      await db.update(_table, {'checked': (!_list[index].checked) ? 1 : 0},
          where: "id = ?", whereArgs: [id]);
      _list[index].checked = !_list[index].checked;
    } catch (e) {
      throw Exception(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> check(int id) async {
    final db = await SQLHelper.db();
    try {
      var index = _list.indexWhere((element) => element.id == id);
      await db.update(_table, {'checked': 1}, where: "id = ?", whereArgs: [id]);
      _list[index].checked = true;
    } catch (e) {
      throw Exception(e);
    } finally {
      notifyListeners();
    }
  }
}
