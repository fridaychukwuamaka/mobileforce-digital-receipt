import 'package:digital_receipt/constant.dart';
import 'package:digital_receipt/models/customer.dart';
import 'package:digital_receipt/screens/customer_detail_screen.dart';
import 'package:digital_receipt/services/api_service.dart';
import 'package:digital_receipt/services/email_service.dart';
import 'package:digital_receipt/utils/connected.dart';
import 'package:digital_receipt/widgets/app_card.dart';
import 'package:digital_receipt/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../widgets/delete_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'no_internet_connection.dart';

// import 'customerDetails/customerDetail.dart';

/// This code displays only the UI
class CustomerList extends StatefulWidget {
  @override
  _CustomerListState createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  String dropdownValue = "Last Upadated";
  TextEditingController _searchFieldController = TextEditingController();
  ApiService _apiService = ApiService();
  var customerList;
  Future customerFuture;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  refreshCustomerList() async {
    customerList = await _apiService.getAllCustomers();
    //print(res);
  }

  @override
  void initState() {
    super.initState();
    customerFuture = _apiService.getAllCustomers();
    Future.delayed(Duration.zero, () {
      setCustomer();
    });
  }

  setCustomer() async {
    List customerData = await _apiService.getAllCustomers();
    List<Customer> customersCopy = [];
    customerData.forEach((customer) {
      customersCopy.add(Customer.fromJson(customer));
    });
    Provider.of<Customer>(context, listen: false).setCustomerList =
        customersCopy;
  }

