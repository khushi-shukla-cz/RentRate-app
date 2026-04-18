import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import '../models/user_model.dart';

// ─── TENANT DASHBOARD ─────────────────────────────────────────────────────────
class TenantDashboard extends StatefulWidget {
  const TenantDashboard({super.key});

  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().fetchProperties(reset: true);
      context.read<PropertyProvider>().fetchSavedProperties();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _tab,
        children: [
          _HomeTab(user: user),
          const _PropertiesTab(),
          const _SavedTab(),
          const _MessagesTab(),
          const _ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search_rounded, color: AppColors.primary), label: 'Browse'),
          NavigationDestination(icon: Icon(Icons.bookmark_outline_rounded), selectedIcon: Icon(Icons.bookmark_rounded, color: AppColors.primary), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_bubble_rounded, color: AppColors.primary), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final UserModel user;
  const _HomeTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final props = context.watch<PropertyProvider>();
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => context.read<PropertyProvider>().fetchProperties(reset: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello, ${user.name.split(' ').first}! 👋',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        const Text('Find your perfect rental', style: TextStyle(color: AppColors.textBody)),
                      ],
                    ),
                  ),
                  UserAvatar(user: user, radius: 22),
                ],
              ),
              const SizedBox(height: 20),
              // Trust Score Card
              _trustCard(user),
              const SizedBox(height: 24),
              // Stats row
              Row(
                children: [
                  _statCard('Saved', '${props.savedProperties.length}', Icons.bookmark_rounded, AppColors.primary),
                  const SizedBox(width: 12),
                  _statCard('Listings', '${props.total}', Icons.home_rounded, AppColors.trustHigh),
                  const SizedBox(width: 12),
                  _statCard('Reviews', '${user.totalReviews}', Icons.star_rounded, AppColors.rating),
                ],
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Recommended Properties',
                actionLabel: 'View All',
                onAction: () {},
              ),
              const SizedBox(height: 12),
              if (props.isLoading && props.properties.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (props.properties.isEmpty)
                const EmptyState(
                  icon: Icons.home_work_outlined,
                  title: 'No properties found',
                  subtitle: 'Check back later for new listings',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: props.properties.take(4).length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, i) {
                    final p = props.properties[i];
                    return PropertyCard(
                      property: p,
                      saved: props.isSaved(p.id),
                      onTap: () => Navigator.pushNamed(context, '/property/${p.id}'),
                      onSaveToggle: () => context.read<PropertyProvider>().toggleSave(p.id),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trustCard(UserModel user) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your Trust Score', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                user.totalReviews == 0 ? 'Not rated yet' : '${user.trustScore.toStringAsFixed(1)} / 10',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
              ),
              const SizedBox(height: 6),
              Text(
                user.totalReviews == 0
                    ? 'Get reviewed to build trust'
                    : '${user.totalReviews} reviews · ${_label(user.trustScore)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        TrustScoreBadge(score: user.trustScore, size: 56),
      ],
    ),
  );

  String _label(double s) => s >= 8 ? 'Excellent' : s >= 5 ? 'Good' : 'Needs improvement';

  Widget _statCard(String label, String value, IconData icon, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textBody)),
        ],
      ),
    ),
  );
}

class _PropertiesTab extends StatelessWidget {
  const _PropertiesTab();

  @override
  Widget build(BuildContext context) {
    return const PropertiesScreen();
  }
}

class _SavedTab extends StatelessWidget {
  const _SavedTab();

  @override
  Widget build(BuildContext context) {
    final props = context.watch<PropertyProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Properties')),
      body: props.savedProperties.isEmpty
          ? const EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'No saved properties',
              subtitle: 'Browse and save properties you like',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: props.savedProperties.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) {
                final p = props.savedProperties[i];
                return PropertyCard(
                  property: p,
                  saved: true,
                  onTap: () => Navigator.pushNamed(context, '/property/${p.id}'),
                  onSaveToggle: () => context.read<PropertyProvider>().toggleSave(p.id),
                );
              },
            ),
    );
  }
}

