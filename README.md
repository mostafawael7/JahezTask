# Movie discovery (TMDB)

## Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/ec8f770d-13bb-4f7a-a834-4258775796f0" alt="Home screen: trending movies, search, genre chips, grid" width="240" />
  <img src="https://github.com/user-attachments/assets/8a0cd4ef-104e-405c-a487-a4fba492b5c7" alt="Home screen: trending movies, search, genre chips, grid" width="240" />
  <img src="https://github.com/user-attachments/assets/e156bcc8-66b8-4ed3-ae37-0dc6bd536285" alt="Home screen: trending movies, search, genre chips, grid" width="240" />
  <img src="https://github.com/user-attachments/assets/40fdc726-be58-4c84-a9e1-8b14941cc70a" alt="Home screen: trending movies, search, genre chips, grid" width="240" />
  <img src="https://github.com/user-attachments/assets/caedcb5e-49e3-443a-92ef-1339462d1e49" alt="Home screen: trending movies, search, genre chips, grid" width="240" />
</p>

---

## Features

- **Home**
  - Trending / discover-style list with **infinite scroll** and **pagination** (loads in UI batches of 10).
  - **Two-column** poster grid with consistent card layout.
  - **Search** via TMDB `search/movie` (debounced); resets paging when the query changes.
  - **Genre chips** from `genre/movie/list`; selection calls `discover/movie` with `with_genres` and resets the list.
  - Empty state when search/filter returns no rows.
- **Movie details** (tap a card)
  - Fetches `movie/{id}` and shows title, poster (high-res with fallbacks), release month/year, genres, overview, homepage (link when present), budget, revenue, spoken languages, status, runtime.
  - Sections with no data are hidden (e.g. no homepage row if missing).
- **Networking**
  - Generic `NetworkService` with typed decoding and centralized error mapping; console logging for requests/responses.
- **Architecture**
  - **MVVM** for presentation, **Clean-style** layering inside the app target: `Domain` (models, repository protocol, use cases), `Data` (TMDB implementation, DTOs), `Presentation` (SwiftUI + view models), `Network`.

---

## Project layout (high level)

```
task/
├── Domain/           # Models, repository protocol, use cases
├── Data/             # REST implementation, DTOs
├── Network/          # NetworkService, NetworkError
├── Presentation/
│   ├── Home/         # HomeView, HomeViewModel, CachedPosterView
│   └── Details/      # MovieDetailsView, MovieDetailsViewModel
├── Constants.swift
├── ContentView.swift # Composition root
└── taskApp.swift
```

---
