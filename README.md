# Vroom Vroom

Projekt "Vroom Vroom" to gra wyścigowa 2D z widokiem top-down, stworzona w silniku Godot z wykorzystaniem języka GDScript. Głównym założeniem projektu było stworzenie grywalnego prototypu, ze szczególnym naciskiem na mechanikę jazdy i sztuczną inteligencję przeciwników.

## Główne funkcjonalności

* **Trzy kompletne trasy:** Zróżnicowane mapy: Tor, Las oraz Park.
* **Zaawansowany model jazdy:** Ruch pojazdu oparty na algorytmie *Kinematic Bicycle Model*. Dodana symulacja bezwładności oraz wektor prędkości szacowany w czasie pozwalają na kontrolowany poślizg (drift) przy wysokich prędkościach lub niskiej przyczepności.
* **Fizyka kolizji:** System identyfikujący rodzaj uderzonego obiektu i obliczający odpowiedni wektor odbicia na podstawie aktualnej prędkości. Zderzenia z otoczeniem powodują silniejsze wytracenie prędkości niż kontakty z rywalem.
* **System Sztucznej Inteligencji (AI):** Przeciwnicy sterowani są przez dwa niezależne systemy:
  * *Podążanie za ścieżką:* Pojazd płynnie podąża za dynamicznie wyznaczanym punktem docelowym umieszczonym na torze jazdy.
  * *Unikanie przeszkód:* System sensorów z przodu pojazdu wykrywający inne samochody, przeszkody i granice trasy. W razie zagrożenia oblicza korektę i zmusza auto do skrętu.
* **Dwa tryby gry:**
  * *Próba czasowa:* Walka o najlepszy czas z wyświetlaną lokalną tablicą wyników, rekordami oraz czasami bieżącymi.
  * *Wyścig:* Rywalizacja z komputerem na torze.
* **Garaż pojazdów:** Do wyboru 4 samochody różniące się teksturą i statystykami: mocą silnika, skrętnością oraz przyczepnością.

## Sterowanie

* `[W]` - Gaz
* `[S]` - Hamulec / Cofanie
* `[A] / [D]` - Skręt

##  Instalacja i uruchomienie

1. Pobierz lub sklonuj to repozytorium.
2. Pobierz silnik [**Godot**](https://godotengine.org/) w wersji 4.5.
3. Uruchom silnik Godot, kliknij "Import", wskaż plik `project.godot` znajdujący się w folderze gry i uruchom projekt.

## Roadmap

- [ ] Możliwość edytowania ustawień wyścigów.
- [ ] Ulepszenie modelu AI poprzez dodanie różnych poziomów trudności.
- [ ] Modyfikacja kolizji, aby zachowywały się w sposób bardziej przewidywalny.

## Źródła i zasoby

* **Silnik:** [Godot Engine](https://godotengine.org/pl/) oraz [Dokumentacja](https://docs.godotengine.org/en/stable/index.html).
* **Grafika:** [Kenney - Racing Pack](https://kenney.nl/assets/racing-pack).
* **Muzyka:** [dj pengu (itch.io)](https://mumusi-c21.itch.io/dj-pengu).
* **Czcionka:** [Fredoka (Google Fonts)](https://fonts.google.com/specimen/Fredoka).
* **Wiedza:** Model poruszania inspirowany artykułem [EngineeringDotNet](https://engineeringdotnet.blogspot.com/2010/04/simple-2d-car-physics-in-games.html).
