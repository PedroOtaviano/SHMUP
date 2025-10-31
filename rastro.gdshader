shader_type canvas_item;

// Cor base do tiro
uniform vec4 bullet_color : source_color = vec4(0.4, 0.8, 1.0, 1.0);

// Intensidade e velocidade do brilho pulsante
uniform float intensity = 1.5;
uniform float pulse_speed = 4.0;

// Configurações do rastro
uniform float trail_speed = 3.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV) * bullet_color;

    // --- Brilho pulsante ---
    float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);
    vec4 glow = tex_color * (1.0 + pulse * intensity);

    // --- Rastro animado ---
    float wave = fract(UV.y * 5.0 - TIME * trail_speed);
    vec4 trail = mix(bullet_color, glow, wave);

    // Resultado final
    COLOR = trail * tex_color.a;
}
