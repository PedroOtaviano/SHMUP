shader_type canvas_item;

uniform vec4 hitbox_color : source_color = vec4(0.0, 1.0, 0.3, 1.0); // verde vibrante
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // preto
uniform float pulse_speed = 4.0;        // velocidade da pulsação
uniform float glow_strength = 0.5;      // intensidade do brilho
uniform float outline_thickness = 0.3; // espessura do contorno

void fragment() {
    vec2 uv = UV;
    float dist = length(uv - vec2(0.5));

    // Raio do círculo principal
    float radius = 0.35;

    // Núcleo do círculo (hitbox real)
    float circle = smoothstep(radius, radius - 0.02, dist);

    // Outline (contorno em volta do círculo)
    float outline = smoothstep(radius + outline_thickness, radius, dist);

    // Pulso senoidal
    float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);

    // Cor base com brilho
    vec4 core_color = hitbox_color;
    core_color.rgb += pulse * glow_strength;

    // Mistura do núcleo + contorno
    vec4 final_color = mix(outline_color, core_color, circle);

    COLOR = final_color * outline;
}