# FFSS API v1.0 — Reference

Source: official FFSS API documentation, restructured for use by code / coding agents.
Shared models are defined once (TypeScript notation); endpoints reference them by name.

---

## 1. Conventions

| Topic | Rule |
|---|---|
| Base URL | Production `https://ffss.fr/api/v1.0/` · development `https://site.ffss.io/api/v1.0/` (the two the app actually talks to — see `core/config/app_environment.dart`). The source doc's `https://api.ffss.fr/v1.0` host does **not** serve this API; ignore it. Endpoint paths below are written with a leading `/`; the base URL already ends with one, so `ApiEndpoints` (`core/config/app_config.dart`) stores them without it (`competition/evenement`). |
| Auth | Every call takes a `token` param (query string for GET, form body for POST), except `/requestToken` and the `/organisme` endpoints. |
| Token | `POST /requestToken` → user token valid **24h**. A permanent application token must be requested from the FFSS head office (siège). |
| Path params | Written `:name` → replace with the value. |
| Envelope | Every response is `{ success, message, ...payload }`. |
| Errors | **Always HTTP 200.** Failure = `success: false` + `message`. Always check `success`, never the HTTP status alone. |
| `success` type | Usually boolean, but some examples return the string `"true"` → treat `true` and `"true"` as success. |
| Times / performances | Integers in **hundredths of a second** (`Temps`, `TempsLive1..3`, `Performance`). Text versions in `*Label` fields. |
| Date formats | Datetime `Y-m-d H:i:s` · Date `Y-m-d` · Hour `H:i` (e.g. `08:00`) |
| Booleans in params | Send `1` / `0`. |
| Arrays in params | PHP form style: `categories[]=1&categories[]=2`, `performances[]=...`, `resultats[]=...` (assumed from the `[]` notation). |
| Pagination (DataTables) | Params: `length` (default 10), `start` (default 0, page n → `start = length*(n-1)`), `order` (a capitalised object field, e.g. `Nom`), `orderValue` (`ASC`\|`DESC`). Returns `recordsTotal`, `recordsFiltered` (and sometimes `draw`, `version`). |
| Field casing | Capitalised fields (`Id`, `Nom`) are DB columns (sortable); camelCase fields (`label`, `statutLabel`) are computed. |

### Generic envelope

```ts
interface ApiResponse<T = unknown> {
  success: boolean | "true" | "false";
  message?: string;
  data?: T;
}
interface ListResponse<T> extends ApiResponse<T[]> { count?: number; }
interface DataTablesResponse<T> extends ApiResponse<T[]> {
  recordsTotal: number; recordsFiltered: number; draw?: number; version?: number;
}
interface SubmitResponse extends ApiResponse { id: number; isCreation?: boolean; }
type Lookup = Record<string, string>; // machine value -> label
```

---

## 2. Domain hierarchy

```
Evenement (competition)
├── Epreuve (discipline × genre × categories)
│   ├── Engagement (entry: organisme + athletes)
│   └── Serie (heat/final) ── Resultat (one per engagement)
├── Deroulement (event format for one discipline) ── Partie (stage: heats, semis, final…)
└── Reunion (session / day)
    └── Creneau (time slot, optional link to a Partie)
        └── Course (race, linked to a Serie)
            └── Place (lane: Engagement + Resultat) ── PlaceRemplacant
```

---

## 3. Models

