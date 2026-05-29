import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class QRScannerScreen extends StatefulWidget {
  final Map<String, dynamic> sessionData;

  const QRScannerScreen({super.key, required this.sessionData});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  List<Map<String, String>> masterList = [];
  List<Map<String, String>> attendanceList = [];
  bool isLoading = true;
  bool isSaving = false;

  Set<String> _markedPnrs = {};  // New: For O(1) duplicate checks

  String? department, semester, category, course, timestamp;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
    _requestPermissions();
    _loadMasterList();
  }

  void _loadSessionData() {
    department = widget.sessionData['department'] ?? 'Unknown';
    semester = widget.sessionData['semester'] ?? 'SEM-1';
    category = widget.sessionData['category'] ?? 'Theory';
    course = widget.sessionData['course'] ?? 'General';
    timestamp = widget.sessionData['timestamp'] ??
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    if (Platform.isAndroid) {
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();
    }
  }

  Future<void> _loadMasterList() async {
    String fileAsset = 'assets/master_list.xlsx';  // Declare outside try (now in scope for catch)
    Excel? excel;  // Declare nullable outside try (null in catch)

    try {
      String lowerDept = (department ?? '').toLowerCase();
      if (lowerDept.contains('computer') || lowerDept == 'cs') {
        fileAsset = 'assets/CS.xlsx';
      } else if (lowerDept.contains('it') || lowerDept == 'information technology') {
        fileAsset = 'assets/IT.xlsx';
      }
      print(" Loading file: $fileAsset for dept: $department, sem: $semester");  // Debug log

      final ByteData data = await rootBundle.load(fileAsset);
      var bytes = data.buffer.asUint8List();
      excel = Excel.decodeBytes(bytes);  // Assign to outer variable
      print("Excel sheets available: ${excel.tables.keys.toList()}");  // Log all sheets

      masterList.clear();
      
      // Improved sheet selection with partial match
      String? targetSheet;
      String lowerSemester = (semester ?? '').toLowerCase().replaceAll(' ', '');
      for (String sheetKey in excel.tables.keys) {
        String lowerKey = sheetKey.toLowerCase().replaceAll(' ', '');
        if (lowerKey.contains(lowerSemester) || lowerSemester.contains(lowerKey)) {
          targetSheet = sheetKey;
          break;
        }
      }
      String sheetName = targetSheet ?? excel.tables.keys.first;
      print(" Selected sheet: $sheetName (target: $semester)");  // Debug log
      
      final sheet = excel.tables[sheetName];
      if (sheet == null) {
        throw Exception('Sheet "$sheetName" not found in $fileAsset');
      }

      int rowCount = 0;
      for (var row in sheet.rows.skip(1)) {  // Skip header
        String? pnrRaw = row[0]?.value?.toString()?.trim();
        String? rollRaw = row[1]?.value?.toString()?.trim();
        
        // Skip invalid rows
        if (pnrRaw == null || pnrRaw.isEmpty || rollRaw == null || rollRaw.isEmpty) {
          print(" Skipping invalid row: PNR=$pnrRaw, Roll=$rollRaw");  // Debug
          continue;
        }

        masterList.add({
          "pnr": pnrRaw.toLowerCase(),
          "roll": rollRaw.toLowerCase(),
          "firstName": row[2]?.value?.toString()?.trim() ?? "",
          "lastName": row[3]?.value?.toString()?.trim() ?? "",
          "division": row[4]?.value?.toString()?.trim() ?? "",
        });
        rowCount++;
        
        // Log first few for debug
        if (rowCount <= 3) {
          print(" Sample student $rowCount: PNR=${pnrRaw.toLowerCase()}, Roll=${rollRaw.toLowerCase()}");
        }
      }

      print(" Master list loaded: $rowCount students from $sheetName");  // Updated count
      if (rowCount == 0) {
        throw Exception('No valid students found in sheet "$sheetName"');
      }

      if (mounted) {
        setState(() => isLoading = false);
        if (rowCount == 0) {
          _showMessage(" No students loaded from $sheetName. Check Excel file.");
        }
      }
    } catch (e) {
      print(" Error loading master list: $e");  // Enhanced log
      if (mounted) {
        // Now fileAsset and excel are in scope; excel is null on error, so sheets='None'
        _showMessage("Error loading master list: $e\nFile: $fileAsset\nSheets: ${excel?.tables.keys ?? 'None'}");
        setState(() => isLoading = false);
      }
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (isSaving) return;
    for (final barcode in capture.barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null) {
        _markAttendance(rawValue);
      }
    }
  }

  void _markAttendance(String qrData) {
    if (isSaving) return;
    
    print(" Scanning QR: '$qrData'");  // Debug: Full QR value
    
    // Improved parsing: Strip common prefixes and handle extras
    String cleanData = qrData.replaceAll(RegExp(r'[\s\n\r]'), '');  // Remove whitespace
    final parts = cleanData.split(",");
    if (parts.length < 2) {
      _showMessage(" Invalid QR format! Got: '$qrData'\nExpected: PNR,ROLL");
      print(" QR parse failed: parts=$parts");  // Debug
      return;
    }

    // Strip prefixes like "PNR:", "Roll:" (common in generated QRs)
    String pnr = parts[0].trim().replaceAll(RegExp(r'^(PNR|ID)[:\s]*', caseSensitive: false), '').toLowerCase();
    String roll = parts[1].trim().replaceAll(RegExp(r'^(ROLL|NO)[:\s]*', caseSensitive: false), '').toLowerCase();
    
    // Convert if numeric (Excel might store as int)
    pnr = int.tryParse(pnr)?.toString() ?? pnr;
    roll = int.tryParse(roll)?.toString() ?? roll;
    
    print(" Parsed: PNR='$pnr', Roll='$roll'");  // Debug

    // Optional: Add regex validation (adjust to your format, e.g., PNR 5-10 digits)
    if (pnr.isEmpty || roll.isEmpty || !RegExp(r'^\d{3,10}$').hasMatch(pnr) || !RegExp(r'^\d{1,3}$').hasMatch(roll)) {
      _showMessage(" Invalid data in QR: PNR='$pnr', Roll='$roll'");
      return;
    }

    // Search with logging
    final matchingStudents = masterList.where((s) => s["pnr"] == pnr && s["roll"] == roll).toList();
    print(" Search results: ${matchingStudents.length} matches for PNR=$pnr, Roll=$roll");  // Debug
    
    if (matchingStudents.isEmpty) {
      // Log sample master PNRs for comparison
      final samplePnrs = masterList.take(5).map((s) => s["pnr"]).join(', ');
      print(" Master PNR samples: $samplePnrs");
      _showMessage(" Student not found: PNR='$pnr', Roll='$roll'\nCheck QR or master list.");
      return;
    }

    final student = matchingStudents.first;  // Use first if multiples (unlikely)

    // Check duplicates with Set (fast)
    if (_markedPnrs.contains(pnr)) {
      _showMessage("Student already marked as Present!");
      HapticFeedback.mediumImpact();
      return;
    }

    String time = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    attendanceList.add({
      "pnr": pnr,
      "roll": roll,
      "firstName": student["firstName"] ?? "",
      "lastName": student["lastName"] ?? "",
      "division": student["division"] ?? "",
      "status": "Present",
      "timestamp": time,
    });

    _markedPnrs.add(pnr);  // Add to set
    setState(() {});
    HapticFeedback.lightImpact();
    _showMessage(" ${student["firstName"]} ${student["lastName"]} marked Present!");
  }

  Future<void> _endSession() async {
    setState(() => isSaving = true);
    String time = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

    for (var student in masterList) {
      bool present = attendanceList.any((a) => a["pnr"] == student["pnr"]);
      if (!present) {
        attendanceList.add({
          "pnr": student["pnr"]!,
          "roll": student["roll"]!,
          "firstName": student["firstName"]!,
          "lastName": student["lastName"]!,
          "division": student["division"]!,
          "status": "Absent",
          "timestamp": time,
        });
      }
    }

    await _saveExcel();
    if (mounted) setState(() => isSaving = false);
  }

  Future<void> _saveExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Attendance'];

      // Headers: Wrap in TextCellValue for v4+
      sheet.appendRow([
        TextCellValue("PNR"),
        TextCellValue("Roll No"),
        TextCellValue("First Name"),
        TextCellValue("Last Name"),
        TextCellValue("Division"),
        TextCellValue("Status"),
        TextCellValue("Timestamp")
      ]);

      for (var entry in attendanceList) {
        // Data rows: Wrap each value in TextCellValue, handle nulls
        sheet.appendRow([
          TextCellValue(entry["pnr"] ?? ""),
          TextCellValue(entry["roll"] ?? ""),
          TextCellValue(entry["firstName"] ?? ""),
          TextCellValue(entry["lastName"] ?? ""),
          TextCellValue(entry["division"] ?? ""),
          TextCellValue(entry["status"] ?? ""),
          TextCellValue(entry["timestamp"] ?? "")
        ]);
      }

      int total = masterList.length;
      int present = attendanceList.where((a) => a["status"] == "Present").length;
      double percent = total > 0 ? (present / total) * 100 : 0;
      
      // Summary row: Wrap in TextCellValue
      String summaryTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
      sheet.appendRow([
        TextCellValue(""),  // Empty PNR
        TextCellValue(""),  // Empty Roll
        TextCellValue("SUMMARY"),  // Summary label
        TextCellValue(""),  // Empty Last Name
        TextCellValue(""),  // Empty Division
        TextCellValue("Total: $total | Present: $present (${percent.toStringAsFixed(1)}%)"),  // Summary text
        TextCellValue(summaryTime)  // Timestamp
      ]);

      // Better path handling
      Directory? dir;
      if (Platform.isAndroid) {
        // Use external storage if permitted, fallback to app docs
        if (await Permission.manageExternalStorage.isGranted) {
          dir = Directory('/storage/emulated/0/Download');
        } else {
          dir = await getExternalStorageDirectory();
        }
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
      
      if (dir == null) throw Exception('Cannot access storage');

      String safeDepartment = department?.replaceAll(RegExp(r'[^\w\s-]', unicode: true), '') ?? 'Dept';
      String safeSemester = semester?.replaceAll(RegExp(r'[^\w\s-]', unicode: true), '') ?? 'Sem';
      String safeCourse = course?.replaceAll(RegExp(r'[^\w\s-]', unicode: true), '') ?? 'Session';

      String fileName = 'Attendance_${safeDepartment}_${safeSemester}_${safeCourse}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      String filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      if (mounted) {
        _showMessage("Saved to $filePath\nPresent: $present/$total (${percent.toStringAsFixed(1)}%)");
      }
    } catch (e) {
      if (mounted) _showMessage(" Failed to save Excel: $e");
      print(" Save error: $e");
    }
  }

  void _clearAttendance() {
    setState(() {
      attendanceList.clear();
      _markedPnrs.clear();  // Clear set too
    });
    _showMessage("Attendance cleared.");
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.blue[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  bool _onPop() {
    if (attendanceList.isNotEmpty && !isSaving) {
      showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exit without saving?'),
          content: const Text('You have unsaved attendance data.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Exit')),
          ],
        ),
      ).then((exit) {
        if (exit == true && mounted) Navigator.pop(context);
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...'), backgroundColor: Colors.blue[800]),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(  // Updated: Replace deprecated WillPopScope
      canPop: false,  // Handle manually
      onPopInvoked: (didPop) {
        if (!didPop && _onPop()) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text('$department / $semester / $course'),
          backgroundColor: Colors.blue[800],
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: MobileScanner(controller: cameraController, onDetect: _onDetect),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: attendanceList.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.list_alt, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No attendance recorded yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            Text('Scan QR codes to mark Present', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: attendanceList.length,
                        itemBuilder: (context, index) {
                          final student = attendanceList[index];
                          return ListTile(
                            leading: Icon(
                              student["status"] == "Present" ? Icons.check_circle : Icons.cancel,
                              color: student["status"] == "Present" ? Colors.green : Colors.red,
                            ),
                            title: Text("${student["firstName"]} ${student["lastName"]}"),
                            subtitle: Text("Roll: ${student["roll"]} | Div: ${student["division"]} | ${student["status"]}"),
                            trailing: Text(student["timestamp"] ?? ''),
                          );
                        },
                      ),
              ),
              if (!isSaving)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _clearAttendance,
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _endSession,
                        icon: const Icon(Icons.save),
                        label: const Text('End Session & Save'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ),
                  ],
                )
              else
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}