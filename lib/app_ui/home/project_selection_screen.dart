part of 'package:bedtime_stories/utils/lib_files.dart';

class ProjectSelectionScreen extends StatefulWidget {
  const ProjectSelectionScreen({super.key});

  @override
  State<ProjectSelectionScreen> createState() => _ProjectSelectionScreenState();
}

class _ProjectSelectionScreenState extends State<ProjectSelectionScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<String> projects = [];
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadProjectsForSavedUser();
  }

  Future<void> _loadProjectsForSavedUser() async {
    final userData = await BedtimeLocalStorage.getUserData();
    final storedUserId = userData["userId"];
    final userId = storedUserId is int
        ? storedUserId
        : int.tryParse(storedUserId?.toString() ?? "") ?? 1;

    if (!mounted) return;

    setState(() {
      _userId = userId;
    });

    context.read<BedtimeProjectBloc>().add(
      BedtimeProjectLoadRequested(companyId: 1, userId: userId),
    );
  }

  Future<void> _logout() async {
    await BedtimeLocalStorage.clearSession();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 40),

              /// Title
              const _PageTitle(),

              const SizedBox(height: 8),

              /// Subtitle
              const _PageSubtitle(),

              const SizedBox(height: 30),

              /// Search Bar
              _SearchBar(controller: searchController, userId: _userId),

              const SizedBox(height: 18),

              /// Project List
              Expanded(
                child: BlocBuilder<BedtimeProjectBloc, BedtimeProjectState>(
                  buildWhen: (previous, current) {
                    // Avoid flicker while typing: keep current list visible
                    // when a search triggers a transient loading state.
                    if (previous is BedtimeProjectLoaded &&
                        current is BedtimeProjectLoading) {
                      return false;
                    }
                    return true;
                  },
                  builder: (context, state) {
                    if (_userId == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is BedtimeProjectLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is BedtimeProjectFailure) {
                      return Center(child: Text(state.message));
                    }

                    if (state is BedtimeProjectLoaded) {
                      final searchText = searchController.text.trim();
                      final activeProjects = state.projects
                          .where((project) => project.bActive)
                          .toList();

                      if (activeProjects.isEmpty) {
                        if (searchText.isEmpty) {
                          return _NoProjectsAssignedState(
                            onLogoutTap: _logout,
                          );
                        }

                        return Center(
                          child: Text(
                            'No project with name "$searchText"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B6B6B),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: activeProjects.length,
                        itemBuilder: (context, index) {
                          final project = activeProjects[index];
                          return _ProjectTile(
                            title: project.cProjectName,

                            onTap: () async {

                              /// ✅ Save Selected Project
                              await BedtimeLocalStorage.saveSelectedProject(
                                projectId: project.nProjectId,
                                projectName: project.cProjectName,
                              );

                              /// ✅ Navigate to Home Screen
                              Navigator.pushReplacementNamed(context, "/homeScreen");
                            },
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
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////
/// Widgets (Same Page - Reusable Parts)
//////////////////////////////////////////////////////////////////

/// Title Widget
class _PageTitle extends StatelessWidget {
  const _PageTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      "Select Project",
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: appPrimaryColor,
      ),
    );
  }
}

/// Subtitle Widget
class _PageSubtitle extends StatelessWidget {
  const _PageSubtitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Please choose a project to continue",
      style: TextStyle(
        fontSize: 16,
        color: Color(0xFF2D2D2D),
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

/// Search Bar Widget
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final int? userId;

  const _SearchBar({required this.controller, required this.userId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: TextFormField(
        onChanged: (value) {
          final resolvedUserId = userId;
          if (resolvedUserId == null) return;

          context.read<BedtimeProjectBloc>().add(
            BedtimeProjectSearchRequested(
              companyId: 1,
              userId: resolvedUserId,
              search: value.trim(),
            ),
          );
        },

        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,

          prefixIcon: Padding(
            padding: const EdgeInsets.all(15),
            child: SvgPicture.asset(
              "assets/icons/search_icon.svg",
              width: 14,
              height: 14,
              fit: BoxFit.contain,
            ),
          ),

          hintText: "Search",
          hintStyle: const TextStyle(
            color: Color(0xFF7F7F7F),
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),

          contentPadding: const EdgeInsets.symmetric(vertical: 14),

          /// Perfect Rounded Border
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: Color(0xFFC8DFEE), width: 1),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: Color(0xFFC8DFEE), width: 1),
          ),
        ),
      ),
    );
  }
}

/// Project Tile Widget
class _ProjectTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _ProjectTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(236, 241, 251, 0.91),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFB7CBEF)),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _NoProjectsAssignedState extends StatelessWidget {
  final VoidCallback onLogoutTap;

  const _NoProjectsAssignedState({required this.onLogoutTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.move_to_inbox_rounded,
            size: 64,
            color: Color(0xFFC7CFDA),
          ),
          const SizedBox(height: 12),
          const Text(
            "No projects found.",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF777777),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            width: 100,
            child: ElevatedButton(
              onPressed: onLogoutTap,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF108DF0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
