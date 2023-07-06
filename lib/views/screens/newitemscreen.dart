import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:barterit/models/user.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:barterit/myconfig.dart';

class NewItemScreen extends StatefulWidget {
  final User user;

  const NewItemScreen({super.key, required this.user});

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  File? _image;
  var pathAsset = "assets/images/camera.png";
  final _formKey = GlobalKey<FormState>();
  late double screenHeight, screenWidth, cardwitdh;
  final TextEditingController _itemnameEditingController =
      TextEditingController();
  final TextEditingController _itemdescEditingController =
      TextEditingController();
  final TextEditingController _itempriceEditingController =
      TextEditingController();
  final TextEditingController _itemqtyEditingController =
      TextEditingController();
  final TextEditingController _prstateEditingController =
      TextEditingController();
  final TextEditingController _prlocalEditingController =
      TextEditingController();
  String selectedType = "Electronic";
  List<String> itemlist = [
    "Electronic",
    "Furniture",
    "Toys",
    "Decoration",
    "Men's Apparel",
    "Women's Apparel",
    "Sports Equipment",
    "Transport",
    "Other"
  ];
  late Position _currentPosition;

  String curaddress = "";
  String curstate = "";
  String prlat = "";
  String prlong = "";

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text("Insert New Item"), actions: [
        IconButton(
            onPressed: () {
              _determinePosition();
            },
            icon: const Icon(Icons.refresh))
      ]),
      body: Column(children: [
        Flexible(
            flex: 4,
            // height: screenHeight / 2.5,
            // width: screenWidth,
            child: GestureDetector(
              onTap: () {
                _selectFromGallery();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: Card(
                  child: Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: _image == null
                              ? AssetImage(pathAsset)
                              : FileImage(_image!) as ImageProvider,
                          fit: BoxFit.contain,
                        ),
                      )),
                ),
              ),
            )),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.type_specimen),
                        const SizedBox(
                          width: 16,
                        ),
                        SizedBox(
                          height: 60,
                          child: DropdownButton(
                            value: selectedType,
                            onChanged: (newValue) {
                              setState(() {
                                selectedType = newValue!;
                                print(selectedType);
                              });
                            },
                            items: itemlist.map((selectedType) {
                              return DropdownMenuItem(
                                value: selectedType,
                                child: Text(
                                  selectedType,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                              textInputAction: TextInputAction.next,
                              validator: (val) =>
                                  val!.isEmpty || (val.length < 3)
                                      ? "Item name must be longer than 3"
                                      : null,
                              onFieldSubmitted: (v) {},
                              controller: _itemnameEditingController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                  labelText: 'Item Name',
                                  labelStyle: TextStyle(),
                                  icon: Icon(Icons.abc),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0),
                                  ))),
                        )
                      ],
                    ),
                    TextFormField(
                        textInputAction: TextInputAction.next,
                        validator: (val) => val!.isEmpty
                            ? "Item description must be longer than 10"
                            : null,
                        onFieldSubmitted: (v) {},
                        maxLines: 4,
                        controller: _itemdescEditingController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                            labelText: 'Item Description',
                            alignLabelWithHint: true,
                            labelStyle: TextStyle(),
                            icon: Icon(
                              Icons.description,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 2.0),
                            ))),
                    Row(
                      children: [
                        Flexible(
                          flex: 5,
                          child: TextFormField(
                              textInputAction: TextInputAction.next,
                              validator: (val) => val!.isEmpty
                                  ? "Item price must contain value"
                                  : null,
                              onFieldSubmitted: (v) {},
                              controller: _itempriceEditingController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: 'Item Price',
                                  labelStyle: TextStyle(),
                                  icon: Icon(Icons.money),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0),
                                  ))),
                        ),
                        Flexible(
                          flex: 5,
                          child: TextFormField(
                              textInputAction: TextInputAction.next,
                              validator: (val) => val!.isEmpty
                                  ? "Quantity should be more than 0"
                                  : null,
                              controller: _itemqtyEditingController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: 'Item Quantity',
                                  labelStyle: TextStyle(),
                                  icon: Icon(Icons.numbers),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0),
                                  ))),
                        ),
                      ],
                    ),
                    Row(children: [
                      Flexible(
                        flex: 5,
                        child: TextFormField(
                            textInputAction: TextInputAction.next,
                            validator: (val) => val!.isEmpty || (val.length < 3)
                                ? "Current State"
                                : null,
                            enabled: false,
                            controller: _prstateEditingController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                                labelText: 'Current State',
                                labelStyle: TextStyle(),
                                icon: Icon(Icons.flag),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0),
                                ))),
                      ),
                      Flexible(
                        flex: 5,
                        child: TextFormField(
                            textInputAction: TextInputAction.next,
                            enabled: false,
                            validator: (val) => val!.isEmpty || (val.length < 3)
                                ? "Current Locality"
                                : null,
                            controller: _prlocalEditingController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                                labelText: 'Current Locality',
                                labelStyle: TextStyle(),
                                icon: Icon(Icons.map),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0),
                                ))),
                      ),
                    ]),
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: screenWidth / 1.2,
                      height: 50,
                      child: ElevatedButton(
                          onPressed: () {
                            insertDialog();
                          },
                          child: const Text("Insert Item")),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Future<void> _selectFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 1200,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage();
    } else {
      print('No image selected.');
    }
  }

  Future<void> cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _image!.path,
      aspectRatioPresets: [
        // CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        // CropAspectRatioPreset.original,
        //CropAspectRatioPreset.ratio4x3,
        // CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio3x2,
            lockAspectRatio: true),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      File imageFile = File(croppedFile.path);
      _image = imageFile;
      int? sizeInBytes = _image?.lengthSync();
      double sizeInMb = sizeInBytes! / (1024 * 1024);
      print(sizeInMb);

      setState(() {});
    }
  }

  void insertDialog() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Check your input")));
      return;
    }
    if (_image == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please take picture")));
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: const Text(
            "Insert your item?",
            style: TextStyle(),
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                insertItem();
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void insertItem() {
    String itemname = _itemnameEditingController.text;
    String itemdesc = _itemdescEditingController.text;
    String itemprice = _itempriceEditingController.text;
    String itemqty = _itemqtyEditingController.text;
    String state = _prstateEditingController.text;
    String locality = _prlocalEditingController.text;
    String base64Image = base64Encode(_image!.readAsBytesSync());

    http.post(Uri.parse("${MyConfig().SERVER}/barterit/php/insert_item.php"),
        body: {
          "userid": widget.user.id.toString(),
          "itemname": itemname,
          "itemdesc": itemdesc,
          "itemprice": itemprice,
          "itemqty": itemqty,
          "type": selectedType,
          "latitude": prlat,
          "longitude": prlong,
          "state": state,
          "locality": locality,
          "image": base64Image
        }).then((response) {
      print(response.body);
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Insert Success")));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Insert Failed")));
        }
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Insert Failed")));
        Navigator.pop(context);
      }
    });
  }

  void _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }
    _currentPosition = await Geolocator.getCurrentPosition();

    _getAddress(_currentPosition);
    //return await Geolocator.getCurrentPosition();
  }

  _getAddress(Position pos) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(pos.latitude, pos.longitude);
    if (placemarks.isEmpty) {
      _prlocalEditingController.text = "Changlun";
      _prstateEditingController.text = "Kedah";
      prlat = "6.443455345";
      prlong = "100.05488449";
    } else {
      _prlocalEditingController.text = placemarks[0].locality.toString();
      _prstateEditingController.text =
          placemarks[0].administrativeArea.toString();
      prlat = _currentPosition.latitude.toString();
      prlong = _currentPosition.longitude.toString();
    }
    setState(() {});
  }
}
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:barterit/models/user.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:http/http.dart' as http;
// import 'package:barterit/myconfig.dart';

