import 'package:adds/model/api_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'widgets/table_data.dart';
import 'service/api_util.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedMenu = 'Main Content Area';
  final List<dynamic> _data = [];
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
    if (_selectedMenu != '폐기보고' && _selectedMenu != '폐기 보고 통계') {
      //_fetchData();
      callApi();
    }
    Navigator.pop(context);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_data.length < _totalCount) {
        _currentPage++;
        //_fetchData();
        callApi();
      }
    }
  }

  void _moveCursor(int offset) {
    setState(() {
      _selectedRow = (_selectedRow + offset).clamp(0, _data.length - 1);
    });
    _scrollController.animateTo(
      _selectedRow * 48.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hamburger Menu Example'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(
              height: 80,
              child: DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ExpansionTile(
              title: const Text(
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
              title: const Text(
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
      body: LoadingOverlay(
        isLoading: _isLoading, 
        child: (_selectedMenu != '폐기보고' && _selectedMenu != '폐기 보고 통계')
          ? Focus(
              focusNode: _focusNode,
              onKeyEvent: (FocusNode node, KeyEvent event) {
                if (event is KeyDownEvent) {
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
              child: _data.isNotEmpty ? 
              TableDataWidget(
                data: _data,
                selectedRow: _selectedRow,
                scrollController: _scrollController,
                onRowTap: (index) {
                  setState(() {
                    _selectedRow = index;
                  });
                },
                totalCount: _totalCount,
              )
              : const Center(
                  child: Text("데이터가 없습니다."),
              ),
            )
          : Center(
              child: Text(_selectedMenu),
            ),
      ),
    );
  }

  Widget _buildMenuItem(String title) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16.0),
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

  callApi() async {
    print("callApi ${_selectedMenu}");
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    ApiResponse<dynamic> apiResponse = await ApiUtil.fetchData(
        path: '/api/biz/nims/v1/getNimsBsshInfoSt',
        method: 'POST',
        parameters: {
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
        });
    
    setState(() {
      _data.addAll(apiResponse.data as List<dynamic>);
      _totalCount = apiResponse.totalCount;
      _isLoading = false;
    });
  }
}
