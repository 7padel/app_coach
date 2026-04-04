import 'package:flutter/material.dart';
import '../core/base/base_view.dart';
import '../core/constants/app_colors.dart';
import '../widgets/confirmation_dialog.dart';
import '../core/utils/date_utils.dart';
import '../models/coach_time_off_model.dart';
import '../viewmodels/time_off_view_model.dart';

class TimeOffsPage extends StatelessWidget {
  const TimeOffsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<TimeOffViewModel>(
      model: TimeOffViewModel(),
      onModelReady: (vm) => vm.loadTimeOffs(context),
      builder: (context, vm, _) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('Time-offs',
              style: TextStyle(fontWeight: FontWeight.w600)),
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          onPressed: () => _showAddDialog(context, vm),
          child: const Icon(Icons.add),
        ),
        body: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => vm.loadTimeOffs(context),
                child: vm.timeOffs.isEmpty
                    ? _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: vm.timeOffs.length,
                        itemBuilder: (context, i) =>
                            _TimeOffCard(
                              timeOff: vm.timeOffs[i],
                              onDelete: () => _confirmDelete(
                                  context, vm, vm.timeOffs[i]),
                            ),
                      ),
              ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, TimeOffViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddTimeOffSheet(vm: vm),
    );
  }

  void _confirmDelete(
      BuildContext context, TimeOffViewModel vm, CoachTimeOffModel t) {
    showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        icon: Icons.event_busy,
        message: 'Remove time-off for ${t.date}?',
        confirmText: 'Remove',
        cancelText: 'Cancel',
        onConfirm: () {
          Navigator.pop(context);
          vm.deleteTimeOff(context, t.id);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}

class _TimeOffCard extends StatelessWidget {
  final CoachTimeOffModel timeOff;
  final VoidCallback onDelete;
  const _TimeOffCard({required this.timeOff, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final hasTime = timeOff.startTime != null;
    final dateParts = timeOff.date.split('-');
    final day = dateParts.length >= 3 ? dateParts[2] : '';
    final month = dateParts.length >= 2 ? _monthShort(int.tryParse(dateParts[1]) ?? 1) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          // Date badge
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF2C4120),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Text(day, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(month, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFCDDE85))),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasTime ? 'Partial Day Off' : 'Full Day Off',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 4),
                  if (hasTime)
                    Row(
                      children: [
                        const Icon(Icons.access_time_outlined, size: 14, color: Color(0xFF6B7280)),
                        const SizedBox(width: 4),
                        Text(
                          DateHelper.prettyTimeRange(timeOff.startTime, timeOff.endTime),
                          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  if (!hasTime)
                    const Text('All day', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  if (timeOff.reason != null && timeOff.reason!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(timeOff.reason!, style: const TextStyle(fontSize: 12, color: Colors.black45, fontStyle: FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
          ),
          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  static String _monthShort(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[(m - 1).clamp(0, 11)];
  }
}

class _AddTimeOffSheet extends StatefulWidget {
  final TimeOffViewModel vm;
  const _AddTimeOffSheet({required this.vm});

  @override
  State<_AddTimeOffSheet> createState() => _AddTimeOffSheetState();
}

class _AddTimeOffSheetState extends State<_AddTimeOffSheet> {
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  String _fmt(TimeOfDay t) {
    final h = t.hour;
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${h12.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $period';
  }

  void _showTimeSlotPicker(BuildContext context, {required bool isStart}) {
    // Generate 30-min interval slots from 6 AM to 11 PM
    final slots = <TimeOfDay>[];
    for (int h = 6; h <= 23; h++) {
      slots.add(TimeOfDay(hour: h, minute: 0));
      if (h < 23) slots.add(TimeOfDay(hour: h, minute: 30));
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Text(
              isStart ? 'Select Start Time' : 'Select End Time',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: slots.length,
                itemBuilder: (context, index) {
                  final slot = slots[index];
                  final isSelected = isStart
                      ? (_startTime?.hour == slot.hour && _startTime?.minute == slot.minute)
                      : (_endTime?.hour == slot.hour && _endTime?.minute == slot.minute);
                  return ListTile(
                    title: Text(
                      _fmt(slot),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected ? const Color(0xFF1D3916) : Colors.black87,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF1D3916)) : null,
                    onTap: () {
                      setState(() {
                        if (isStart) _startTime = slot; else _endTime = slot;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_date == null) return;
    final dateStr =
        '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}';
    final ok = await widget.vm.createTimeOff(
      context,
      date: dateStr,
      startTime: _startTime != null ? _fmt(_startTime!) : null,
      endTime: _endTime != null ? _fmt(_endTime!) : null,
      reason: _reasonCtrl.text.trim().isEmpty ? null : _reasonCtrl.text.trim(),
    );
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Time-off',
              style:
                  TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          // Date picker
          GestureDetector(
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (d != null) setState(() => _date = d);
            },
            child: _PickerTile(
              icon: Icons.calendar_today_outlined,
              label: _date != null
                  ? '${_date!.day}/${_date!.month}/${_date!.year}'
                  : 'Select date *',
              selected: _date != null,
            ),
          ),
          const SizedBox(height: 10),
          // Start time — dropdown with 30-min intervals
          GestureDetector(
            onTap: () => _showTimeSlotPicker(context, isStart: true),
            child: _PickerTile(
              icon: Icons.access_time_outlined,
              label: _startTime != null
                  ? 'Start: ${_fmt(_startTime!)}'
                  : 'Start time (optional)',
              selected: _startTime != null,
            ),
          ),
          const SizedBox(height: 10),
          // End time — dropdown with 30-min intervals
          GestureDetector(
            onTap: () => _showTimeSlotPicker(context, isStart: false),
            child: _PickerTile(
              icon: Icons.access_time_filled,
              label: _endTime != null
                  ? 'End: ${_fmt(_endTime!)}'
                  : 'End time (optional)',
              selected: _endTime != null,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _reasonCtrl,
            decoration: InputDecoration(
              hintText: 'Reason (optional)',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_date == null || widget.vm.submitting)
                  ? null
                  : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: widget.vm.submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Add Time-off',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  const _PickerTile(
      {required this.icon, required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: selected ? AppColors.primary : Colors.black45),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  color: selected ? Colors.black87 : Colors.black45)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        const Icon(Icons.event_available_outlined,
            size: 64, color: Colors.black26),
        const SizedBox(height: 16),
        const Center(
          child: Text('No time-offs added',
              style: TextStyle(fontSize: 16, color: Colors.black45)),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text('Tap + to block time off',
              style: TextStyle(fontSize: 13, color: Colors.black38)),
        ),
      ],
    );
  }
}
