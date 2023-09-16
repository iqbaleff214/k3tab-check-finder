import 'package:flutter/cupertino.dart';

class Item {
  late int id;
  late int listId;
  late int itemNumber;
  late String partNumber;
  late String jobDescription;
  late String status;
  bool checked = false;
  int quantity = 0;
  String note = '';

  Item(this.jobDescription, this.status, this.listId, num qty, dynamic partNo, dynamic itemNo) {
    if (qty is double) {
      quantity = qty.toInt();
    } else if (qty is int) {
      quantity = qty;
    }

    if (partNo is double) {
      partNumber = partNo.toStringAsFixed(0);
    } else {
      partNumber = partNo.toString();
    }

    if (itemNo is int) {
      itemNumber = itemNo;
    } else if (itemNo is double) {
      itemNumber = itemNo.toInt();
    }
  }

  Item.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemNumber = json['item_number'];
    partNumber = json['part_number'];
    jobDescription = json['job_description'];
    status = json['status'];
    listId = json['list_id'];
    quantity = json['quantity'];
    checked = json['checked'] == 1;
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    return {
      'item_number': itemNumber,
      'part_number': partNumber,
      'job_description': jobDescription,
      'status': status,
      'list_id': listId,
      'quantity': quantity,
      'checked': checked ? 1 : 0,
      'note': note,
    };
  }
}