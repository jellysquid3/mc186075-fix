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

struct Layer {
    vec4 color;
    float depth;
};

#define NUM_LAYERS 6

Layer layers[NUM_LAYERS];

vec3 blend(vec3 destination, vec4 source) {
    return (destination * (1.0 - source.a)) + source.rgb;
}

void init_arrays() {
    layers[0] = Layer(vec4(texture2D(DiffuseSampler, texCoord).rgb, 1.0), texture2D(DiffuseDepthSampler, texCoord).r);
    layers[1] = Layer(texture2D(TranslucentSampler, texCoord), texture2D(TranslucentDepthSampler, texCoord).r);
    layers[2] = Layer(texture2D(ItemEntitySampler, texCoord), texture2D(ItemEntityDepthSampler, texCoord).r);
    layers[3] = Layer(texture2D(ParticlesSampler, texCoord), texture2D(ParticlesDepthSampler, texCoord).r);
    layers[4] = Layer(texture2D(WeatherSampler, texCoord), texture2D(WeatherDepthSampler, texCoord).r);
    layers[5] = Layer(texture2D(CloudsSampler, texCoord), texture2D(CloudsDepthSampler, texCoord).r);


    int j;
    
    for (int i = 0; i < NUM_LAYERS; i++) {
        j = i;
        
        while (j > 0 && layers[j].depth > layers[j - 1].depth) {
            Layer temp = layers[j];
            layers[j] = layers[j - 1];
            layers[j - 1] = temp;
            j--;
        }
    }
}

void main() {
    init_arrays();

    vec3 OutTexel = vec3(0.0);

    for (int ii = 0; ii < NUM_LAYERS; ++ii) {
        OutTexel = blend(OutTexel, layers[ii].color);
    }

    gl_FragColor = vec4(OutTexel.rgb, 1.0);
}


