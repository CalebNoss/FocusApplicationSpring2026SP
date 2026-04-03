import 'package:flutter/material.dart';

class TeamMember {
  final String name;
  final String role;
  final List<String> contributions;

  const TeamMember({
    required this.name,
    required this.role,
    required this.contributions,
  });
}

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const members = [
      TeamMember(
        name: 'Caleb Noss',
        role: 'Role / focus area',
        contributions: [
          'Add here.',
          'Add second like this.',
        ],
      ),
      TeamMember(
        name: 'Esha Patel',
        role: 'Role / focus area',
        contributions: ['Add here.'],
      ),
      TeamMember(
        name: 'Imaan Edhi',
        role: 'Role / focus area',
        contributions: ['Add here.'],
      ),
      TeamMember(
        name: 'Mert Dayi',
        role: 'Role / focus area',
        contributions: ['Add here.'],
      ),
      TeamMember(
        name: 'Siri Dubbaka',
        role: 'Role / focus area',
        contributions: ['Add here.'],
      ),
    ];

    return DefaultTabController(
      length: members.length,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Project Team', style: TextStyle(color: Colors.white)),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: members.map((member) => Tab(text: member.name)).toList(),
          ),
        ),
        body: TabBarView(
          children: members
              .map(
                (member) => _TeamMemberTab(member: member),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _TeamMemberTab extends StatelessWidget {
  final TeamMember member;

  const _TeamMemberTab({required this.member});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.white),
                title: Text(member.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  member.role,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ...List.generate(member.contributions.length, (index) {
                final contribution = member.contributions[index];
                return Column(
                  children: [
                    const Divider(height: 1, color: Colors.white12),
                    ListTile(
                      leading: const Icon(Icons.check_circle_outline, color: Colors.white70),
                      title: Text(
                        'Contribution ${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        contribution,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
