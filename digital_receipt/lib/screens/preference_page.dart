import 'package:digital_receipt/utils/theme_manager.dart';
import 'package:digital_receipt/widgets/signature_dialog.dart';
import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import '../services/shared_preference_service.dart';

class PreferencePage extends StatefulWidget {
  @override
  _PreferencePageState createState() => _PreferencePageState();
}

class _PreferencePageState extends State<PreferencePage> {
  bool _isDark = false;
  bool _currentAutoLogoutStatus = false;

  getCurrentAutoLogoutStatus() async {
    var _logoutStatus =
        await _sharedPreferenceService.getBoolValuesSF("AUTO_LOGOUT") ?? false;
    setState(() {
      _currentAutoLogoutStatus = _logoutStatus;
    });
  }

  @override
  void initState() {
    super.initState();
    _isDark = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCurrentAutoLogoutStatus();
    });
  }

  static SharedPreferenceService _sharedPreferenceService =
      SharedPreferenceService();

  @override
  Widget build(BuildContext context) {
    _isDark = ThemeProvider.controllerOf(context).currentThemeId ==
            ThemeManager.darkTheme
        ? true
        : false;
    return Scaffold(
      //backgroundColor: Color(0xFFF2F8FF),
      appBar: AppBar(),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text(
                      "Preferences",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(0, 16.0, 0, 16.0),
                    //alignment: FractionalOffset(0.5, 2.0),
                  ),
                  SwitchListTile(
                    activeColor: Color(0xFF25CCB3),
                    contentPadding: const EdgeInsets.all(0),
                    value: _isDark,
                    title: Text(
                      'Dark Mode',
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontFamily: 'Montserrat',
                          ),
                    ),
                    onChanged: (val) {
                      ThemeProvider.controllerOf(context).nextTheme();
                    },
                  ),
                  SwitchListTile(
                      activeColor: Color(0xFF25CCB3),
                      contentPadding: const EdgeInsets.all(0),
                      value: _currentAutoLogoutStatus,
                      title: Text(
                        'Enable Auto Logout',
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              fontFamily: 'Montserrat',
                            ),
                      ),
                      onChanged: (value) {
                        _sharedPreferenceService.addBoolToSF(
                            "AUTO_LOGOUT", value);
                        getCurrentAutoLogoutStatus();
                      }),
                  ListTile(
                    title: Text(
                      'Change Signature',
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                    onTap: () {
                      
                      showDialog(
                        context: context,
                        builder: (context) => SignatureDialog(),
                      );
                    },
                    contentPadding: const EdgeInsets.all(0),
                    trailing: Icon(Icons.keyboard_arrow_right),
                  )
                  // ExportOptionButton(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
