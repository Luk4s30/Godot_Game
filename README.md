# Vroom Vroom

Projekt "Vroom Vroom" to gra wyścigowa 2D z widokiem top-down, stworzona w silniku Godot z wykorzystaniem języka GDScript. Głównym założeniem projektu było stworzenie grywalnego prototypu, ze szczególnym naciskiem na mechanikę jazdy i sztuczną inteligencję przeciwników.

## Główne funkcjonalności

* **Trzy kompletne trasy:** Zróżnicowane mapy: Tor, Las oraz Park.
<img width="300" height="180" alt="image1" src="https://github.com/user-attachments/assets/f58bb489-93aa-4511-b8d0-da85e3ebf590" />
<img width="300" height="180" alt="image4" src="https://github.com/user-attachments/assets/d87be91d-bd65-41c7-8282-3375d5d5de91" />
<img width="300" height="180" alt="image9" src="https://github.com/user-attachments/assets/e20e1fa8-7c4a-43a4-bab8-5961eb8790e9" />

* **Zaawansowany model jazdy:** Ruch pojazdu oparty na algorytmie *Kinematic Bicycle Model*. Dodana symulacja bezwładności oraz wektor prędkości szacowany w czasie pozwalają na kontrolowany poślizg (drift) przy wysokich prędkościach lub niskiej przyczepności.
<img width="400" alt="image6" src="https://github.com/user-attachments/assets/377a4a64-c2de-4d07-9367-06c6aa9f451b" />

* **Fizyka kolizji:** System identyfikujący rodzaj uderzonego obiektu i obliczający odpowiedni wektor odbicia na podstawie aktualnej prędkości. Zderzenia z otoczeniem powodują silniejsze wytracenie prędkości niż kontakty z rywalem.
  
* **System Sztucznej Inteligencji (AI):** Przeciwnicy sterowani są przez dwa niezależne systemy:
  * *Podążanie za ścieżką:* Pojazd płynnie podąża za dynamicznie wyznaczanym punktem docelowym umieszczonym na torze jazdy.
  * *Unikanie przeszkód:* System sensorów z przodu pojazdu wykrywający inne samochody, przeszkody i granice trasy. W razie zagrożenia oblicza korektę i zmusza auto do skrętu.
<img width="359" height="305" alt="image5" src="https://github.com/user-attachments/assets/4d0bea6e-04b8-42c8-a5ee-bdc5c65ac802" />

* **Dwa tryby gry:**
  * *Próba czasowa:* Walka o najlepszy czas z wyświetlaną lokalną tablicą wyników, rekordami oraz czasami bieżącymi.
  * *Wyścig:* Rywalizacja z komputerem na torze.
<img width="350" alt="image3" src="https://github.com/user-attachments/assets/eb2979ba-2f8c-44cb-901c-af331e3b8d94" />

* **Garaż pojazdów:** Do wyboru 4 samochody różniące się teksturą i statystykami: mocą silnika, skrętnością oraz przyczepnością.
<img width="350" alt="image8" src="https://github.com/user-attachments/assets/d4532158-751a-4a13-a1e1-0e4bc893dd82" />

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
