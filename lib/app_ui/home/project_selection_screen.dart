part of 'package:bedtime_stories/utils/lib_files.dart';

class ProjectSelectionScreen extends StatefulWidget {
  const ProjectSelectionScreen({super.key});

  @override
  State<ProjectSelectionScreen> createState() => _ProjectSelectionScreenState();
}

class _ProjectSelectionScreenState extends State<ProjectSelectionScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<String> projects = [];
  @override
  void initState() {
    super.initState();

    context.read<BedtimeProjectBloc>().add(
      BedtimeProjectLoadRequested(companyId: 1, userId: 1),
    );
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
              _SearchBar(controller: searchController),

              const SizedBox(height: 18),

              /// Project List
              Expanded(
                child: BlocBuilder<BedtimeProjectBloc, BedtimeProjectState>(
                  builder: (context, state) {
                    if (state is BedtimeProjectLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is BedtimeProjectFailure) {
                      return Center(child: Text(state.message));
                    }

                    if (state is BedtimeProjectLoaded) {
                      return ListView.builder(
                        itemCount: state.projects.length,
                        itemBuilder: (context, index) {
                          return _ProjectTile(
                            title: state.projects[index].cProjectName,

                            onTap: () async {
                              final project = state.projects[index];

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

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: TextFormField(
        onChanged: (value) {
          context.read<BedtimeProjectBloc>().add(
            BedtimeProjectSearchRequested(
              companyId: 1,
              userId: 1,
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
