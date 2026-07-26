# 3D 單人射擊遊戲名稱發想

**Date**: July 26, 2026 at 09:58 PM
**Turns**: 1
**Source**: [Gemini Chat](https://gemini.google.com/app/a4e54f0b9d00d723)

---

## Turn 1

### 🤖 Assistant

```python
import urllib.request

content = """# Godot 4 第一人稱射擊系統與環境設定指南

本文件統整了第一人稱視角（FPS）角色控制、射擊系統以及環境天空盒的設定流程。

## 1. 玩家視角與碰撞體設定修正

### 修正邊緣滑落問題
當角色走到平台邊緣低頭時滑落，通常是因物理碰撞體跟隨攝影機旋轉所致。
* **正確層級結構**：`CollisionShape3D` 必須與 `Head` 同級，不可作為其子節點。
  ```text
  Player (CharacterBody3D)
  ├── CollisionShape3D
  └── Head (Node3D)
      └── Camera3D

```

- Transform 檢查：確保 `Player` 的 `Rotation` 為 `0, 0, 0`，且 `CollisionShape3D` 的 `Position` 為 `0, 0, 0`。

### 修正輸入映射誤綁定
若在邊緣滑動滑鼠造成移動，需檢查「專案設定」>「輸入映射」。

- 確認 `move_forward`、`move_backward` 等動作中，未誤綁定 **Mouse Motion / Mouse Axis**。僅保留鍵盤按鍵。

## 2. 射擊系統實作：實體子彈機制

### 建立子彈場景 (Bullet.tscn)

1. 建立 `Area3D` 根節點，命名為 `Bullet`。
2. 新增 `MeshInstance3D`（CapsuleMesh，縮放為 `0.1, 0.1, 0.3`，X軸旋轉 90度）。
3. 新增 `CollisionShape3D`（CapsuleShape3D，尺寸吻合網格）。
4. 在右側「節點 > 訊號」中，將 `body_entered` 連接至腳本（注意避免重複連接）。
5. 實作移動、傷害判定與生命週期（避免子彈擊中玩家自身）。
**Bullet.gd 腳本：**

```gdscript
extends Area3D

const SPEED = 40.0
const MAX_LIFETIME = 10.0

var current_lifetime = 0.0

func _physics_process(delta):
    position -= transform.basis.z * SPEED * delta
    current_lifetime += delta
    if current_lifetime >= MAX_LIFETIME:
        queue_free()

func _on_body_entered(body):
    if body.name == "Player": # 防止開火時擊中自己
        return
        
    if body.has_method("take_damage"):
        body.take_damage()
    
    queue_free()

```

### 玩家開火邏輯與後座力

1. 於 `Camera3D` 下新增 `Marker3D`，命名為 `Muzzle`，Z 軸稍微往前推移（如 `-1.0` 至 `-2.0`），確保位於玩家碰撞體外。
2. 實作按住連發、垂直後座力、水平隨機後座力與 FOV 視覺回饋。
**Player.gd 核心更新：**

```gdscript
const RECOIL_VERTICAL = 2.0
const RECOIL_HORIZONTAL = 1.2
const FIRE_RATE = 0.15

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var muzzle = $Head/Camera3D/Muzzle

var bullet_scene = preload("res://Bullet.tscn")
var fire_cooldown = 0.0

func shoot():
    var bullet = bullet_scene.instantiate()
    get_tree().root.add_child(bullet)
    bullet.global_transform = muzzle.global_transform # 注意屬性無括號
    apply_recoil()

func apply_recoil():
    head.rotation.x += deg_to_rad(RECOIL_VERTICAL)
    head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
    
    var random_h_recoil = randf_range(-RECOIL_HORIZONTAL, RECOIL_HORIZONTAL)
    rotate_y(deg_to_rad(random_h_recoil))
    
    var tween = get_tree().create_tween()
    tween.tween_property(camera, "fov", 72.0, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    tween.tween_property(camera, "fov", 75.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _physics_process(delta):
    # 連發判定
    if fire_cooldown > 0.0:
        fire_cooldown -= delta
        
    if Input.is_action_pressed("fire") and fire_cooldown <= 0.0:
        shoot()
        fire_cooldown = FIRE_RATE

```

## 3. UI 主選單與字體套用

1. 建立 `Control` 根節點，命名為 `MainMenu`，錨點設為「佔滿矩形 (Full Rect)」。
2. 加入 `VBoxContainer` 置中。內部放入 `Label`（標題）、`Button`（開始）、`Button`（離開）。
3. 將字型檔拖曳至節點的 **Theme Overrides -> Fonts** 進行套用並設定尺寸。
4. 將按鈕的 `pressed` 訊號連接至腳本：

```gdscript
func _on_start_button_pressed():
    get_tree().change_scene_to_file("res://World.tscn")

func _on_quit_button_pressed():
    get_tree().quit()

```

## 4. 環境設定：Skybox (.exr) 與資源儲存

### 載入全景天空盒

1. 在場景新增 `WorldEnvironment` 與 `DirectionalLight3D`。
2. 建立新 `Environment`，將 Background Mode 改為 **Sky**。
3. 建立新 `Sky` 資源，Sky Material 選擇 **PanoramaSkyMaterial**。
4. 將 `.exr` (OpenEXR) 或 `.hdr` 圖片拖曳至 Panorama 屬性中即可完成渲染。

### 儲存為 .res / .tres 資源檔

1. 點擊 Environment 屬性右側向下小箭頭，選擇 **「儲存 (Save)」**。
2. 存為 `.tres` 或 `.res`。未來在其他場景新增 `WorldEnvironment` 時，將此檔案拖入 Environment 屬性即可直接套用天空設定。
"""
with open("godot_tutorial.md", "w", encoding="utf-8") as f:
f.write(content)
print("godot_tutorial.md")

```

```text?code_stdout&code_event_index=1
godot_tutorial.md

```
你的 Markdown 檔案已準備好![「MD」圖示](assets/img-001.png) godot_tutorial  MD 
檔案內容已將稍早討論的邊緣滑落除錯、實體子彈射擊與隨機後座力邏輯、主選單字型設定，以及 Skybox 的 EXR 套用與資源檔儲存方法，完整整理至此文件中。

---

*Exported from [Voyager](https://github.com/Nagi-ovo/voyager)*  
*Generated on July 26, 2026 at 09:58 PM*