// class NewItemScreen extends StatefulWidget {
//   final User user;
//   const NewItemScreen({super.key, required this.user});

//   @override
//   State<NewItemScreen> createState() => _NewItemScreenState();
// }

// class _NewItemScreenState extends State<NewItemScreen> {
//   final ImagePicker picker = ImagePicker();
//   late int axiscount = 3;
//   int _index = 0;
//   List<File> _imageList = [];
//   File? _image;
//   var pathAsset = "assets/images/camera.png";
//   final _formKey = GlobalKey<FormState>();
//   late double screenHeight, screenWidth, cardwitdh;
//   final TextEditingController _itemnameEditingController =
//       TextEditingController();
//   final TextEditingController _itemdescEditingController =
//       TextEditingController();
//   final TextEditingController _itempriceEditingController =
//       TextEditingController();
//   final TextEditingController _itemqtyEditingController =
//       TextEditingController();
//   final TextEditingController _prstateEditingController =
//       TextEditingController();
//   final TextEditingController _prlocalEditingController =
//       TextEditingController();

//   String selectedType = "Electronic";

//   List<String> itemlist = [
//     "Electronic",
//     "Furniture",
//     "Toy",
//     "Kid's Apparel",
//     "Men's Apparel",
//     "Women's Apparel",
//     "Sports Equipment",
//     "Transport",
//     "Other"
//   ];
//   late Position _currentPosition;

