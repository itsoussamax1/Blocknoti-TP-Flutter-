# 📱 Documentation - Application Blocknotii

## Table des Matières
1. [Qu'est-ce que Blocknotii ?](#quest-ce-que-blocknotii-)
2. [Architecture Globale](#architecture-globale)
3. [Structure du Projet](#structure-du-projet)
4. [Les Composants Principaux](#les-composants-principaux)
5. [Le Modèle de Données](#le-modèle-de-données)
6. [Flux de Données](#flux-de-données)
7. [Les Pages de l'Application](#les-pages-de-lapplication)
8. [Guide Utilisateur](#guide-utilisateur)
9. [Limitations Actuelles](#limitations-actuelles)

---

## Qu'est-ce que Blocknotii ?

**Blocknotii** est une application mobile de prise de notes simple et intuitive, développée avec **Flutter** et **Dart**.

### 🎯 Objectif Principal
Permettre aux utilisateurs de :
- ✅ Créer des notes
- ✅ Consulter leurs notes
- ✅ Modifier des notes existantes
- ✅ Supprimer des notes
- ✅ Organiser les notes par couleur

### 🎨 Caractéristiques
- Interface en français
- Système de couleurs pour catégoriser les notes
- Suivi des dates de création et modification
- Design moderne avec Material Design 3
- Couleur principale : Bleu profond (#035EA1)

---

## Architecture Globale

### Technologie Utilisée
```
┌─────────────────────────────────────────┐
│         FLUTTER FRAMEWORK               │
│         (Langage: Dart 3.10.3)          │
├─────────────────────────────────────────┤
│    Material Design 3 (Interface)        │
│    Stateful Widgets (Gestion d'État)    │
│    Navigation avec MaterialPageRoute    │
└─────────────────────────────────────────┘
```

### Stack Technique
- **Framework** : Flutter
- **Langage** : Dart
- **Gestion d'État** : Stateful Widgets (état local)
- **Persistance** : Mémoire uniquement (actuellement)
- **Design** : Material 3
- **Plateforme** : Multi-plateforme (Android, iOS, Web, Windows, macOS, Linux)

### Points Clés
- ✅ Pas de base de données externe
- ✅ Pas de library compliquée de gestion d'état
- ✅ Code simple et facile à comprendre pour débuter
- ⚠️ Données perdues au fermeture de l'application

---

## Structure du Projet

```
blocknotii/
├── 📄 pubspec.yaml              # Configuration du projet et dépendances
├── 📄 analysis_options.yaml      # Règles d'analyse du code
├── 📁 lib/                       # CODE SOURCE DE L'APPLICATION
│   ├── 📄 main.dart              # Point d'entrée de l'app
│   ├── 📁 models/                # Modèles de données
│   │   └── 📄 note.dart          # Classe Note (structure des notes)
│   └── 📁 pages/                 # Pages/Écrans de l'app
│       ├── 📄 home_page.dart     # Écran d'accueil (liste des notes)
│       ├── 📄 create_page.dart   # Écran de création/édition
│       └── 📄 detail_page.dart   # Écran de détail (vue complète)
├── 📁 android/                   # Code natif Android
├── 📁 ios/                       # Code natif iOS
├── 📁 web/                       # Code pour Web
├── 📁 windows/, macos/, linux/   # Code pour autres plateformes
└── 📁 test/                      # Tests
```

---

## Les Composants Principaux

### 1️⃣ **main.dart** - Point d'Entrée
**Rôle** : Initialise l'application et configure le thème

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloc-Notii',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Color(0xFF035EA1),  // Bleu profond
        // ... configuration du thème
      ),
      home: const HomePage(),
    );
  }
}
```

**Ce qu'il fait** :
- Lance l'application Flutter
- Définit le thème général (couleurs, police, etc.)
- Définit la page d'accueil (`HomePage`)
- Affiche le titre "Bloc-Notii" dans la barre d'application

### 2️⃣ **note.dart** - Modèle de Données
**Rôle** : Définit la structure d'une note

```dart
class Note {
  String id;                      // Identifiant unique (basé sur timestamp)
  String titre;                   // Titre de la note
  String contenu;                 // Contenu de la note
  String couleur;                 // Code couleur (ex: #FF5733)
  DateTime dateCreation;          // Date de création
  DateTime? dateModification;     // Date de modification (optionnel)
}
```

**Explications** :
- **id** : Créé automatiquement avec `DateTime.now().millisecondsSinceEpoch.toString()`
- **titre** : Limité à 60 caractères
- **contenu** : Peut être vide ou très long
- **couleur** : 6 couleurs prédéfinies (bleu, vert, orange, etc.)
- **dateCreation** : Ne change jamais après création
- **dateModification** : Mis à jour seulement lors de modification d'une note existante

---

## Le Modèle de Données

### Couleurs Disponibles

| Couleur | Code Hex | Usage |
|---------|----------|-------|
| 🔵 Bleu | #2196F3 | Notes par défaut |
| 🟢 Vert | #4CAF50 | Notes importantes |
| 🟡 Amber | #FFC107 | Notes à faire |
| 🟠 Orange | #FF9800 | Notes urgentes |
| 🟣 Violet | #9C27B0 | Notes personnelles |
| 🔴 Rose | #E91E63 | Notes confidentielles |

### Exemple d'une Note en Mémoire

```dart
Note {
  id: '1234567890123',
  titre: 'Faire les courses',
  contenu: 'Pain, lait, oeufs, fromage',
  couleur: '#4CAF50',  // Vert
  dateCreation: 2026-04-21 14:30:00,
  dateModification: 2026-04-21 15:45:00,
}
```

---

## Flux de Données

### Diagramme du Flux Global

```
┌──────────────────┐
│   HOME PAGE      │  ◄─── Point d'entrée principal
│  (Liste notes)   │
└────────┬─────────┘
         │
         ├──────► FAB (Bouton +) ────► CREATE PAGE (nouvelle note)
         │                                    │
         │                                    └─► Sauvegarde ─► Retourne Note
         │                                                           │
         │                                                           ▼
         └──────► Tap Carte Note ────► DETAIL PAGE                HOME (ajoute à liste)
                                             │
                                             ├─► Bouton Éditer ──► CREATE PAGE (mode édition)
                                             │                           │
                                             │                           └─► Retourne Note
                                             │                                    │
                                             │                                    ▼
                                             │                              HOME (met à jour)
                                             │
                                             └─► Bouton Supprimer ──► Dialog Confirmation
                                                                             │
                                                                             └─► Supprime
                                                                                    │
                                                                                    ▼
                                                                              HOME (retire)
```

### Étapes Clés

**1. Création d'une note** :
- Utilisateur clique le bouton "+" (FAB)
- L'app affiche `CreateNotePage` en mode "nouvelle note"
- Utilisateur remplir titre et sélectionne couleur
- Utilisateur valide et retourne à `HomePage`
- La nouvelle note s'ajoute à la liste `_notes`

**2. Consultation d'une note** :
- Utilisateur tape sur une carte note
- L'app affiche `DetailNotePage`
- Affiche le titre complet, contenu, dates

**3. Modification d'une note** :
- Depuis `DetailNotePage`, clic sur le bouton "éditer" ✏️
- L'app affiche `CreateNotePage` en mode "édition"
- Les champs sont pré-remplis avec les données existantes
- Modification et validation
- La note originale est remplacée dans la liste `_notes`
- `dateModification` est mise à jour

**4. Suppression d'une note** :
- Depuis `DetailNotePage`, clic sur le bouton "supprimer" 🗑️
- Un dialog de confirmation s'affiche
- Si confirmé : la note est supprimée de la liste `_notes`
- L'app retourne à `HomePage`

---

## Les Pages de l'Application

### 📄 HomePage - L'Écran d'Accueil

**Chemin** : `lib/pages/home_page.dart`

**Objectif** : Afficher la liste de toutes les notes créées

#### Composition :
```
┌─────────────────────────────────────┐
│  Bloc-Notii                    ☰   │ ← AppBar
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐ │
│  │ 🟢 | Faire les courses...      │ │ ← Carte note (couleur verte)
│  │    2026-04-21 14:30            │ │
│  └─────────────────────────────────┘ │
│  ┌─────────────────────────────────┐ │
│  │ 🔵 | Appeler le plombier       │ │ ← Carte note (couleur bleu)
│  │    2026-04-20 09:15            │ │
│  └─────────────────────────────────┘ │
│  ┌─────────────────────────────────┐ │
│  │ 🟡 | Préparer présentation...   │ │ ← Carte note (couleur orange)
│  │    2026-04-19 18:45            │ │
│  └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│                                   [+] │ ← FAB (Floating Action Button)
└─────────────────────────────────────┘
```

#### Fonctionnalités :
- **ListView** : Affiche toutes les notes dans une liste scrollable
- **Chaque Carte Note** affiche :
  - 🎨 Bande de couleur gauche (couleur de la note)
  - 📝 Titre de la note
  - 📄 Aperçu du contenu (30 caractères max)
  - 📅 Date de création formatée (JJ/MM/AAAA)
- **FAB Button (+)** : Crée une nouvelle note
- **Message Vide** : "Aucune note trouvée" si liste vide
- **Tap sur Carte** : Ouvre la vue détaillée (`DetailNotePage`)

#### Gestion d'État :
```dart
List<Note> _notes = [];  // Liste stockée en mémoire

// Quand l'utilisateur revient de CreatePage ou DetailPage
// L'app reçoit la note retournée et met à jour _notes
```

#### Interactions :
```
FAB [+] ─────► CreateNotePage (new) ───► retourne Note ───► _notes.add(note)
Tap Card ─────► DetailNotePage ─────────► retourne Note ───► _notes[index] = note
               (ou 'deleted') ───────────────────────────► _notes.removeAt(index)
```

---

### ✏️ CreateNotePage - Créer ou Éditer une Note

**Chemin** : `lib/pages/create_page.dart`

**Objectif** : Formulaire pour créer une nouvelle note ou modifier une existante

#### Composition :
```
┌─────────────────────────────────────┐
│  Nouvelle Note (ou Modifier Note)   │ ← Titre AppBar change selon mode
├─────────────────────────────────────┤
│  Titre de la note              [0/60] │ ← TextField avec compteur
│  ___________________________________  │
│                                        │
│  Contenu                              │ ← TextArea (multi-ligne)
│  ___________________________________  │
│  ___________________________________  │
│  ___________________________________  │
│                                        │
│  Couleur :                           │
│  [🔵] [🟢] [🟡] [🟠] [🟣] [🔴]     │ ← 6 boutons couleur
│                                        │
│                        [Sauvegarder] │ ← Bouton action
└─────────────────────────────────────┘
```

#### Champs du Formulaire :

**1. Titre (TextField)**
- Placeholder : "Titre de la note"
- Limite : 60 caractères (affichage du compteur)
- Obligatoire : Doit avoir au moins 1 caractère
- Validation : Message d'erreur si vide

**2. Contenu (TextField multiligne)**
- Placeholder : "Contenu de la note"
- Lignes : 4-10 (peut s'étendre)
- Optionnel : Peut être vide
- ScrollPhysics : Scrollable si dépassement

**3. Sélection Couleur**
- 6 boutons circulaires
- Sélection par défaut : Bleu (#2196F3)
- Bouton sélectionné a une bordure visible
- **L'AppBar change de couleur selon la sélection** ✨

**4. Bouton Sauvegarder**
- Récupère les données du formulaire
- Crée ou met à jour l'objet `Note`
- Valide que le titre n'est pas vide
- Retourne la note à la page précédente
- Affiche message d'erreur si validation échoue

#### Deux Modes de Fonctionnement :

**Mode 1 : Nouvelle Note** 🆕
```dart
// Affichage : "Nouvelle Note" en AppBar
// Création d'une Note vierge
Note note = Note(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  titre: '',
  contenu: '',
  couleur: '#2196F3',  // Bleu par défaut
  dateCreation: DateTime.now(),
  dateModification: null,
);
```

**Mode 2 : Édition** ✏️
```dart
// Affichage : "Modifier Note" en AppBar
// Pré-remplissage des champs avec la note existante
// Conservation de l'ID et dateCreation originels
Note note = Note(
  id: existingNote.id,              // IDENTIQUE
  titre: titleController.text,
  contenu: contentController.text,
  couleur: selectedColor,
  dateCreation: existingNote.dateCreation,  // IDENTIQUE
  dateModification: DateTime.now(),  // MISE À JOUR
);
```

#### Logique de Validation :
```dart
// Vérification simple mais effective
if (titleController.text.isEmpty) {
  ScaffoldMessenger.showSnackBar(
    SnackBar(content: Text('Le titre ne peut pas être vide'))
  );
  return;  // Empêche la sauvegarde
}

// Si validation OK, sauvegarde et retour
Navigator.pop(context, noteCreatedOrModified);
```

---

### 🔍 DetailNotePage - Vue Détaillée d'une Note

**Chemin** : `lib/pages/detail_page.dart`

**Objectif** : Afficher la note complète avec ses métadonnées et options d'action

#### Composition :
```
┌─────────────────────────────────────┐
│  ← Titre de la note           [✏️] [🗑️] │ ← AppBar avec boutons action
├─────────────────────────────────────┤
│  Créée le : 21/04/2026 à 14:30      │ ← Date de création formatée
│  Modifiée le : 21/04/2026 à 15:45   │ ← Date de modification (si existe)
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                      │
│  Contenu de la note                 │
│  ___________________________________  │
│  ___________________________________  │
│  ___________________________________  │
│  Peut être très long sur plusieurs   │
│  lignes, avec saut à la ligne...     │
│                                      │
└─────────────────────────────────────┘
```

#### Informations Affichées :

**1. Titre et Couleur**
- Titre complet en gros caractères
- Couleur de l'AppBar = couleur de la note
- Barre de statut teintée de la même couleur

**2. Métadonnées (Dates)**
- **Date de création** : formatée en français (DD/MM/YYYY HH:MM)
  - Ex : "21 avril 2026 à 14:30"
- **Date de modification** : affichée seulement si la note a été éditée
  - Ex : "Modifiée le 21 avril 2026 à 15:45"

**3. Contenu**
- Texte complet de la note
- Scrollable si le texte est très long
- Format préservé (sauts de ligne, etc.)

#### Boutons d'Action (AppBar) :

**Bouton Éditer ✏️**
- Icône : `Icons.edit`
- Action : Ouvre `CreateNotePage` en mode édition
- Passe la note courante comme paramètre
- Reçoit la note modifiée au retour

**Bouton Supprimer 🗑️**
- Icône : `Icons.delete`
- Action : Affiche un dialog de confirmation
- Si confirmé : retourne `'deleted'` à la page précédente
- La note est supprimée par HomePage

#### Protection de Navigation :
```dart
PopScope(
  canPop: true,  // Permet le retour
  onPopInvokedWithResult: (didPop, result) {
    // Gère le retour de la page
    // Retourne la note modifiée ou 'deleted'
  },
  child: ...
)
```

#### Flux de Modification/Suppression :

**Modification** :
```
DetailPage ──[Edit]──► CreatePage ──[Modify]──► return Note ──► DetailPage updates
  │
  └─► HomePage reçoit Note ──► met à jour _notes[index]
```

**Suppression** :
```
DetailPage ──[Delete]──► Dialog Confirmation ──[OK]──► return 'deleted'
  │
  └─► HomePage reçoit 'deleted' ──► _notes.removeAt(index)
```

---

## Guide Utilisateur

### 📝 Comment Créer une Note ?

1. **Accédez à l'écran d'accueil** : L'app démarre sur `HomePage`
2. **Cliquez le bouton +** (FAB en bas à droite)
3. **Remplissez le formulaire** :
   - Entrez un **Titre** (obligatoire)
   - Entrez le **Contenu** (optionnel)
   - Sélectionnez une **Couleur**
4. **Cliquez "Sauvegarder"**
5. **La note apparaît** dans la liste de l'écran d'accueil

### 📖 Comment Consulter une Note ?

1. **Depuis l'écran d'accueil**, tapez sur une **carte note**
2. **La vue détaillée s'ouvre** avec :
   - Le titre complet
   - Le contenu entier
   - Les dates de création/modification
3. **Cliquez la flèche ← en haut** pour revenir à la liste

### ✏️ Comment Modifier une Note ?

1. **Ouvrez la note** (voir "Comment Consulter")
2. **Cliquez le bouton ✏️ (éditer)** en haut à droite
3. **Le formulaire s'ouvre** avec vos données pré-remplies
4. **Modifiez ce que vous voulez**
5. **Cliquez "Sauvegarder"**
6. **La note est mise à jour** dans la liste

### 🗑️ Comment Supprimer une Note ?

1. **Ouvrez la note** (voir "Comment Consulter")
2. **Cliquez le bouton 🗑️ (supprimer)** en haut à droite
3. **Un dialog demande confirmation** ("Êtes-vous sûr ?")
4. **Cliquez "OUI"** pour confirmer la suppression
5. **Vous retournez à la liste** - la note a disparu

### 🎨 Comment Changer la Couleur d'une Note ?

1. **Ouvrez le formulaire** (création ou édition)
2. **Cliquez sur un des 6 boutons couleur** :
   - 🔵 Bleu
   - 🟢 Vert
   - 🟡 Amber/Jaune
   - 🟠 Orange
   - 🟣 Violet
   - 🔴 Rose/Magenta
3. **Observez l'AppBar changer de couleur**
4. **Sauvegardez** pour appliquer

---

## Limitations Actuelles

### ⚠️ Vous Devez Savoir :

**1. Pas de Sauvegarde Persistante** 💾
- Les notes existent **uniquement en mémoire**
- Si vous fermez l'application complètement
- **TOUTES les notes sont perdues** ❌
- Nécessite une base de données (SQLite, Firebase, etc.) pour résoudre

**2. Pas de Recherche** 🔍
- Impossible de rechercher une note par mots-clés
- Vous devez scroller dans toute la liste

**3. Pas de Tri** 📊
- Les notes s'affichent dans l'ordre de création
- Pas de tri par date, titre, ou couleur
- Pas d'option "Plus récent d'abord"

**4. Pas d'Export/Import** 📤
- Impossible d'exporter vos notes
- Impossible d'importer depuis fichier
- Pas de sauvegarde externe

**5. Pas de Synchronisation** ☁️
- Une seule instance de l'app
- Pas de synchronisation sur cloud (Firebase, iCloud, etc.)
- Pas d'accès multi-appareils

**6. Pas de Catégories/Tags** 🏷️
- Seulement l'organisation par couleur
- Impossible d'assigner plusieurs catégories
- Une note = une couleur

**7. Pas de Partage** 👥
- Impossible de partager une note
- Pas de collaboration
- Notes 100% privées (stockage local)

---

## Résumé Technique

### Comment les Notes Sont Stockées ?

```dart
// Dans la classe HomePage, variable privée
List<Note> _notes = [];  

// ✅ AVANTAGE : Très simple, super rapide
// ❌ INCONVÉNIENT : Volatil, perte au redémarrage
```

### Cycle de Vie d'une Note

```
Création (HomePage.initState)
    ↓
Note._notes.add(note)  ← Stockage en RAM
    ↓
Utilisateur navigue (DetailPage, CreatePage, etc.)
    ↓
Note reste en mémoire (_notes)  ← Modifiée si édition
    ↓
[APP FERMÉE] ───► Note est supprimée de la mémoire ❌
```

### Données Structurées

```
HomePage._notes = [
  {
    id: '1234567890123',
    titre: 'Exemple 1',
    contenu: 'Contenu 1',
    couleur: '#2196F3',
    dateCreation: DateTime(...),
    dateModification: DateTime(...),
  },
  {
    id: '1234567890124',
    titre: 'Exemple 2',
    contenu: 'Contenu 2',
    couleur: '#4CAF50',
    dateCreation: DateTime(...),
    dateModification: null,  // N'a jamais été modifiée
  },
  ...
]
```

---

## Pour Aller Plus Loin

### Améliorations Suggérées 💡

**Court Terme** (facile) :
1. Ajouter une recherche par titre
2. Ajouter un tri (date, titre, couleur)
3. Ajouter une confirmation de sortie

**Moyen Terme** (modéré) :
1. Implémenter SQLite pour persistance
2. Ajouter des catégories/tags
3. Ajouter un système de favoris

**Long Terme** (avancé) :
1. Ajouter Firebase pour synchronisation cloud
2. Implémenter export PDF/TXT
3. Ajouter du rich text (gras, italique, etc.)
4. Authentification utilisateur multi-appareils

---

## Conclusion

**Blocknotii** est une application de prise de notes simple et didactique qui démontre les concepts fondamentaux de Flutter :
- Navigation entre pages
- Gestion d'état avec Stateful Widgets
- Formulaires et validation
- Architecture modulaire (séparation pages/modèles)

Elle est **parfaite pour apprendre** mais nécessite **des améliorations** pour une utilisation en production (persistance, synchronisation, etc.).

---

**Dernière mise à jour** : 21 avril 2026
**Version** : 1.0 (Base)
