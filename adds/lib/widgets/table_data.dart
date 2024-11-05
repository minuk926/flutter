import 'package:flutter/material.dart';
import 'table_header.dart';

class TableDataWidget extends StatelessWidget {
  final List<dynamic> data;
  final int selectedRow;
  final ScrollController scrollController;
  final Function(int) onRowTap;
  final int totalCount;

  const TableDataWidget({
    super.key,
    required this.data,
    required this.selectedRow,
    required this.scrollController,
    required this.onRowTap,
    required this.totalCount,
  });

  String _truncateWithEllipsis(int cutoff, String text) {
    return (text.length <= cutoff) ? text : '${text.substring(0, cutoff)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey),
                    ),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: const TableHeaderWidget(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: List.generate(
                        data.length,
                        (index) {
                          final item = data[index];
                          final isSelected = index == selectedRow;
                          final isEven = index % 2 == 0;
                          return GestureDetector(
                            onTap: () => onRowTap(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue.withOpacity(0.3)
                                    : isEven
                                        ? Colors.grey.withOpacity(0.1)
                                        : Colors.white,
                                border: const Border(
                                  bottom: BorderSide(color: Colors.grey),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Tooltip(
                                      message: '${index + 1}',
                                      child: Text('${index + 1}'),
                                    ),
                                  ),
                                  Container(
                                    width: 100,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Tooltip(
                                      message: item['bsshCd'] ?? 'Unknown',
                                      child: Text(_truncateWithEllipsis(
                                          10, item['bsshCd'] ?? 'Unknown')),
                                    ),
                                  ),
                                  Container(
                                    width: 150,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Tooltip(
                                      waitDuration:
                                          const Duration(milliseconds: 500),
                                      message: item['bsshNm'] ?? 'Unknown',
                                      child: Text(_truncateWithEllipsis(
                                          9, item['bsshNm'] ?? 'Unknown')),
                                    ),
                                  ),
                                  Container(
                                    width: 100,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Tooltip(
                                      message: item['rprsntvNm'] ?? 'Unknown',
                                      child: Text(_truncateWithEllipsis(
                                          9, item['rprsntvNm'] ?? 'Unknown')),
                                    ),
                                  ),
                                  Container(
                                    width: 100,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Tooltip(
                                      message: item['indutyNm'] ?? 'Unknown',
                                      child: Text(_truncateWithEllipsis(
                                          9, item['indutyNm'] ?? 'Unknown')),
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
          child: Text('1 ~ ${data.length} / $totalCount'),
        ),
      ],
    );
  }
}
