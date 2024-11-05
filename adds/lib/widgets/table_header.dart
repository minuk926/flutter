import 'package:flutter/material.dart';

class TableHeaderWidget extends StatelessWidget {
  const TableHeaderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 50,
          child: Text('No', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          width: 100,
          child: Text('업체코드', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          width: 150,
          child: Text('업체명', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          width: 100,
          child: Text('대표자명', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          width: 100,
          child: Text('업종', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
