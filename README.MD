# Vertex

A 3D first-person shooter game built with [Godot Engine 4.7](https://godotengine.org/).

## Controls

| Action | Key |
|--------|-----|
| Move | W / A / S / D |
| Jump | Space |
| Fire | Left Mouse Button |
| Look | Mouse |

## Features

- FPS camera with mouse look
- Raycast-based shooting with recoil
- Enemy AI that chases and attacks at close range
- Enemy spawner with random spawn points
- Health bar and ammo HUD
- Main menu

## Project Structure

| File | Description |
|------|-------------|
| `player.gd` / `player.tscn` | Player controller, shooting, HUD, health |
| `enemy.gd` / `enemy.tscn` | Enemy AI with chase and melee attack |
| `enemy_spawner.gd` | Timer-based enemy spawning at Marker3D points |
| `bullet.gd` / `bullet.tscn` | Bullet projectile with collision detection |
| `main_menu.gd` / `main_menu.tscn` | Start/Quit menu |
| `world.tscn` | Main game world scene |

## Requirements

- [Godot Engine 4.7](https://godotengine.org/download/) or later (Forward+ renderer)

## Running

1. Open the project in Godot Engine
2. Press **F5** or click **Run Project**

## Export

Export presets are configured in `export_presets.cfg`. HTML5 exports output to the `output/` folder.
