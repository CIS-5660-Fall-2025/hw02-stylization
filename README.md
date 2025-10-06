# *3D Stylization*
 > In this assignment, you will use a 2D concept art piece as inspiration to create a 3D Stylized scene in Unity. This will give you the opportunity to explore stylized graphics techniques alongside non-photo-realistic (NPR) real-time rendering workflows in Unity.


## 1. Interesting Shaders

### a. Improved Surface Shader: ###

 - Multiple Light Support
 - Additional Specular Highlight Feature
 - Custom Shadow Pattern

<img width="827" height="634" alt="image" src="https://github.com/user-attachments/assets/c2032141-73bd-4028-9587-6731cdbf1470" />

   
### b. Special Surface Shader: ###

 - Animated colors
 
 https://github.com/user-attachments/assets/f5c20527-67d0-48af-8200-2f3abd445a30


## 2. Stylized Scene

 In this project, I implemented 2 stylization effects with different concept arts, and built a simple transition animation for them.

## *a. Kuwahara Filters*

### Introduction

For the first shader I tried to implement some pretty NPR rendering effects in current games, like the Zelda games. They have graphics that combine both realistic and cartoony shaders.

| <img width="800" alt="image" src="https://github.com/user-attachments/assets/7c8114e2-a079-4375-8914-d4cb1deb0507" /> |
|:--:|
| *The legend of Zelda: Breath of The Wild* |

To achieve that effects, multiple passes with carefully configured shaders are needed. But there's a simpler method to get these graphics, which is the Kuwahara Filter.

> The Kuwahara filter is a non-linear smoothing filter used in image processing for adaptive noise reduction. Most filters that are used for image smoothing are linear low-pass filters that effectively reduce noise but also blur out the edges. However the Kuwahara filter is able to apply smoothing on the image while preserving the edges.

However, because its sampling kernel is isotropic (i.e., square, with equal weight for all directions), it cannot perceive the "structural direction" of the image. When encountering fine edges or sharp corners that are not horizontal or vertical, it tends to "round" the edges, failing to produce long, flowing strokes that follow the contours of the object.

Therefore, we need something anisotropic to dynamically deform and stretch the sampled area according to the local structure of the image, so that its shape becomes an ellipse that fits the edge direction. In this way, when the filter processes the outline of an object, its sampling "strokes" will naturally stretch along the direction of the outline, resulting in a very smooth and beautiful painting effect.

In my [Kuwahara Filter Shader](https://github.com/ReV3nus/CIS-5660-hw02/blob/main/Assets/RenderingFeatures/Anisotropic%20Kuwahara%20Filter/AnisotropicKuwahara.shader), I implemented both isotropic and anisotropic Kuwahara Filters in renderer feature with configurable params. 

<img width="606" height="153" alt="image" src="https://github.com/user-attachments/assets/6eaf1642-7eea-4c41-9dc3-9dc2accd27fd" />

### Renderings

 - Here are the different images under different params:

| <img width="1000" alt="image" src="https://github.com/user-attachments/assets/d4df66fe-4e0c-447b-9fd4-2461a4d2e67c" /> |
|:--:|
| *Original Image* |
| <img width="1000" alt="image" src="https://github.com/user-attachments/assets/1217393e-635f-46d3-8ca5-ed47d3cc796d" /> |
| *Anisotropic, Kernel = 8* |
| <img width="1000" alt="image" src="https://github.com/user-attachments/assets/1b48d37d-cb86-47ae-9508-f61e2a2e5ef9" /> |
| *Anisotropic, Kernel = 32* |
| <img width="1000" alt="image" src="https://github.com/user-attachments/assets/0317eb3f-81db-4e4b-a4d1-17a8abc95505" /> |
| *Anisotropic, Kernel = 16* |
| <img width="1000" alt="image" src="https://github.com/user-attachments/assets/e54b6ea5-3b82-4be9-b2d6-6ecac2c4cb98" /> |
| *Isotropic, Kernel = 16* |

 - The turnaround video of the scene:

https://github.com/user-attachments/assets/c66e29e4-0362-4ee2-bf7d-628213767b68

## *b. One Last Stylization*

### Introduction

Inspired by the famous song *One Last Kiss* and its cover, I decided to implement a stylization and took it as the concept art.

| <img width="600" alt="image" src="https://github.com/user-attachments/assets/b2c1c8b4-506a-4dfc-94e1-a18e856fa0d4" /> |
|:--:|
| [*One Last Kiss*](https://en.wikipedia.org/wiki/One_Last_Kiss_(EP)) |

- **In my implemented [*OneLastShader*](https://github.com/ReV3nus/CIS-5660-hw02/blob/main/Assets/RenderingFeatures/One%20Last%20Shader/OneLastStylize.shader), I:**

  - drawed two different dynamic outlines with different amplitude and frequency to animate manga-like strokes, and used multiple passes to speed up the calculations
  - applied dense sketch texture with SSAO results using animated world coords
  - applied another sketch texture to draw on simple shadows using animated world coords too.
  - mapped to a hand-painted LUT texture

### Renderings

- Here's the final results:

https://github.com/user-attachments/assets/dc1c1a11-3f9b-4e3e-9fc8-ac7d31cbb3c3

https://github.com/user-attachments/assets/4041fd0c-8814-4fd5-b191-022f8da381b8


## *c. Transition*

To make a transtition of these two stylizations, I created another simple white screen renderer feature with configurable intensity. Besides, I created a controller script to toggle or switch the rendering effects using buttons on Inspector or keybords.

Here's the transition's video:

https://github.com/user-attachments/assets/1d7770b6-40f8-45d3-8e4d-bf2de1398a3a



