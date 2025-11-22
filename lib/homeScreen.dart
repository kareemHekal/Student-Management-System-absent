import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'cards/Magmo3aWidget.dart';
import 'colors_app.dart';
import 'firbase/FirebaseFunctions.dart';
import 'loadingFile/loadingWidget.dart';
import 'models/Magmo3amodel.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  DateTime _date = DateTime.now();
  String _selectedDay = ''; // variable for the name of the day
  String _selectedDateStr = ''; // variable for the date in 'yyyy-MM-dd' format

  @override
  void initState() {
    super.initState();
    _selectedDay =
        _date == DateTime.now() ? 'Today' : DateFormat('EEEE').format(_date);
    _selectedDateStr =
        DateFormat('yyyy-MM-dd').format(_date); // initialize _selectedDateStr
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: app_colors.green,
        title: Image.asset(
          "assets/images/logo.png",
          height: 100,
          width: 90,
        ),
        toolbarHeight: 150,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Center(child: Image.asset("assets/images/studenizer_logo_2.png")),
          ),
          Column(
            children: [
              EasyDateTimeLine(
                initialDate: _date,
                onDateChange: (selectedDate) {
                  setState(() {
                    _date = selectedDate;
                    _selectedDay = selectedDate == DateTime.now()
                        ? 'Today'
                        : DateFormat('EEEE').format(selectedDate);
                    _selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
                  });
                  print('$_selectedDay, $_selectedDateStr');
                },
                activeColor: app_colors.green,
                dayProps: const EasyDayProps(
                  todayHighlightStyle: TodayHighlightStyle.withBackground,
                  todayHighlightColor: app_colors.ligthGreen,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<List<Magmo3amodel>>(
                  stream: Firebasefunctions.getAllDocsFromDay(_selectedDay),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: DiscreteCircle(
                          color: app_colors.green,
                          size: 30,
                          secondCircleColor: app_colors.ligthGreen,
                          thirdCircleColor: app_colors.orange,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          children: [
                            Text("Something went wrong"),
                            ElevatedButton(
                              onPressed: () {
                                // Implement retry logic here if needed
                              },
                              child: Text('Try again'),
                            ),
                          ],
                        ),
                      );
                    }

                    var magmo3as = snapshot.data ?? [];
                    if (magmo3as.isEmpty) {
                      return Center(
                        child: Text(
                          "لا توجد مجموعات في هذا اليوم",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 25,
                            color: app_colors.black,
                          ),
                        ),
                      );
                    }

                    // Remove the second Expanded widget here
                    return ListView.separated(
                      separatorBuilder: (context, index) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return Magmo3aWidget(
                          selectedDay: _selectedDay,
                          magmo3aModel: magmo3as[index],
                          selectedDateStr: _selectedDateStr,
                        );
                      },
                      itemCount: magmo3as.length,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );

  }
}
