#version 110

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D TranslucentSampler;
uniform sampler2D TranslucentDepthSampler;
uniform sampler2D ItemEntitySampler;
uniform sampler2D ItemEntityDepthSampler;
uniform sampler2D ParticlesSampler;
uniform sampler2D ParticlesDepthSampler;
uniform sampler2D WeatherSampler;
uniform sampler2D WeatherDepthSampler;
uniform sampler2D CloudsSampler;
uniform sampler2D CloudsDepthSampler;

varying vec2 texCoord;

#define NUM_LAYERS 6

#define try_insert_sample(color_sampler, depth_sampler) { \
    vec4 color = texture2D(color_sampler, texCoord); \
    if (color.a > 0.0) { \
        int i = sample_count++; \
        color_samples[i] = color; \
        depth_samples[i] = texture2D(depth_sampler, texCoord).r; \
        \
        /* Perform an insertion sort at the given index in the array, sorted by descending depth */ \
        /* Although the i>0 check will always be false on the first iteration, keeping it here seems to elide a branch */ \
        while (i > 0 && depth_samples[i] > depth_samples[i - 1]) { \
            vec4 color = color_samples[i]; \
            color_samples[i] = color_samples[i - 1]; \
            color_samples[i - 1] = color; \
            \
            float depth = depth_samples[i]; \
            depth_samples[i] = depth_samples[i - 1]; \
            depth_samples[i - 1] = depth; \
            \
            i--; \
        } \
    } \
}

// Avoid an array of structs to keep data aligned in memory, helps some on older hardware
// The color samples can then be linearly scanned after sorting is done, making optimal use of the cache lines
vec4 color_samples[NUM_LAYERS];
float depth_samples[NUM_LAYERS];

// This blending works with color components that have already been premultiplied by their alpha component
vec3 blend(vec3 tex, vec4 sample) {
    float factor = 1.0 - sample.a;
    return (tex * factor) + sample.rgb;
}

void main() {
    // There will always be at least one sample (from the diffuse layer)
    int sample_count = 1;
    
    // Always sample the diffuse layer to provide a base color for blending
    color_samples[0] = texture2D(DiffuseSampler, texCoord);
    color_samples[0].a = 1.0; // Discard the alpha channel to fix issues with cutout textures
    depth_samples[0] = texture2D(DiffuseDepthSampler, texCoord).r;
    
    // Try to insert a sample from each layer
    // If the sample's color component is empty, do not insert it to the list of samples
    // Samples are sorted as they are inserted into the array
    try_insert_sample(TranslucentSampler, TranslucentDepthSampler);
    try_insert_sample(ItemEntitySampler, ItemEntityDepthSampler);
    try_insert_sample(ParticlesSampler, ParticlesDepthSampler);
    try_insert_sample(WeatherSampler, WeatherDepthSampler);
    try_insert_sample(CloudsSampler, CloudsDepthSampler);
    
    // Blend and merge the framebuffer samples

    // We don't need to consider the first layer's alpha value because the color components are already premultiplied
    vec3 tex = color_samples[0].rgb;
    for (int i = 1; i < sample_count; i++) {
        tex = blend(tex, color_samples[i]);
    }
    
    // Write the blended colors to the final framebuffer output
    gl_FragColor = vec4(tex, 1.0);
}
