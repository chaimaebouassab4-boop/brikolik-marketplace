import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';

class JobDetailsScreen extends StatelessWidget {
  const JobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobId = ModalRoute.of(context)?.settings.arguments as String?;
    if (jobId == null) {
      return Scaffold(
        appBar: const BrikolikAppBar(title: 'Erreur', showBackButton: true),
        body: Center(child: Text('Mission introuvable'.tr())),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').doc(jobId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: BrikolikColors.primary)));
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(body: Center(child: Text('Mission introuvable'.tr())));
        }

        final jobData = snapshot.data!.data() as Map<String, dynamic>;
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        final isOwner = currentUserId == jobData['customerId'];
        final isAcceptedWorker = currentUserId == jobData['acceptedWorkerId'];
        final jobStatus = jobData['status'] ?? 'open';

        return Scaffold(
          backgroundColor: BrikolikColors.background,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, jobData),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusRow(context, jobData),
                      const SizedBox(height: 16),
                      _buildTitle(context, jobData),
                      const SizedBox(height: 20),
                      _buildInfoGrid(context, jobData),
                      const SizedBox(height: 24),
                      _buildDescription(context, jobData),
                      const SizedBox(height: 24),
                      _buildClientCard(context, jobData),
                      const SizedBox(height: 24),
                      if (isOwner) _buildOffersSection(context, jobId),
                      if (isAcceptedWorker) _buildAcceptedBanner(context, jobData),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: isOwner 
              ? null 
              : isAcceptedWorker 
                  ? _buildAcceptedBottomBar(context, jobData)
                  : jobStatus == 'inprogress'
                      ? null // Job already taken, hide offer button for other workers
                      : _buildBottomBar(context, jobId),
        );
      },
    );
  }

  Widget _buildAcceptedBanner(BuildContext context, Map<String, dynamic> jobData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        ),
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(color: BrikolikColors.success, width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.celebration_rounded, size: 40, color: BrikolikColors.success),
          const SizedBox(height: 10),
          Text('Felicitations !'.tr(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: BrikolikColors.success),
          ),
          const SizedBox(height: 6),
          Text(
            '${jobData['customerName'] ?? 'Le client'} a accepte votre offre.\nVous pouvez maintenant le contacter pour organiser la mission.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, color: BrikolikColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  void _goToContact(
    BuildContext context, {
    required String contactUserId,
    required String contactName,
    required String contactRole,
    required String preferredAction,
  }) {
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: <String, dynamic>{
        'contactUserId': contactUserId,
        'contactName': contactName,
        'contactRole': contactRole,
        'preferredAction': preferredAction,
      },
    );
  }

  Widget _buildAcceptedBottomBar(
    BuildContext context,
    Map<String, dynamic> jobData,
  ) {
    final customerId = (jobData['customerId'] as String? ?? '').trim();
    final customerName =
        (jobData['customerName'] as String? ?? 'Client').trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        border: const Border(top: BorderSide(color: BrikolikColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: BrikolikButton(
              label: 'WhatsApp',
              icon: Icons.chat_bubble_rounded,
              height: 52,
              onPressed: () => _goToContact(
                context,
                contactUserId: customerId,
                contactName: customerName,
                contactRole: 'customer',
                preferredAction: 'whatsapp',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: BrikolikButton(
              label: 'Appeler',
              icon: Icons.call_rounded,
              height: 52,
              outlined: true,
              onPressed: () => _goToContact(
                context,
                contactUserId: customerId,
                contactName: customerName,
                contactRole: 'customer',
                preferredAction: 'call',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Map<String, dynamic> jobData) {
    final cat = jobData['category'] as String? ?? 'Autre';
    IconData icon = Icons.work_outline;
    if (cat == 'Plomberie') icon = Icons.water_drop_outlined;
    else if (cat == 'Electricite' || cat == 'Électricite') icon = Icons.bolt_outlined;
    else if (cat == 'Nettoyage') icon = Icons.cleaning_services_outlined;
    else if (cat == 'Peinture') icon = Icons.format_paint_outlined;
    else if (cat == 'Jardinage') icon = Icons.grass_outlined;
    else if (cat == 'Menuiserie') icon = Icons.carpenter_outlined;
    else if (cat == 'Maconnerie' || cat == 'Maçonnerie') icon = Icons.construction_outlined;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: BrikolikColors.surface,
      foregroundColor: BrikolikColors.textPrimary,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                size: 20, color: BrikolikColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            child: IconButton(
              icon: const Icon(Icons.share_outlined,
                  size: 20, color: BrikolikColors.textPrimary),
              onPressed: () {},
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFECEEF7), Color(0xFFF0ECF8)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: BrikolikColors.brandGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: BrikolikColors.primary.withValues(alpha: 0.28),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Icon(icon, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: BrikolikColors.primaryLight,
                    borderRadius:
                        BorderRadius.circular(BrikolikRadius.full),
                    border: Border.all(
                        color: BrikolikColors.border, width: 1),
                  ),
                  child: Text(
                    cat,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: BrikolikColors.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, Map<String, dynamic> jobData) {
    String timeStr = "A l'instant";
    final createdAt = jobData['createdAt'] as Timestamp?;
    if (createdAt != null) {
      final diff = DateTime.now().difference(createdAt.toDate());
      if (diff.inMinutes < 60) timeStr = 'Il y a ${diff.inMinutes} min';
      else if (diff.inHours < 24) timeStr = 'Il y a ${diff.inHours} h';
      else timeStr = 'Il y a ${diff.inDays} j';
    }

    return Row(
      children: [
        jobData['status'] == 'open' ? StatusBadge.open() : StatusBadge.inProgress(),
        const SizedBox(width: 8),
        const Icon(Icons.access_time_rounded,
            size: 14, color: BrikolikColors.muted),
        const SizedBox(width: 4),
        Text(timeStr, style: Theme.of(context).textTheme.bodySmall),
        const Spacer(),
        const Icon(Icons.visibility_outlined,
            size: 14, color: BrikolikColors.muted),
        const SizedBox(width: 4),
        Text('${jobData['offersCount'] ?? 0} offres', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildTitle(BuildContext context, Map<String, dynamic> jobData) {
    return Text(
      jobData['title'] ?? 'Sans titre',
      style: Theme.of(context).textTheme.headlineLarge,
    );
  }

  Widget _buildInfoGrid(BuildContext context, Map<String, dynamic> jobData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: BrikolikColors.heroGradient,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(color: BrikolikColors.border),
      ),
      child: Row(
        children: [
          _InfoTile(
            icon: Icons.payments_outlined,
            label: 'Budget',
            value: jobData['budget'] ?? 'Non specifie',
            color: BrikolikColors.success,
          ),
          _VerticalDivider(),
          _InfoTile(
            icon: Icons.location_on_outlined,
            label: 'Lieu',
            value: jobData['location'] ?? 'Inconnu',
            color: BrikolikColors.primary,
          ),
          _VerticalDivider(),
          _InfoTile(
            icon: Icons.schedule_rounded,
            label: 'Delai',
            value: jobData['urgency'] ?? 'Flexible',
            color: BrikolikColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context, Map<String, dynamic> jobData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description'.tr(), style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: BrikolikColors.surface,
            borderRadius: BorderRadius.circular(BrikolikRadius.lg),
            border: Border.all(color: BrikolikColors.border),
          ),
          child: Text(
            jobData['description'] ?? 'Aucune description.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: BrikolikColors.textSecondary,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientCard(BuildContext context, Map<String, dynamic> jobData) {
    final name = (jobData['customerName'] as String? ?? 'Client').trim();
    final customerId = (jobData['customerId'] as String? ?? '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Client'.tr(), style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: BrikolikColors.surface,
            borderRadius: BorderRadius.circular(BrikolikRadius.lg),
            border: Border.all(color: BrikolikColors.border),
            boxShadow: [
              BoxShadow(
                color: BrikolikColors.primary.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              BrikolikAvatar(name: name, size: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StarRating(rating: (jobData['rating'] ?? 5.0).toDouble(), reviewCount: 0),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: BrikolikColors.successLight,
                            borderRadius:
                                BorderRadius.circular(BrikolikRadius.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield_outlined,
                                  size: 11, color: BrikolikColors.success),
                              SizedBox(width: 3),
                              Text('Verifie'.tr(),
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: BrikolikColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  _ContactCircleButton(
                    icon: Icons.chat_bubble_rounded,
                    backgroundColor: const Color(0xFF25D366),
                    onTap: () => _goToContact(
                      context,
                      contactUserId: customerId,
                      contactName: name,
                      contactRole: 'customer',
                      preferredAction: 'whatsapp',
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ContactCircleButton(
                    icon: Icons.call_rounded,
                    backgroundColor: BrikolikColors.primary,
                    onTap: () => _goToContact(
                      context,
                      contactUserId: customerId,
                      contactName: name,
                      contactRole: 'customer',
                      preferredAction: 'call',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOffersSection(BuildContext context, String jobId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Offres recues',
          actionLabel: '',
          onAction: () {},
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('jobs').doc(jobId).collection('offers').orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator(color: BrikolikColors.primary);
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
               return const Text("Vous n'avez pas encore recu d'offre pour l'instant.", style: TextStyle(color: BrikolikColors.textHint, fontFamily: 'Nunito'));
            }
            return Column(
              children: snapshot.data!.docs.map((doc) {
                 final offer = doc.data() as Map<String, dynamic>;
                 final isAccepted = offer['status'] == 'accepted';
                 return Padding(
                   padding: const EdgeInsets.only(bottom: 10),
                   child: _OfferCard(
                     name: offer['workerName'] ?? 'Artisan',
                     rating: 4.8,
                     reviews: 12,
                     price: offer['price'] ?? '...',
                     message: offer['message'] ?? '',
                     isPro: true,
                     isAccepted: isAccepted,
                     onAccept: isAccepted ? null : () => _acceptOffer(context, jobId, doc.id, offer['workerId'] ?? '', offer['workerName'] ?? 'Artisan'),
                     onContactWhatsApp: () => _goToContact(
                       context,
                       contactUserId: (offer['workerId'] as String? ?? '').trim(),
                       contactName: (offer['workerName'] as String? ?? 'Artisan').trim(),
                       contactRole: 'worker',
                       preferredAction: 'whatsapp',
                     ),
                     onContactCall: () => _goToContact(
                       context,
                       contactUserId: (offer['workerId'] as String? ?? '').trim(),
                       contactName: (offer['workerName'] as String? ?? 'Artisan').trim(),
                       contactRole: 'worker',
                       preferredAction: 'call',
                     ),
                   ),
                 );
              }).toList(),
            );
          }
        ),
      ],
    );
  }

  void _acceptOffer(BuildContext context, String jobId, String offerId, String workerId, String workerName) async {
    try {
      // 1. Update job status to 'inprogress' and save accepted worker
      await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
        'status': 'inprogress',
        'acceptedWorkerId': workerId,
        'acceptedWorkerName': workerName,
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // 2. Mark the offer as accepted
      await FirebaseFirestore.instance
          .collection('jobs').doc(jobId)
          .collection('offers').doc(offerId)
          .update({'status': 'accepted'});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vous avez accepte l offre de $workerName !'),
            backgroundColor: BrikolikColors.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('=== ACCEPT ERROR: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildBottomBar(BuildContext context, String jobId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        border: const Border(
            top: BorderSide(color: BrikolikColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: BrikolikColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _showOfferDialog(context, jobId);
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: BrikolikColors.brandGradient,
                  borderRadius:
                      BorderRadius.circular(BrikolikRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color:
                          BrikolikColors.accent.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Faire une offre'.tr(),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: BrikolikColors.surfaceVariant,
              borderRadius:
                  BorderRadius.circular(BrikolikRadius.md),
              border: Border.all(color: BrikolikColors.border),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.bookmark_border_rounded,
                  color: BrikolikColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showOfferDialog(BuildContext context, String jobId) {
    final offerCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          decoration: const BoxDecoration(
            color: BrikolikColors.background,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Faire une offre", style: Theme.of(ctx).textTheme.headlineMedium),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                BrikolikInput(hint: "Ex: 250 MAD", label: "Votre tarif", controller: offerCtrl),
                const SizedBox(height: 10),
                BrikolikInput(hint: "Pourquoi vous choisir ?", label: "Message", controller: messageCtrl, maxLines: 3),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: isSubmitting ? null : () async {
                    if (offerCtrl.text.isEmpty) return;
                    setState(() => isSubmitting = true);
                    try {
                      final workerId = FirebaseAuth.instance.currentUser?.uid;
                      debugPrint('=== OFFER: workerId=$workerId, jobId=$jobId');
                      if (workerId == null) {
                        Navigator.pop(ctx);
                        return;
                      }
                      
                      final workerDoc = await FirebaseFirestore.instance.collection('users').doc(workerId).get();
                      final wName = workerDoc.data()?['fullName'] ?? 'Artisan';
                      debugPrint('=== OFFER: workerName=$wName');
                      
                      await FirebaseFirestore.instance.collection('jobs').doc(jobId).collection('offers').add({
                         'workerId': workerId,
                         'workerName': wName,
                         'price': offerCtrl.text,
                         'message': messageCtrl.text,
                         'createdAt': FieldValue.serverTimestamp(),
                      });
                      debugPrint('=== OFFER: offer saved!');
                      
                      await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
                         'offersCount': FieldValue.increment(1)
                      });
                      debugPrint('=== OFFER: offersCount incremented!');
                      
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Offre envoyee avec succes !'.tr()),
                            backgroundColor: BrikolikColors.success,
                          ),
                        );
                      }
                    } catch(e) {
                      debugPrint('=== OFFER ERROR: $e');
                      setState(() => isSubmitting = false);
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    height: 52,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: isSubmitting ? null : BrikolikColors.brandGradient,
                      color: isSubmitting ? BrikolikColors.surfaceVariant : null,
                      borderRadius: BorderRadius.circular(BrikolikRadius.md),
                    ),
                    child: Center(
                      child: isSubmitting 
                         ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: BrikolikColors.primary, strokeWidth: 2))
                         : const Text(
                              "Envoyer l'offre",
                              style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white),
                           ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Info Tile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: BrikolikColors.textHint,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: BrikolikColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Vertical Divider â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 52,
      color: BrikolikColors.divider,
    );
  }
}

// â”€â”€ Offer Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _OfferCard extends StatelessWidget {
  final String name;
  final double rating;
  final int reviews;
  final String price;
  final String message;
  final bool isPro;
  final bool isAccepted;
  final VoidCallback? onAccept;
  final VoidCallback onContactWhatsApp;
  final VoidCallback onContactCall;

  const _OfferCard({
    required this.name,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.message,
    required this.isPro,
    required this.onContactWhatsApp,
    required this.onContactCall,
    this.isAccepted = false,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrikolikColors.surface,
        borderRadius: BorderRadius.circular(BrikolikRadius.lg),
        border: Border.all(
          color: isAccepted ? BrikolikColors.success : (isPro ? BrikolikColors.primary : BrikolikColors.border),
          width: isAccepted ? 2 : (isPro ? 1.5 : 1),
        ),
        boxShadow: isAccepted
            ? [
                BoxShadow(
                  color: BrikolikColors.success.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : isPro
                ? [
                    BoxShadow(
                      color: BrikolikColors.primary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAccepted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: BrikolikColors.successLight,
                borderRadius: BorderRadius.circular(BrikolikRadius.sm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, size: 16, color: BrikolikColors.success),
                  SizedBox(width: 6),
                  Text('Offre acceptee'.tr(), style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700, color: BrikolikColors.success)),
                ],
              ),
            ),
          Row(
            children: [
              BrikolikAvatar(name: name, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name,
                            style:
                                Theme.of(context).textTheme.titleSmall),
                        if (isPro) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: BrikolikColors.brandGradient,
                              borderRadius: BorderRadius.circular(
                                  BrikolikRadius.full),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    StarRating(rating: rating, reviewCount: reviews),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isAccepted ? BrikolikColors.successLight : BrikolikColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(BrikolikRadius.sm),
                ),
                child: Text(
                  price,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isAccepted ? BrikolikColors.success : BrikolikColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          if (!isAccepted) ...[
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onAccept,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: BrikolikColors.brandGradient,
                        borderRadius: BorderRadius.circular(BrikolikRadius.md),
                      ),
                      child: Center(
                        child: Text(
                          'Accepter'.tr(),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: BrikolikButton(
                  label: 'WhatsApp',
                  icon: Icons.chat_bubble_rounded,
                  onPressed: onContactWhatsApp,
                  outlined: !isAccepted,
                  height: 40,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BrikolikButton(
                  label: 'Appeler',
                  icon: Icons.call_rounded,
                  onPressed: onContactCall,
                  outlined: true,
                  height: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactCircleButton extends StatelessWidget {
  const _ContactCircleButton({
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.28),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

