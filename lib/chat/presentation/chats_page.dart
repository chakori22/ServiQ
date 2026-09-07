import 'package:flutter/material.dart';

import 'package:local_markerplace/basket/app_bottom_bar.dart';
import 'package:local_markerplace/chat/presentation/components/chat_bits.dart';
import 'package:local_markerplace/chat/presentation/conversation_page.dart';
import 'package:local_markerplace/chat/repository/chat_repository.dart';
import 'package:local_markerplace/components/motion/entrance.dart';
import 'package:local_markerplace/components/textfield.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_tab_bar.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// Every conversation the seeker has.
///
/// A thread cannot be started from here, which is the whole point of the
/// note at the foot of the list: chats open when an offer is accepted or a
/// provider is connected with, and until then nobody has the seeker's
/// number. The empty state offers the two things that would open one.
class ChatsPage extends StatefulWidget {
  const ChatsPage({
    super.key,
    this.repository,
    this.onTabSelected,
    this.onPost,
    this.onFindProvider,
  });

  final ChatRepository? repository;
  final ValueChanged<DiscoveryTab>? onTabSelected;
  final VoidCallback? onPost;

  /// Sends the seeker to browse providers from the empty state.
  final VoidCallback? onFindProvider;

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late final ChatRepository _chats = widget.repository ?? ChatRepository.shared;

  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _open(String providerName) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ConversationPage(providerName: providerName, repository: _chats),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasThreads = _chats.threads.isNotEmpty;
    final results = _chats.search(_query.text);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Text('Chats', style: DiscoveryText.headline),
            ),
            if (hasThreads) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppTextField(
                  controller: _query,
                  onChanged: (_) => setState(() {}),
                  hintText: 'Search chats',
                  autofocus: false,
                  textInputAction: TextInputAction.search,
                  fillColor: AppColor.discoveryTint,
                  borderColor: AppColor.discoveryBorder,
                  borderWidth: 1.4,
                  cornerRadius: 14,
                  verticalPadding: 13,
                  textStyle: DiscoveryText.searchValue,
                  hintStyle: DiscoveryText.searchHint,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: AppColor.discoveryTextTertiary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColor.discoveryBorder,
              ),
            ],
            Expanded(
              child: !hasThreads
                  ? _NoChats(
                      onFindProvider: widget.onFindProvider,
                      onPost: widget.onPost,
                    )
                  : results.isEmpty
                  ? const _NoMatches()
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: results.length + 1,
                      separatorBuilder: (_, _) => const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColor.discoveryBorder,
                        ),
                      ),
                      itemBuilder: (context, index) {
                        if (index == results.length) return const _HowChats();
                        return FadeSlideIn(
                          index: index,
                          child: ChatRow(
                            thread: results[index],
                            onTap: () => _open(results[index].providerName),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomBar(
        current: DiscoveryTab.me,
        onSelect: (tab) {
          widget.onTabSelected?.call(tab);
          Navigator.of(context).pop();
        },
        onPost: widget.onPost,
      ),
    );
  }
}

/// Why the seeker cannot start one of these themselves.
class _HowChats extends StatelessWidget {
  const _HowChats();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.discoveryTint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Chats open when you accept an offer or connect with a provider. '
        'Numbers stay hidden until then.',
        style: DiscoveryText.smallPrint.copyWith(height: 17 / 11.5),
      ),
    ),
  );
}

class _NoMatches extends StatelessWidget {
  const _NoMatches();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        'No chats match that.',
        textAlign: TextAlign.center,
        style: DiscoveryText.footnoteStrong,
      ),
    ),
  );
}

/// 04 — nothing has been said to anybody yet.
class _NoChats extends StatelessWidget {
  const _NoChats({required this.onFindProvider, required this.onPost});

  final VoidCallback? onFindProvider;
  final VoidCallback? onPost;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 132,
              height: 132,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.discoveryTint,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 52,
                color: AppColor.discoveryTextTertiary,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'No chats yet',
            textAlign: TextAlign.center,
            style: DiscoveryText.emptyTitle,
          ),
          const SizedBox(height: 10),
          Text(
            'A chat opens when you accept an offer or connect with a '
            'provider. Until then nobody has your number.',
            textAlign: TextAlign.center,
            style: DiscoveryText.caption.copyWith(height: 19 / 12.5),
          ),
          const SizedBox(height: 26),
          _PrimaryAction(label: 'Find a provider', onTap: onFindProvider),
          const SizedBox(height: 12),
          _OutlinedAction(label: 'Post what you need', onTap: onPost),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.97,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
              AppColor.discoveryGradientStart,
              AppColor.discoveryGradientEnd,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.discoveryGradientEnd.withValues(alpha: 0.32),
              blurRadius: 11,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Text(
          label,
          style: DiscoveryText.onAccent(16.5, letterSpacing: -0.165),
        ),
      ),
    );
  }
}

class _OutlinedAction extends StatelessWidget {
  const _OutlinedAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.97,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColor.discoveryAccent.withValues(alpha: 0.35),
            width: 1.6,
          ),
        ),
        child: Text(label, style: DiscoveryText.actionOutlined),
      ),
    );
  }
}
