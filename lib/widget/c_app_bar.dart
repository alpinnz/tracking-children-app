import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/app/app_bloc.dart';

enum CAppBarActions { Logout }

class CAppBar extends StatelessWidget {
  final String title;
  final List<CAppBarActions> actions;
  final isHistory;

  CAppBar({Key key, @required this.title, this.actions, this.isHistory = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget actionWidget({CAppBarActions action}) {
      switch (action) {
        case CAppBarActions.Logout:
          return IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              BlocProvider.of<AppBloc>(context)..add(AppLogoutEvent());
            },
          );
          break;
        default:
          return Icon(Icons.error);
          break;
      }
    }

    return AppBar(
      backgroundColor: Colors.redAccent,
      title: Row(
        children: [
          if (isHistory)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text('History'),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('User'),
          ),
          Text(title),
        ],
      ),
      actions: actions != null ? actions.map((e) => actionWidget(action: e)).toList() : null,
    );
  }
}
