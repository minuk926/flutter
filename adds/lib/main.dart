import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int _selectedRow = -1;
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
    Navigator.pop(context);
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
      _selectedRow * 48.0,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  String _truncateWithEllipsis(int cutoff, String text) {
    return (text.length <= cutoff) ? text : '${text.substring(0, cutoff)}...';
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
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
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
                                Container(
                                  width: 50,
                                  child: Text('No',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  width: 100,
                                  child: Text('업체코드',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  width: 150,
                                  child: Text('업체명',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  width: 100,
                                  child: Text('대표자명',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  width: 100,
                                  child: Text('업종',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                children: List.generate(
                                  _data.length,
                                  (index) {
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
                                            bottom:
                                                BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 50,
                                              padding: EdgeInsets.all(8.0),
                                              child: Tooltip(
                                                message: '${index + 1}',
                                                child: Text('${index + 1}'),
                                              ),
                                            ),
                                            Container(
                                              width: 100,
                                              padding: EdgeInsets.all(8.0),
                                              child: Tooltip(
                                                message:
                                                    item['bsshCd'] ?? 'Unknown',
                                                child: Text(
                                                    _truncateWithEllipsis(
                                                        10,
                                                        item['bsshCd'] ??
                                                            'Unknown')),
                                              ),
                                            ),
                                            Container(
                                              width: 150,
                                              padding: EdgeInsets.all(8.0),
                                              child: Tooltip(
                                                waitDuration:
                                                    Duration(milliseconds: 500),
                                                message:
                                                    item['bsshNm'] ?? 'Unknown',
                                                child: Text(
                                                    _truncateWithEllipsis(
                                                        9,
                                                        item['bsshNm'] ??
                                                            'Unknown')),
                                              ),
                                            ),
                                            Container(
                                              width: 100,
                                              padding: EdgeInsets.all(8.0),
                                              child: Tooltip(
                                                message: item['rprsntvNm'] ??
                                                    'Unknown',
                                                child: Text(
                                                    _truncateWithEllipsis(
                                                        9,
                                                        item['rprsntvNm'] ??
                                                            'Unknown')),
                                              ),
                                            ),
                                            Container(
                                              width: 100,
                                              padding: EdgeInsets.all(8.0),
                                              child: Tooltip(
                                                message: item['indutyNm'] ??
                                                    'Unknown',
                                                child: Text(
                                                    _truncateWithEllipsis(
                                                        9,
                                                        item['indutyNm'] ??
                                                            'Unknown')),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
      contentPadding: EdgeInsets.only(left: 16.0),
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
