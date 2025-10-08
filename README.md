# HW 4: *3D Stylization*

## Project Overview:
Using a 2D concept art piece as inspiration to create a 3D Stylized scene in Unity.

| <img width="500px" src="./Bakers_Baguette.webp">  |
|:--:|
| *2D Concept Illustration* |

| <img width="950px" src="./Turnaround.gif"> |
|:--:|
| *3D Unity Stylization* |

---
# Steps

## 1. Object Shaders

 - Started by creating a basic 3-color toon shader, then added multiple light support and specular highlight so that light sources other than the main directional light can also illuminate objects in the scene.
 - Applied custom shadow texture to the floor. The shadows are now matrices of stars with a softened edge.
 - Added sin-wave vertex animation to Pusheen's hands to simulate her movement as in the 2D concept art.


## 2. Full Screen Post Process Outline Shader

 - Fixed the given "Full Screen Feature" template so that it Blit from the color buffer to a temporary buffer and back.
 - Created the outline shader that edits the temporary buffer. 
 - Outline shader draws outlines based on both depth and normal information of the scene.
 - A gradient noise is added to the depth outline to give it an animated look.

## 3. Full Screen Post Process Distortion Effect

 - Implemented both horizontal and verticle distortion effect for the entire scene based on a random 2D cloud noise. 

## 4. Interactivity

 - Pressing spacebar will give the beguette a much more realistic look which excites Pusheen to knead it faster.

## Resources:

1. Object models:
    - [Pusheen](https://sketchfab.com/3d-models/pusheen-im-busy-d1c8c1bc1ae24227a9561db686b9faec)
    - [Chef hat](https://sketchfab.com/3d-models/chef-hat-cacfc7474a604ed4b0275b8a3293eff6)
    - [Beguette](https://sketchfab.com/3d-models/bread-b97740f0f5114befaf6563830a3cdecb)
