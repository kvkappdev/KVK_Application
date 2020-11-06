import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fab_dialer/flutter_fab_dialer.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/icons/kvk_icons.dart';
import 'package:kvk_app/services/navBar_Service.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/navBar/tab_item.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';

final NavBarService _navBarFunctions = locator<NavBarService>();

class KVKBottomNavBar extends StatelessWidget {
  final KVKViewModel model;
  final String routeFrom;

  KVKBottomNavBar({@required this.model, @required this.routeFrom});

  /// Builds the bottom app bar with required colors
  ///
  /// param: BuildContext [context]
  /// returns: new Theme
  /// Initial creation: 22/09/2020
  /// Last Updated: 04/10/2020
  @override
  Widget build(BuildContext context) {
    return new Theme(
        data: Theme.of(context).copyWith(
            canvasColor: Colors.white,
            primaryColor: Colors.orange,
            textTheme: Theme.of(context)
                .textTheme
                .copyWith(caption: new TextStyle(color: Colors.grey))),
        child: _buildBottomTab(routeFrom: routeFrom));
  }

  /// Create the bottom navigation bar
  ///
  /// param:
  /// returns: BottomAppBar
  /// Initial creation: 22/09/2020
  /// Last Updated: 04/10/2020
  BottomAppBar _buildBottomTab({@required String routeFrom}) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TabItem(
              isSelected: _navBarFunctions.getCurrentIndex() == 0,
              message: model.lang().mainMenuBar[0],
              icon: KVKIcons.home_original,
              onTap: () {
                _navBarFunctions.bottomNavigation(
                    index: 0, routeFrom: routeFrom);
                model.notifyListeners();
              }),
          TabItem(
              isSelected: _navBarFunctions.getCurrentIndex() == 1,
              message: model.lang().mainMenuBar[1],
              icon: KVKIcons.search_original,
              onTap: () {
                _navBarFunctions.bottomNavigation(
                    index: 1, routeFrom: routeFrom);
                model.notifyListeners();
              }),
          TabItem(
            isSelected: _navBarFunctions.getCurrentIndex() == 4,
            message: model.lang().mainMenuBar[2],
            icon: Icons.device_unknown,
            iconColor: Colors.transparent,
          ),
          TabItem(
              isSelected: _navBarFunctions.getCurrentIndex() == 2,
              message: model.lang().mainMenuBar[3],
              icon: KVKIcons.user_original,
              onTap: () {
                _navBarFunctions.bottomNavigation(
                    index: 2, routeFrom: routeFrom);
                model.notifyListeners();
              }),
          TabItem(
              isSelected: _navBarFunctions.getCurrentIndex() == 3,
              message: model.lang().mainMenuBar[4],
              icon: KVKIcons.more_original,
              onTap: () {
                _navBarFunctions.bottomNavigation(
                    index: 3, routeFrom: routeFrom);
                model.notifyListeners();
              })
        ],
      ),
    );
  }
}

/// Creates the "Create Post" button in the middle of the app bar
///
/// param: BuildContext [context]
/// returns: Container
/// Initial creation: 22/09/2020
/// Last Updated: 04/10/2020
class KVKPostNavButton extends StatelessWidget {
  final String routeFrom;
  final bool isBasicUser;
  final double screenWidth;

  KVKPostNavButton(
      {@required this.routeFrom,
      @required this.isBasicUser,
      @required this.screenWidth});

  // int _counter = 0;

  void _gotoAddPost() {
    _navBarFunctions.post(routeFrom: routeFrom);
  }

  void _gotoAddAnnouncement() {
    _navBarFunctions.announcement(routeFrom: routeFrom);
  }

  @override
  Widget build(BuildContext context) {
    var _fabMiniMenuItemList = [
      new FabMiniMenuItem.noText(
          new Icon(KVKIcons.megaphone_original),
          Colour.kvk_background_green,
          4.0,
          "Button menu",
          _gotoAddAnnouncement,
          true),
      new FabMiniMenuItem.noText(new Icon(KVKIcons.edit_original),
          Colour.kvk_background_green, 4.0, "Button menu", _gotoAddPost, true),
    ];

    return isBasicUser
        ? Container(
            width: 90,
            height: 90,
            child: FittedBox(
              child: FloatingActionButton.extended(
                heroTag: null,
                elevation: 0,
                backgroundColor: Colour.kvk_background_green,
                shape: CircleBorder(),
                label: Icon(
                  KVKIcons.edit_figma_exported_custom_rotated,
                  textDirection: TextDirection.rtl,
                ),
                onPressed: () {
                  _navBarFunctions.post(routeFrom: routeFrom);
                },
              ),
            ),
          )
        : Container(
            width: 100,
            margin: new EdgeInsets.only(right: 20, bottom: 20),
            child: FabDialer(
                _fabMiniMenuItemList,
                Colour.kvk_background_green,
                new Icon(
                  KVKIcons.edit_figma_exported_custom_rotated,
                  textDirection: TextDirection.rtl,
                )));
  }
}
