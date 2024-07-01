import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'home_SlideWidgets.dart';
import 'edit_profile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/services.dart';

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  XFile? _image;
  final ImagePicker picker = ImagePicker();
  Map<String, String> infoMap = {
    'name': '홍길동',
    'student_number': '20230710',
    'department': '전산학부',
  };

  List<Map<String, dynamic>> widgetDataList = [
    {
      'type': 'Link',
      'links': [
        {'url': 'https://iam2.kaist.ac.kr/#/commonLogin?sso_type=S&param_id=aP1ZtAnnH5y', 'summary': 'KAIST Portal'}
      ],
      'color': Colors.red.value.toString(),
    },
  ];

  final CarouselController _controller = CarouselController();
  int _cur = 0;
  final GlobalKey _carouselKey = GlobalKey();
  Size? widgetSize;

  void _editProfile() async {
    final updatedInfo = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditPage(infos: infoMap),
      ),
    );

    if (updatedInfo != null) {
      setState(() {
        infoMap = updatedInfo;
      });
    }
  }

  void _viewProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileViewPage(infos: infoMap),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
      });
    }
  }

  Future<void> _navigateToWidgetsGridScreen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WidgetsGridScreen(
          widgetDataList: widgetDataList,
          onUpdate: (newList) {
            setState(() {
              widgetDataList = newList;
            });
          },
          widgetSize: widgetSize!,
        ),
      ),
    );
  }

  void _openEditWidgetPopup(BuildContext context, Map<String, dynamic> widgetData, double width, double height) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: EditWidgetPopup(
            widgetData: widgetData,
            width: width,
            height: height,
          ),
        );
      },
    );
  }

  void _getWidgetSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox = _carouselKey.currentContext?.findRenderObject() as RenderBox;
      setState(() {
        widgetSize = renderBox.size;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getWidgetSize();
  }

  @override
  Widget build(BuildContext context) {
    File? imageFile;
    if (infoMap['imagePath'] != null) {
      imageFile = File(infoMap['imagePath']!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보'),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(
            child: Icon(Icons.settings),
            label: 'Widget Settings',
            onTap: () => _navigateToWidgetsGridScreen(context),
          ),
          SpeedDialChild(
            child: Icon(Icons.add_a_photo),
            label: 'Add to Gallery',
            onTap: () {
              // Add your camera functionality here
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.camera_front),
            label: 'Add to Contacts',
            onTap: () {
              // Add your camera functionality here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 5.0, bottom: 5.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 200,
                      height: 200,
                      child: imageFile == null
                          ? CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person, size: 50),
                      )
                          : CircleAvatar(
                        radius: 50,
                        backgroundImage: FileImage(imageFile),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(infoMap['name'] ?? 'Unknown',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('학번 : ${infoMap['student_number'] ?? 'Unknown'}'),
                        SizedBox(height: 8),
                        Text('학과 : ${infoMap['department'] ?? 'Unknown'}'),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: _viewProfile,
                              child: Text('View More'),
                            ),
                            SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: _editProfile,
                              child: Text('Edit Profile'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              CarouselSlider(
                key: _carouselKey,
                carouselController: _controller,
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.48,
                  enlargeCenterPage: true,
                  autoPlay: false,
                  aspectRatio: 16 / 9,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  pauseAutoPlayOnTouch: true,
                  enableInfiniteScroll: true,
                  viewportFraction: 0.8,
                  onPageChanged: ((index, reason) {
                    setState(() {
                      _cur = index;
                    });
                  }),
                ),
                items: widgetDataList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final widgetData = entry.value;
                  final type = widgetData['type'];
                  final color = Color(int.parse(widgetData['color']));

                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        key: ValueKey(index),
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: type == 'Link'
                            ? _createUpdatedLinkWidget(
                          List<Map<String, String>>.from(widgetData['links']),
                          color,
                          true,
                        )
                            : _createUpdatedImageWidget(
                          widgetData['imagePath'],
                          color,
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widgetDataList.asMap().entries.map((entry) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        _controller.animateToPage(entry.key);
                      },
                      child: Container(
                        width: 12.0,
                        height: 12.0,
                        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromARGB(255, 133, 133, 133)
                                .withOpacity(_cur == entry.key ? 0.9 : 0.4)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createUpdatedLinkWidget(List<Map<String, String>> linkData, Color color, bool openLinks) {
    return Container(
      margin: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: color,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: linkData.map((data) => Padding(
          padding: const EdgeInsets.only(left: 25.0, top: 10.0,right: 15.0,bottom: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: openLinks ? () => _launchURL(data['url']!) : null,
                  child: Text(
                    data['summary']!,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.copy, color: Colors.white),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: data['url']!)).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Link copied to clipboard')),
                    );
                  });
                },
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _createUpdatedImageWidget(String imagePath, Color color) {
    return Container(
      margin: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: color,
      ),
      child: Center(
        child: Image.file(File(imagePath), fit: BoxFit.cover),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
