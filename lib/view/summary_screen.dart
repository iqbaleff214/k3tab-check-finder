import 'dart:io';

import 'package:accordion/accordion.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/item_model.dart';
import '../model/shipping_model.dart';
import '../repository/item_repository.dart';
import '../repository/shipping_repository.dart';
import '../util/color.dart';

enum Category { all, open, noted, completed }

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
  Category _selectedCategory = Category.all;
  TextEditingController _searchController = TextEditingController();

  List<Item> _items = [];

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
      _items = widget.itemRepository.list.where((item) => _find(item, key) && _category(item)).toList();
    });
  }

  bool _find(Item item, String key) {
    return item.partNumber.toLowerCase().contains(key) ||
        item.jobDescription.toLowerCase().contains(key) ||
        item.itemNumber.toString().toLowerCase().contains(key);
  }

  bool _category(Item item) {
    switch (_selectedCategory) {
      case Category.completed:
        return item.checked;
      case Category.noted:
        return !item.checked && item.note.isNotEmpty;
      case Category.open:
        return !item.checked && item.note.isEmpty;
      default:
        return true;
    }
  }

  Future<void> export(BuildContext context) async {
    try {
      var excel = Excel.createExcel();

      Sheet sheetObject = excel['Sheet1'];

      sheetObject.appendRow([
        "Item No.",
        "Product / Service",
        "Job Description",
        "Status",
        "Segment Number",
        "Quantity",
        "Checked?",
        "Note"
      ]);

      for (var item in _items) {
        sheetObject.appendRow([
          item.itemNumber,
          item.partNumber,
          item.jobDescription,
          item.status,
          item.segment,
          item.quantity,
          item.checked ? 'Yes' : 'No',
          item.note,
        ]);
      }

      if (!await _requestPermission(Permission.storage)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Denied.'),
        ));
        debugPrint('gagal');
      }

      if (!await _requestPermission(Permission.manageExternalStorage)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Denied.'),
        ));
        debugPrint('gagal2');
      }

      final current = DateTime.now();
      final fileBytes = excel.save();
      var directory = await getExternalStorageDirectory();
      if (directory == null) return;
      String newPath = "";
      debugPrint(directory.path);
      List<String> paths = directory.path.split("/");
      for (int x = 1; x < paths.length; x++) {
        String folder = paths[x];
        if (folder != "Android") {
          newPath += "/$folder";
        } else {
          break;
        }
      }
      newPath = "$newPath/CheckFinder";
      directory = Directory(newPath);

      debugPrint('location: ${directory.path}');

      File file = File(
          '${directory?.path}/${current.year}_${current.month}_${current.day}_${current.hour}_${current.minute}_${current.second}_summary_of_${widget.shipping.title.replaceAll(" ", "_")}');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      file = await file.create();
      // file.createSync(recursive: true);
      file = await file.writeAsBytes(fileBytes!);
      debugPrint(sheetObject.rows.length.toString());
      debugPrint(file.path);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Downloaded and stored at: ${file.path}'),
      ));
    } catch (e) {
      debugPrint('error: ${e.toString()}');
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      debugPrint('already true');
      return true;
    }

    var res = await permission.request();
    debugPrint('asked?');
    debugPrint(res.toString());
    return res == PermissionStatus.granted;
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
                    Flexible(
                      child: Column(
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
                            maxLines: 1,
                            style: GoogleFonts.poppins().copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w100,
                                color: const Color(0xff8D92A3)),
                          )
                        ],
                      ),
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
                TextField(
                  controller: _searchController,
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
                  ),
                  keyboardType: TextInputType.text,
                  style: GoogleFonts.poppins().copyWith(fontSize: 10),
                  maxLines: 1,
                  onChanged: (value) => _searchItem(value),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: Category.values.map<Widget>((e) => GestureDetector(
                      onTap: () {
                        setState(() { _selectedCategory = e; });
                        _searchItem(_searchController.text);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 5),
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        decoration: BoxDecoration(
                            color: _selectedCategory == e ? orangeColor : const Color(0xFF8D92A3),
                            borderRadius: BorderRadius.circular(15)
                        ),
                        child: Text(e.name.toUpperCase(), style: GoogleFonts.poppins().copyWith(fontSize: 10, color: Colors.white),),
                      ),
                    )).toList(),
                ),
                const SizedBox(
                  height: 15,
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
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                _items[index].itemNumber.toString(),
                                                style: GoogleFonts.poppins()
                                                    .copyWith(
                                                    fontSize: 10,
                                                    color: const Color(
                                                        0xFF8D92A3)),
                                              ),
                                              Text(
                                                _items[index].segment.toString(),
                                                style: GoogleFonts.poppins()
                                                    .copyWith(
                                                    fontSize: 10,
                                                    color: const Color(
                                                        0xFF8D92A3)),
                                              ),
                                            ],
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
                                                Text(_items[index].partNumber,
                                                    style: GoogleFonts.poppins()
                                                        .copyWith(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w900),
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                                Text(
                                                  _items[index].status,
                                                  style: GoogleFonts.poppins()
                                                      .copyWith(
                                                          fontSize: 12,
                                                          color: const Color(
                                                              0xFF8D92A3),
                                                          fontWeight:
                                                              FontWeight.w100),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              _items[index]
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
                                                '${_items[index].quantity.toString()} Qty',
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
                                            _items[index]
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
                              itemCount: _items.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                            ),
                          ))
                        : Container(margin: const EdgeInsets.only(top: 10), child: Center(child: Text("Item(s) not found.", style: GoogleFonts.poppins().copyWith(color: const Color(0xFF8D92A3))),)),
              ]),
        ));
  }
}
