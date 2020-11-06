import 'package:flutter/material.dart';

import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/services/database_service.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/ui/coloursheet.dart';

class DeleteDialog extends StatefulWidget {
   final List<String> deleteMessageDetails;

  DeleteDialog(
      {@required this.deleteMessageDetails});

  @override
  _DeleteDialogState createState() => new _DeleteDialogState(
      deleteMessageDetails: deleteMessageDetails);
}

class _DeleteDialogState extends State<DeleteDialog> {
  bool _deleteActive = false;
  final DatabaseService _databaseService = locator<DatabaseService>();
  final InternalProfileService _userProfileService = locator<InternalProfileService>();

   List<String> deleteMessageDetails;

  _DeleteDialogState(
      {@required this.deleteMessageDetails});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(
          deleteMessageDetails[0],
          style: TextStyle(fontFamily: "Lato", fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: RichText(
                text: TextSpan(
                    style: TextStyle(
                      fontFamily: "Lato",
                      color: Colour.kvk_dark_grey,
                      fontSize: 14,
                    ),
                    children: <TextSpan>[
                      TextSpan(text: deleteMessageDetails[1]),
                      TextSpan(
                          text: deleteMessageDetails[2],
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: deleteMessageDetails[3]),
                    ]),
              ),
            ),
            Container(
              margin: new EdgeInsets.only(top: 10),
              child: TextField(
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 18, color: Colour.kvk_black),
                decoration: new InputDecoration(
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colour.kvk_grey)),
                  hintText: deleteMessageDetails[4],
                  hintStyle: TextStyle(color: Colour.kvk_grey, fontSize: 18),
                ),
                onChanged: (value) => setState(
                  () {
                    if (value == "123456") {
                      _deleteActive = true;
                    } else {
                      _deleteActive = false;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          FlatButton(
            child: //CANCEL
                Text(deleteMessageDetails[5].toUpperCase(),
                    style: TextStyle(
                      fontFamily: "Lato",
                      color: Colour.kvk_orange,
                      fontSize: 14,
                    )),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Container(
            margin: new EdgeInsets.only(right: 8),
            child: InkWell(
              child: //DELETE
                  Text(deleteMessageDetails[6].toUpperCase(),
                      style: TextStyle(
                          fontFamily: "Lato",
                          fontSize: 14,
                          color: _deleteActive
                              ? Colour.kvk_error_red
                              : Colour.kvk_grey)),
              onTap: () async {
                if (_deleteActive) {
                  _databaseService.deleteProfile(
                      databaseID: _userProfileService.getAccountDatabaseID(), context: context);
                }
              },
            ),
          )
        ]);
  }
}
