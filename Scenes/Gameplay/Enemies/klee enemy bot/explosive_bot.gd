extends EnemyBot
class_name ExplosiveBot

@onready var explosive_component: Node = $ExplosiveComponent
@onready var sfx_explosion: AudioStreamPlayer2D = $SFX_explosion
@onready var sfx_boom_boom_bakudan: AudioStreamPlayer2D = $SFX_boom_boom_bakudan


func _ready() -> void:
	super._ready()
	explosive_component.explosion_sound_path = sfx_explosion.get_path()
	

func self_destruct():
	sfx_boom_boom_bakudan.play()
	
	await sfx_boom_boom_bakudan.finished
	# Skip animation logic, explode immediately
	explosive_component.explode()
func _on_attack_area_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		var target = area.get_parent()
		if target == self or target is EnemyBot:
			return

		if target == target_player:
			damageable_in_range = target
			object_timer.stop()
			pending_object_target = null
			if can_attack:
				self_destruct()
		elif can_destroy_objects and target.has_node("HealthComponent"):
			pending_object_target = target
			object_timer.start()
			
func die(attack: AttackComponent):
	if is_dead:
		return
	is_dead = true

	if attack.attacker and attack.attacker.is_in_group("player"):
		var level_node = get_tree().current_scene
		if level_node.has_method("register_enemy_kill"):
			level_node.register_enemy_kill(attack.attacker)

	self_destruct()
