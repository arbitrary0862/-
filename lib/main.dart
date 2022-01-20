import 'package:flutter/material.dart';
import 'aqi_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '全臺空氣品質監測',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('全臺空氣品質監測'),
        ),
        body: const AQIList(),
      ),
    );
  }
}

class AQIList extends StatefulWidget {
  const AQIList({Key? key}) : super(key: key);

  @override
  _AQIListState createState() => _AQIListState();
}

class _AQIListState extends State<AQIList> {
  Future<List<Station>>? futureStationList;

  @override
  void initState() {
    super.initState();
    futureStationList = fetchAQI();
  }

  @override
  Widget build(BuildContext context) {
    MaterialColor aqiColor(int aqi) {
      if (aqi <= -1) {
        return Colors.blue;
      } else if (aqi <= 50) {
        return Colors.green;
      } else if (aqi <= 100) {
        return Colors.yellow;
      } else if (aqi <= 200) {
        return Colors.red;
      } else {
        return Colors.purple;
      }
    }

    return Container(
        child: FutureBuilder<List<Station>>(
      future: futureStationList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // print(snapshot.data);
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              // print('build ${index}');
              return ListTile(
                  title: Container(
                    child: Text(
                      snapshot.data![index].siteName,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                  subtitle: Container(
                    margin: const EdgeInsets.only(top: 5, left: 15, right: 160),
                    child: Text(
                      snapshot.data![index].aqi.toString(),
                      style: TextStyle(
                          backgroundColor: aqiColor(snapshot.data![index].aqi!),
                          color: Colors.black,
                          fontSize: 25),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SecondPage(
                                name: snapshot.data![index].siteName,
                                County: snapshot.data![index].county,
                                AQI: snapshot.data![index].aqi!,
                                PM25: snapshot.data![index].PM2!,
                                Status: snapshot.data![index].status,
                                PublishTime:
                                    snapshot.data![index].publishTime)));
                  },
                  tileColor: Colors.yellow[100]);
            },
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    ));
  }
}

class SecondPage extends StatelessWidget {
  final String name;
  final String County;
  final int AQI;
  final int PM25;
  final String Status;
  final String PublishTime;
  const SecondPage(
      {Key? key,
      required this.name,
      required this.County,
      required this.AQI,
      required this.PM25,
      required this.Status,
      required this.PublishTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (Status == '普通') {
      statusColor = Colors.yellow;
    } else if (Status == '良好') {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.red;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(County + '空氣品質'),
      ),
      body: Column(
        children: [
          Container(
            child: Center(
              child: Text('城市:' + name,
                  style: const TextStyle(fontSize: 40, color: Colors.white)),
            ),
            color: Colors.blueGrey[800],
            margin: const EdgeInsets.all(5),
          ),
          Container(
            child: Center(
              child: Text('AQI(空氣品質指標):' + AQI.toString() + '\nPM2.5：' + PM25.toString()+'(μg/m3)',
                  style: const TextStyle(fontSize: 32, color: Colors.white)),
            ),
            color: Colors.blueGrey[800],
            margin: const EdgeInsets.all(5),
          ),
          Container(
            child: Center(
              child: Text('品質:' + Status,
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                  )),
            ),
            color: statusColor,
            margin: const EdgeInsets.all(5),
          ),
          Container(
            child: Center(
              child: Text(
                '資料取得時間\n' + PublishTime,
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
            ),
            color: Colors.blueGrey[800],
            margin: const EdgeInsets.all(5),
          ),
          ElevatedButton(
            child: const Text('返回上一頁 '),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
