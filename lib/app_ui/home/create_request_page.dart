part of 'package:bedtime_stories/utils/lib_files.dart';

class CreateRequestPage extends StatefulWidget {
  const CreateRequestPage({super.key});

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  static const double _taxHeaderHeight = 30;
  static const double _taxRowHeight = 34;

  bool isTdsChecked = true;
  bool isTaxableChecked = true;

  final List<String> taxOptions = ["CGST", "SGST", "GST", "IGST"];
  final Map<String, String> taxRates = {
    "CGST": "10",
    "SGST": "10",
    "GST": "18",
    "IGST": "18",
  };
  List<Map<String, String>> taxList = [
    {"name": "CGST", "rate": "10"},
  ];

  void _onTaxNameChanged(int index, String? selectedTax) {
    if (selectedTax == null) return;
    setState(() {
      taxList[index]["name"] = selectedTax;
      taxList[index]["rate"] = taxRates[selectedTax] ?? "";
    });
  }

  void _addTaxRow() {
    setState(() {
      final defaultTax = taxOptions.first;
      taxList.add({"name": defaultTax, "rate": taxRates[defaultTax] ?? ""});
    });
  }

  void _removeTaxRow(int index) {
    setState(() {
      taxList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Request",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: const Icon(Icons.arrow_back_ios, size: 18,color: Colors.black,),
       
      ),

      /// Body Scroll
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 170),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Dropdown Fields
            _dropdownField("Account", suffixText: "+ Add New Account"),
            const SizedBox(height: 12),
            _dropdownField("Category"),
            const SizedBox(height: 12),
            _dropdownField("Section"),

            const SizedBox(height: 16),

            /// Requested Amount + TDS
            const Text("Requested Amount", style: TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 140, child: _inputBox(hint: "")),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _CreateRequestBlueCheckBox(isChecked: isTdsChecked),
                        const SizedBox(width: 6),
                        const Text(
                          "TDS",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                         const SizedBox(width: 16),
                         SizedBox(width: 70, child: _inputBox(hint: "%")),
                      ],
                    ),
                    const SizedBox(height: 6),
                   
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// Taxable Checkbox
            GestureDetector(
              onTap: () {
                setState(() => isTaxableChecked = !isTaxableChecked);
              },
              child: Row(
                children: [
                  _CreateRequestBlueCheckBox(isChecked: isTaxableChecked),
                  const SizedBox(width: 6),
                  const Text("Taxable", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),

            /// Tax Table
            if (isTaxableChecked) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF98D5F9)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: _taxHeaderHeight,
                            color: const Color(0xFFBBE3FA),
                            child: Row(
                              children: const [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      "Tax Name",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                  color: Color(0xFF98D5F9),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      "Tax Rate %",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...taxList.asMap().entries.map((entry) {
                            final int index = entry.key;
                            final Map<String, String> tax = entry.value;

                            return Container(
                              height: _taxRowHeight,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Color(0xFF98D5F9)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: tax["name"],
                                          isExpanded: true,
                                          icon: const Icon(
                                            Icons.chevron_right,
                                            size: 16,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                          items: taxOptions
                                              .map(
                                                (taxName) => DropdownMenuItem(
                                                  value: taxName,
                                                  child: Text(taxName),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (val) =>
                                              _onTaxNameChanged(index, val),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const VerticalDivider(
                                    width: 1,
                                    thickness: 1,
                                    color: Color(0xFF98D5F9),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        "${tax["rate"] ?? ""} %",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    children: [
                      const SizedBox(height: _taxHeaderHeight + 1),
                      ...taxList.asMap().entries.map(
                        (entry) => SizedBox(
                          height: _taxRowHeight,
                          child: Row(
                            children: [
                              Center(
                                child: GestureDetector(
                                  onTap: () => _removeTaxRow(entry.key),
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF4040),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (entry.key == taxList.length - 1)
                                Center(
                                  child: GestureDetector(
                                    onTap: _addTaxRow,
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: const Icon(Icons.add, size: 14),
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(width: 22),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),

            /// Comment Box
            const Text("Comment", style: TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCCDDEB)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const TextField(
                maxLines: null,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  filled: false,
                ),
              ),
            ),

            const SizedBox(height: 14),

            /// Upload Box
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFB8A7FF)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    color: Color(0xFF7A5CF5),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Choose files",
                    style: TextStyle(color: Color(0xFF7A5CF5)),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "(JPEG, PNG, format, up to 50MB)",
                    style: TextStyle(fontSize: 10, color: Color(0xFF6F6F6F)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _smallButton("Camera"),
                      const SizedBox(width: 8),
                      _smallButton("Gallery"),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),

      bottomNavigationBar: _CreateRequestSummaryBar(
        requestedAmount: "₹0.00",
        tds: "₹0.00",
        tax: "₹0.00",
        payable: "₹0.00",
        onSave: () {},
      ),
    );
  }

  /// Dropdown Style Field
  Widget _dropdownField(String label, {String suffixText = ""}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            const Spacer(),
            if (suffixText.isNotEmpty)
              Text(
                suffixText,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF2E7CF6),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCDDEB)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: const [
              Expanded(child: Text("")),
              Icon(Icons.chevron_right, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  /// Input Box
  Widget _inputBox({
    required String hint,
    String initialValue = "",
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCDDEB)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
        controller: TextEditingController(text: initialValue),
        onChanged: onChanged,
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        minLines: null,
        maxLines: null,
        expands: true,
        decoration: InputDecoration.collapsed(
          hintText: hint,
          border: InputBorder.none,
        ).copyWith(
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }

  /// Small Upload Buttons
  Widget _smallButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF25008C),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}

class _CreateRequestBlueCheckBox extends StatelessWidget {
  final bool isChecked;

  const _CreateRequestBlueCheckBox({required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: isChecked ? const Color(0xFF0096FB) : Colors.white,
        border: Border.all(color: const Color(0xFF0096FB)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: isChecked
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : null,
    );
  }
}

class _CreateRequestSummaryBar extends StatelessWidget {
  final String requestedAmount;
  final String tds;
  final String tax;
  final String payable;
  final VoidCallback onSave;

  const _CreateRequestSummaryBar({
    required this.requestedAmount,
    required this.tds,
    required this.tax,
    required this.payable,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F616161),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CreateRequestSummaryRow(
            label: "Requested Amount",
            value: requestedAmount,
          ),
          const SizedBox(height: 4),
          _CreateRequestSummaryRow(
            label: "TDS (Less)",
            value: tds,
            labelColor: const Color(0xFF00B421),
          ),
          const SizedBox(height: 4),
          _CreateRequestSummaryRow(
            label: "Tax (Add)",
            value: tax,
            labelColor: const Color(0xFFFB0000),
          ),
          const Divider(),
          _CreateRequestSummaryRow(
            label: "Payable Amount",
            value: payable,
            isBold: true,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 90,
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onSave,
                child: const Text("Save"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateRequestSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;
  final bool isBold;

  const _CreateRequestSummaryRow({
    required this.label,
    required this.value,
    this.labelColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 13 : 12,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: labelColor ?? Colors.black,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 13 : 12,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}


