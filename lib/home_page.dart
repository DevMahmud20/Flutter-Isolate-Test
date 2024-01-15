import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  final int loopTime = 400000000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Isolate Test"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 50),
            ElevatedButton(
                onPressed: () async {
                  Timer _timer = Timer.periodic(Duration(seconds: 1), (timer) {
                    print("Timer: ${timer.tick}");
                  });

                  await Future.wait([
                    heavyTaskWithoutIsolate(loopTime),
                    heavyTaskWithoutIsolate(loopTime),
                    heavyTaskWithoutIsolate(loopTime),
                    heavyTaskWithoutIsolate(loopTime),
                    heavyTaskWithoutIsolate(loopTime),
                    heavyTaskWithoutIsolate(loopTime),
                  ]);

                  _timer.cancel();
                },
                child: const Text("Run heavy task without isolate")),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: () async {
                  Timer _timer = Timer.periodic(Duration(seconds: 1), (timer) {
                    print("Timer: ${timer.tick}");
                  });

                  await Future.wait([
                    heavytaskWithIsolate(1),
                    heavytaskWithIsolate(2),
                    heavytaskWithIsolate(3),
                    heavytaskWithIsolate(4),
                    heavytaskWithIsolate(5),
                    heavytaskWithIsolate(6),
                  ]);

                  _timer.cancel();
                },
                child: const Text("Run heavy task with isolate")),
          ],
        ),
      ),
    );
  }

  Future heavytaskWithIsolate(int taskNumber) async {
    final ReceivePort receivePort = ReceivePort();
    try {
      await Isolate.spawn(runTask, [receivePort.sendPort, loopTime]);
      final result = await receivePort.first;
      print("heavytaskWithIsolate: $result, taskNumver: $taskNumber");
    } on Object {
      print("Isolate failed");
      receivePort.close();
    }
  }

  int runTask(List<dynamic> args) {
    SendPort resultPort = args[0];
    int value = 0;
    for (var i = 0; i < args[1]; i++) {
      value = value + 1;
    }
    Isolate.exit(resultPort, value);
  }

  Future<void> heavyTaskWithoutIsolate(int count) async {
    int result = 0;
    for (var i = 0; i < count; i++) {
      result = result + 1;
    }
    print("headyTask: result: $result");
  }
}
