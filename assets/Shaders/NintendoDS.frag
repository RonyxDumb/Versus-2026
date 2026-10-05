#pragma header

// Uniform passati dal Main (invariati)
uniform vec2 uScreenSize;
uniform float uColorDepth; 

void main() {
    // 1. Risoluzione SM64 (320x240)
    vec2 targetRes = vec2(320.0, 240.0);
    vec2 uv = floor(openfl_TextureCoordv * targetRes) / targetRes;

    // Recuperiamo il colore centrale e la sua alpha nativa
    vec4 baseColor = flixel_texture2D(bitmap, uv);

    // 2. Filtro Antialiasing Hardware N64 (Blur a croce, super leggero e compatibile)
    vec2 texelSize = 1.0 / targetRes;
    
    vec3 n64Blur = baseColor.rgb * 0.4;
    n64Blur += flixel_texture2D(bitmap, uv + vec2(texelSize.x, 0.0)).rgb * 0.15;
    n64Blur += flixel_texture2D(bitmap, uv - vec2(texelSize.x, 0.0)).rgb * 0.15;
    n64Blur += flixel_texture2D(bitmap, uv + vec2(0.0, texelSize.y)).rgb * 0.15;
    n64Blur += flixel_texture2D(bitmap, uv - vec2(0.0, texelSize.y)).rgb * 0.15;

    // 3. Bilanciamento retro-colori senza funzioni matematiche pesanti
    n64Blur.r *= 1.03; // Un pizzico di calore in più per emulare il CRT
    n64Blur.b *= 0.97;

    // Output finale sicuro
    gl_FragColor = vec4(n64Blur, baseColor.a);
}