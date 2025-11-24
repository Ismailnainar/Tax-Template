import 'package:aljeflutterapp/components/Style.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:aljeflutterapp/mainsidebar/mainSidebar.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:aljeflutterapp/Database/IpAddress.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileUploadScreen extends StatefulWidget {
  final TextEditingController SalesmannoController;
  final TextEditingController SalesmannameController;
  final TextEditingController deliveryidController;
  final TextEditingController transportchargeController;
  final TextEditingController loadingchargeController;
  final TextEditingController miscchargeController;

  const FileUploadScreen(
      this.SalesmannoController,
      this.SalesmannameController,
      this.deliveryidController,
      this.transportchargeController,
      this.loadingchargeController,
      this.miscchargeController,
      {super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  PlatformFile? _selectedFile;
  String? _fileName;
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  bool _isCompressing = false;
  String? _uploadResponse;
  bool _uploadSuccess = false;
  TextEditingController scanpathcontroller = TextEditingController();
  // 20 MB max
  final double _maxFileSizeKB = 20 * 1024;
  // simulate compression on >11 KB
  final double _compressThresholdKB = 11;

  @override
  void initState() {
    super.initState();
    fetchAccessControl();
    widget.SalesmannoController.addListener(_printValues);

    widget.SalesmannameController.addListener(_printValues);

    widget.deliveryidController.addListener(_printValues);
    widget.transportchargeController.addListener(_printValues);
    widget.loadingchargeController.addListener(_printValues);
    widget.miscchargeController.addListener(_printValues);
  }

  void _printValues() {
    print("Values: "
        "${widget.SalesmannoController.text}, "
        "${widget.SalesmannameController.text}, "
        "${widget.deliveryidController.text}, "
        "${widget.transportchargeController.text}, "
        "${widget.loadingchargeController.text}, "
        "${widget.miscchargeController.text}");
  }

  @override
  void dispose() {
    widget.SalesmannoController.removeListener(_printValues);

    widget.SalesmannameController.removeListener(_printValues);
    widget.deliveryidController.removeListener(_printValues);
    widget.transportchargeController.removeListener(_printValues);
    widget.loadingchargeController.removeListener(_printValues);
    widget.miscchargeController.removeListener(_printValues);
    super.dispose();
  }

  String DeliveryId = '';

  String convertPdfName(String deliveryId) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MMM-yyyy').format(now);
    print('Delivery ID: $deliveryId'); // Print the deliveryId
    final String deliveryName = "$deliveryId-($formattedDate)";

    print('deliveryNameeeeeeeeee ID: $deliveryName'); // Print the deliveryId
    return deliveryName;
  }

  Future<void> _pickFile() async {
    DeliveryId = await convertPdfName(widget.deliveryidController.text);

    postLogData("Pending Scan (Dispatch Completed Pop-up)",
        "Uploading the PDF For Dispatch Id ${widget.deliveryidController.text}");
    print("Deliveridddddd $DeliveryId");
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final fileSizeKB = file.size / 1024;

      if (fileSizeKB > _maxFileSizeKB) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File too large (${fileSizeKB.toStringAsFixed(1)} KB). Max '
              '${(_maxFileSizeKB / 1024).toStringAsFixed(1)} MB allowed.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // if bigger than threshold, simulate compress
      if (fileSizeKB > _compressThresholdKB) {
        setState(() {
          _isCompressing = true;
          _selectedFile = file;
          _fileName = 'Compressing ${file.name}...';
          _uploadProgress = 0.0;
        });

        // ~5 s compress: 100 steps ×50 ms = 5 s
        for (int i = 0; i <= 100; i++) {
          await Future.delayed(const Duration(milliseconds: 50));
          setState(() => _uploadProgress = i / 100);
        }

        setState(() {
          _isCompressing = false;
          _fileName = '${file.name} (compressed)';
          _uploadProgress = 0.0;
        });
      } else {
        setState(() {
          _selectedFile = file;
          _fileName = file.name;
          _uploadProgress = 0.0;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? empAddress;
  String? empEmail;
  String? errorMessage;
  Future<void> fetchEmployeeDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? empNo = widget.SalesmannoController.text;

    final IpAddress = await getActiveIpAddress();
    final url = Uri.parse('$IpAddress/get-employee-address/$empNo/');
    print("urllsss $IpAddress/get-employee-address/$empNo/");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          final email = data['data']['EMPLOYEE_NUMBER'];
          final address = data['data']['EMAIL_ADDRESS'];

          setState(() {
            empAddress = address;
            empEmail = email;
          });

          // 🔹 Print employee details
          print('✅ Employee Details:');
          print('Emp No: $empNo');
          print('Address: $address');
          print('Email: ${email ?? "Not available"}');

          if (email == null || email.toString().trim().isEmpty) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text("Email Not Available"),
                content: Text("There is no email available for this employee."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OK"),
                  )
                ],
              ),
            );
          }
        } else {
          setState(() {
            errorMessage = data['message'];
          });

          // 🔹 Print error
          print('❌ Error: ${data['message']}');

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Employee Not Found"),
              content: Text("This employee is not available."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                )
              ],
            ),
          );
        }
      } else {
        final err = 'Error ${response.statusCode}: ${response.reasonPhrase}';
        setState(() {
          errorMessage = err;
        });
        print('❌ $err');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Exception: $e';
      });
      print('❌ Exception: $e');
    }
  }

  String _status = '';

  Future<void> Sendemail() async {
    DeliveryId = await convertPdfName(widget.deliveryidController.text);

    if (_selectedFile == null) {
      setState(() {
        _status = 'Please select a file first';
      });
      return;
    }

    try {
      final IpAddress = await getActiveIpAddress();
      String lowercasedEmail =
          empAddress!.toLowerCase(); // ✅ Convert to lowercase

      final uri =
          Uri.parse('$IpAddress/Send_pdf_to_email/?email=$lowercasedEmail');
      print(
          "📡 Sending to: $uri  ${widget.SalesmannameController.text.trim()}");

      final request = http.MultipartRequest('POST', uri);

      // ✅ Add salesman name as a form field
      request.fields['salesmanname'] =
          widget.SalesmannameController.text.trim();

      // ✅ Attach the PDF file
      request.files.add(
        http.MultipartFile.fromBytes(
          'pdf', // Must match Django's expected key
          _selectedFile!.bytes!,
          filename: '$DeliveryId.pdf',
          contentType: MediaType('application', 'pdf'),
        ),
      );

      // ✅ Send the request
      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        setState(() {
          _status = '✅ Upload successful!';
        });
        print("✅ Upload successful");
      } else {
        setState(() {
          _status =
              '❌ Upload failed! Status: ${response.statusCode}, Body: ${response.body}';
        });
        print("❌ Upload failed! Status: ${response.statusCode}");
        print("📦 Response body: ${response.body}");
      }
    } catch (e) {
      setState(() {
        _status = '❌ Upload error: $e';
      });
      print("❌ Upload error: $e");
    }
  }

  Future<void> _uploadFile() async {
    await convertPdfName(widget.deliveryidController.text);
    // DateTime now = DateTime.now();

    // String formattedDate = DateFormat('dd-MMM-yyyy').format(now);
    // DeliveryId = "${widget.deliveryidController.text}-($formattedDate)";
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadResponse = null;
      _uploadSuccess = false;
    });

    // Simulate progress
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      setState(() => _uploadProgress = i / 100);
    }
    final IpAddress = await getActiveIpAddress();

    try {
      final url = Uri.parse('$IpAddress/upload/');
      var request = http.MultipartRequest('POST', url);

      // Rename the file to "dispatch24.pdf"
      final renamedFilename = '$DeliveryId.pdf';

      if (_selectedFile!.bytes != null) {
        // File picked as bytes (web or memory)
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          _selectedFile!.bytes!,
          filename: renamedFilename,
          contentType: MediaType('application', 'pdf'),
        ));
      } else if (_selectedFile!.path != null) {
        // File picked from disk
        List<int> fileBytes = await _selectedFile!.readStream!
            .reduce((a, b) => Uint8List.fromList([...a, ...b]));
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: renamedFilename,
          contentType: MediaType('application', 'pdf'),
        ));
      }

      // Optionally add fields (body)
      request.fields['customField'] = 'your_value'; // Add if needed

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      setState(() {
        // _isUploading = false;
        _uploadSuccess = response.statusCode == 200;
        _uploadResponse = 'Status: ${response.statusCode}\n${response.body}';
        _uploadProgress = _uploadSuccess ? 1.0 : _uploadProgress;

        try {
          final decoded = json.decode(response.body);
          // final uploadedUrl = decoded['url'] ?? '';
          // scanpathcontroller.text = uploadedUrl;
          final uploadedUrl = decoded['url'] ?? '';
          final uri = Uri.parse(uploadedUrl);
          final filePath =
              uri.path; // This gives "/alje/DL25055-(22-May-2025).pdf"

          scanpathcontroller.text = filePath;
        } catch (e) {
          scanpathcontroller.text = '';
          print('Error decoding response: $e');
        }

        print('scanpathcontroller.text: ${scanpathcontroller.text}');
      });
    } catch (e) {
      setState(() {
        // _isUploading = false;
        _uploadSuccess = false;
        _uploadResponse = 'Error: $e';
      });
      print('Upload error: $e');
    }
  }

  Future<void> updateTruckScanDetails() async {
    final IpAddress = await getActiveIpAddress();
    final String url = '$IpAddress/update-truck-scan/';

    try {
      // Prepare your data
      Map<String, dynamic> requestBody = {
        "deliveryid": widget.deliveryidController.text,
        "loadingcharge": widget.loadingchargeController.text,
        "transportcharge": widget.transportchargeController.text,
        "misecharge": widget.miscchargeController.text,
        "deliverystatus": "Delivery Completed",
        "scanpath": scanpathcontroller.text
      };

      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      postLogData("Pending Scan (Dispatch Completed Pop-up)",
          "Save PDF FIle For Dispatch Id ${widget.deliveryidController.text}");
      // Handle the response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          print('✅ Update successful: ${data['message']}');
          setState(() {
            _isUploading = false;
          });
        } else {
          print('⚠️ Update failed: ${data['message']}');
        }
      } else {
        print('❌ Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception: $e');
    }
  }

  List<String> accessControl = [];
  Future<List<String>> fetchAccessControl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lableRoleIDList = prefs.getString('departmentid');
    String? salesloginnoStr = prefs.getString('salesloginno');

    final IpAddress = await getActiveIpAddress();

    final String url =
        "$IpAddress/New_Updated_get_submenu_list/$lableRoleIDList/$salesloginnoStr/";
    print("Fetching submenu list from: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('submenu')) {
          // Update accessControl with fetched submenu list
          accessControl = List<String>.from(data['submenu']);
        }

        print("Fetched accessControl: $accessControl"); // Debugging output
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching submenu list: $e");
    }

    return accessControl; // ✅ Added return statement
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pick + status row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File picker box
              Expanded(
                child: GestureDetector(
                  onTap: _isUploading || _isCompressing ? null : _pickFile,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5),
                        width: 2,
                      ),
                      color: Colors.grey.withOpacity(0.1),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 50,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Upload PDF File',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Max file size: $_maxFileSizeKB MB\nClick to select a PDF file from your device ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Status box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isCompressing) ...[
                        const Text(
                          'Compressing PDF...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: _uploadProgress,
                          backgroundColor: Colors.grey[300],
                          color: Colors.orange,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(_uploadProgress * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ] else if (_isUploading) ...[
                        const Text(
                          'Uploading PDF...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: _uploadProgress,
                          backgroundColor: Colors.grey[300],
                          color: Theme.of(context).primaryColor,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(_uploadProgress * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ] else if (_fileName != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red[400],
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _fileName!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Will be uploaded as: $DeliveryId.pdf',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _selectedFile = null;
                                  _fileName = null;
                                  _uploadProgress = 0;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[400],
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'Ready to Submit',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const Text('No file selected',
                            style: TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // const SizedBox(height: 14),

          // Save button
          if (_fileName != null && !_isCompressing && !_isUploading)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  // width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await fetchEmployeeDetails();
                      await _uploadFile();
                      await Sendemail();
                      await updateTruckScanDetails();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainSidebar(
                              enabledItems: accessControl, initialPageIndex: 9),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Save Delivery Status',
                          style: TextStyle(fontSize: 14, color: Colors.white)),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize:
                          const Size(45.0, 31.0), // Set width and height
                      backgroundColor:
                          buttonColor, // Make background transparent to show gradient
                      shadowColor: Colors
                          .transparent, // Disable shadow to preserve gradient
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
