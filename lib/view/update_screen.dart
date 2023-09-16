import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:k3tab_2023/model/item_model.dart';
import 'package:k3tab_2023/model/shipping_model.dart';
import 'package:k3tab_2023/repository/item_repository.dart';
import 'package:k3tab_2023/repository/shipping_repository.dart';
import 'package:k3tab_2023/util/color.dart';
import 'package:scan/scan.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen(
      {super.key,
      required this.shipping,
      required this.shippingRepository,
      required this.itemRepository});

  final Shipping shipping;
  final ShippingRepository shippingRepository;
  final ItemRepository itemRepository;

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final itemNoteController = TextEditingController();

  bool _isLoading = false;
  bool _scanMode = false;
  String _search = '';

  List<Item> _items = [];

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void dispose() {
    itemNoteController.dispose();
    super.dispose();
  }

  void _load() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await widget.itemRepository.load(widget.shipping.id);
      _items = widget.itemRepository.list;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchItem(String key) {
    key = key.toLowerCase();
    setState(() {
      _search = key;
      _items = widget.itemRepository.list
          .where((element) =>
              element.partNumber.toLowerCase().contains(key) ||
              element.jobDescription.toLowerCase().contains(key) ||
              element.itemNumber.toString().toLowerCase().contains(key))
          .toList();
    });
    // await widget.itemRepository.search(key, widget.shipping.id);
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
                          "Incoming Items",
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
                          child: const Icon(Icons.file_copy),
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  decoration: InputDecoration(
                      hintText: "Item number, Part Number, or Part Name",
                      hintStyle: GoogleFonts.poppins().copyWith(
                          fontSize: 10, color: const Color(0xFF8D92A3)),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 15),
                      isDense: true,
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      suffixIcon: InkWell(
                        onTap: () => setState(() {
                          if (_scanMode) {
                            _scanMode = false;
                            _searchItem('');
                          } else {
                            _scanMode = true;
                          }
                          // _scanMode = !_scanMode;
                        }),
                        splashColor: const Color(0xffFAFAFA),
                        highlightColor: const Color(0xffFAFAFA),
                        focusColor: const Color(0xffFAFAFA),
                        hoverColor: const Color(0xffFAFAFA),
                        child: _scanMode
                            ? const Icon(
                                Icons.document_scanner,
                                color: orangeColor,
                              )
                            : const Icon(
                                Icons.document_scanner_outlined,
                                color: Colors.black,
                              ),
                      )),
                  keyboardType: TextInputType.text,
                  style: GoogleFonts.poppins().copyWith(fontSize: 10),
                  maxLines: 1,
                  onChanged: (value) => _searchItem(value),
                ),
                AnimatedSize(
                  curve: Curves.bounceInOut,
                  duration: const Duration(milliseconds: 500),
                  child: Visibility(
                    visible: _scanMode,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: MediaQuery.of(context).size.width,
                      height: _scanMode ? 60.0 : 0.0,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8)),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ScanView(
                              scanAreaScale: 1,
                              scanLineColor: orangeColor,
                              onCapture: (key) async {
                                _searchItem(key);
                                // var id = widget.itemRepository.list
                                //     .firstWhere((element) =>
                                //         element.partNumber.toLowerCase() == key)
                                //     .id;
                                // await widget.itemRepository.check(id);
                                // setState(() {
                                //   _scanMode = false;
                                // });
                              },
                            ),
                          ),
                          Center(
                            child: Text(
                              "Scan Barcode",
                              style: GoogleFonts.poppins()
                                  .copyWith(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  child: Visibility(
                    visible: _search != '',
                    child: Center(child: Text('${_items.length} item(s) found.', style: GoogleFonts.poppins().copyWith(
                      fontSize: 9, color: const Color(0xFF8D92A3),
                    ),)),
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
                    : _items.isNotEmpty
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
                                            _items[index].itemNumber.toString(),
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
                                                  _items[index].jobDescription,
                                                  style: GoogleFonts.poppins()
                                                      .copyWith(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                        _items[index]
                                                            .partNumber,
                                                        style: GoogleFonts
                                                                .poppins()
                                                            .copyWith(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900),
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                    Text(
                                                      '${_items[index].quantity.toString()} Qty',
                                                      style: GoogleFonts
                                                              .poppins()
                                                          .copyWith(
                                                              fontSize: 9,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w100,
                                                              color: const Color(
                                                                  0xFF8D92A3)),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          Checkbox(
                                              value: _items[index].checked,
                                              onChanged: (checked) async {
                                                await widget.itemRepository
                                                    .toggle(_items[index].id);
                                                await widget.shippingRepository
                                                    .progress(
                                                        widget.shipping.id,
                                                        widget.itemRepository
                                                                .list
                                                                .where((element) =>
                                                                    element
                                                                        .checked)
                                                                .length /
                                                            widget
                                                                .itemRepository
                                                                .list
                                                                .length *
                                                            100);
                                              }),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _items[index].note,
                                            style:
                                                GoogleFonts.poppins().copyWith(
                                              fontSize: 10,
                                              color: const Color(0xFF8D92A3),
                                            ),
                                          ),
                                          InkWell(
                                            child: const Icon(
                                              Icons.edit,
                                              color: Color(0xFF8D92A3),
                                              size: 12,
                                            ),
                                            onTap: () => showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                  title: Text("Item Note", style: GoogleFonts.poppins().copyWith(
                                                    fontSize: 14,
                                                  ),),
                                                  content: TextField(
                                                    controller: itemNoteController,
                                                    keyboardType: TextInputType.text,
                                                    style: GoogleFonts.poppins().copyWith(fontSize: 10),
                                                    maxLines: 3,
                                                    decoration: InputDecoration(
                                                      hintText: "Give a note to the item",
                                                      hintStyle: GoogleFonts.poppins().copyWith(
                                                          fontSize: 10, color: const Color(0xFF8D92A3)),
                                                      border: const OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                          borderSide: BorderSide(width: 3)),
                                                      contentPadding: const EdgeInsets.symmetric(
                                                          horizontal: 18, vertical: 15),
                                                      isDense: true,
                                                      fillColor: Colors.white,
                                                      filled: true,
                                                    ),
                                                  ),
                                                  actions: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 20, left: 20, bottom: 10),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: const Color(0xffFFCC28),
                                                          padding: const EdgeInsets.only(
                                                              top: 5, bottom: 5, left: 20, right: 20),
                                                        ),
                                                        onPressed: () async {
                                                          await widget.itemRepository.addNote(_items[index].id, itemNoteController.text);
                                                          itemNoteController.clear();
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: Text(
                                                          'Save',
                                                          style: GoogleFonts.poppins().copyWith(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 13,
                                                            color: const Color(0xFF0F2A75),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              itemCount: _items.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                            ),
                          ))
                        : const SizedBox(),
              ]),
        ));
  }
}