//   String curaddress = "";
//   String curstate = "";
//   String prlat = "";
//   String prlong = "";

//   @override
//   void initState() {
//     super.initState();
//     _determinePosition();
//   }

//   @override
//   Widget build(BuildContext context) {
//     screenHeight = MediaQuery.of(context).size.height;
//     screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//         appBar: AppBar(title: const Text("Insert New Item"), actions: []),
//         body: Column(children: [
//           SizedBox(
//             height: 250,
//             child: PageView.builder(
//                 itemCount: 3,
//                 controller: PageController(viewportFraction: 0.6),
//                 onPageChanged: (int index) => setState(() {
//                       _index = index;
//                     }),
//                 itemBuilder: (BuildContext context, int index) {
//                   if (index == 0) {
//                     return image1();
//                   } else if (index == 1) {
//                     return image2();
//                   } else if (index == 2) {
//                     return image3();
//                   }
//                 }),
//           ),
//           const SizedBox(
//             height: 5,
//           ),
//           Expanded(
//             flex: 15,
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
//               child: Form(
//                 key: _formKey,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               height: 55,
//                               width: screenWidth,
//                               decoration: BoxDecoration(
//                                   gradient: LinearGradient(colors: [
//                                     Colors.brown.shade100,
//                                     Colors.brown.shade50,
//                                     Colors.brown.shade100,
//                                   ]),
//                                   boxShadow: const [
//                                     BoxShadow(
//                                         color:
//                                             Color.fromARGB(255, 210, 210, 210),
//                                         blurRadius: 2.0,
//                                         offset: Offset(2.0, 2.0))
//                                   ]),
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.fromLTRB(40, 2, 40, 2),
//                                 child: DropdownButtonHideUnderline(
//                                   child: DropdownButton(
//                                     itemHeight: 55,
//                                     value: selectedType,
//                                     dropdownColor: Color.fromARGB(255, 196, 174, 144),
//                                     onChanged: (newValue) {
//                                       setState(() {
//                                         selectedType = newValue!;
//                                       });
//                                     },
//                                     items: itemlist.map((selectedType) {
//                                       return DropdownMenuItem(
//                                         alignment: AlignmentDirectional.center,
//                                         value: selectedType,
//                                         child: Text(
//                                           selectedType,
//                                         ),
//                                       );
//                                     }).toList(),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 12,
//                             ),
//                           ]),
//                       TextFormField(
//                           textInputAction: TextInputAction.next,
//                           validator: (val) => val!.isEmpty || (val.length < 3)
//                               ? "Item name must be longer than 3"
//                               : null,
//                           onFieldSubmitted: (v) {},
//                           controller: _itemnameEditingController,
//                           keyboardType: TextInputType.text,
//                           decoration: const InputDecoration(
//                               labelText: 'Item Name',
//                               labelStyle: TextStyle(),
//                               icon: Icon(Icons.type_specimen),
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(width: 2.0),
//                               ))),
//                       TextFormField(
//                           textInputAction: TextInputAction.next,
//                           validator: (val) => val!.isEmpty
//                               ? "Item description must be longer than 10"
//                               : null,
//                           onFieldSubmitted: (v) {},
//                           maxLines: 4,
//                           controller: _itemdescEditingController,
//                           keyboardType: TextInputType.text,
//                           decoration: const InputDecoration(
//                               labelText: 'Item Description',
//                               alignLabelWithHint: true,
//                               labelStyle: TextStyle(),
//                               icon: Icon(
//                                 Icons.description,
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(width: 2.0),
//                               ))),
//                       Row(
//                         children: [
//                           Flexible(
//                             flex: 5,
//                             child: TextFormField(
//                                 textInputAction: TextInputAction.next,
//                                 validator: (val) =>
//                                     val!.isEmpty ? "Invalid price" : null,
//                                 onFieldSubmitted: (v) {},
//                                 controller: _itempriceEditingController,
//                                 keyboardType: TextInputType.number,
//                                 decoration: const InputDecoration(
//                                     labelText: 'Item Price',
//                                     labelStyle: TextStyle(),
//                                     icon: Icon(Icons.attach_money),
//                                     focusedBorder: OutlineInputBorder(
//                                       borderSide: BorderSide(width: 2.0),
//                                     ))),
//                           ),
//                           Flexible(
//                             flex: 5,
//                             child: TextFormField(
//                                 textInputAction: TextInputAction.next,
//                                 validator: (val) =>
//                                     val!.isEmpty ? "Invalid quantity" : null,
//                                 controller: _itemqtyEditingController,
//                                 keyboardType: TextInputType.number,
//                                 decoration: const InputDecoration(
//                                     labelText: 'Item quantity',
//                                     labelStyle: TextStyle(),
//                                     icon: Icon(Icons.numbers),
//                                     focusedBorder: OutlineInputBorder(
//                                       borderSide: BorderSide(width: 2.0),
//                                     ))),
//                           ),
//                         ],
//                       ),
//                       Row(children: [
//                         Flexible(
//                           flex: 5,
//                           child: TextFormField(
//                               textInputAction: TextInputAction.next,
//                               validator: (val) =>
//                                   val!.isEmpty || (val.length < 3)
//                                       ? "Current State unavailable"
//                                       : null,
//                               enabled: false,
//                               controller: _prstateEditingController,
//                               keyboardType: TextInputType.text,
//                               decoration: const InputDecoration(
//                                   labelText: 'Current State',
//                                   labelStyle: TextStyle(),
//                                   icon: Icon(Icons.flag),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(width: 2.0),
//                                   ))),
//                         ),
//                         Flexible(
//                           flex: 5,
//                           child: TextFormField(
//                               textInputAction: TextInputAction.next,
//                               enabled: false,
//                               validator: (val) =>
//                                   val!.isEmpty || (val.length < 3)
//                                       ? "Current Locality unavailable"
//                                       : null,
//                               controller: _prlocalEditingController,
//                               keyboardType: TextInputType.text,
//                               decoration: const InputDecoration(
//                                   labelText: 'Current Locality',
//                                   labelStyle: TextStyle(),
//                                   icon: Icon(Icons.place),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderSide: BorderSide(width: 2.0),
//                                   ))),
//                         ),
//                       ]),
//                       const SizedBox(
//                         height: 16,
//                       ),
//                       SizedBox(
//                         width: screenWidth,
//                         height: 50,
//                         child: ElevatedButton(
//                             onPressed: () {
//                               insertDialog();
//                             },
//                             child: const Text("Insert Item")),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ]));
//   }

