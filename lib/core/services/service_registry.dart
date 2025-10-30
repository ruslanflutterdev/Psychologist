import 'package:heros_journey/core/services/agreement_service.dart';
import 'package:heros_journey/core/services/mock_agreement_service.dart';
import 'package:heros_journey/core/services/mock_quest_service.dart';
import 'package:heros_journey/core/services/quest_catalog_service.dart';
import 'package:heros_journey/core/services/quest_service.dart';
import 'package:heros_journey/core/services/supabase_quest_catalog_service.dart';
import 'package:heros_journey/features/achievements/repository/achievement_service.dart';
import 'package:heros_journey/features/achievements/repository/supabase_achievement_service.dart';
import 'package:heros_journey/features/auth_registration/repository/services/auth_service.dart';
import 'package:heros_journey/features/auth_registration/repository/services/supabase_auth_service.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_progress_service.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_quests_service.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_service.dart';
import 'package:heros_journey/features/child_screen/repository/services/supabase_child_quests_service.dart';
import 'package:heros_journey/features/child_screen/repository/services/supabase_child_service.dart';
import 'package:heros_journey/features/child_screen/repository/services/supabase_progress_service.dart';
import 'package:heros_journey/features/psychologist_screen/repository/services/psychologist_service.dart';
import 'package:heros_journey/features/psychologist_screen/repository/services/supabase_psychologist_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class ServiceRegistry {
  static late AuthService auth;
  static late ChildService child;
  static late QuestService quest;
  static late ProgressService progress;
  static late PsychologistService psychologist;
  static late AgreementService agreement;
  static late QuestCatalogService questCatalog;
  static late ChildQuestsService childQuests;
  static late AchievementService achievement;

  static void initSupabase() {
    auth = SupabaseAuthService(sb.Supabase.instance.client);
    child = SupabaseChildService(sb.Supabase.instance.client);
    quest = MockQuestService();
    progress = SupabaseProgressService(sb.Supabase.instance.client);
    psychologist = SupabasePsychologistService(sb.Supabase.instance.client);
    agreement = const MockAgreementService();
    questCatalog = SupabaseQuestCatalogService(sb.Supabase.instance.client);
    childQuests = SupabaseChildQuestsService(sb.Supabase.instance.client);
    achievement = SupabaseAchievementService(sb.Supabase.instance.client);
  }

  static void dispose() {
    (child as SupabaseChildService).dispose();
    (achievement as SupabaseAchievementService).dispose();
  }

  static Future<void> refreshAllServices() async {
    await Future.wait([
      (child as SupabaseChildService).refresh(),
      (achievement as SupabaseAchievementService).refresh(),
    ]);
  }
}
