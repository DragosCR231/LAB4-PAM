# Learning Lab 4 – Variant 4 (REST API + JSON + Clean Architecture)

Același design ca în Laboratorul 3 (Home → Course Overview → Lesson details),
dar datele vin acum de la un serviciu Web REST prin HTTP:

| Endpoint | Ecran |
|---|---|
| `GET https://test-api-jlbn.onrender.com/lab2026/v4/feed` | Home (salut, progres, learning plan, meetup) |
| `GET https://test-api-jlbn.onrender.com/lab2026/v4/feed/details` | Course Overview (curs, lecții, preț) + cardul de curs de pe Home |

## Rulare

```sh
flutter pub get
flutter run
flutter test
```

> Serverul este pe Render (plan gratuit): la primul apel poate dura 30–50 s până „se trezește”.
> Timeout-ul este 60 s; dacă expiră apare mesajul de eroare cu butonul **Try again**.

## Structura (Clean Architecture)

```
lib/
├── main.dart                       pornește aplicația, creează Cubit-ul și apelează load()
├── injection.dart                  leagă straturile: ApiClient → DataSource → Repository → UseCases → Cubit
├── core/
│   ├── network/api_client.dart     cerere HTTP GET, verificare status, jsonDecode
│   ├── network/api_constants.dart  URL-uri, timeout
│   └── error/                      exceptions (Data), failures (Domain), Result<T> = Ok | Err
└── features/learning/
    ├── domain/                     (nu depinde de Flutter / HTTP / JSON)
    │   ├── entities/               HomeFeed, PlanItem, Course, Lesson
    │   ├── repositories/           LearningRepository (interfață abstractă)
    │   └── usecases/               GetHomeFeed, GetCourseDetails
    ├── data/
    │   ├── models/                 HomeFeedModel, CourseDetailsModel (fromJson / toJson / toEntity)
    │   ├── datasources/            LearningRemoteDataSource – apelează API-ul
    │   └── repositories/           LearningRepositoryImpl – DTO → Entity, Exception → Failure
    └── presentation/
        ├── cubit/                  LearningCubit + LearningState (loading / success / empty / error)
        ├── screens/                HomeScreen, CourseOverviewScreen, LessonDetailsScreen
        └── widgets/                componente reutilizabile (LoadingView, StatusMessage, InlineError,
                                    NetworkPhoto, SectionHeading, LessonTile, LessonFilterBar, ...)
```

Regula dependențelor: **Presentation → Domain ← Data**. Domain nu importă nimic din celelalte straturi;
Data implementează interfața din Domain (inversarea dependenței).

## Fluxul datelor (UI → Web Service → UI)

1. **UI** – `main.dart` creează `LearningCubit` și apelează `load()`; la pull-to-refresh sau
   butonul *Try again* se apelează din nou `load()` / `loadCourse()`.
2. **Cubit** emite `LoadStatus.loading` (UI afișează `LoadingView`) și apelează use case-urile
   `GetHomeFeed()` și `GetCourseDetails()` **în paralel** (`Future.wait`).
3. **Use case** → `LearningRepository.getHomeFeed()` (interfața din Domain).
4. **LearningRepositoryImpl** (Data) → `LearningRemoteDataSource.fetchHomeFeed()`.
5. **DataSource** → `ApiClient.getJson('/feed')` → `http.get(...)` către serverul REST.
6. **ApiClient** verifică status code-ul (2xx), decodează corpul cu `jsonDecode` → `Map<String, dynamic>`.
   La erori aruncă `ServerException`, `NetworkException`, `ParsingException` sau `TimeoutException`.
7. **DataSource** deserializează: `HomeFeedModel.fromJson(map)`.
8. **Repository** transformă modelul în entitate (`toEntity()`) și întoarce `Ok(entity)`;
   excepțiile devin `Err(Failure)` cu un mesaj prietenos.
9. **Cubit** face `result.fold(...)` și emite `success` / `empty` / `error`.
10. **UI** (`BlocBuilder`) se reconstruiește și afișează datele sau mesajul de eroare.

Cele două request-uri au stări separate: dacă `/feed/details` cade, Home se afișează normal,
iar doar cardul de curs arată eroarea cu buton **Retry**.

## Funcționalități păstrate din Laboratorul 3

Căutare lecții, filtre (All / Available / Favorites / Completed), sortare (ordine curs / titlu / durată),
favorite, marcare lecție ca finalizată, Enroll (deblochează lecțiile blocate), tab-uri Lessons / Description.

## Teste

- `test/data_layer_test.dart` – serializare JSON (fromJson/toJson) și maparea erorilor HTTP în Failure.
- `test/learning_cubit_test.dart` – stări loading/success/empty/error, căutare, filtre, sortare.
- `test/widget_test.dart` – navigare Home → Course → Lesson și ecranul de eroare.

Testele folosesc `MockClient` (din `package:http/testing.dart`) cu răspunsuri reale salvate în `test/fixtures/`,
deci nu au nevoie de internet.