class _MessagesTab extends StatelessWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context) {
    return const MessagesScreen();
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}

// ─── OWNER DASHBOARD ──────────────────────────────────────────────────────────
class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().fetchMyProperties();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [
          _OwnerHomeTab(),
          _MyPropertiesTab(),
          _MessagesTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.home_work_outlined), selectedIcon: Icon(Icons.home_work_rounded, color: AppColors.primary), label: 'My Properties'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_bubble_rounded, color: AppColors.primary), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary), label: 'Profile'),
        ],
      ),
    );
  }
}

class _OwnerHomeTab extends StatelessWidget {
  const _OwnerHomeTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final props = context.watch<PropertyProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, ${user.name.split(' ').first}! 👋',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                      const Text('Manage your listings', style: TextStyle(color: AppColors.textBody)),
                    ],
                  ),
                ),
                UserAvatar(user: user, radius: 22),
              ],
            ),
            const SizedBox(height: 20),
            // Owner stats card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.trustHigh, Color(0xFF238A80)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Trust Score', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          user.totalReviews == 0 ? 'Not rated yet' : '${user.trustScore.toStringAsFixed(1)} / 10',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${props.myProperties.length} active listings',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  TrustScoreBadge(score: user.trustScore, size: 56),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _stat('Listings', '${props.myProperties.length}', Icons.home_rounded, AppColors.primary),
                const SizedBox(width: 12),
                _stat('Reviews', '${user.totalReviews}', Icons.star_rounded, AppColors.rating),
                const SizedBox(width: 12),
                _stat('Rating', user.averageRating > 0 ? user.averageRating.toStringAsFixed(1) : '-', Icons.thumb_up_rounded, AppColors.trustHigh),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.pushNamed(context, '/property/add');
                context.read<PropertyProvider>().fetchMyProperties();
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add New Property'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Recent Listings'),
            const SizedBox(height: 12),
            if (props.myProperties.isEmpty)
              const EmptyState(
                icon: Icons.home_work_outlined,
                title: 'No properties yet',
                subtitle: 'Add your first property to start receiving inquiries',
              )
            else
              ...props.myProperties.take(3).map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: PropertyCard(
                  property: p,
                  onTap: () => Navigator.pushNamed(context, '/property/${p.id}'),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textBody)),
        ],
      ),
    ),
  );
}

class _MyPropertiesTab extends StatelessWidget {
  const _MyPropertiesTab();

  @override
  Widget build(BuildContext context) {
    final props = context.watch<PropertyProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: () async {
              await Navigator.pushNamed(context, '/property/add');
              context.read<PropertyProvider>().fetchMyProperties();
            },
          ),
        ],
      ),
      body: props.isLoading
          ? const Center(child: CircularProgressIndicator())
          : props.myProperties.isEmpty
              ? EmptyState(
                  icon: Icons.home_work_outlined,
                  title: 'No properties yet',
                  subtitle: 'Tap + to add your first listing',
                  actionLabel: 'Add Property',
                  onAction: () => Navigator.pushNamed(context, '/property/add'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: props.myProperties.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, i) {
                    final p = props.myProperties[i];
                    return Dismissible(
                      key: Key(p.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.delete_rounded, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete Property'),
                            content: const Text('Are you sure you want to delete this property?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) => context.read<PropertyProvider>().deleteProperty(p.id),
                      child: PropertyCard(
                        property: p,
                        onTap: () => Navigator.pushNamed(context, '/property/${p.id}'),
                      ),
                    );
                  },
                ),
    );
  }
}

