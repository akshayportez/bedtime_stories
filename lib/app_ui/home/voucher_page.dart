part of 'package:bedtime_stories/utils/lib_files.dart';

class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  late final BedtimePaymentVoucherBloc _voucherBloc;
  bool _isRouteObserverSubscribed = false;
  int _projectId = 0;
  int _userActionId = 0;
  String _payModeFilter = "";
  String _dFrom = "";
  String _dTo = "";

  int _resolveInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? "") ?? fallback;
  }

  @override
  void initState() {
    super.initState();
    _voucherBloc = BedtimePaymentVoucherBloc(
      context.read<BedtimePaymentVoucherBloc>().repository,
    );
    _loadVouchers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isRouteObserverSubscribed) return;
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      routeObserver.subscribe(this, modalRoute as ModalRoute<void>);
      _isRouteObserverSubscribed = true;
    }
  }

  @override
  void didPopNext() {
    _loadVouchers();
  }

  @override
  void dispose() {
    if (_isRouteObserverSubscribed) {
      routeObserver.unsubscribe(this);
    }
    _voucherBloc.close();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVouchers() async {
    final projectId = await BedtimeLocalStorage.getSelectedProjectId();
    final userData = await BedtimeLocalStorage.getUserData();
    final userIdValue = userData["userId"];
    _projectId = projectId;
    _userActionId = userIdValue is int
        ? userIdValue
        : int.tryParse(userIdValue?.toString() ?? "") ?? 0;

    if (!mounted) return;

    _voucherBloc.add(
      BedtimePaymentVoucherLoadRequested(
        companyId: 1,
        projectId: projectId,
        userActionId: _userActionId,
        search: "",
        statusFilter: _payModeFilter,
        dFrom: _dFrom,
        dTo: _dTo,
      ),
    );
  }

  Future<void> _openProjectSelectionSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ProjectSelectionBottomSheet(
          onProjectSelected: () async {
            if (!mounted) return;
            setState(() {});
            await _loadVouchers();
          },
        );
      },
    );
  }

  void _onSearchChanged(String value) {
    if (_userActionId == 0) {
      BedtimeLocalStorage.getUserData().then((userData) {
        if (!mounted) return;
        final userIdValue = userData["userId"];
        final resolvedUserId = userIdValue is int
            ? userIdValue
            : int.tryParse(userIdValue?.toString() ?? "") ?? 0;
        _userActionId = resolvedUserId;
        _voucherBloc.add(
          BedtimePaymentVoucherSearchRequested(
            companyId: 1,
            projectId: _projectId,
            userActionId: _userActionId,
            search: value.trim(),
            statusFilter: _payModeFilter,
            dFrom: _dFrom,
            dTo: _dTo,
          ),
        );
      });
      return;
    }

    _voucherBloc.add(
      BedtimePaymentVoucherSearchRequested(
        companyId: 1,
        projectId: _projectId,
        userActionId: _userActionId,
        search: value.trim(),
        statusFilter: _payModeFilter,
        dFrom: _dFrom,
        dTo: _dTo,
      ),
    );
  }

  Future<void> _reloadAfterVoucherChange() async {
    await _loadVouchers();

    final projectId = _projectId > 0
        ? _projectId
        : await BedtimeLocalStorage.getSelectedProjectId();
    final userActionId = _userActionId > 0
        ? _userActionId
        : _resolveInt((await BedtimeLocalStorage.getUserData())["userId"]);

    if (!mounted) return;
    context.read<BedtimePaymentRequestBloc>().add(
      BedtimePaymentRequestLoadRequested(
        companyId: 1,
        projectId: projectId,
        userActionId: userActionId,
        search: "",
        statusFilter: "",
        dFrom: "",
        dTo: "",
      ),
    );
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, "0");
    final m = date.month.toString().padLeft(2, "0");
    final d = date.day.toString().padLeft(2, "0");
    return "$y-$m-$d";
  }

  String _selectedDateRangeText() {
    if (_dFrom.isEmpty && _dTo.isEmpty) return "";
    if (_dFrom.isNotEmpty && _dTo.isNotEmpty) {
      return "Date: $_dFrom - $_dTo";
    }
    return "Date: ${_dFrom.isNotEmpty ? _dFrom : _dTo}";
  }

  Future<void> _openFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _VoucherFilterBottomSheet(
          initialPayMode: _payModeFilter,
          initialFromDate: _dFrom.isEmpty ? null : DateTime.tryParse(_dFrom),
          initialToDate: _dTo.isEmpty ? null : DateTime.tryParse(_dTo),
          onApply: (fromDate, toDate, payMode) async {
            _payModeFilter = payMode;
            if (fromDate == null && toDate == null) {
              _dFrom = "";
              _dTo = "";
            } else {
              _dFrom = fromDate == null ? "" : _formatDate(fromDate);
              _dTo = toDate == null ? "" : _formatDate(toDate);
            }
            if (mounted) setState(() {});
            await _loadVouchers();
          },
        );
      },
    );
  }

  bool _isPaid(String status) => status.trim().toLowerCase() == "paid";

  String _formatAmount(double amount) => amount.toStringAsFixed(2);

  BedtimePaymentRequest _toPaymentRequest(BedtimePaymentVoucher voucher) {
    return BedtimePaymentRequest(
      nPayReqId: voucher.nPayReqId,
      cRequestNo: voucher.cRequestNo,
      cVoucherNo: voucher.cVoucherNo,
      dRequestDateTime: voucher.dRequestDateTime,
      cRequestDateTime: voucher.cRequestDateTime,
      nRequestedBy: voucher.nRequestedBy,
      cRequestedBy: voucher.cRequestedBy,
      dRejectedDateTime: voucher.dRejectedDateTime,
      cRejectedDateTime: voucher.cRejectedDateTime,
      cRejectedBy: voucher.cRejectedBy,
      dApprovedDateTime: voucher.dApprovedDate,
      cApprovedDateTime: voucher.cApprovedDate,
      cApprovedBy: voucher.cApprovedBy,
      dVoucherDateTime: voucher.dVoucherDate,
      cVoucherDateTime: voucher.cVoucherDate,
      cPaidBy: voucher.cPaidBy,
      nAccountId: 0,
      cAccountName: voucher.cAccountName,
      nCategoryId: 0,
      cCategoryName: voucher.cCategoryName,
      nSectionId: 0,
      cSectionName: voucher.cSectionName,
      nPayableAmount: voucher.nPayableAmount,
      cStatus: voucher.cStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateRangeText = _selectedDateRangeText();

    return Scaffold(
      appBar: BedtimeGradientAppBar(onProjectTap: _openProjectSelectionSheet),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              "Voucher",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _RequestSearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: _openFilterSheet,
                    child: Center(
                      child: Image.asset(
                        "assets/icons/filter.png",
                        width: 18,
                        height: 18,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (selectedDateRangeText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  selectedDateRangeText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Expanded(
              child: BlocBuilder<
                BedtimePaymentVoucherBloc,
                BedtimePaymentVoucherState
              >(
                bloc: _voucherBloc,
                builder: (context, state) {
                  if (state is BedtimePaymentVoucherLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is BedtimePaymentVoucherFailure) {
                    return Center(child: Text(state.message));
                  }

                  if (state is BedtimePaymentVoucherLoaded) {
                    final vouchers =
                        state.vouchers.where((v) => _isPaid(v.cStatus)).toList();
                    if (vouchers.isEmpty) {
                      return const Center(child: Text("No vouchers found"));
                    }

                    final bottomInset = MediaQuery.of(context).padding.bottom;
                    return ListView.builder(
                      padding: EdgeInsets.only(bottom: 16 + bottomInset + 96),
                      itemCount: vouchers.length,
                      itemBuilder: (context, index) {
                        final voucher = vouchers[index];
                        final request = _toPaymentRequest(voucher);
                        return _VoucherCard(
                          request: request,
                          voucherNo: voucher.cVoucherNo.isEmpty
                              ? voucher.cRequestNo
                              : voucher.cVoucherNo,
                          dateTime: voucher.cVoucherDate.isNotEmpty
                              ? voucher.cVoucherDate
                              : (voucher.cRequestDateTime ?? ""),
                          name: voucher.cAccountName,
                          category: voucher.cCategoryName,
                          section: voucher.cSectionName,
                          amount: _formatAmount(voucher.nPayableAmount),
                          payMode: voucher.cPaymode,
                          onRefresh: _reloadAfterVoucherChange,
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  final BedtimePaymentRequest request;
  final String voucherNo;
  final String dateTime;
  final String name;
  final String category;
  final String section;
  final String amount;
  final String payMode;
  final Future<void> Function()? onRefresh;

  const _VoucherCard({
    required this.request,
    required this.voucherNo,
    required this.dateTime,
    required this.name,
    required this.category,
    required this.section,
    required this.amount,
    required this.payMode,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final shouldReload = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => VoucherViewPage(request: request),
          ),
        );
        if (shouldReload == true && onRefresh != null) {
          await onRefresh!();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFCADDF4)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Vou No : $voucherNo",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateTime,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF3B3B3B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(height: 2, color: const Color(0xFFF3F7FC)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: const Color(0xFFEAF2FF),
                        child: Text(
                          name.isNotEmpty ? name[0] : "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        "Category",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2C2C2C),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        " : $category",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7F7F7F),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Text(
                        "Section",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2C2C2C),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        " : $section",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7F7F7F),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F9FC),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(9),
                  bottomRight: Radius.circular(9),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/icons/payment_animation.gif",
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "Payable Amt : ",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7F7F7F),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "\u20B9$amount",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF256DFB),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 30,
                    constraints: const BoxConstraints(minWidth: 84, maxWidth: 108),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC7D5F4),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      payMode.trim().isEmpty ? "-" : payMode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4A4A4A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherFilterBottomSheet extends StatefulWidget {
  final String initialPayMode;
  final DateTime? initialFromDate;
  final DateTime? initialToDate;
  final void Function(DateTime? fromDate, DateTime? toDate, String payMode)
      onApply;

  const _VoucherFilterBottomSheet({
    required this.initialPayMode,
    required this.initialFromDate,
    required this.initialToDate,
    required this.onApply,
  });

  @override
  State<_VoucherFilterBottomSheet> createState() =>
      _VoucherFilterBottomSheetState();
}

class _VoucherFilterBottomSheetState extends State<_VoucherFilterBottomSheet> {
  DateTime? _fromDate;
  DateTime? _toDate;
  DateTime _activeDate = DateTime.now();
  String _selectedPayMode = "";

  @override
  void initState() {
    super.initState();
    _fromDate = widget.initialFromDate;
    _toDate = widget.initialToDate;
    _activeDate = widget.initialToDate ?? widget.initialFromDate ?? DateTime.now();
    _selectedPayMode = widget.initialPayMode;
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, "0");
    final m = date.month.toString().padLeft(2, "0");
    final d = date.day.toString().padLeft(2, "0");
    return "$y-$m-$d";
  }

  void _onCalendarDateChanged(DateTime date) {
    setState(() {
      _activeDate = date;
      if (_fromDate == null || _toDate != null) {
        _fromDate = date;
        _toDate = null;
        return;
      }

      if (date.isBefore(_fromDate!)) {
        _toDate = _fromDate;
        _fromDate = date;
      } else {
        _toDate = date;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return FractionallySizedBox(
      heightFactor: 0.82,
      child: Container(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 12,
          bottom: 16 + bottomPadding,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    "Filter",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEAEAEA)),
                        ),
                        child: CalendarDatePicker(
                          initialDate: _activeDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          onDateChanged: _onCalendarDateChanged,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "From: ${_fromDate == null ? '-' : _formatDate(_fromDate!)}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4C4C4C),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "To: ${_toDate == null ? '-' : _formatDate(_toDate!)}",
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4C4C4C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _fromDate = null;
                              _toDate = null;
                            });
                          },
                          child: const Text("Clear range"),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 6),
                      _VoucherFilterRadioRow(
                        label: "All",
                        value: "",
                        groupValue: _selectedPayMode,
                        onChanged: (value) {
                          setState(() => _selectedPayMode = value);
                        },
                      ),
                      _VoucherFilterRadioRow(
                        label: "Cash",
                        value: "cash",
                        groupValue: _selectedPayMode,
                        onChanged: (value) {
                          setState(() => _selectedPayMode = value);
                        },
                      ),
                      _VoucherFilterRadioRow(
                        label: "Bank",
                        value: "bank",
                        groupValue: _selectedPayMode,
                        onChanged: (value) {
                          setState(() => _selectedPayMode = value);
                        },
                      ),
                      _VoucherFilterRadioRow(
                        label: "Cheque",
                        value: "cheque",
                        groupValue: _selectedPayMode,
                        onChanged: (value) {
                          setState(() => _selectedPayMode = value);
                        },
                      ),
                      _VoucherFilterRadioRow(
                        label: "UPI",
                        value: "upi",
                        groupValue: _selectedPayMode,
                        onChanged: (value) {
                          setState(() => _selectedPayMode = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 80,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B84F3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      final effectiveToDate = _toDate ?? _fromDate;
                      widget.onApply(_fromDate, effectiveToDate, _selectedPayMode);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoucherFilterRadioRow extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _VoucherFilterRadioRow({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: groupValue,
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