```ts
type Genre = "H" | "F" | "M";          // Homme, Femme, Mixte
type DateTime = string;                // "Y-m-d H:i:s"

interface Categorie { Id: number; Nom: string; AgeMin: number; AgeMax: number; }

interface Discipline {
  Id: number; Nom: string;
  Specialite: number; specialiteLabel: string;   // 1 côtier, 2 eau-plate
  Distance: number;
  NbAthleteParEquipe: number;                    // 1 = individual event
}

interface Epreuve {
  Id: number; IdEvenement: number; IdDiscipline: number;
  Genre: Genre; genreLabel: string;
  discipline: Discipline; categories: Categorie[];
  isEligibleToNationalRecord: boolean;           // flat-water only
}

interface Parametre { Id: number; cle: string; cleLabel: string; Valeur: string; valeurLabel: string; }

interface Organisme {
  Id: number; NumAffiliationOrga: string; SiretOrga: string;
  TypeAssoIdAutomneOrga: number; typeAssoLabel: string; AssociationIsoleOrga: boolean;
  NomOrga: string; NomCompletOrga: string; label: string;
  RegionDepartementIdAutomneOrga: number; departementLabel: string;
  RegionIdAutomneOrga: number; regionLabel: string;   // doc swaps these two descriptions
  PrenomContactOrga: string; NomContactOrga: string;
  PrenomPresidentOrga: string; NomPresidentOrga: string;
  TelContactOrga: string; Tel2ContactOrga: string; MailContactOrga: string;
  MailOrga: string; TelOrga: string; Tel2Orga: string; SiteOrga: string;
  AdresseOrga: string; CodePostOrga: string; VilleOrga: string;
  StatutOrga: boolean; DateValiditeOrga: string; CommentaireOrga: string;
  NDAOrga: string; RNAOrga: string; APEOrga: string;
  CertificateurOrga: string; QualiopiCertificatOrga: string; QualiopiDateValiditeOrga: string;
  coordinates: unknown;      // "Coordinate" — structure not documented
  logo: string;              // URL
  bonnet: string;            // URL of cap image (competitions)
}

interface Officiel {
  Id: number; Prenom: string; Nom: string;
  isLicencie: boolean; isInvite: boolean; NumeroLicence: string;
  Sexe: string; Annee: number;
  Jours: number; joursLabel: string;
  Principal: boolean;                      // head judge
  Niveau: unknown; NiveauMax: unknown;     // structures not documented
  IdOrganisme: number; organismeLabel: string;          // organisme that registered the official
  idOfficielClub: number; officielClubLabel: string;    // official's own club (organisme or guest club)
  isValid: boolean;                        // licence validity (always true for guests)
  nationalite: string; nationaliteCode: string;
}

interface Evenement {
  Id: number; IdOrganisme: number; Organisme: Organisme; Nom: string;
  Statut: number; statutLabel: string;
  Specialite: number; specialiteLabel: string;   // 1 côtier, 2 eau-plate, 3 mixte
  Niveau: number; niveauLabel: string;
  Debut: string; Fin: string;                    // event dates
  DebutEngagement: string; Engagement: string;   // entries open / close dates
  TarifParClub: number; TarifParAthlete: number; TarifParEngagement: number;
  Description: string; NbEquipeParClub: number;
  parametres: Parametre[];
  isEligibleToNationalRecord: boolean;
  chronoLabel: string;
  officielPrincipal: Officiel;
}

interface Athlete {
  Id: number; Prenom: string; Nom: string;
  isLicencie: boolean; isInvite: boolean; NumeroLicence: string;
  Sexe: string; Annee: number;
  Performance: number; performanceLabel: string;   // entry time (1/100 s)
  idClub: string; clubLabel: string;               // organisme or guest club
  isValid: boolean;
  isRemplacant: boolean;                           // substitute vs starting athlete
  nationalite: string; nationaliteCode: string;
}

interface Participant {          // athlete at event level
  Id: number; Prenom: string; Nom: string;
  isLicencie: boolean; isInvite: boolean; NumeroLicence: string;
  Sexe: string; Annee: number;
  idClub: string; clubLabel: string;
  Dossard: string;               // bib number
  isValid: boolean;
  epreuves: Epreuve[];
}

interface OrganismeParticipant { Id: number; label: string; officiels: Officiel[]; athletes: Participant[]; }

interface Engagement {
  Id: number; IdEpreuve: number; categorie: Categorie;
  IdOrganisme: number; Organisme: Organisme;
  Statut: number; statutLabel: string;
  athletes: Athlete[];
  forfait: boolean;
}

interface Partie {
  Id: number; IdDiscipline: number;
  Ordre: number;                                           // stage number
  Niveau: string; niveauLabel: string;                     // see Serie.niveaux lookup
  LogiqueQualification: string; logiqueQualificationLabel: string; // see Partie.logiques lookup
  categories: Categorie[];
  NbCourse: number; NbPlaceParCourse: number;
  NbPlaceQualificative: number;                            // qualifiers to next stage
}

interface Deroulement {
  Id: number; label: string; fullLabel: string;
  IdDiscipline: number; Discipline: Discipline;
  Genre: Genre; genreLabel: string;
  categories: Categorie[]; Parties: Partie[];
}

interface Creneau { Id: number; label: string; fullLabel: string; Nom: string; partie: Partie | null; }

interface Reunion {
  Id: number; label: string; fullLabel: string;
  Nom: string; Description: string; Jour: string;
  Debut: string; Fin: string;
  creneaus: Creneau[];
}

interface PlaceRemplacant {
  Id: number;
  Athlete: Athlete;              // replaced athlete
  Invite: unknown | null;        // replacing guest  (structure not documented)
  Licencie: unknown | null;      // replacing licensee (structure not documented)
  nationalite: string; nationaliteCode: string;
}

interface Place {
  Id: number; Numero: string;    // lane number
  Engagement: Engagement; Resultat: Resultat;
  remplacants: PlaceRemplacant[];
}

interface Course {
  Id: number; label: string; fullLabel: string;
  Nom: string; Site: string;
  Statut: string; statutLabel: string;   // 0 En attente, 1 Marshalling, 2 En cours, 3 Terminé
  Debut: string; Fin: string;
  Serie: Serie; places: Place[];
}

interface Serie {
  Id: number; Nom: string; Fini: boolean; Numero: number;
  UpdatedAt: DateTime; Debut: DateTime; Fin: DateTime;
  epreuve: Epreuve; resultats: Resultat[];
}

interface Resultat {
  Id: number; isValid: boolean;
  Statut: number; statutLabel: string;            // see Resultat.statuts lookup
  Rang: number;                                   // 0 = no rank
  Temps: number; tempsLabel: string;              // 1/100 s
  TempsLive1: number; TempsLive2: number; TempsLive3: number;
  complement: string; complementLabel: string;    // see Resultat.complements lookup
  disqualificationCode: string; disqualificationReason: string;
  disqualificationObject: DisqualificationCode;
  serie: Serie; engagement: Engagement;
  Athletes: Athlete[];                            // may differ from engagement (substitutions)
}

type DisqualificationCode = unknown;   // structure not documented

// Ranking payloads
interface ClassementAthleteRow { rang: number; athlete: unknown[]; points: number; nbCourses: number; }
interface ClassementAthleteByCategorie { id: number; categorie: Categorie; classement: ClassementAthleteRow[]; }
interface ClassementOrganismeRow { rang: number; organisme: unknown[]; points: number; nbAthletes: number; nbCourses: number; }
```

