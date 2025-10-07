# 2D-Shaders in Unity

## Final Output
<img alt="homework video" src="https://github.com/user-attachments/assets/0df077c2-91e6-431b-a3a2-994713ddea5e">

## Reference Artwork
This is the art style that I am aiming for:

<img width="200" alt="doggiecorgi00001" src="https://github.com/user-attachments/assets/03d0d381-a715-4791-b7d2-9d66eab0c247" />
<img width="200"  alt="doggiecorgi00002" src="https://github.com/user-attachments/assets/cf31d7b7-9ee1-4600-9590-67dc1c8cad67" />
<img width="200" alt="doggiecorgi00003" src="https://github.com/user-attachments/assets/c3a44206-5808-4f2c-86eb-27b8ad6fae2e" />

## Process

### Features included:
#### Multiple Lights in a Scene
I created a small script that took in all additional lights in the scene and set three different intensities based on Lambert's Reflection Model. I lerped between all three of these intensities. 

<img width="500" alt="AdditionalLighting00001" src="https://github.com/user-attachments/assets/d4f7dabd-38e8-4d92-8f39-7ced75c56c6e" />

You can vary the size of the rings given a light (Additional Lighting Threshold), or the intensity itself of the light (Ramped Diffuse Values).

<img width="500"alt="AdditionalLighting00002" src="https://github.com/user-attachments/assets/91c80412-b931-4203-9b09-c273e338b1fa" />

### Rim Lighting (changing with time)
I implemented a Fresnel effect to create a rim light off of any given object, as illustrated in the highlights of the leaves and the floor in the Final Output.
The custom Fresnel node makes use of the following toolbox functions:
- a bias function
- a sine function
- a step function

The bias function was used to weight the sine function to look like it pulsated more rather than a regular sine function. The step function was used to create a discretized animation for the watercolor paper texture.

#### Shadow Texture (changing with time)
I chose not to implement a textured shadow in my final result, but here is an examples of using a halftone textured shadow in object space:

<img width="700" alt="textured shadow" src="https://github.com/user-attachments/assets/d4983dce-caf2-49c2-87df-d20e1076aa69" />

#### Outlines
I implemented the Sobel Edge Detection algorithm in a post-processed full screen shader utilizing the Unity URP pipeline. On top of that, I layered over a paper-lke texture and multiplied a time-changing noise function to create variation in the line shape, as shown in the final output video.

#### Further Post-Processing Effects
To better follow the style of my reference images, I created a white vignette with a watercolor texture on top of the existing render, as shown in the final output video.

#### Real-time Effects
You can switch between different set materials in the scene by pressing the space bar each time, as shown in the final output video.
