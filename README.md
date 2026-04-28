# Dirty Service Prototype

This repo is a fresh Godot 4 prototype for the back-of-house plate scraping game described in the build plan.

## Current scope

The first playable loop is intentionally narrow:

- One player character with `WASD` movement
- `Space` for pickup/drop
- `Q` to slide a tray from drop-off into the work lane
- `E` to process the next dirty item on the work table
- `F` to put the next processed item away
- `Esc` to pause
- Dirty tray delivery from waiters to a 4-slot drop-off table
- Direct tray interception from waiters if you reach them before they unload
- One work table slot for active tray processing
- Plate scraping into garbage plus glass dumping into a liquid bucket
- One plate crate that fills, must be walked to kitchen, and swapped for an empty crate
- One glass rack that fills, must be walked to kitchen, and swapped for an empty rack
- One garbage station that fills from scraping and must be bagged and walked to disposal
- One liquid bucket that fills from glasses and must be carried to the sink, dumped, and returned
- A visible kitchen pit where returned empty trays are cleaned into clean trays over time
- Service Collapse pressure from waiter delay, full drop-off congestion, ignored garbage, and ignored liquid
- Success and failure end screens
- Post-event report grading on successful runs
- Data-driven balance loaded from `data/levels/level_01.json`

This prototype now includes the first glass-handling pass. Cutlery, debris/strainers, collisions, crate variants, and more expressive NPC behavior are left for the next pass.

## Run

1. Open the folder in Godot 4.x.
2. Load `project.godot`.
3. Run the main scene.

The main scene is [`scenes/main.tscn`](C:\Users\bryce\Desktop\game\scenes\main.tscn) and the gameplay script is [`scripts/main.gd`](C:\Users\bryce\Desktop\game\scripts\main.gd).

Core support scripts:

- [`scripts/core/LevelConfig.gd`](C:\Users\bryce\Desktop\game\scripts\core\LevelConfig.gd)
- [`scripts/core/ServiceCollapseManager.gd`](C:\Users\bryce\Desktop\game\scripts\core\ServiceCollapseManager.gd)
- [`scripts/core/ScoreManager.gd`](C:\Users\bryce\Desktop\game\scripts\core\ScoreManager.gd)
- [`data/levels/level_01.json`](C:\Users\bryce\Desktop\game\data\levels\level_01.json)

## Prototype loop

1. Pull dirty trays off the drop-off table with `Space`, or intercept them directly from waiters.
2. Slide a tray from drop-off into the work lane with `Q`, or carry it there with `Space`.
3. Process tray items with `E`: scrape plates into garbage and dump glasses into the liquid bucket.
4. Put processed items away with `F`: plates go into the crate and glasses go into the glass rack.
5. Return the empty tray to the tray rail with `Space`.
6. When the plate crate or glass rack fills, carry it to the kitchen, then carry back an empty replacement.
7. Watch the kitchen pit convert dirty returned trays into clean trays over time.
8. When garbage fills, lift the bag, carry it to the disposal zone, and return to work.
9. When the liquid bucket fills, carry it to the sink, dump it, and return it to the station.
10. If you survive to the timer, the successful run now shows a category-based post-event report.

## Next good additions

- Add cutlery collection and a second sorting action
- Add garnish/straw debris handling for glasses
- Add solid collisions around tables and tighter pathing pressure
- Split scene logic into reusable `Player`, `Waiter`, and `Station` scripts
- Add art, sounds, feedback, and stronger UI signaling for collapse warnings