// These are imported screens used in tabs — forward declarations
class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().fetchProperties(reset: true);
    });
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<PropertyProvider>().fetchProperties();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final props = context.watch<PropertyProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Browse Properties')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by city...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<PropertyProvider>().setFilters();
                        },
                      )
                    : null,
              ),
              onSubmitted: (v) => context.read<PropertyProvider>().setFilters(city: v),
            ),
          ),
          Expanded(
            child: props.isLoading && props.properties.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : props.properties.isEmpty
                    ? const EmptyState(
                        icon: Icons.home_work_outlined,
                        title: 'No properties found',
                        subtitle: 'Try a different search',
                      )
                    : RefreshIndicator(
                        onRefresh: () => context.read<PropertyProvider>().fetchProperties(reset: true),
                        child: ListView.separated(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: props.properties.length + (props.hasMore ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (_, i) {
                            if (i == props.properties.length) {
                              return const Center(child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ));
                            }
                            final p = props.properties[i];
                            return PropertyCard(
                              property: p,
                              saved: props.isSaved(p.id),
                              onTap: () => Navigator.pushNamed(context, '/property/${p.id}'),
                              onSaveToggle: () => context.read<PropertyProvider>().toggleSave(p.id),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// Forward declare—defined in other files
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MessageProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: mp.isLoading
          ? const Center(child: CircularProgressIndicator())
          : mp.conversations.isEmpty
              ? const EmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'No conversations yet',
                  subtitle: 'Contact a property owner to start a conversation',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: mp.conversations.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final c = mp.conversations[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      leading: UserAvatar(user: c.partner, radius: 24),
                      title: Text(c.partner.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(c.lastMessage.content, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textBody)),
                      trailing: c.unread > 0
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              child: Text('${c.unread}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                            )
                          : null,
                      onTap: () => Navigator.pushNamed(context, '/messages/${c.partner.id}',
                          arguments: {'name': c.partner.name, 'partner': c.partner}),
                    );
                  },
                ),
    );
  }
}

// ProfileScreen — Forward declare, defined in profile_screen.dart
class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await auth.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            UserAvatar(user: user, radius: 40),
            const SizedBox(height: 14),
            Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.role == 'owner' ? 'Property Owner' : 'Tenant',
                style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Text(user.email, style: const TextStyle(color: AppColors.textBody, fontSize: 13)),
            const SizedBox(height: 4),
            Text(user.phone, style: const TextStyle(color: AppColors.textBody, fontSize: 13)),
            const SizedBox(height: 20),
            TrustScoreBadge(score: user.trustScore, size: 72),
            const SizedBox(height: 20),
            if (user.bio.isNotEmpty) ...[
              Text(user.bio, textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),
            ],
            Row(
              children: [
                _infoCard('Reviews', '${user.totalReviews}', Icons.rate_review_rounded),
                const SizedBox(width: 12),
                _infoCard('Rating', user.averageRating > 0 ? '${user.averageRating}/5' : 'N/A', Icons.star_rounded),
                const SizedBox(width: 12),
                _infoCard('Trust', '${user.trustScore}/10', Icons.verified_user_rounded),
              ],
            ),
            const SizedBox(height: 24),
            _menuItem(Icons.settings_outlined, 'Edit Profile', () {}),
            _menuItem(Icons.info_outline_rounded, 'About RentRate', () => Navigator.pushNamed(context, '/about')),
            _menuItem(Icons.contact_support_outlined, 'Contact Us', () => Navigator.pushNamed(context, '/contact')),
            _menuItem(Icons.logout_rounded, 'Sign Out', () async {
              await auth.logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            }, color: AppColors.warning),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String label, String value, IconData icon) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textBody)),
        ],
      ),
    ),
  );

  Widget _menuItem(IconData icon, String label, VoidCallback onTap, {Color? color}) => ListTile(
    leading: Icon(icon, color: color ?? AppColors.textSecondary, size: 22),
    title: Text(label, style: TextStyle(fontSize: 14, color: color ?? AppColors.textDark, fontWeight: FontWeight.w500)),
    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textBody),
    onTap: onTap,
    contentPadding: EdgeInsets.zero,
  );
}