---

## 4. Endpoints

Legend: `?` = optional · `[]` = array · `(1)` = default value · all endpoints also take `token` unless marked **no token**.

### 4.1 Auth

| Method | Path | Params | Returns |
|---|---|---|---|
| POST | `/requestToken` | **no token** · `login`, `password` | `{ token, expiration: DateTime }` |
| GET | `/me` | — | `{ label, type, data: any }` (data depends on user type) |

### 4.2 Evenement (competition)

| Method | Path | Params | Returns |
|---|---|---|---|
| GET | `/competition/evenement` | `saison?` (e.g. `2021-2022`, **filter currently disabled**), `debut?`, `fin?`, `niveau?`, `type?` (1 côtier, 2 eau-plate, 3 mixte), `visibility?` (`incoming`\|`passed`), `search?`, pagination | `DataTablesResponse<Evenement>` |
| GET | `/competition/evenement/:id` | — | `Evenement` |
| GET | `/competition/evenement/:id/me` | — | `data` incl. roles: `public, admin, hote, organisme_participant, licencie, athlete, officiel, juge_principal` |
| GET | `/competition/evenement/:id/categories` | — | `Categorie[]` |
| GET | `/competition/evenement/:id/disciplines` | — | `Discipline[]` |
| GET | `/competition/evenement/:id/officiels` | — | `Officiel[]` |
| GET | `/competition/evenement/:id/organismes` | — | `OrganismeParticipant[]` (organismes with entries) |
| GET | `/competition/evenement/:id/participants` | — | `Participant[]` |
| POST | `/competition/evenement/:id/participant/dossard/generate` | — | `message` (assigns bibs to participants without one) |
| GET | `/competition/evenement/:id/participant/classement` | `byCategorie?` (1), `withGuest?` (1), `withRelais?` (0), `sexe?` (`H`\|`F`, empty = all) | byCategorie=1 → `ClassementAthleteByCategorie[]`; 0 → `ClassementAthleteRow[]` |
| GET | `/competition/evenement/:id/organisme/classement` | `withGuest?` (1), `withRelais?` (0) | `ClassementOrganismeRow[]` |
| POST | `/competition/evenement/:id/cache/clear` | requires **private-access token** | `{ success, message }` — idempotent; caches rebuild on next read |

### 4.3 Epreuve

| Method | Path | Params | Returns |
|---|---|---|---|
| GET | `/competition/epreuve` | `evenement` | `ListResponse<Epreuve>` |
| GET | `/competition/epreuve/:id` | — | `Epreuve` |

### 4.4 Engagement (entries)

| Method | Path | Params | Returns |
|---|---|---|---|
| GET | `/competition/engagement` | `epreuve` | `ListResponse<Engagement>` |
| GET | `/competition/engagement/:id` | — | `Engagement` |
| POST | `/competition/engagement/:id/submit` | `forfait` (bool) | `{ success, message }` |

### 4.5 Deroulement (event format)

