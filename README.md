# HW 4: *3D Stylization*

1. Picking a piece of concept art
Here is the art style that I am aiming for:
<img width="586" height="584" alt="doggiecorgi00001" src="https://github.com/user-attachments/assets/03d0d381-a715-4791-b7d2-9d66eab0c247" />
<img width="594" height="589" alt="doggiecorgi00002" src="https://github.com/user-attachments/assets/cf31d7b7-9ee1-4600-9590-67dc1c8cad67" />
<img width="584" height="720" alt="doggiecorgi00003" src="https://github.com/user-attachments/assets/c3a44206-5808-4f2c-86eb-27b8ad6fae2e" />

2. 
    1. a. Improved surface shader: <img width="1041" height="651" alt="Screenshot 2025-09-29 at 11 59 25 PM" src="https://github.com/user-attachments/assets/a091a85d-0afa-4b23-a65b-bbc3cf9378f0" />
        b. Rim light shader <img width="930" height="386" alt="Rim light nodes" src="https://github.com/user-attachments/assets/4fbea121-5a8e-48ac-be10-f06150e6f6dd" />

        c. Custom shadow texture:
             I used a watercolor texture for the shadows (and the overall background in general)
             ![watercolorpaper](https://github.com/user-attachments/assets/fbbddf50-8d9f-4b2e-a854-e56aac8e52a2)
             In the actual scene, I used screen position UVs since it fit the aesthetic better that way. however, I experimented with default object UVs as well:
             <img width="733" height="576" alt="Screenshot 2025-09-29 at 11 58 08 PM" src="https://github.com/user-attachments/assets/c82b4bba-89c1-4dd6-a41e-95e327a1d5e2" />
        d. As shown in the image
            <img width="1029" height="663" alt="doggiecorgireplica" src="https://github.com/user-attachments/assets/67d27c6e-5bf3-439e-b3ef-a3337fb4e32c" />
    2. I animated the rim light so that it fades away and somewhat flickers to give it a crayon-like feel. Furthermore, I also animated the placement of the watercolor paper texture. For the toolbox functions, I used 
        - a bias function
        - a sine function
        - a step function
        The bias function was used to weight the sine function to look like it pulsated more rather than a regular sine function. The step function was used to create a discretized animation for the watercolor paper texture.

<img width="1037" height="554" alt="bias and sine" src="https://github.com/user-attachments/assets/868c368a-390c-4478-a261-f3cb428249c2" />


<img width="1029" height="663" alt="doggiecorgireplica" src="https://github.com/user-attachments/assets/8cc13fa5-aa6b-421d-9e93-9cf0ff82cb48" />