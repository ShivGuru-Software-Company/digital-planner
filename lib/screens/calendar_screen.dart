import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/planner_provider.dart';
import '../models/entry_model.dart';
import '../widgets/glass_card.dart';
import 'entry_editor_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F7FA), Color(0xFFE0E7FF)],
        ),
      ),
      child: Column(
        children: [
          _buildCalendar(),
          Expanded(child: _buildEntriesList()),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GlassCard(
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            Provider.of<PlannerProvider>(
              context,
              listen: false,
            ).setSelectedDate(selectedDay);
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: Color(0xFFEC4899),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
          ),
          eventLoader: (day) {
            final provider = Provider.of<PlannerProvider>(
              context,
              listen: false,
            );
            return provider.getEntriesForDate(day);
          },
        ),
      ),
    );
  }

  Widget _buildEntriesList() {
    return Consumer<PlannerProvider>(
      builder: (context, provider, child) {
        final entries = provider.getEntriesForDate(_selectedDay);

        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Calendar View',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a date to view details',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Text(
                  'Future calendar features will be integrated here',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _buildEntryCard(context, entry);
          },
        );
      },
    );
  }

  Widget _buildEntryCard(BuildContext context, EntryModel entry) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EntryEditorScreen(entry: entry)),
        );
      },
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  if (entry.reminderTime != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            size: 14,
                            color: Color(0xFFEC4899),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Reminder',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFEC4899),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              if (entry.images.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: entry.images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: const Icon(Icons.image),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