//   Future<void> _selectFromGallery() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(
//       source: ImageSource.gallery,
//       maxHeight: 1200,
//       maxWidth: 800,
//     );

//     if (pickedFile != null) {
//       _image = File(pickedFile.path);
//       cropImage();
//     } else {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("No image selected")));
//     }
//   }

//   Future<void> cropImage() async {
//     CroppedFile? croppedFile = await ImageCropper().cropImage(
//       sourcePath: _image!.path,
//       aspectRatioPresets: [
//         CropAspectRatioPreset.ratio3x2,
//       ],
//       uiSettings: [
//         AndroidUiSettings(
//             toolbarTitle: 'Cropper',
//             toolbarColor: Colors.lightBlue,
//             toolbarWidgetColor: Colors.white,
//             initAspectRatio: CropAspectRatioPreset.ratio3x2,
//             lockAspectRatio: true),
//         IOSUiSettings(
//           title: 'Cropper',
//         ),
//       ],
//     );
//     if (croppedFile != null) {
//       File imageFile = File(croppedFile.path);
//       _image = imageFile;
//       _imageList.add(_image!);
//       setState(() {});
//     }
//   }

//   void insertDialog() {
//     if (!_formKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Check your input")));
//       return;
//     }
//     if (_imageList.length < 3) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Please upload 3 pictures")));
//       return;
//     }
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(Radius.circular(10.0))),
//           title: const Text(
//             "Insert your item?",
//             style: TextStyle(),
//           ),
//           content: const Text("Are you sure?", style: TextStyle()),
//           actions: <Widget>[
//             TextButton(
//               child: const Text(
//                 "Yes",
//                 style: TextStyle(),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 insertItem();
//               },
//             ),
//             TextButton(
//               child: const Text(
//                 "No",
//                 style: TextStyle(),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void insertItem() {
//     String itemname = _itemnameEditingController.text;
//     String itemdesc = _itemdescEditingController.text;
//     String itemprice = _itempriceEditingController.text;
//     String itemqty = _itemqtyEditingController.text;
//     String state = _prstateEditingController.text;
//     String locality = _prlocalEditingController.text;
//     String base64Image1 = base64Encode(_imageList[0].readAsBytesSync());
//     String base64Image2 = base64Encode(_imageList[1].readAsBytesSync());
//     String base64Image3 = base64Encode(_imageList[2].readAsBytesSync());

