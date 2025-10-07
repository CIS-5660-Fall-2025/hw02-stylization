Homework 02: Stylization and Interactivity

1. Animated Sketchy Outlines

Built using a Fullscreen Shader Graph that samples Scene Depth and Normal Buffers. Integrated into URP via a ScriptableRendererFeature performing a two-step blit. Includes wobble animation driven by procedural noise and time (sin and vnoise).

Adjustable parameters exposed in Shader Graph:
- Depth and normal thickness (in pixels)
- Wobble amplitude, frequency, and speed
- Threshold and softness
- Weights for depth vs. normal edges
- Line color

2. Post-Processing Effect: Stylized Color and Tone Mapping

Attempted to make a vignet using only a shader graph (can be found in /Shaders/Vignet). Not sure it turned out how I wanted, but was meant to give the edges of the scene a pink glow.


3. Real-Time Interactivity: Rage Mode

Wrote RageModePostFX.cs, which toggles "Rage Mode" on any key press. In rage mode, any lights added to rage mode turn red and intensify and the outline material properties are modified to change from black to red, increased line thickness, and increased wobble and speed. The main camera zooms in on the worm. On a second key press the properties all revert to normal.