| Method | Path | Params | Returns |
|---|---|---|---|
| GET | `/competition/:id/deroulement` | `:id` = evenement | `DataTablesResponse<Deroulement>` |
| GET | `/competition/deroulement/:id` | — | `Deroulement` |
| POST | `/competition/:competition/deroulement/submit` | `id?` (update; **not** the URL id), `discipline` (must belong to the event), `genre`, `categories[]` (non-empty) | `SubmitResponse` |
| POST | `/competition/deroulement/:id/delete` | — | `{ success, message }` |

### 4.6 Partie (stage of a deroulement)

| Method | Path | Params | Returns |
|---|---|---|---|
| GET | `/competition/deroulement/partie/:id` | — | `Partie` |
| POST | `/competition/deroulement/:deroulement/partie/submit` | `id?`, `ordre`, `niveau` (slug), `logiqueQualification` (code), `nbCourse`, `nbPlaceParCourse`, `nbPlaceQualificative`, `categories[]` | `SubmitResponse` |
| POST | `/competition/deroulement/partie/:id/delete` | — | `{ success, message }` |

### 4.7 Reunion (session)

| Method | Path | Params | Returns |
|---|---|---|---|
| GET | `/competition/:id/reunion` | `:id` = evenement | `DataTablesResponse<Reunion>` |
| GET | `/competition/reunion/:id` | — | `Reunion` |
| POST | `/competition/:competition/reunion/submit` | `id?` (update; **not** the URL id), `nom`, `description`, `jour` (`Y-m-d` or `d/m/Y`), `debut` (`H:i`), `fin` (`H:i`) | `SubmitResponse` |
| POST | `/competition/reunion/:id/delete` | — | `{ success, message }` |

### 4.8 Creneau (time slot)

| Method | Path | Params | Returns |
|---|---|---|---|
| GET | `/competition/reunion/creneau/:id` | — | `Creneau` |
| POST | `/competition/reunion/:reunion/creneau/submit` | `id?`, `nom`, `debut` (`H:i`), `fin` (`H:i`), `partie?` (null = informational slot) | `SubmitResponse` |
| POST | `/competition/reunion/creneau/:id/delete` | — | `{ success, message }` |

### 4.9 Course (race)

| Method | Path | Params | Returns |
|---|---|---|---|
| GET | `/competition/reunion/creneau/:id/course` | `:id` = creneau (doc says "evenement", likely wrong) | `ListResponse<Course>` |
| GET | `/competition/reunion/creneau/course/:id` | — | `Course` |
| POST | `/competition/reunion/creneau/:creneau/course/submit` | `nom`, `description`, `jour` (`Y-m-d`), `debut` (`H:i`), `fin` (`H:i`) — no `id` documented for update | `SubmitResponse` |
| POST | `/competition/reunion/creneau/course/:id/delete` | — | `{ success, message }` |

### 4.10 Place (lane) & lane substitutes

| Method | Path | Params | Returns |
|---|---|---|---|
| GET | `/competition/reunion/creneau/course/place/:id` | — | `Place` |
| POST | `/competition/reunion/creneau/course/:course/place/submit` | `id?`, `numero`, `engagement`, `resultat`, (`nom?`, `debut?`, `fin?`, `partie?` — likely copy-paste in doc) | `SubmitResponse` |
| POST | `/competition/reunion/creneau/course/place/:id/delete` | — | `{ success, message }` |
| POST | `/competition/reunion/creneau/course/place/:place/remplacant/submit` | doc lists `id?`, `nom`, `debut`, `fin`, `partie` — **suspect copy-paste**; expected `athlete`, `invite`\|`licencie` (verify) | `SubmitResponse` |
| POST | `/competition/reunion/creneau/course/place/:id/remplacant/delete` | `:id` = place | `{ success, message }` |

### 4.11 Serie (heat / final)

| Method | Path | Params | Returns |
|---|---|---|---|
| GET | `/competition/serie` | `epreuve` | `ListResponse<Serie>` |
| GET | `/competition/serie/:id` | — | `Serie` |
| POST | `/competition/serie/submit` | `id?` (update if exists), `nom` (unique per epreuve), `epreuve`, `statut` (0 validé — needs admin/juge_principal, 1 en attente, 2 refusé), `fini?` (false), `numero?` (1; 2 = final, legacy), `niveau?` (default `heat`), `debut?`, `fin?` (DateTime), `course?`, `resultats[]?` (same shape as Resultat.submit) | `SubmitResponse` (`isCreation`, `id`) |
| POST | `/competition/serie/:id/delete` | — | `{ success, message }` |

### 4.12 Resultat

