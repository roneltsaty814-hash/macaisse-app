# Ma Caisse — MVP

Application de facturation et de caisse pour petits commerçants, avec calcul
automatique de la TVA (18%, Congo) et fonctionnement 100% hors-ligne
(stockage local sur le téléphone, aucune connexion internet requise).

## Ce que fait cette v1

- Créer des clients
- Créer des factures (articles, quantités, prix) avec TVA calculée automatiquement
- Marquer une facture comme payée ou en attente
- Voir le solde de caisse (total encaissé / en attente) sur l'écran d'accueil
- Exporter chaque facture en PDF, l'imprimer ou la partager (WhatsApp, email,
  etc. — via le menu de partage du téléphone), depuis l'écran de détail
- **Essai gratuit de 14 jours**, puis blocage de la création de nouvelles
  factures tant que l'abonnement n'est pas activé (30 jours, renouvelable)
- **Activation par mobile money (Airtel Money / MTN MoMo)** — voir la
  limite importante ci-dessous

## ⚠️ Limite importante sur le mobile money

Les vraies API d'Airtel Money et MTN MoMo demandent un **compte marchand
professionnel** (dossier entreprise, KYC) que toi seul peux demander
directement auprès d'Airtel Congo / MTN Congo — ça ne se fait pas depuis
le code.

En attendant, l'app utilise un flux **manuel** qui fonctionne dès
aujourd'hui : le client paie par le code USSD habituel vers ton numéro
personnel/marchand, reçoit une référence par SMS, et la saisit dans
l'app pour activer son abonnement. **Tu dois vérifier toi-même** (au
début) que l'argent est bien arrivé sur ton compte — ce n'est pas encore
automatique.

➡️ Avant la première utilisation, remplace les numéros placeholder dans
`lib/services/paiement_service.dart` (`numeroAirtelMoney` et
`numeroMtnMomo`) par tes vrais numéros.

➡️ Quand tu obtiendras un compte marchand officiel, un exemple de code
pour l'API MTN MoMo réelle est déjà en commentaire en bas de ce même
fichier, prêt à être activé.

## Ce qui n'est PAS encore fait (volontairement, pour rester simple au départ)

- Vérification automatique des paiements mobile money (voir ci-dessus)
- Bilan comptable SYSCOHADA complet
- Multi-utilisateurs / multi-boutiques

## Option C — Compilation 100% automatique (GitHub Actions)

Le projet contient un fichier `.github/workflows/build.yml` qui compile
l'APK automatiquement à chaque modification du code — sans que tu aies
besoin d'ouvrir Codespaces ni de taper une seule commande.

1. Uploade (ou push) tout le contenu du projet sur ton dépôt GitHub,
   y compris le dossier `.github`
2. Va dans l'onglet **Actions** de ton dépôt sur GitHub
3. Le workflow "Compiler l'APK" se lance automatiquement (tu verras un
   rond jaune ⏳ puis vert ✅ après quelques minutes)
4. Une fois terminé, clique sur le run terminé → descends jusqu'à
   **Artifacts** → clique sur **ma-caisse-apk** pour télécharger un
   fichier `.zip` contenant ton APK
5. Dézippe-le sur ta tablette/téléphone et installe l'APK normalement

Gratuit jusqu'à 2000 minutes/mois — largement suffisant pour ce projet.

## Comment lancer le projet

### Option A — Sur un ordinateur (Windows/Mac/Linux)

Il te faut Flutter installé sur ton ordinateur :
👉 https://docs.flutter.dev/get-started/install

Une fois Flutter installé :

```bash
cd compta_app
flutter pub get
flutter run
```

`flutter run` te proposera de lancer l'app sur un émulateur Android, ou sur
ton téléphone/tablette si tu le branches en USB avec le mode développeur activé.

### Option B — Depuis une tablette ou un téléphone (GitHub Codespaces)

Ce projet contient un dossier `.devcontainer` qui installe Flutter
automatiquement — aucune installation manuelle nécessaire.

1. Crée un compte gratuit sur https://github.com si tu n'en as pas
2. Crée un nouveau dépôt (repository) et mets-y tout le contenu de ce
   dossier `compta_app` (y compris le dossier `.devcontainer`)
3. Depuis le dépôt : **Code → Codespaces → Create codespace on main**
4. Codespaces installe Flutter tout seul (ça prend quelques minutes la
   première fois) — tu verras le résultat de `flutter doctor` s'afficher
5. Une fois prêt, dans le terminal :
   ```bash
   flutter build apk
   ```
6. Le fichier `.apk` généré se trouve dans
   `build/app/outputs/flutter-apk/app-release.apk` — clique droit dessus
   dans l'explorateur de fichiers de Codespaces → **Download**, puis
   installe-le sur ta tablette/téléphone Android (autorise "sources
   inconnues" dans les paramètres si demandé)

⚠️ Le quota gratuit de Codespaces est d'environ 60h/mois — largement
suffisant pour ce projet tant que tu ne codes pas des journées entières.

## Prochaine étape : publier sur Google Play

1. `flutter build appbundle` génère le fichier à soumettre
2. Crée un compte développeur Google Play (25 $, une fois) :
   https://play.google.com/console/signup
3. Crée une fiche store (description, captures d'écran, politique de
   confidentialité — obligatoire même pour une app gratuite)
4. Soumets le fichier `.aab` généré à l'étape 1

## Structure du projet

```
lib/
  main.dart                        → navigation principale (3 onglets)
  models/
    client.dart                    → structure d'un client
    facture.dart                   → structure d'une facture + calcul TVA
    abonnement.dart                → structure de l'essai gratuit / abonnement
  services/
    storage_service.dart           → sauvegarde locale (hors-ligne)
    pdf_service.dart               → génération du PDF de facture
    abonnement_service.dart        → gestion de l'essai gratuit et de l'activation
    paiement_service.dart          → instructions de paiement mobile money
  screens/
    home_screen.dart               → écran d'accueil / caisse
    factures_screen.dart           → liste des factures
    nouvelle_facture_screen.dart   → création d'une facture
    facture_detail_screen.dart     → détail + export/partage PDF
    clients_screen.dart            → gestion des clients
    abonnement_screen.dart         → statut et activation de l'abonnement
```
