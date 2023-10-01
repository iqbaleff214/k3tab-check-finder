import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:k3tab_2023/model/item_model.dart';
import 'package:k3tab_2023/model/shipping_model.dart';
import 'package:k3tab_2023/repository/item_repository.dart';
import 'package:k3tab_2023/repository/shipping_repository.dart';
import 'package:k3tab_2023/util/color.dart';
import 'package:k3tab_2023/view/summary_screen.dart';
import 'package:k3tab_2023/view/update_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(
      {super.key, required this.shippingRepo, required this.itemRepo});

  final ShippingRepository shippingRepo;
  final ItemRepository itemRepo;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  bool _isUploadLoading = false;

  @override
  void initState() {
    _load();
    super.initState();
  }

  void _load() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await widget.shippingRepo.load();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void upload() async {
    setState(() {
      _isUploadLoading = true;
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    try {
      if (result == null) return;

      for (var file in result.files) {
        var path = file.path ?? '';
        if (path == '') continue;

        await widget.shippingRepo.add(Shipping(file.name, path));
        var shipping = widget.shippingRepo.list.last;
        widget.shippingRepo.sort();

        var excel = Excel.decodeBytes(File(path).readAsBytesSync());
        for (var element in excel.tables.keys) {
          var table = excel.tables[element];
          if (table == null) continue;

          bool fromExported = false;
          int rowPointer = 0;
          for (var row in table.rows) {
            rowPointer++;
            if (rowPointer == 1) {
              fromExported = row[1]?.value.toString() == 'Product / Service';
              continue;
            }

            if (fromExported) {
              var item = Item(
                  row[2]!.value.toString(),
                  row[3]!.value.toString(),
                  shipping.id,
                  row[4]!.value.toString(),
                  row[5]!.value,
                  row[1]!.value,
                  row[0]!.value);
              item.checked = row[6]!.value.toString() == 'Yes';
              item.note = (row[7]?.value ?? '-').toString();

              if (item.checked) continue;

              await widget.itemRepo.add(item);
            } else {
              var status =
                  table.maxCols < 9 ? 'Open' : row[8]!.value.toString();
              if (status.toLowerCase() == 'released') {
                continue;
              }

              var category =
                  table.maxCols < 8 ? 'Order Item' : row[7]!.value.toString();
              debugPrint('\t $category');
              if (!category.toLowerCase().contains('order item')) {
                continue;
              }

              await widget.itemRepo.add(
                Item(
                    row[5]!.value.toString(),
                    // jobDescription
                    status,
                    // status
                    shipping.id,
                    // listId
                    (row[2]?.value ?? '-').toString(),
                    // segment
                    row[4]!.value,
                    // qty
                    row[3]!.value,
                    // partNo
                    row[0]!.value), // itemNo
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('error:$e');
    } finally {
      setState(() {
        _isUploadLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAFAFA),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 30 + 20.0, 30, 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Shipping List",
              style: GoogleFonts.poppins().copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                "Your incoming shipping list history",
                style: GoogleFonts.poppins()
                    .copyWith(fontSize: 12, color: const Color(0xFF8D92A3)),
              ),
            ),
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: orangeColor,
                      ),
                    ),
                  )
                : widget.shippingRepo.list.isNotEmpty
                    ? Expanded(
                        child: MediaQuery.removePadding(
                        removeTop: true,
                        context: context,
                        child: ListView.builder(
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateScreen(
                                    itemRepository: widget.itemRepo,
                                    shippingRepository: widget.shippingRepo,
                                    shipping: widget.shippingRepo.list[index],
                                  ),
                                )),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 225,
                                            child: Text(
                                              widget
                                                  .shippingRepo.list[index].title,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins()
                                                  .copyWith(
                                                      fontSize: 10,
                                                      color: const Color(
                                                          0xFF8D92A3)),
                                            ),
                                          ),
                                          Text(
                                            '${widget.shippingRepo.list[index].progress.toStringAsFixed(1)}%',
                                            style: GoogleFonts.poppins().copyWith(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'last updated: ${widget.shippingRepo.list[index].updatedAt.toLocal().toString()}',
                                            style: GoogleFonts.poppins().copyWith(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w100,
                                                color: const Color(0xFF8D92A3)),
                                          )
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        PopupMenuButton(
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                                child: Text(
                                                  "Summary",
                                                  style: GoogleFonts.poppins()
                                                      .copyWith(
                                                          fontSize: 16,
                                                          color: const Color(
                                                              0xFF8D92A3)),
                                                ),
                                                onTap: () => WidgetsBinding
                                                        ?.instance
                                                        ?.addPostFrameCallback(
                                                            (_) {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                SummaryScreen(
                                                              itemRepository:
                                                                  widget
                                                                      .itemRepo,
                                                              shippingRepository:
                                                                  widget
                                                                      .shippingRepo,
                                                              shipping: widget
                                                                  .shippingRepo
                                                                  .list[index],
                                                            ),
                                                          ));
                                                    })),
                                            PopupMenuItem(
                                              child: Text(
                                                "Update",
                                                style: GoogleFonts.poppins()
                                                    .copyWith(
                                                        fontSize: 16,
                                                        color: const Color(
                                                            0xFF8D92A3)),
                                              ),
                                              onTap: () => WidgetsBinding
                                                  ?.instance
                                                  ?.addPostFrameCallback((_) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          UpdateScreen(
                                                        itemRepository:
                                                            widget.itemRepo,
                                                        shippingRepository:
                                                            widget.shippingRepo,
                                                        shipping: widget
                                                            .shippingRepo
                                                            .list[index],
                                                      ),
                                                    ));
                                              }),
                                            ),
                                            PopupMenuItem(
                                              child: Text(
                                                "Delete",
                                                style: GoogleFonts.poppins()
                                                    .copyWith(
                                                        fontSize: 16,
                                                        color: const Color(
                                                            0xFF8D92A3)),
                                              ),
                                              onTap: () => WidgetsBinding
                                                  .instance
                                                  .addPostFrameCallback((_) {
                                                showDialog<void>(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      actionsAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      title: Center(
                                                        child: Text(
                                                          'Are you sure?',
                                                          style: GoogleFonts
                                                                  .poppins()
                                                              .copyWith(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                const Color(
                                                                    0xFFFFCC28),
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5,
                                                                    bottom: 5,
                                                                    left: 20,
                                                                    right: 20),
                                                          ),
                                                          child: Text(
                                                            'YES',
                                                            style: GoogleFonts
                                                                    .poppins()
                                                                .copyWith(
                                                              fontSize: 13,
                                                              color: const Color(
                                                                  0xFF0F2A75),
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            widget.shippingRepo
                                                                .delete(widget
                                                                    .shippingRepo
                                                                    .list[index]
                                                                    .id);
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        TextButton(
                                                          style: TextButton
                                                              .styleFrom(
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .labelLarge,
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5,
                                                                    bottom: 5,
                                                                    left: 20,
                                                                    right: 20),
                                                          ),
                                                          child: Text(
                                                            'NO',
                                                            style: GoogleFonts
                                                                    .poppins()
                                                                .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: const Color(
                                                                  0xFF0F2A75),
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                        widget.shippingRepo.list[index]
                                                    .progress >=
                                                99.9
                                            ? const Icon(
                                                Icons.check_circle_sharp,
                                                color: orangeColor,
                                              )
                                            : const Icon(
                                                Icons.check_circle_sharp,
                                                color: Color(0xFFD3D3D3),
                                              )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          itemCount: widget.shippingRepo.list.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                        ),
                      ))
                    : Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Center(
                          child: Text(
                            "No shipping list yet.",
                            style: GoogleFonts.poppins().copyWith(
                                color: const Color(0xFF8D92A3), fontSize: 12),
                          ),
                        ),
                      ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploadLoading ? () => {} : upload,
        backgroundColor: orangeColor,
        child: _isUploadLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 1,
                ),
              )
            : const Icon(
                Icons.add,
                color: Colors.black,
                weight: 100,
              ),
      ),
    );
  }
}
