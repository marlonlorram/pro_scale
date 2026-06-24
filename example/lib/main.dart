import 'package:flutter/material.dart';
import 'package:pro_scale/pro_scale.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pro_scale example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      // Initialize pro_scale once, below the app's MediaQuery.
      home: const ProScaleInit(
        designWidth: 375,
        designHeight: 812,
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Subscribe once at the top of the screen. This makes the whole page
    // rebuild when the screen size or system text scale changes, so the static
    // `.w` / `.h` / `.sp` / `.r` helpers below stay in sync — on the first
    // settled frame and on every rotation/resize afterwards.
    final scale = context.scale;

    return Scaffold(
      appBar: AppBar(
        title: Text('pro_scale', style: TextStyle(fontSize: 20.sp)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Static helpers', style: TextStyle(fontSize: 16.sp)),
            SizedBox(height: 12.h),
            // Sized with the static extensions; reflows because this page
            // subscribed via `context.scale` above.
            Container(
              width: 220.w,
              height: 120.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                '220.w x 120.h',
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ),

            SizedBox(height: 28.h),

            Text('Live scale factors', style: TextStyle(fontSize: 16.sp)),
            SizedBox(height: 12.h),
            Text(
              'scaleWidth:  ${scale.scaleWidth.toStringAsFixed(3)}',
              style: TextStyle(fontSize: 13.sp),
            ),
            Text(
              'scaleHeight: ${scale.scaleHeight.toStringAsFixed(3)}',
              style: TextStyle(fontSize: 13.sp),
            ),

            SizedBox(height: 28.h),
            Text(
              'Rotate the device or change the system font size to watch the '
              'numbers and the box update.',
              style: TextStyle(fontSize: 13.sp),
            ),
          ],
        ),
      ),
    );
  }
}
