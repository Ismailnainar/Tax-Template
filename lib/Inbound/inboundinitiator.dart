import 'dart:io';
import 'package:aljeflutterapp/Database/IpAddress.dart';
import 'package:aljeflutterapp/components/Style.dart';
import 'package:aljeflutterapp/components/constaints.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InboundInitiatorEntryPage extends StatefulWidget {
  const InboundInitiatorEntryPage({super.key});

  @override
  State<InboundInitiatorEntryPage> createState() =>
      _InboundInitiatorEntryPageState();
}

class _InboundInitiatorEntryPageState extends State<InboundInitiatorEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _containers = [];

  TextEditingController supplierController = TextEditingController();
  TextEditingController houseBLController = TextEditingController();
  TextEditingController containerCountController = TextEditingController();
  TextEditingController clearanceDtController = TextEditingController();
  TextEditingController supplierNameController = TextEditingController();
  TextEditingController supplierNoController = TextEditingController();
  TextEditingController BayanController = TextEditingController();
  TextEditingController BLDateController = TextEditingController();
  TextEditingController POLController = TextEditingController();
  TextEditingController LCNoController = TextEditingController();
  TextEditingController InvoiceNo1Controller = TextEditingController();
  TextEditingController InvoiceNo1ValueController = TextEditingController();
  TextEditingController TermPaymentController = TextEditingController();
  TextEditingController BayanDateController = TextEditingController();
  TextEditingController ETDDateController = TextEditingController();
  TextEditingController PODController = TextEditingController();
  TextEditingController BillNoController = TextEditingController();
  TextEditingController InvoiceNo2Controller = TextEditingController();
  TextEditingController InvoiceNo2ValueController = TextEditingController();
  TextEditingController TermPayment2Controller = TextEditingController();
  TextEditingController MasterBLController = TextEditingController();
  TextEditingController ETAController = TextEditingController();
  TextEditingController LineNameController = TextEditingController();
  TextEditingController BillDueDateController = TextEditingController();
  TextEditingController InvoiceNo3Controller = TextEditingController();
  TextEditingController InvoiceNo3ValueController = TextEditingController();
  TextEditingController TermPayment3Controller = TextEditingController();
  TextEditingController conatinerNoController = TextEditingController();
  TextEditingController SizeControlller = TextEditingController();
  TextEditingController PoNoControlller = TextEditingController();

  FocusNode supplierFocus = FocusNode();
  FocusNode houseBLFocus = FocusNode();
  FocusNode containerCountFocus = FocusNode();
  FocusNode clearanceDtFocus = FocusNode();
  FocusNode supplierNameFocus = FocusNode();
  FocusNode supplierNoFocus = FocusNode();
  FocusNode BayanFocus = FocusNode();
  FocusNode BLDateFocus = FocusNode();
  FocusNode POLFocus = FocusNode();
  FocusNode LCNoFocus = FocusNode();
  FocusNode InvoiceNo1Focus = FocusNode();
  FocusNode InvoiceNo1ValueFocus = FocusNode();
  FocusNode TermPaymentFocus = FocusNode();
  FocusNode BayanDateFocus = FocusNode();
  FocusNode ETDDateFocus = FocusNode();
  FocusNode PODFocus = FocusNode();
  FocusNode BillNoFocus = FocusNode();
  FocusNode InvoiceNo2Focus = FocusNode();
  FocusNode InvoiceNo2ValueFocus = FocusNode();
  FocusNode TermPayment2Focus = FocusNode();
  FocusNode MasterBLFocus = FocusNode();
  FocusNode ETAFocus = FocusNode();
  FocusNode LineNameFocus = FocusNode();
  FocusNode BillDueDateFocus = FocusNode();
  FocusNode InvoiceNo3Focus = FocusNode();
  FocusNode InvoiceNo3ValueFocus = FocusNode();
  FocusNode TermPayment3Focus = FocusNode();
  FocusNode ContainerNoFocus = FocusNode();
  FocusNode SizeFocus = FocusNode();
  FocusNode containerAddButtonFocus = FocusNode();
  FocusNode poNumberFocus = FocusNode();
  FocusNode poAddFocus = FocusNode();
  FocusNode IncoTermsFocus = FocusNode();
  FocusNode IncoTerms2Focus = FocusNode();
  FocusNode IncoTerms3Focus = FocusNode();

  final Map<int, TextEditingController> shippedQtyControllers = {};
  final Map<int, TextEditingController> containerNoControllers = {};

  String docNo = '';

  bool isLoading = false;

  final List<String> INCOTerms = ['FOB', 'EXW', 'CFR', 'CIF', 'DDP'];

  String? _INCOTermsValue1;
  String? _INCOTermsValue2;
  String? _INCOTermsValue3;

  Future<void> fetchLastDocNo() async {
    final IpAddress = await getActiveIpAddress();
    final url = '$IpAddress/generate_docno/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String lastDocNo = data['DOC_NO']?.toString() ?? '';

        if (lastDocNo.isNotEmpty) {
          // Match format like IC25050001
          RegExp regExp = RegExp(r'^([A-Z]{2})(\d{2})(\d{2})(\d+)$');
          Match? match = regExp.firstMatch(lastDocNo);

          if (match != null) {
            String prefix = match.group(1)!; // IC
            String year = match.group(2)!; // 25
            String month = match.group(3)!; // 05
            int lastNumber = int.parse(match.group(4)!); // 0001 → 1
            int newNumber = lastNumber + 1;

            // Pad number to same length as original
            int numberLength = match.group(4)!.length;
            String newNumberStr =
                newNumber.toString().padLeft(numberLength, '0');

            String newDocNo =
                '$prefix$year$month$newNumberStr'; // e.g., IC25050002
            docNo = newDocNo;
          } else {
            docNo = lastDocNo; // fallback if format doesn't match
          }
        } else {
          // fallback default
          final now = DateTime.now();
          String fallback =
              "IC${now.year % 100}${now.month.toString().padLeft(2, '0')}0001";
          docNo = fallback;
        }
      } else {
        // Handle non-200 response
        docNo = "DOCNO_ERR";
      }
    } catch (e) {
      // Handle any exception
      docNo = "DOCNO_EXC";
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLastDocNo(); // Fetch when screen loads
  }

  @override
  void dispose() {
    // Dispose all controllers when widget is disposed
    shippedQtyControllers.values.forEach((c) => c.dispose());
    containerNoControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  bool _showInDialog = false;

  bool _fillShippedWithBalance = false;

  bool _hasShownEmptyContainerDialog = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbound Initiator',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: buttonColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Document Header
              _buildDocumentHeader(isMobile),
              const SizedBox(height: 5),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Shipment Details Section
                      _buildShipmentDetailsSection(isMobile),
                      const SizedBox(height: 5),

                      // Container and Product Information Sections
                      if (isMobile) ...[
                        Row(
                          children: [
                            Text(
                              "Add Containers",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 4),
                            StatefulBuilder(
                              builder: (context, setState) {
                                return Checkbox(
                                  value: _showInDialog,
                                  onChanged: (value) async {
                                    // Make this async
                                    setState(
                                        () => _showInDialog = value ?? false);
                                    if (value ?? false) {
                                      _showContainerInfoDialog(isMobile);
                                    }
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                );
                              },
                            ),
                          ],
                        ),
                        const Divider(thickness: 1, height: 16),
                        _buildProductInfoSection(isMobile),
                      ] else ...[
                        Row(
                          children: [
                            Text(
                              "Add Containers",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 4),
                            StatefulBuilder(
                              builder: (context, setState) {
                                return Checkbox(
                                  value: _showInDialog,
                                  onChanged: (value) {
                                    setState(
                                        () => _showInDialog = value ?? false);
                                    if (value ?? false) {
                                      _showContainerInfoDialog(isMobile);
                                    }
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                );
                              },
                            ),
                          ],
                        ),
                        const Divider(thickness: 1, height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 7,
                              child: _buildProductInfoSection(isMobile),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              _buildActionButtons(isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentHeader(bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          const Text('Doc No:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: isMobile ? 6 : 8,
                  ),
                  border: InputBorder.none,
                  hintText: docNo,
                  hintStyle: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentDetailsSection(bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Shipment Details",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          if (isMobile) ...[
            // Mobile layout - vertical fields
            _buildCompactTextField(
              'Supplier',
              supplierController,
              'Enter supplier',
              isMobile,
              focusNode: supplierFocus,
              nextFocus: houseBLFocus,
            ),
            const SizedBox(height: 8),
            _buildCompactTextField(
              'House BL',
              houseBLController,
              'Enter house BL',
              isMobile,
              focusNode: houseBLFocus,
              nextFocus: containerCountFocus,
            ),
            const SizedBox(height: 8),
            _buildCompactTextField(
              'Container Count',
              containerCountController,
              'Enter count',
              isMobile,
              focusNode: containerCountFocus,
              nextFocus: clearanceDtFocus,
            ),
            const SizedBox(height: 8),
            _buildCompactTextField(
              'Clearance Date',
              clearanceDtController,
              'Select date',
              isMobile,
              icon: Icons.calendar_month,
              focusNode: clearanceDtFocus,
              nextFocus: supplierNameFocus,
            ),
            const SizedBox(height: 8),
            _buildCompactTextField(
              'Supplier Name',
              supplierNameController,
              'Enter name',
              isMobile,
              focusNode: supplierNameFocus,
              nextFocus: supplierNoFocus,
            ),
            const SizedBox(height: 8),
            _buildCompactTextField(
              'Supplier No',
              supplierNoController,
              'Enter number',
              isMobile,
              focusNode: supplierNoFocus,
              nextFocus: BayanFocus,
            ),
            const SizedBox(height: 8),
            _buildCompactTextField(
              'Bayan',
              BayanController,
              'Enter bayan',
              isMobile,
              focusNode: BayanFocus,
              nextFocus: BLDateFocus,
            ),
            const SizedBox(height: 8),
            _buildCompactTextField(
              'BL Date',
              BayanDateController,
              'Select date',
              isMobile,
              icon: Icons.calendar_month,
              focusNode: BLDateFocus,
              nextFocus: POLFocus,
            ),
            const SizedBox(height: 8),
            _buildCompactTextField(
              'POL',
              POLController,
              'Enter POL',
              isMobile,
              focusNode: POLFocus,
              nextFocus: LCNoFocus,
            ),
            const SizedBox(height: 8),
            _buildCompactTextField(
              'LC No',
              LCNoController,
              'Enter LC number',
              isMobile,
              focusNode: LCNoFocus,
              nextFocus: BillNoFocus,
            ),
            const SizedBox(height: 8),

            _buildCompactTextField(
              'Invoice No 1',
              InvoiceNo1Controller,
              'Enter number',
              isMobile,
              focusNode: InvoiceNo1Focus,
              nextFocus: InvoiceNo1ValueFocus,
            ),
            const SizedBox(height: 8),

            _buildCompactTextField(
              'Invoice 1 Value',
              InvoiceNo1ValueController,
              'Enter value',
              isMobile,
              focusNode: InvoiceNo1ValueFocus,
              nextFocus: TermPaymentFocus,
            ),
            const SizedBox(height: 8),

            _buildCompactTextField(
              'Term Payment',
              TermPaymentController,
              'Enter term',
              isMobile,
              focusNode: TermPaymentFocus,
              nextFocus: IncoTermsFocus,
            ),
            const SizedBox(height: 8),

            _buildCompactDropdown(
              'INCOTERMS',
              _INCOTermsValue1,
              isMobile,
              focusNode: IncoTermsFocus,
              nextFocus: InvoiceNo2Focus,
            ),
            const SizedBox(height: 8),
          ] else ...[
            // Desktop layout - rows of fields
            // Row 1 - 5 fields
            _buildSevenColumnRow(isMobile, children: [
              _buildCompactTextField(
                'Supplier',
                supplierController,
                'Enter supplier',
                isMobile,
                focusNode: supplierFocus,
                nextFocus: BayanFocus,
              ),
              _buildCompactTextField(
                'House BL',
                houseBLController,
                'Enter house BL',
                isMobile,
                focusNode: houseBLFocus,
                nextFocus: BLDateFocus,
              ),
              _buildCompactTextField(
                'Container Count',
                containerCountController,
                'Enter count',
                isMobile,
                focusNode: containerCountFocus,
                nextFocus: POLFocus,
              ),
              _buildCompactTextField(
                'Clearance Date',
                clearanceDtController,
                'Select date',
                isMobile,
                icon: Icons.calendar_month,
                focusNode: clearanceDtFocus,
                nextFocus: LCNoFocus,
              ),
              _buildCompactTextField(
                'Supplier Name',
                supplierNameController,
                'Enter name',
                isMobile,
                focusNode: supplierNameFocus,
                nextFocus: supplierNoFocus,
              ),
              _buildCompactTextField(
                'Supplier No',
                supplierNoController,
                'Enter number',
                isMobile,
                focusNode: supplierNoFocus,
                nextFocus: InvoiceNo1Focus,
              ),
              const SizedBox(),
              const SizedBox(),
            ]),

            // Row 2 - 5 fields
            _buildSevenColumnRow(isMobile, children: [
              _buildCompactTextField(
                'Bayan',
                BayanController,
                'Enter bayan',
                isMobile,
                focusNode: BayanFocus,
                nextFocus: BayanDateFocus,
              ),
              _buildCompactTextField(
                'BL Date',
                BLDateController,
                'Select date',
                isMobile,
                icon: Icons.calendar_month,
                focusNode: BLDateFocus,
                nextFocus: ETDDateFocus,
              ),
              _buildCompactTextField(
                'POL',
                POLController,
                'Enter POL',
                isMobile,
                focusNode: POLFocus,
                nextFocus: PODFocus,
              ),
              _buildCompactTextField(
                'LC No',
                LCNoController,
                'Enter LC number',
                isMobile,
                focusNode: LCNoFocus,
                nextFocus: BillNoFocus,
              ),
              _buildCompactTextField(
                'Invoice No 1',
                InvoiceNo1Controller,
                'Enter number',
                isMobile,
                focusNode: InvoiceNo1Focus,
                nextFocus: InvoiceNo1ValueFocus,
              ),
              _buildCompactTextField(
                'Invoice 1 Value',
                InvoiceNo1ValueController,
                'Enter value',
                isMobile,
                focusNode: InvoiceNo1ValueFocus,
                nextFocus: TermPaymentFocus,
              ),
              _buildCompactTextField(
                'Term Payment',
                TermPaymentController,
                'Enter term',
                isMobile,
                focusNode: TermPaymentFocus,
                nextFocus: IncoTermsFocus,
              ),
              _buildCompactDropdown(
                'INCOTERMS',
                _INCOTermsValue1,
                isMobile,
                focusNode: IncoTermsFocus,
                nextFocus: InvoiceNo2Focus,
              ),
            ]),

            // Row 3 - 5 fields
            _buildSevenColumnRow(isMobile, children: [
              _buildCompactTextField(
                'Bayan Date',
                BayanDateController,
                'Select date',
                isMobile,
                icon: Icons.calendar_month,
                focusNode: BayanDateFocus,
                nextFocus: MasterBLFocus,
              ),
              _buildCompactTextField(
                'ETD Date',
                ETDDateController,
                'Select date',
                isMobile,
                icon: Icons.calendar_month,
                focusNode: ETDDateFocus,
                nextFocus: ETAFocus,
              ),
              _buildCompactTextField(
                'POD',
                PODController,
                'Enter POD',
                isMobile,
                focusNode: PODFocus,
                nextFocus: LineNameFocus,
              ),
              _buildCompactTextField(
                'Bill No',
                BillNoController,
                'Enter bill number',
                isMobile,
                focusNode: BillNoFocus,
                nextFocus: BillDueDateFocus,
              ),
              _buildCompactTextField(
                'Invoice No 2',
                InvoiceNo2Controller,
                'Enter number',
                isMobile,
                focusNode: InvoiceNo2Focus,
                nextFocus: InvoiceNo2ValueFocus,
              ),
              _buildCompactTextField(
                'Invoice 2 Value',
                InvoiceNo2ValueController,
                'Enter value',
                isMobile,
                focusNode: InvoiceNo2ValueFocus,
                nextFocus: TermPayment2Focus,
              ),
              _buildCompactTextField(
                'Term2 Payment',
                TermPayment2Controller,
                'Enter term',
                isMobile,
                focusNode: TermPayment2Focus,
                nextFocus: IncoTerms2Focus,
              ),
              _buildCompactDropdown(
                'INCOTERMS2',
                _INCOTermsValue2,
                isMobile,
                focusNode: IncoTerms2Focus,
                nextFocus: InvoiceNo3Focus,
              ),
            ]),

            // Row 4 - 5 fields
            _buildSevenColumnRow(isMobile, children: [
              _buildCompactTextField(
                'Master BL',
                MasterBLController,
                'Enter master BL',
                isMobile,
                focusNode: MasterBLFocus,
                nextFocus: houseBLFocus,
              ),
              _buildCompactTextField(
                'ETA Date',
                ETAController,
                'Select date',
                isMobile,
                icon: Icons.calendar_month,
                focusNode: ETAFocus,
                nextFocus: containerCountFocus,
              ),
              _buildCompactTextField(
                'Line Name',
                LineNameController,
                'Enter line name',
                isMobile,
                focusNode: LineNameFocus,
                nextFocus: clearanceDtFocus,
              ),
              _buildCompactTextField(
                'Bill Due Date',
                BillDueDateController,
                'Select date',
                isMobile,
                icon: Icons.calendar_month,
                focusNode: BillDueDateFocus,
                nextFocus: supplierNameFocus,
              ),
              _buildCompactTextField(
                'Invoice No 3',
                InvoiceNo3Controller,
                'Enter number',
                isMobile,
                focusNode: InvoiceNo3Focus,
                nextFocus: InvoiceNo3ValueFocus,
              ),
              _buildCompactTextField(
                'Invoice 3 Value',
                InvoiceNo3ValueController,
                'Enter value',
                isMobile,
                focusNode: InvoiceNo3ValueFocus,
                nextFocus: TermPayment3Focus,
              ),
              _buildCompactTextField(
                'Term3 Payment',
                TermPayment3Controller,
                'Enter term',
                isMobile,
                focusNode: TermPayment3Focus,
                nextFocus: IncoTerms3Focus,
              ),
              _buildCompactDropdown(
                'INCOTERMS3',
                _INCOTermsValue3,
                isMobile,
                focusNode: IncoTerms3Focus,
                nextFocus: supplierFocus,
              ),
            ]),
          ],
        ],
      ),
    );
  }

  void _showContainerInfoDialog(bool isMobile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? MediaQuery.of(context).size.width : 550,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Container Information",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              Navigator.pop(context);
                              _showInDialog = false;
                            });
                          }),
                    ],
                  ),
                ),

                // Content area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Input row
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildCompactTextField(
                                  'Container No',
                                  conatinerNoController,
                                  'Enter number',
                                  isMobile,
                                  focusNode: ContainerNoFocus,
                                  nextFocus: SizeFocus,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildCompactTextField(
                                  'Size',
                                  SizeControlller,
                                  'Select size',
                                  isMobile,
                                  focusNode: SizeFocus,
                                  nextFocus: containerAddButtonFocus,
                                ),
                              ),
                              const SizedBox(width: 3),
                              IconButton(
                                focusNode: containerAddButtonFocus,
                                icon: const Icon(Icons.add,
                                    color: Colors.green, size: 28),
                                onPressed: () {
                                  _addContainer();
                                  Navigator.pop(context);
                                },
                              ),
                              const SizedBox(width: 3),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.upload, size: 16),
                                  label: const Text(
                                    'Upload Excel',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onPressed: () async {
                                    await _uploadExcelData();
                                    setState(() {}); // Refresh the dialog state
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    side: BorderSide(
                                      color: Colors.blue.shade700,
                                      width: 1.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Table

                        const SizedBox(height: 5),

                        _buildEnhancedContainerTable(isMobile),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'No. of Containers:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Text(
                        _containers.length.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
    if (mounted) setState(() => _showInDialog = false);
  }

  Widget _buildEnhancedContainerTable(bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate column widths based on available space
          final serialWidth = isMobile ? 40.0 : 60.0;
          final containerWidth = constraints.maxWidth * (isMobile ? 0.5 : 0.6);
          final sizeWidth = isMobile ? 0.0 : constraints.maxWidth * 0.3;

          return Column(
            children: [
              // Table header
              Container(
                decoration: BoxDecoration(
                  color: buttonColor,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 10 : 14,
                    horizontal: 8,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: serialWidth,
                        child: Center(
                          child: Text(
                            'S.No',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Text(
                            'Container No',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      if (!isMobile) SizedBox(width: 8),
                      if (!isMobile)
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              'Size',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Table content
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _containers.length,
                  itemBuilder: (context, index) {
                    final container = _containers[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        color: index.isOdd ? Colors.grey.shade50 : Colors.white,
                      ),
                      child: InkWell(
                        hoverColor: Colors.blue.shade50,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 8 : 12,
                            horizontal: 8,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: serialWidth,
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: Center(
                                  child: Text(
                                    container['no'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              if (!isMobile) SizedBox(width: 8),
                              if (!isMobile)
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getSizeColor(container['size']),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          )
                                        ],
                                      ),
                                      child: Text(
                                        container['size'] ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _getSizeTextColor(
                                              container['size']),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> poList = [];

  Widget _buildProductInfoSection(bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Product Information",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Container(
                width: 180,
                child: _buildCompactTextField(
                  'Enter PO Number',
                  PoNoControlller,
                  'PO number',
                  isMobile,
                  focusNode: poNumberFocus,
                  nextFocus: poAddFocus,
                ),
              ),
              IconButton(
                focusNode: poAddFocus,
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: _addProduct,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildProductTable(isMobile),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 10,
                ),
                Text(
                  'No. of PO Details:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  width: 3,
                ),
                Text(
                  poList.length.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          _buildActionButton('Save', Icons.save, buttonColor, _saveForm,
              isSmall: isMobile),
          SizedBox(width: isMobile ? 10 : 20),
          _buildActionButton('Clear', Icons.clear, buttonColor, _clearForm,
              isSmall: isMobile),
        ],
      ),
    );
  }

  Widget _buildSevenColumnRow(bool isMobile, {required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: isMobile
          ? Column(
              children: children
                  .map((child) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: child,
                      ))
                  .toList(),
            )
          : Row(
              children: [
                Expanded(child: children[0]),
                const SizedBox(width: 10),
                Expanded(child: children[1]),
                const SizedBox(width: 10),
                Expanded(child: children[2]),
                const SizedBox(width: 10),
                Expanded(child: children[3]),
                const SizedBox(width: 10),
                Expanded(child: children[4]),
                const SizedBox(width: 10),
                Expanded(child: children[5]),
                const SizedBox(width: 10),
                Expanded(child: children[6]),
                const SizedBox(width: 10),
                Expanded(child: children[7]),
              ],
            ),
    );
  }

  Widget _buildCompactTextField(
    String label,
    TextEditingController controller,
    String hint,
    bool isMobile, {
    IconData? icon,
    required FocusNode focusNode,
    FocusNode? nextFocus,
  }) {
    if (icon != null && controller.text.isEmpty) {
      controller.text = _formatDate(DateTime.now());
    }

    return SizedBox(
      height: isMobile ? 36 : 40,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode, // ✅ This line is required!
        decoration: InputDecoration(
          isDense: true,
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(fontSize: isMobile ? 11 : 12),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: isMobile ? 10 : 14,
          ),
          border: const OutlineInputBorder(),
          suffixIcon: icon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(icon, size: isMobile ? 16 : 18),
                )
              : null,
          labelStyle: TextStyle(fontSize: isMobile ? 11 : 12),
        ),
        style: TextStyle(fontSize: 12),
        readOnly: icon != null, // Only make read-only if it has calendar icon
        onTap: icon != null
            ? () async {
                DateTime currentDate;
                try {
                  currentDate = _parseDate(controller.text) ?? DateTime.now();
                } catch (e) {
                  currentDate = DateTime.now();
                }

                final date = await showDatePicker(
                  context: context,
                  initialDate: currentDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (date != null) {
                  controller.text = _formatDate(date);
                }
              }
            : null,
        textInputAction:
            nextFocus != null ? TextInputAction.next : TextInputAction.done,
        onFieldSubmitted: (_) {
          _fieldFocusChange(focusNode, nextFocus);
        },
      ),
    );
  }

  void _fieldFocusChange(FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    if (nextFocus != null) {
      FocusScope.of(context).requestFocus(nextFocus);
    }
  }

  Widget _buildCompactDropdown(
    String label,
    String? selectedValue,
    bool isMobile, {
    required FocusNode focusNode,
    FocusNode? nextFocus,
  }) {
    return SizedBox(
      height: isMobile ? 36 : 40,
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        focusNode: focusNode,
        items: INCOTerms.map((term) => DropdownMenuItem<String>(
              value: term,
              child: Text(term, style: TextStyle(fontSize: 12)),
            )).toList(),
        onChanged: (val) {
          _fieldFocusChange(focusNode, nextFocus);
        },
        decoration: InputDecoration(
          isDense: true,
          labelText: label,
          labelStyle: TextStyle(fontSize: isMobile ? 11 : 12),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: isMobile ? 10 : 14,
          ),
          border: const OutlineInputBorder(),
        ),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

// Format date as "25-May-2025"
  String _formatDate(DateTime date) {
    final monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return '${date.day}-${monthNames[date.month - 1]}-${date.year}';
  }

// Parse date from "25-May-2025" format
  DateTime? _parseDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final monthNames = [
          "Jan",
          "Feb",
          "Mar",
          "Apr",
          "May",
          "Jun",
          "Jul",
          "Aug",
          "Sep",
          "Oct",
          "Nov",
          "Dec"
        ];
        final monthIndex = monthNames.indexOf(parts[1]);
        if (monthIndex != -1) {
          return DateTime(
            int.parse(parts[2]), // year
            monthIndex + 1, // month
            int.parse(parts[0]), // day
          );
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  final ScrollController _verticalScrollController2 = ScrollController();

// Helper method for table headers
  final List<Color> _sizeColors = [
    Colors.red.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.teal.shade100,
    Colors.pink.shade100,
    Colors.indigo.shade100,
    Colors.amber.shade100,
    Colors.cyan.shade100,
    Colors.deepOrange.shade100,
  ];

// Predefined list of matching dark text colors (shade 800)
  final List<Color> _sizeTextColors = [
    Colors.red.shade800,
    Colors.blue.shade800,
    Colors.green.shade800,
    Colors.orange.shade800,
    Colors.purple.shade800,
    Colors.teal.shade800,
    Colors.pink.shade800,
    Colors.indigo.shade800,
    Colors.amber.shade800,
    Colors.cyan.shade800,
    Colors.deepOrange.shade800,
  ];

  Color _getSizeColor(String? size) {
    if (size == null || size.isEmpty) return Colors.grey.shade100;

    // Use a map to ensure consistent colors for the same size
    final sizeIndex = size.hashCode.abs() % _sizeColors.length;
    return _sizeColors[sizeIndex];
  }

  Color _getSizeTextColor(String? size) {
    if (size == null || size.isEmpty) return Colors.grey.shade800;

    // Match the text color with the background color
    final sizeIndex = size.hashCode.abs() % _sizeTextColors.length;
    return _sizeTextColors[sizeIndex];
  }

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  Widget _buildProductTable(bool isMobile) {
    // Define column widths based on screen size
    final columnWidths = {
      0: FixedColumnWidth(isMobile ? 40.0 : 50.0), // S.No
      1: FlexColumnWidth(isMobile ? 1.0 : 1.2), // PO No
      2: FlexColumnWidth(isMobile ? 0.8 : 1.0), // Franchise
      3: FlexColumnWidth(isMobile ? 0.8 : 1.0), // Family
      4: FlexColumnWidth(isMobile ? 0.8 : 1.0), // Class
      5: FlexColumnWidth(isMobile ? 0.8 : 1.0), // Subclass
      6: FlexColumnWidth(isMobile ? 1.0 : 1.2), // ItemCode
      7: FixedColumnWidth(isMobile ? 60.0 : 70.0), // PO Qty
      8: FixedColumnWidth(isMobile ? 60.0 : 70.0), // Rec Qty
      9: FixedColumnWidth(isMobile ? 70.0 : 80.0), // Balance Qty
      10: FixedColumnWidth(isMobile ? 80.0 : 90.0), // Shipped Qty
      11: FlexColumnWidth(isMobile ? 1.2 : 1.5), // Container No
    };

    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          )
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                maxHeight: isMobile ? 300 : 400,
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      cardTheme: CardTheme(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                    ),
                    child: DataTable(
                      columnSpacing: isMobile ? 8 : 12,
                      horizontalMargin: isMobile ? 8 : 12,
                      headingRowHeight: 40,
                      dataRowHeight: 40,
                      headingRowColor: MaterialStateProperty.resolveWith<Color>(
                        (states) => Colors.blue.shade50,
                      ),
                      dataTextStyle: TextStyle(
                        fontSize: isMobile ? 12 : 13,
                        color: Colors.grey.shade800,
                      ),
                      headingTextStyle: TextStyle(
                        fontSize: isMobile ? 12 : 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                      columns: [
                        DataColumn(
                          label: Center(
                              child: Text(
                            'S.No',
                            style: TextStyle(fontSize: 12),
                          )),
                          numeric: true,
                        ),
                        DataColumn(
                            label: Text(
                          'PO No',
                          style: TextStyle(fontSize: 12),
                        )),
                        DataColumn(
                            label: Text(
                          'Franchise',
                          style: TextStyle(fontSize: 12),
                        )),
                        DataColumn(
                            label: Text(
                          'Family',
                          style: TextStyle(fontSize: 12),
                        )),
                        DataColumn(
                            label: Text(
                          'Class',
                          style: TextStyle(fontSize: 12),
                        )),
                        DataColumn(
                            label: Text(
                          'Subclass',
                          style: TextStyle(fontSize: 12),
                        )),
                        DataColumn(
                            label: Text(
                          'ItemCode',
                          style: TextStyle(fontSize: 12),
                        )),
                        DataColumn(
                          label: Center(
                              child: Text(
                            'PO Qty',
                            style: TextStyle(fontSize: 12),
                          )),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Center(
                              child: Text(
                            'Rec Qty',
                            style: TextStyle(fontSize: 12),
                          )),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Center(
                              child: Text(
                            'Balance Qty',
                            style: TextStyle(fontSize: 12),
                          )),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Row(
                            children: [
                              Transform.scale(
                                scale: 0.75,
                                child: Checkbox(
                                  value: _fillShippedWithBalance,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _fillShippedWithBalance = value ?? false;

                                      if (_fillShippedWithBalance) {
                                        for (int i = 0;
                                            i < poList.length;
                                            i++) {
                                          final poQty =
                                              poList[i]['PO_QUANTITY'] ?? 0;
                                          final recQty =
                                              poList[i]['REC_QTY'] ?? 0;
                                          final balanceQty = poQty - recQty;

                                          poList[i]['SHIPPED_QTY'] = balanceQty;
                                          shippedQtyControllers[i] ??=
                                              TextEditingController();
                                          shippedQtyControllers[i]!.text =
                                              balanceQty.toString();
                                        }
                                      } else {
                                        for (int i = 0;
                                            i < poList.length;
                                            i++) {
                                          poList[i]['SHIPPED_QTY'] = 0;
                                          shippedQtyControllers[i] ??=
                                              TextEditingController();
                                          shippedQtyControllers[i]!.text = '0';
                                        }
                                      }
                                    });
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const Text('Shipped Qty',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                            label: Text(
                          'Container No',
                          style: TextStyle(fontSize: 12),
                        )),
                      ],
                      rows: List<DataRow>.generate(poList.length, (index) {
                        final item = poList[index];
                        final poQty = item['PO_QUANTITY'] ?? 0;
                        final recQty = item['REC_QTY'] ?? 0;
                        final balanceQty = (poQty - recQty);

                        // Initialize controllers if they don't exist
                        shippedQtyControllers.putIfAbsent(
                            index,
                            () => TextEditingController(
                                text: (item['SHIPPED_QTY'] ?? 0).toString()));
                        containerNoControllers.putIfAbsent(
                            index,
                            () => TextEditingController(
                                text: (item['CONTAINER_NO'] ?? '').toString()));

                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color>(
                            (states) => index.isEven
                                ? Colors.white
                                : Colors.grey.shade50,
                          ),
                          cells: [
                            DataCell(Center(
                                child: Text(
                              '${index + 1}',
                              style: TextStyle(fontSize: 12),
                            ))),
                            DataCell(Text(
                              '${item['PO_NUMBER']}',
                              style: TextStyle(fontSize: 12),
                            )),
                            DataCell(Text(
                              '${item['FRANCHISE'] ?? '-'}',
                              style: TextStyle(fontSize: 12),
                            )),
                            DataCell(Text(
                              '${item['FAMILY'] ?? '-'}',
                              style: TextStyle(fontSize: 12),
                            )),
                            DataCell(Text(
                              '${item['CLASS'] ?? '-'}',
                              style: TextStyle(fontSize: 12),
                            )),
                            DataCell(Text(
                              '${item['SUBCLASS'] ?? '-'}',
                              style: TextStyle(fontSize: 12),
                            )),
                            DataCell(Text(
                              '${item['ITEM_CODE'] ?? '-'}',
                              style: TextStyle(fontSize: 12),
                            )),
                            DataCell(Center(
                                child: Text(
                              '$poQty',
                              style: TextStyle(fontSize: 12),
                            ))),
                            DataCell(Center(
                                child: Text(
                              '$recQty',
                              style: TextStyle(fontSize: 12),
                            ))),
                            DataCell(Center(
                                child: Text(
                              '$balanceQty',
                              style: TextStyle(fontSize: 12),
                            ))),
                            DataCell(
                              Container(
                                width: isMobile ? 80 : 90,
                                child: TextFormField(
                                  controller: shippedQtyControllers[index],
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,2}')),
                                  ],
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    final enteredQty =
                                        double.tryParse(value) ?? 0;
                                    if (enteredQty > balanceQty) {
                                      shippedQtyControllers[index]!.text =
                                          balanceQty.toString();
                                      shippedQtyControllers[index]!.selection =
                                          TextSelection.collapsed(
                                              offset:
                                                  shippedQtyControllers[index]!
                                                      .text
                                                      .length);
                                      _showErrorDialog(
                                          'Shipped quantity cannot exceed $balanceQty');
                                    } else {
                                      poList[index]['SHIPPED_QTY'] = enteredQty;
                                    }
                                  },
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                height: 30,
                                width: isMobile ? 100 : 120,
                                child: TypeAheadFormField<String>(
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                    controller: containerNoControllers[index],
                                    style: const TextStyle(fontSize: 12),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 8),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      hintText: 'Select Container',
                                      hintStyle: const TextStyle(fontSize: 12),
                                      suffixIcon: const Icon(
                                          Icons.arrow_drop_down,
                                          size: 20,
                                          color: Colors.grey),
                                    ),
                                  ),
                                  suggestionsCallback: (pattern) {
                                    if (_containers.isEmpty) {
                                      if (!_hasShownEmptyContainerDialog) {
                                        _hasShownEmptyContainerDialog = true;
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          _showErrorDialog(
                                              'Kindly add a container details');
                                        });
                                      }
                                      return [];
                                    } else {
                                      _hasShownEmptyContainerDialog =
                                          false; // reset if containers are available
                                    }

                                    return _containers
                                        .map((e) => e['no']?.toString() ?? '')
                                        .where((item) => item
                                            .toLowerCase()
                                            .contains(pattern.toLowerCase()))
                                        .toList();
                                  },
                                  itemBuilder: (context, suggestion) {
                                    return Container(
                                      height: 30,
                                      child: ListTile(
                                        dense: true,
                                        title: Text(
                                          suggestion,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    );
                                  },
                                  onSuggestionSelected: (suggestion) {
                                    containerNoControllers[index]!.text =
                                        suggestion;
                                    poList[index]['CONTAINER_NO'] = suggestion;
                                    setState(
                                        () {}); // Trigger rebuild if needed
                                  },
                                  noItemsFoundBuilder: (context) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('No containers found',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a container';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
      String text, IconData icon, Color color, VoidCallback onPressed,
      {bool isSmall = false}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: isSmall ? 16 : 18),
      label: Text(text, style: commonWhiteStyle),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 20,
          vertical: isSmall ? 8 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
    );
  }

  TextStyle _tableTextStyle(bool isMobile) {
    return TextStyle(fontSize: isMobile ? 10 : 12);
  }

  void _addContainer() {
    if (conatinerNoController.text.trim().isEmpty ||
        SizeControlller.text.trim().isEmpty) {
      _showErrorDialog("Kindly enter both Container No and Size.");
      return;
    }

    setState(() {
      _containers.add({
        'no': conatinerNoController.text.trim(),
        'size': SizeControlller.text.trim(),
      });
    });

    conatinerNoController.clear();
    SizeControlller.clear();
  }

  void _removeContainer(int index) {
    setState(() {
      _containers.removeAt(index);
    });
  }

  Future<void> _addProduct() async {
    final poNumber = PoNoControlller.text.trim();

    // Validate PO number input
    if (poNumber.isEmpty) {
      _showErrorDialog('Kindly enter a PO Number');
      return;
    }

    final IpAddress = await getActiveIpAddress();
    final uri = Uri.parse('$IpAddress/get_pending_po/?po_number=$poNumber');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          // Check for duplicates before adding
          final existingPoNumbers =
              poList.map((item) => item['PO_NUMBER']).toSet();

          final newItems = data
              .where((item) => !existingPoNumbers.contains(item['PO_NUMBER']))
              .map((item) => item as Map<String, dynamic>)
              .toList();

          if (newItems.isEmpty) {
            _showErrorDialog('PO $poNumber already added.');
            return;
          }

          setState(() {
            poList.addAll(newItems);
          });
        } else {
          _showErrorDialog('No data found for PO $poNumber');
        }
      } else {
        _showErrorDialog('Error fetching PO data. Please try again.');
      }
    } catch (e) {
      print("❗ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error occurred.')),
      );
    }
  }

  Future<void> _uploadExcelData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        List<int> bytes;

        if (kIsWeb) {
          if (file.bytes != null) {
            bytes = file.bytes!;
          } else {
            throw Exception('No bytes found for the selected file.');
          }
        } else {
          if (file.path != null) {
            bytes = await File(file.path!).readAsBytes();
          } else {
            throw Exception('Unable to read file contents.');
          }
        }

        // Process the Excel data
        _processExcelData(bytes);
      } else {
        throw Exception('No file selected.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing Excel: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _processExcelData(List<int> bytes) {
    try {
      var excel = Excel.decodeBytes(bytes);
      var sheet = excel.tables[excel.tables.keys.first]!;

      List<Map<String, String>> newContainers = [];

      for (var row in sheet.rows.skip(1)) {
        // Skip header row
        if (row.length >= 2) {
          newContainers.add({
            'no': row[0]?.value?.toString() ?? '',
            'size': row[1]?.value?.toString() ?? '',
          });
        } else {
          throw Exception('Row does not have enough columns.');
        }
      }

      // Update the state with new containers
      setState(() {
        _containers.clear();
        _containers.addAll(newContainers);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Successfully imported ${newContainers.length} containers'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing Excel: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveForm() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    // 🔍 Validate required TextEditingControllers
    List<String> emptyFields = [];

    if (supplierController.text.trim().isEmpty) emptyFields.add("Supplier");
    if (houseBLController.text.trim().isEmpty) emptyFields.add("House B/L");
    if (containerCountController.text.trim().isEmpty)
      emptyFields.add("Container Count");
    if (clearanceDtController.text.trim().isEmpty)
      emptyFields.add("Clearance Date");
    if (supplierNameController.text.trim().isEmpty)
      emptyFields.add("Supplier Name");
    if (supplierNoController.text.trim().isEmpty)
      emptyFields.add("Supplier No");
    if (BayanController.text.trim().isEmpty) emptyFields.add("Bayan No");
    if (BLDateController.text.trim().isEmpty) emptyFields.add("B/L Date");
    if (POLController.text.trim().isEmpty) emptyFields.add("POL");
    if (LCNoController.text.trim().isEmpty) emptyFields.add("LC No");
    if (InvoiceNo1Controller.text.trim().isEmpty)
      emptyFields.add("Invoice No 1");
    if (InvoiceNo1ValueController.text.trim().isEmpty)
      emptyFields.add("Invoice 1 Value");
    if (TermPaymentController.text.trim().isEmpty)
      emptyFields.add("Term of Payment 1");
    if (BayanDateController.text.trim().isEmpty) emptyFields.add("Bayan Date");
    if (ETDDateController.text.trim().isEmpty) emptyFields.add("ETD");
    if (PODController.text.trim().isEmpty) emptyFields.add("POD");
    if (BillNoController.text.trim().isEmpty) emptyFields.add("Bill No");
    if (InvoiceNo2Controller.text.trim().isEmpty)
      emptyFields.add("Invoice No 2");
    if (InvoiceNo2ValueController.text.trim().isEmpty)
      emptyFields.add("Invoice 2 Value");
    if (TermPayment2Controller.text.trim().isEmpty)
      emptyFields.add("Term of Payment 2");
    if (MasterBLController.text.trim().isEmpty) emptyFields.add("Master B/L");
    if (ETAController.text.trim().isEmpty) emptyFields.add("ETA");
    if (LineNameController.text.trim().isEmpty) emptyFields.add("Line Name");
    if (BillDueDateController.text.trim().isEmpty)
      emptyFields.add("Bill Due Date");
    if (InvoiceNo3Controller.text.trim().isEmpty)
      emptyFields.add("Invoice No 3");
    if (InvoiceNo3ValueController.text.trim().isEmpty)
      emptyFields.add("Invoice 3 Value");
    if (TermPayment3Controller.text.trim().isEmpty)
      emptyFields.add("Term of Payment 3");

    if (emptyFields.isNotEmpty) {
      _showErrorDialog("Kindly fill all required fields");
      return;
    }
    // 📦 Validate container list
    if (_containers.isEmpty) {
      _showErrorDialog('Kindly add container details.');
      return;
    }

    // 🛒 Validate product list
    if (poList.isEmpty) {
      _showErrorDialog('Kindly add at least one product.');
      return;
    }

    // 📏 Validate SHIPPED_QTY
    for (var item in poList) {
      if ((item['SHIPPED_QTY'] ?? 0).toDouble() <= 0) {
        _showErrorDialog('One or more products have SHIPPED QTY as 0.');
        return;
      }
    }

    // ✅ All validations passed
    bool shouldClear = await _showSuccessDialog(); // Wait for user confirmation

    if (shouldClear) {
      await saveInboundShipment();
      await saveInboundContainers();
      await saveProductData();

      // 🧹 Clear data after save
      _clearForm();
    }
  }

  String token = '';

  Future<void> fetchTokenwithCusid() async {
    final IpAddress = await getActiveIpAddress();

    try {
      // Send a GET request to fetch the REQ_ID and token from the server
      final response = await http.get(
        Uri.parse('$IpAddress/DocNo_generate-token/'),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // Get full REQ_ID string like "REQ_25_04_4"
        String DOC_NO = data['DOC_NO']?.toString() ?? '';
        token = data['TOKEN'] ?? 'No Token found'; // correct key spelling

        setState(() {
          // You can set any state variables if needed
        });

        print('DOC_NO: $DOC_NO  token: $token');

        // Save to shared preferences
        // await saveToSharedPreferences(reqID, token);
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _clearForm() async {
    // Clear controllers and lists
    _containers.clear();
    poList.clear();
    PoNoControlller.clear();
    conatinerNoController.clear();
    SizeControlller.clear();
    supplierController.clear();
    houseBLController.clear();
    containerCountController.clear();
    clearanceDtController.clear();
    supplierNameController.clear();
    supplierNoController.clear();
    BayanController.clear();
    BLDateController.clear();
    POLController.clear();
    LCNoController.clear();
    InvoiceNo1Controller.clear();
    InvoiceNo1ValueController.clear();
    TermPaymentController.clear();
    BayanDateController.clear();
    ETDDateController.clear();
    PODController.clear();
    BillNoController.clear();
    InvoiceNo2Controller.clear();
    InvoiceNo2ValueController.clear();
    TermPayment2Controller.clear();
    MasterBLController.clear();
    ETAController.clear();
    LineNameController.clear();
    BillDueDateController.clear();
    InvoiceNo3Controller.clear();
    InvoiceNo3ValueController.clear();
    TermPayment3Controller.clear();

    // Reset INCOTerms values
    _INCOTermsValue1 = null;
    _INCOTermsValue2 = null;
    _INCOTermsValue3 = null;

    // Call setState to rebuild the UI
    setState(() {});
  }

  Future<void> saveInboundShipment() async {
    // Correctly initialized map using {}
    Map<String, dynamic> shipmentData = {
      "DOC_NO": docNo,
      "SUPPLIER": supplierController.text,
      "HOUSE_BL": houseBLController.text,
      "CONTAINER_COUNT": 1,
      "CLEARANCE_DATE": clearanceDtController.text,
      "SUPPLIER_NAME": supplierNameController.text,
      "SUPPLIER_NO": supplierNoController.text,
      "BL_DATE": BLDateController.text,
      "LC_NO": LCNoController.text,
      "BAYAN_DATE": BayanDateController.text,
      "ETD_DATE": ETDDateController.text,
      "POD": PODController.text,
      "POL": POLController.text,
      "BILL_NO": BillNoController.text,
      "MASTER_BL": MasterBLController.text,
      "ETA_DATE": ETAController.text,
      "LINE_NAME": LineNameController.text,
      "BILL_DUE_DATE": BillDueDateController.text,
      "INVOICE_NO1": InvoiceNo1Controller.text,
      "INVOICE_NO2": InvoiceNo2Controller.text,
      "INVOICE_NO3": InvoiceNo3Controller.text,
      "INVOICE_1VALUE": InvoiceNo1ValueController.text,
      "INVOICE_2VALUE": InvoiceNo2ValueController.text,
      "INVOICE_3VALUE": InvoiceNo3ValueController.text,
      "TERM_1PAYMENT": TermPaymentController.text,
      "TERM_2PAYMENT": TermPayment2Controller.text,
      "TERM_3PAYMENT": TermPayment3Controller.text,
      "INCOTERM1": _INCOTermsValue1,
      "INCOTERM2": _INCOTermsValue2,
      "INCOTERM3": _INCOTermsValue3
    };

    final IpAddress = await getActiveIpAddress();
    // Replace with your actual Django backend URL
    final url = Uri.parse('$IpAddress/save_shipment/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(shipmentData),
      );

      print(json.encode(shipmentData));

      if (response.statusCode == 200) {
        print('✅ Shipment saved successfully.');
      } else {
        print('❌ Failed to save shipment. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❗ Exception occurred while saving shipment: $e');
    }
  }

  Future<void> saveInboundContainers() async {
    if (_containers.isEmpty) {
      print('❌ No containers to save.');
      return;
    }

    final IpAddress = await getActiveIpAddress();
    final url = Uri.parse('$IpAddress/save_container_Info/');

    try {
      for (var container in _containers) {
        Map<String, dynamic> containerData = {
          "DOC_NO": docNo,
          "CONTAINER_NO": container['no'],
          "SIZE": container['size'],
        };

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(containerData),
        );

        print("📦 Sending containerData: ${json.encode(containerData)}");

        if (response.statusCode == 200) {
          print('✅ Container ${container['no']} saved successfully.');
        } else {
          print(
              '❌ Failed to save container ${container['no']}. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('❗ Exception occurred while saving containers: $e');
    }
  }

  Future<void> saveProductData() async {
    final IpAddress = await getActiveIpAddress();
    final url = Uri.parse('$IpAddress/save_product_info/');

    List<Map<String, dynamic>> productList = [];

    for (var item in poList) {
      final poQty = (item['PO_QUANTITY'] ?? 0).toDouble();
      final recQty = (item['REC_QTY'] ?? 0).toDouble();
      final balanceQty = poQty - recQty;

      Map<String, dynamic> productData = {
        "DOC_NO": docNo, // Make sure docNo is set properly
        "PO_NUMBER": item['PO_NUMBER'] ?? "",
        "FRANCHISE": item['FRANCHISE'] ?? "",
        "FAMILY": item['FAMILY'] ?? "",
        "CLASS": item['CLASS'] ?? "",
        "SUBCLASS": item['SUBCLASS'] ?? "",
        "ITEM_CODE": item['ITEM_CODE'] ?? "",
        "PO_QTY": poQty,
        "REC_QTY": recQty,
        "BALANCE_QTY": balanceQty,
        "SHIPPED_QTY":
            (item['SHIPPED_QTY'] ?? 0).toDouble(), // Use updated value
        "CONTAINER_NO": item['CONTAINER_NO']?.toString() ??
            "", // Use updated value or empty string
      };

      productList.add(productData);
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(productList),
      );

      if (response.statusCode == 201) {
        print('✅ Product info saved successfully.');
      } else {
        print('❌ Failed to save product info: ${response.body}');
      }
    } catch (e) {
      print('❗ Exception occurred while saving product info: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.yellow,
            ),
            Text(
              'Warning',
              style: textStyle,
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  Future<bool> _showSuccessDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.check_circle_rounded, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'Successfully Saved',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    docNo,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 68, 67, 67),
                    ),
                  ),
                ],
              ),
              content: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Inbound Sent Successfully !!',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    await fetchTokenwithCusid();
                    await fetchLastDocNo();

                    Navigator.of(ctx)
                        .pop(true); // Return true when OK is pressed
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    backgroundColor: subcolor,
                    minimumSize: const Size(30.0, 28.0),
                  ),
                  child: const Text(
                    'Ok',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed without pressing OK
  }
}
