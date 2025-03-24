= Design

#lorem(1) // just a little introduction

Odin serves as the primary programming language for the entire project, forming the foundation upon which all other components are built and integrated.


== Odin
Odin is a general-purpose programming language with distinct typing built for high performance, modern systems and data-oriented programming. 
It serves as an alternative to C, offering refinements that address common issues experienced by C/C++ developers. 
For programmers familiar with C or C++, Odin's improvements are immediately recognizable as they directly target the minor problems encountered in traditional systems programming languages.

=== Features of Odin

The selection of Odin was driven by  by several key technical considerations. 
A significant factor was Odin's native support for swizzling at the language level. 
This feature provides a fast and ergonomic approach to vector and matrix manipulation, similar to what is available in shader languages. 
This capability is particularly valuable for the mathematical operations required in this project.

Additionally, Odin comes with built-in bindings for all popular graphics APIs, eliminating the need for third-party libraries or extensive integration work. 
The language offers unique features unavailable in other imperative procedural languages, creating a compelling technical advantage.

Among these distinctive features are first-class SOA (Structure of Arrays) data types, complemented by `soa_zip` and `soa_unzip` operations. 
It's worth noting that operations like `a[i].x = 123` (syntactic sugar for `a.x[i] = 123`) require language-level semantics to function correctly and cannot be achieved through metaprogramming in other languages. 
Odin also introduces the `using` statement and relative pointers, among many other innovative features.

Odin serves as the primary programming language for the entire project, forming the foundation upon which all other components are built and integrated.

=== Benefits

Odin has been designed with a focus on readability, scalability, and orthogonality of concepts. 
This design philosophy acknowledges that achieving simplicity is complex, and clarity is more valuable than cleverness. 
The language's architecture allows for the highest performance through low-level control over memory layout, memory management, and custom allocators.

Furthermore, Odin is designed from the ground up for modern computing hardware, incorporating built-in support for SOA data types, array programming, and other features that maximize performance and developer productivity. This modern approach ensures the project can take full advantage of contemporary hardware capabilities while maintaining code clarity and maintainability.

// Ref
//https://odin-lang.org/,
//https://www.reddit.com/r/programming/comments/xb120h/a_review_of_the_odin_programming_language/



== OpenGL
What role does OpenGL play in your project?
Explain the purpose of OpenGL within your application or system.

Why did you select OpenGL?
What were the considerations (performance, platform support, etc.) that led to choosing OpenGL over other graphics APIs?

How does OpenGL support your design goals?
Detail how OpenGL facilitates the rendering or graphical aspects of your project.

What challenges did you anticipate or encounter with OpenGL, and how were they addressed?
Discuss any difficulties during implementation and how your team resolved them.

== ECS architecture
What is ECS architecture, and why did you adopt it?
Provide an overview of ECS and explain why it was chosen as the architectural pattern.

How does ECS benefit your project design?
Detail the advantages ECS brings to managing complexity, scalability, or performance.

How is ECS implemented in your system?
Describe the specific components, entities, and systems in your ECS setup.

What are the implications of ECS on development workflow and collaboration?
Discuss how ECS influences code organization, debugging, and team collaboration.