| Method | Path | Params | Returns |
|---|---|---|---|
| GET | `/competition/resultat/:id` | — | `Resultat` |
| GET | `/competition/resultat/best` | `discipline`, `categorie`, `genre`, `from` (`Y-m-d`), `to` (`Y-m-d`) | `Resultat` |
| GET | `/competition/resultat/isRecord` | `performances[]`, `discipline`, `bassin` (1 = 25 m, 2 = 50 m), `genre`, `categorie`, `saison?` (`AAAA-AAAA`, only if national=0), `national?` (1 record de France, 0 meilleure perf. nationale, empty = all) | `{ isRecord: boolean, actual: Resultat }[]` |
| POST | `/competition/resultat/submit` | `id?` (update if exists), `serie`, `engagement`, `temps?`, `tempsLive1?`, `tempsLive2?`, `tempsLive3?` (1/100 s, null OK e.g. côtier), `rang` (0 = none), `statut`, `points?`, `complement`, `remplacants?` (`[{athlete, invite, licencie}]`), `place?` (place's substitutes applied unless `remplacants` sent) | `SubmitResponse` (`isCreation`, `id`) |
| POST | `/competition/resultat/:id/delete` | — | `{ success, message }` |
| GET | `/competition/resultat/:id/remplacant/available` | — | `{ data: { invites: Invite[], licencies: Licencie[] } }` |
| POST | `/competition/resultat/:id/remplacant/submit` | `athlete` (replaced), `invite` \| `licencie` (replacement) | `SubmitResponse` (AthleteRemplacant id) |
| POST | `/competition/resultat/remplacant/:id/delete` | `:id` = AthleteRemplacant | `{ success, message }` |

### 4.13 Lookups (reference values)

| Method | Path | Returns (`Lookup`) — known values |
|---|---|---|
| GET | `/competition/serie/niveau` | `heat` Série, `quarter` Quart de finale, `semi` Demi-finale, `final` Finale |
| GET | `/competition/serie/statut` | example: `0` Validée, `2` En attente, `3` Refusée, … (conflicts with Serie.submit) |
| GET | `/competition/deroulement/partie/logique` | `none` N/A, `course` Par course, `partie` Toute course confondue, … |
| GET | `/competition/reunion/creneau/course/statut` | `0` En attente, `1` Marshalling, (`2` En cours, `3` Terminé) |
| GET | `/competition/resultat/statut` | `0` OK, `1` DQ, `2` F, `3` F/DQ, … |
| GET | `/competition/resultat/complement` | `QFA` Qualifié Finale A, `QFB` Qualifié Finale B, `F` Forfait, `FF` Forfait finale, … |
| GET | `/competition/disqualification` | `DisqualificationCode[]` |
| GET | `/typeOrga` | `23` Club / Association, `24` Comité départemental, `25` Ligue régionale |

Fetch lookups at startup and cache them; the lists above are partial examples from the doc.

### 4.14 Organismes

| Method | Path | Params | Returns |
|---|---|---|---|
| GET | `/organisme` | **no token** · `departement?`, `region?`, `type?` (typeOrga id), `siret?`, `search?`, pagination | `DataTablesResponse<Organisme>` |
| GET | `/organisme/:id` | **no token** | `Organisme` |

---

## 5. Known inconsistencies in the source doc (verify before relying on them)

1. Several list endpoints declare `data: Evenement` but actually return arrays (`Categorie[]`, `Discipline[]`, `Officiel[]`, `Participant[]`, `OrganismeParticipant[]`).
2. `Resultat.Remplacant.submit` representative URL shows `/competition/resultat/submit`; the real path is `/competition/resultat/:id/remplacant/submit`.
3. `Place.Remplacant.submit` params (`nom`, `debut`, `fin`, `partie`) are copied from Creneau.submit.
4. `Place.submit` also lists `nom`, `debut`, `fin`, `partie` (probably copy-paste).
5. Serie statut: `Serie.submit` says `0/1/2` (validé/en attente/refusé), lookup example shows `0/2/3`.
6. `Serie.submit.niveau` typed Number, but niveaux are slugs (`heat`, `final`…).
7. `Resultat.submit.complement` typed Number, but complements are string codes (`QFA`, `F`…).
8. `Course.submit` has no `id` param → update path unclear.
9. `Organisme.regionLabel` / `RegionIdAutomneOrga` descriptions are swapped.
10. `Course.list` describes `:id` as an evenement id though the path is `creneau/:id/course`.
11. Return model fields documented as `Result.*` instead of `Resultat.*` (same object). `points` is accepted on submit but not documented on read.
12. `Course.submit` date format written `Y-m-D` (assume `Y-m-d`).