  @override
  Widget build(BuildContext context) {
    var _customerListModel = Provider.of<Customer>(context, listen: false);
    return Scaffold(
      key: _scaffoldKey,
      // backgroundColor: Color(0xffE5E5E5),
      appBar: AppBar(
        //backgroundColor: Color(0xff226EBE),

        title: Text(
          "Customer List",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
            letterSpacing: 0.03,
          ),
        ),
        //centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 20.0, left: 16, right: 16),
        child: Column(
          children: <Widget>[
            SizedBox(height: 10.0),
            AppTextFormField(
              hintText: "Type a keyword",
              prefixIcon: IconButton(
                icon: Icon(
                  Icons.search,
                  color: Theme.of(context).disabledColor,
                ),
                onPressed: () {
                  _customerListModel
                      .searchCustomerList(_searchFieldController.text);
                },
              ),
              onChanged: (value) {
                _customerListModel.searchCustomerList(value);
              },
            ),
            SizedBox(height: 30.0),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Text("Sort By"),
              ),
              Container(
       
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Color(0xff25CCB3),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    value: dropdownValue,
                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                          fontFamily: 'Montserrat',
                        ),
                    underline: Divider(),
                    items: <String>[
                      "Last Upadated",
                      "A to Z",
                      "Z to A",
                    ].map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text(
                              value,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                    onChanged: (String value) {
                      setState(() => dropdownValue = value);
                      // No logic Implemented
                    },
                  ),
                ),
              ),
            ]),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  var connected = await Connected().checkInternet();
                  if (!connected) {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return NoInternet();
                      },
                    );
                  } else {
                    await refreshCustomerList();
                  }
                },
                child: FutureBuilder(
                  future: customerFuture, // receipts from API
                  builder: (context, snapshot) {
                    // If the API returns nothing it means the user has to upgrade to premium
                    // for now it doesn't validate if the user has upgraded to premium
                    /// If the API returns nothing it shows the dialog box `JUST FOR TESTING`
                    ///
                    // print(snapshot.data);
                    customerList = snapshot.data;
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                        ),
                      );
                    } else if (snapshot.connectionState ==
                            ConnectionState.done &&
                        snapshot.hasData &&
                        snapshot.data.length > 0) {
                      return Column(
                        children: <Widget>[
                          SizedBox(height: 20.0),
                          Consumer<Customer>(
                            builder: (_, model, child) {
                              // child:
                              return Flexible(
                                child: ListView.builder(
                                  itemCount: model.customerList.length,
                                  itemBuilder: (context, index) {
                                    return _buildCustomer(
                                      id: model.customerList[index].id,
                                      customerName:
                                          model.customerList[index].name,
                                      customerEmail:
                                          model.customerList[index].email,
                                      index: index,
                                      phoneNumber:
                                          model.customerList[index].phoneNumber,
                                      address:
                                          model.customerList[index].address,

                                      // numberOfReceipts: 0,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    } else {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            kBrokenHeart,
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: Text(
                                "You don't have any customer!",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 16,
                                      letterSpacing: 0.3,
                                    ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      );
                    }
                    // }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomer(
      {String id,
      String customerName,
      customerEmail,
      int index,
      phoneNumber,
      int numberOfReceipts,
      String address}) {
    return GestureDetector(
      onLongPress: () async {
        showDialog(
          context: context,
          builder: (_) => DeleteDialog(
            title: 'Are sure you want to delete this item?',
            onDelete: () async {
              var resp = await _apiService.deleteCustomer(id: id);
              if (resp == 'false') {
                Fluttertoast.showToast(msg: 'An error occured');
              } else {
                Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => CustomerList()))
                    .then((value) => Navigator.of(context).pop());
                print('successful');
              }
            },
          ) /* AlertDialog(
            titleTextStyle: TextStyle(fontSize: 18, color: Colors.black),
            titlePadding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
            title: Text('Delete this item'),
            actions: [
              RaisedButton(
                color: Color(0xFFE0EEFF),
                textColor: Colors.black,
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              RaisedButton(
                color: Color(0xFFD93725),
                textColor: Colors.white,
                onPressed: () async {
                  var resp = await _apiService.deleteCustomer(id: id);
                  if (resp == 'false') {
                    Fluttertoast.showToast(msg: 'An error occured');
                  } else {
                    Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => CustomerList()))
                        .then((value) => Navigator.of(context).pop());
                    print('successful');
                  }
                },
                child: Text(
                  'Delete',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ) */
          ,
        );
      },
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 99,
            child: Center(
              child: Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                secondaryActions: <Widget>[
                  Container(
                    color: Color(0xFFB3E2F4),
                    child: InkWell(
                      onTap: () {
                        print("tapped");
                        var url = "$phoneNumber";
                        print(url);

                        UrlLauncher.launch("tel://$url");
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.call,
                            color: Colors.black,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Call Customer",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Color(0xffBFEDC7),
                    child: InkWell(
                      onTap: () {
                        final EmailService emailService = EmailService();
                        emailService.setMail(
                          body: '',
                          subject: '',
                          recipients: [customerEmail],
                          isHTML: true,
                          bccRecipients: [],
                          ccRecipients: [],
                          attachments: [],
                        );
                        emailService.sendMail();
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset("assets/gmail.png",
                              height: 24, width: 24),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Mail Customer",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => CustomerDetailScreen(
                                customer: Customer(
                                  name: customerName,
                                  email: customerEmail,
                                  phoneNumber: phoneNumber,
                                  address: address,
                                ),
                              )),
                    );
                  },
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("$customerName",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                      )),
                              /* Text(
                                "$numberOfReceipts Receipts",

                              ), */
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
                          child: Text(
                            "$customerEmail",
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
                          child: Text(
                            "$phoneNumber",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          index == 0
              ? SizedBox(
                  height: 8,
                )
              : SizedBox.shrink(),
          index == 0
              ? Text(
                  'Swipe for more options, longpress to delete',
                  textAlign: TextAlign.center,
                )
              : SizedBox.shrink(),
          SizedBox(
            height: 19,
          ),
        ],
      ),
    );
  }

  //   _confirmCuustomerDelete(String id, String name) {
  //   return showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           contentPadding: EdgeInsets.all(10),
  //           // insetPadding: EdgeInsets.all(50),
  //           title: Text(
  //             "Are sure you want to delete $name?",
  //             style: TextStyle(
  //               fontSize: 15,
  //             ),
  //           ),
  //           content: SingleChildScrollView(
  //             scrollDirection: Axis.vertical,
  //             padding: EdgeInsets.all(30.0),
  //             child: Expanded(
  //               child: ListBody(
  //                 children: <Widget>[
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: <Widget>[
  //                       MaterialButton(
  //                         onPressed: () {
  //                           Navigator.pop(context);
  //                         },
  //                         color: Colors.blue[50],
  //                         child: Padding(
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: Text(
  //                             'cancel',
  //                             style: TextStyle(
  //                                 fontSize: 13, fontWeight: FontWeight.bold),
  //                           ),
  //                         ),
  //                       ),
  //                       MaterialButton(
  //                         onPressed: () async {
  //                           var resp =
  //                               await _apiService.deleteCustomer(id: id);
  //                           if (resp == 'false') {
  //                             Navigator.push(context, MaterialPageRoute(builder:(_)=> CustomerList()));
  //                             Fluttertoast.showToast(msg: 'an error occured');
  //                           } else {
  //                             Navigator.push(context, MaterialPageRoute(builder:(_)=> CustomerList()));
  //                             print('successful');
  //                           }
  //                         },
  //                         color: Colors.red,
  //                         child: Padding(
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: Text(
  //                             'delete',
  //                             style: TextStyle(
  //                                 fontSize: 13, fontWeight: FontWeight.bold),
  //                           ),
  //                         ),
  //                       )

  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       });

  // }
}
