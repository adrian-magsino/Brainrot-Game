extends Area2D
class_name HitboxComponent

@export var health_component: HealthComponent

func take_damage(attack: AttackComponent):
	if health_component:
		health_component.damage(attack)
		if get_parent().has_method("hit_effect"):
			get_parent().hit_effect()
