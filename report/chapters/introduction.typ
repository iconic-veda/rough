= Introduction

The development of modern video games relies heavily on robust and flexible game engines, which abstract complex rendering, physics, and logic systems into accessible tools for creators. While commercial engines like Unity and Unreal Engine dominate the industry, building a custom engine from scratch provides invaluable insights into the low-level workings of real-time graphics, resource management, and performance optimization. This report documents the design, implementation, and challenges encountered during the creation of a lightweight game engine using the Odin programming language and OpenGL, supporting core features such as texture mapping, 3D model rendering, dynamic lighting, skeletal animation, and an Entity-Component-System (ECS) architecture for efficient entity management.

The primary goal of this project was to explore the intersection of modern graphics programming and systems design by leveraging Odin’s simplicity, performance, and memory management. The engine serves as a foundational framework for rendering interactive 3D scenes, with a focus on modularity and efficiency. Key components include an ECS framework to decouple game logic from data, a rendering pipeline for processing meshes and textures, a resource manager for loading and caching assets (e.g., OBJ/glTF models and PNG/JPG textures), and an animation system capable of interpolating skeletal keyframes. Basic directional lighting was implemented to enhance visual depth.

By adopting an ECS architecture, the engine achieves a clear separation of concerns: entities represent game objects as unique identifiers, components store raw data (e.g., transform, mesh, light, or animation properties), and systems execute logic over relevant subsets of components. This design not only improves cache coherence and performance for large scenes but also simplifies the addition of new features, such as dynamic physics or gameplay mechanics, by composing reusable components.

//For example, the animation system processes entities with skeletal mesh components, while the lighting system iterates over entities with light components to update shading calculations.

This project not only demonstrates the feasibility of using Odin — a relatively young, statically typed language — for graphics-intensive applications but also underscores the challenges of bridging high-level engine design with low-level OpenGL API interactions. By prioritizing clarity and performance, the engine lays the groundwork for future extensions, such as a particle systems, physics simulations, or scriptable entity behaviors.

The following report details the architectural decisions, implementation strategies, and lessons learned during development. It begins with an overview of the engine’s structure, followed by deep dives into its rendering pipeline, lighting model, and animation system. Performance benchmarks, limitations, and potential improvements are also discussed, offering a comprehensive reflection on the journey of building a functional game engine from the ground up.

// This work ultimately highlights the educational and practical value of understanding the inner workings of game engines, providing a springboard for further innovation in real-time graphics and interactive systems.


//First, you provide a general background, then you go into a narrower field and finally you describe the specific problems to be solved. You must formulate your own project definition, see later.
//
//All in all, we can say that the chapter has the task of answering the following questions:
// In what field is your thesis located?
// What problem are you going to solve, what is the goal of the work?
// Who has given the problem (problem owner): teacher, company, …
// How do you intend to proceed to solve the problem, what is your solution strategy?

//All the text between the main heading 1. Introduction and 1.1 Background, i.e. what you have read on this page so far, is called an introduction. The introduction leads the reader into the chapter. Many supervisors (and examiners) appreciate a well-written introduction of 5 – 20 lines.