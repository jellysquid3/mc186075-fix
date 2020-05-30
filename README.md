**You can download this resource pack for your game from the [Releases page](https://github.com/jellysquid3/mc186075-fix/releases).**

----

A resource pack which optimizes the framebuffer blending code introduced by Minecraft snapshot 20w22a, used to
correct translucency errors between render layers. See [this comment](https://bugs.mojang.com/browse/MC-186075?focusedCommentId=712420)
on [issue MC-186075](https://bugs.mojang.com/browse/MC-186075) for more information.

### Less than scientific benchmarks

Measured with a render distance of 24 chunks on a system with an FX-8370 and GTX 960.
```
                            GPU TDP     GPU Utilization
20w11a (Vanilla)            54W         38%
20w22a (Vanilla)            66W         95%
20w22a (Patch)              54W         45%
```

### License

The shader code in this repository is made available under the [Creative Commons CC0 Public Domain license](https://github.com/jellysquid3/mc186075-fix/blob/master/LICENSE).
