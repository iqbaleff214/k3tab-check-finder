import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import '../model/shipping_model.dart';
import '../repository/item_repository.dart';
import '../repository/shipping_repository.dart';
import '../util/color.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen(
      {super.key,
      required this.shipping,
      required this.shippingRepository,
      required this.itemRepository});

  final Shipping shipping;
  final ShippingRepository shippingRepository;
  final ItemRepository itemRepository;

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool _isLoading = false;

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
      await widget.itemRepository.load(widget.shipping.id);
      widget.itemRepository.sort();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> export(BuildContext context) async {
    try {
      var excel = Excel.createExcel();

      Sheet sheetObject = excel['Sheet1'];

      sheetObject.appendRow([
        "Item No.",
        "Product / Service",
        "Quantity",
        "Job Description",
        "Checked?",
        "Note"
      ]);

      for (var item in widget.itemRepository.list) {
        sheetObject.appendRow([
          item.itemNumber,
          item.partNumber,
          item.quantity,
          item.jobDescription,
          item.checked,
          item.note,
        ]);
      }

      final fileBytes = excel.save();
      final directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      final current = DateTime.now();

      debugPrint('location: ${directory.path}');

      var file = File(
          '${directory.path}/${current.year}_${current.month}_${current.day}_summary_of_${widget.shipping.title.replaceAll(" ", "_")}');
      file = await file.create();
      // file.createSync(recursive: true);
      file = await file.writeAsBytes(fileBytes!);
      debugPrint(sheetObject.rows.length.toString());
      debugPrint(file.path);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Downloaded.'),
      ));
    } catch (e) {
      debugPrint('error: ${e.toString()}');
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      child: const Icon(Icons.arrow_back_ios),
                      onTap: () => Navigator.pop(context),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Summary",
                          style: GoogleFonts.poppins().copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.shipping.title,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins().copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w100,
                              color: const Color(0xff8D92A3)),
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            text:
                                '${widget.itemRepository.list.where((element) => element.checked).length} ',
                            style: GoogleFonts.poppins().copyWith(
                                fontSize: 16,
                                color: orangeColor,
                                fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: '/${widget.itemRepository.list.length}',
                                style: GoogleFonts.poppins().copyWith(
                                    fontSize: 8,
                                    color: const Color(0xFF8D92A3),
                                    fontWeight: FontWeight.w200),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () => export(context),
                          child: const Icon(Icons.save_alt),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
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
                    : widget.itemRepository.list.isNotEmpty
                        ? Expanded(
                            child: MediaQuery.removePadding(
                            removeTop: true,
                            context: context,
                            child: ListView.builder(
                              itemBuilder: (context, index) => Card(
                                margin:
                                    const EdgeInsets.only(bottom: 10, top: 0),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.itemRepository.list[index]
                                                .itemNumber
                                                .toString(),
                                            style: GoogleFonts.poppins()
                                                .copyWith(
                                                    fontSize: 10,
                                                    color: const Color(
                                                        0xFF8D92A3)),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                200,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget
                                                      .itemRepository
                                                      .list[index]
                                                      .jobDescription,
                                                  style: GoogleFonts.poppins()
                                                      .copyWith(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                    widget.itemRepository
                                                        .list[index].partNumber,
                                                    style: GoogleFonts.poppins()
                                                        .copyWith(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w900),
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              widget.itemRepository.list[index]
                                                      .checked
                                                  ? const Icon(
                                                      Icons.check_circle_sharp,
                                                      color: orangeColor,
                                                    )
                                                  : const Icon(
                                                      Icons.check_circle_sharp,
                                                      color: Color(0xFFD3D3D3),
                                                    ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                '${widget.itemRepository.list[index].quantity.toString()} Qty',
                                                style: GoogleFonts.poppins()
                                                    .copyWith(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.w100,
                                                        color: const Color(
                                                            0xFF8D92A3)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            widget.itemRepository.list[index]
                                                .note,
                                            style:
                                                GoogleFonts.poppins().copyWith(
                                              fontSize: 10,
                                              color: const Color(0xFF8D92A3),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              itemCount: widget.itemRepository.list.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                            ),
                          ))
                        : const SizedBox(),
              ]),
        ));
  }
}