//     http.post(Uri.parse("${MyConfig().SERVER}/barterit/php/insert_item.php"),
//         body: {
//           "userid": widget.user.id.toString(),
//           "itemname": itemname,
//           "itemdesc": itemdesc,
//           "itemprice": itemprice,
//           "itemqty": itemqty,
//           "type": selectedType,
//           "latitude": prlat,
//           "longitude": prlong,
//           "state": state,
//           "locality": locality,
//           "image1": base64Image1,
//           "image2": base64Image2,
//           "image3": base64Image3,
//         }).then((response) {
//       if (response.statusCode == 200) {
//         var jsondata = jsonDecode(response.body);
//         if (jsondata['status'] == 'success') {
//           ScaffoldMessenger.of(context)
//               .showSnackBar(const SnackBar(content: Text("Insert Success")));
//         } else {
//           ScaffoldMessenger.of(context)
//               .showSnackBar(const SnackBar(content: Text("Insert Failed")));
//         }
//         Navigator.pop(context);
//       } else {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text("Insert Failed")));
//         Navigator.pop(context);
//       }
//     });
//   }

//   void _determinePosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return Future.error('Location permissions are permanently denied.');
//     }
//     _currentPosition = await Geolocator.getCurrentPosition();

//     _getAddress(_currentPosition);
//   }

//   _getAddress(Position pos) async {
//     List<Placemark> placemarks =
//         await placemarkFromCoordinates(pos.latitude, pos.longitude);
//     if (placemarks.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Location is not available")));
//     } else {
//       _prlocalEditingController.text = placemarks[0].locality.toString();
//       _prstateEditingController.text =
//           placemarks[0].administrativeArea.toString();
//       prlat = _currentPosition.latitude.toString();
//       prlong = _currentPosition.longitude.toString();
//     }
//     setState(() {});
//   }

//   Widget image1() {
//     return Transform.scale(
//       scale: 1,
//       child: Card(
//           elevation: 6,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           shadowColor: Colors.black,
//           child: GestureDetector(
//             onTap: _selectFromGallery,
//             child: Container(
//               height: 200,
//               width: 200,
//               decoration: BoxDecoration(
//                   image: DecorationImage(
//                 image: _imageList.isNotEmpty
//                     ? FileImage(_imageList[0]) as ImageProvider
//                     : AssetImage(pathAsset),
//                 fit: BoxFit.cover,
//               )),
//             ),
//           )),
//     );
//   }

//   Widget image2() {
//     return Transform.scale(
//       scale: 1,
//       child: Card(
//           elevation: 6,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           child: GestureDetector(
//             onTap: _selectFromGallery,
//             child: Container(
//               height: 200,
//               width: 200,
//               decoration: BoxDecoration(
//                   image: DecorationImage(
//                 image: _imageList.length > 1
//                     ? FileImage(_imageList[1]) as ImageProvider
//                     : AssetImage(pathAsset),
//                 fit: BoxFit.cover,
//               )),
//             ),
//           )),
//     );
//   }

//   Widget image3() {
//     return Transform.scale(
//       scale: 1,
//       child: Card(
//           elevation: 6,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           child: GestureDetector(
//             onTap: _selectFromGallery,
//             child: Container(
//               height: 200,
//               width: 200,
//               decoration: BoxDecoration(
//                   image: DecorationImage(
//                 image: _imageList.length > 2
//                     ? FileImage(_imageList[2]) as ImageProvider
//                     : AssetImage(pathAsset),
//                 fit: BoxFit.cover,
//               )),
//             ),
//           )),
//     );
//   }
// }
