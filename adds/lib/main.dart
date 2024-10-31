import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for keyboard events
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedMenu = 'Main Content Area';
  List<dynamic> _data = [];
  int _currentPage = 1;
  int _totalCount = 0;
  bool _isLoading = false;
  int _selectedRow = -1; // Track the selected row
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onMenuTap(String menu) {
    setState(() {
      _selectedMenu = menu;
      _data.clear();
      _currentPage = 1;
    });
    if (menu == '신청서 접수') {
      _fetchData();
    }
    Navigator.pop(context); // Close the drawer
  }

  Future<void> _fetchData() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        'http://211.119.124.9:9076/api/biz/nims/v1/getNimsBsshInfoSt');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        "k": "",
        "fg": "1",
        "pg": _currentPage.toString(),
        "bi": "",
        "hp": "",
        "bn": "중앙약국",
        "bc": "",
        "ymd": "",
        "fg2": "1",
        "userId": "suji",
        "rprsntvNm": ""
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        _data.addAll(jsonResponse['data']);
        _totalCount = jsonResponse['totalCount'];
        _isLoading = false;
      });
    } else {
      // Handle error
      print('Failed to load data');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_data.length < _totalCount) {
        _currentPage++;
        _fetchData();
      }
    }
  }

  void _moveCursor(int offset) {
    setState(() {
      _selectedRow = (_selectedRow + offset).clamp(0, _data.length - 1);
    });
    _scrollController.animateTo(
      _selectedRow * 48.0, // Assuming each row is 48 pixels high
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hamburger Menu Example'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
            ),
            ExpansionTile(
              title: Text(
                '폐기보고',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              children: <Widget>[
                _buildMenuItem('신청서 접수'),
                _buildMenuItem('결과[통보]처리'),
                _buildMenuItem('폐기 보고 확인'),
                _buildMenuItem('보고 문서 관리'),
              ],
            ),
            ExpansionTile(
              title: Text(
                '폐기 보고 통계',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              children: <Widget>[
                _buildMenuItem('제품 구분별 현황'),
                _buildMenuItem('제품별 폐기 현황'),
                _buildMenuItem('취급 업종별 폐기 현황'),
                _buildMenuItem('취급자별 폐기 현황'),
              ],
            ),
          ],
        ),
      ),
      body: _selectedMenu == '신청서 접수'
          ? Focus(
              focusNode: _focusNode,
              onKey: (FocusNode node, RawKeyEvent event) {
                if (event is RawKeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    _moveCursor(1);
                    return KeyEventResult.handled;
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    _moveCursor(-1);
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey),
                      ),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Text('No',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 3,
                            child: Text('Name',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 3,
                            child: Text('Representative',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _data.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _data.length) {
                          return _isLoading
                              ? Center(child: CircularProgressIndicator())
                              : SizedBox.shrink();
                        }
                        final item = _data[index];
                        final isSelected = index == _selectedRow;
                        final isEven = index % 2 == 0;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRow = index;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.3)
                                  : isEven
                                      ? Colors.grey.withOpacity(0.1)
                                      : Colors.white,
                              border: Border(
                                bottom: BorderSide(color: Colors.grey),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 1, child: Text('${index + 1}')),
                                  Expanded(
                                      flex: 3,
                                      child: Text(item['bsshNm'] ?? 'Unknown')),
                                  Expanded(
                                      flex: 3,
                                      child:
                                          Text(item['rprsntvNm'] ?? 'Unknown')),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('1 ~ ${_data.length} / $_totalCount'),
                  ),
                ],
              ),
            )
          : Center(
              child: Text(_selectedMenu),
            ),
    );
  }

  Widget _buildMenuItem(String title) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 16.0), // Add padding to the left
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: _selectedMenu == title ? Colors.blue : Colors.black,
        ),
      ),
      onTap: () {
        _onMenuTap(title);
      },
    );
  }
}
