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
Entity Component System (ECS) is an architectural design pattern predominantly used in video game development.It represents a departure from traditional event-based approaches commonly provided by default in most engines.
The core strength of ECS lies in its ability to facilitate code reusability through the separation of data from behavior.
This architecture adheres to the "composition over inheritance principle," which enhances flexibility and helps developers more effectively identify and classify objects (entities) within a game scene.

=== The Design pattern
The ECS implementation is founded on the three core components that define this architecture:
#figure(
  image("../assets/images/ECSBlockDiagram.png", width: 80%),
  caption: [
    Simple ECS Block Diagram
  ],
)
- #strong("Entity"): 
    An entity represents a general-purpose object, essentially serving as a container for components.
    Typically, entities consist solely of a unique identifier, commonly implemented as a plain integer.
    In our system, ... // Strings??
- #strong("Component"): 
    Components characterize entities by providing specific attributes or capabilities.
    These are reusable data modules attached to entities that define behavior, functionality, and appearance.
    For example, a "shininess" component might define how an entity reflects light in the rendering system.
- #strong("System"): 
    Systems represent the processing logic that operates on entities possessing specific components.
    They decouple game logic from data, essentially functioning as specialized pipelines for processing particular combinations of components.
    For instance, a physics system would query for entities having mass, velocity, and position components, then perform physics calculations on that set of components for each qualifying entity.
The architecture allows for dynamic modification of an entity's behavior at runtime through systems that add, remove, or modify components.
This approach eliminates the ambiguity problems often encountered in deep and wide inheritance hierarchies typical of Object-Oriented Programming.
Furthermore, data for all instances of a component are stored contiguously in physical memory, enabling efficient memory access for systems that operate across numerous entities.

=== Benefits
The adoption of ECS architecture brings significant advantages to our project.
Primarily, it is expected to deliver enhanced performance due to its data-oriented design principles.
While implementing ECS initially presents greater complexity compared to traditional event-based approaches, the long-term benefits justify this investment.
The architecture provides improved scalability and more efficient management of complex systems as the project grows.
It's worth noting that the initial learning curve and implementation complexity of ECS is higher than with conventional patterns.
However, this upfront investment pays dividends through superior performance characteristics and maintainability as the system scales.

// ref
// https://www.simplilearn.com/entity-component-system-introductory-guide-article
// https://habr.com/en/articles/651921/
// https://www.reddit.com/r/gamedev/comments/18od4yw/what_are_your_thoughts_on_entity_component/
// https://www.simplilearn.com/entity-component-system-introductory-guide-article
// https://en.wikipedia.org/wiki/Entity_component_system
// Maybe read for later: 
// https://www.richardlord.net/blog/ecs/what-is-an-entity-framework

