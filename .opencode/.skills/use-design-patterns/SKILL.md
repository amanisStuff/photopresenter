---
name: use-design-patterns
description: encourages the use of design patterns in cases needing a more structured solution to issues that might be confrunted by the ai
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: debugging
---
## Common Issues and Recommended Design Patterns

### 1. Complex Object Creation
**Issue:** Creating objects with numerous configuration options or complex initialization logic leads to messy constructors.
**Pattern:** **Builder Pattern**
*   **Solution:** Separate the construction of a complex object from its representation so that the same construction process can create different representations.

### 2. Incompatible Interfaces
**Issue:** A third-party library or legacy module has an interface that doesn't match the rest of the application.
**Pattern:** **Adapter Pattern**
*   **Solution:** Create a wrapper that translates the incompatible interface into one that the client expects.

### 3. State-Dependent Behavior
**Issue:** An object's behavior changes drastically based on its internal state, leading to massive `if-else` or `switch` blocks.
**Pattern:** **State Pattern**
*   **Solution:** Encapsulate state-specific behaviors into separate classes and delegate the work to the current state object.

### 4. Notification and Event Handling
**Issue:** Multiple components need to stay in sync with changes in a single object without being tightly coupled to it.
**Pattern:** **Observer Pattern**
*   **Solution:** Define a subscription mechanism to notify multiple "observer" objects about any events that happen to the "subject" they’re observing.

### 5. Algorithm Interchangeability
**Issue:** You have multiple ways to perform a task (e.g., different image compression algorithms) and need to switch between them at runtime.
**Pattern:** **Strategy Pattern**
*   **Solution:** Define a family of algorithms, encapsulate each one, and make them interchangeable.

### 6. Resource-Intensive Object Access
**Issue:** An object is expensive to create or requires controlled access (e.g., a large image buffer or a database connection).
**Pattern:** **Proxy Pattern**
*   **Solution:** Provide a surrogate or placeholder for another object to control access to it, perform lazy initialization, or handle logging.
### 7. Global Access to a Shared Resource
**Issue:** Multiple parts of the application need to access a single shared instance of a resource (e.g., a configuration manager or a hardware interface) to ensure consistency.
**Pattern:** **Singleton Pattern**
*   **Solution:** Ensure a class has only one instance and provide a global point of access to it, while maintaining control over its initialization.

### 8. Decoupling Request Senders and Receivers
**Issue:** A request needs to be processed by one of several possible handlers, but the sender shouldn't need to know which specific object will handle it.
**Pattern:** **Chain of Responsibility Pattern**
*   **Solution:** Pass the request along a chain of potential handlers until one of them handles it, allowing multiple objects a chance to process the request.
### 9. Managing Complex Subsystems
**Issue:** A system consists of many complex classes and interfaces, making it difficult for clients to use or understand the underlying logic.
**Pattern:** **Facade Pattern**
*   **Solution:** Provide a simplified, high-level interface that makes the subsystem easier to use by masking the underlying complexity.

### 10. Reusing Large Numbers of Fine-Grained Objects
**Issue:** The application needs to handle a vast number of small objects, leading to high memory consumption.
**Pattern:** **Flyweight Pattern**
*   **Solution:** Share common parts of state between multiple objects instead of keeping all data in each object, significantly reducing memory footprint.
### 11. Encapsulating Requests as Objects
**Issue:** You need to parameterize objects with operations, queue requests, or support undoable operations.
**Pattern:** **Command Pattern**
*   **Solution:** Turn a request into a stand-alone object that contains all information about the request. This transformation lets you pass requests as a method arguments, delay or queue a request's execution, and support undoable operations.

### 12. Defining the Skeleton of an Algorithm
**Issue:** Several classes share a similar algorithm structure but differ in specific implementation steps, leading to code duplication.
**Pattern:** **Template Method Pattern**
*   **Solution:** Define the skeleton of an algorithm in a superclass but let subclasses override specific steps of the algorithm without changing its structure.
### 13. Accessing Elements of a Collection
**Issue:** You need to traverse a complex data structure (like a tree or a linked list) without exposing its internal representation.
**Pattern:** **Iterator Pattern**
*   **Solution:** Provide a way to access the elements of an aggregate object sequentially without exposing its underlying representation.

### 14. Adding Responsibilities Dynamically
**Issue:** You need to add behavior or state to individual objects at runtime without affecting other objects of the same class or using inheritance.
**Pattern:** **Decorator Pattern**
*   **Solution:** Attach additional responsibilities to an object dynamically by wrapping it in a special wrapper class that contains the extra behaviors.
### 15. Separating Operations from Object Structures
**Issue:** You need to perform new operations on a complex structure of objects (like a file system tree) without modifying the classes of the elements on which it operates.
**Pattern:** **Visitor Pattern**
*   **Solution:** Define a new operation in a separate "visitor" class, which can then be applied to the elements of the object structure.

### 16. Restoring Previous States
**Issue:** You need to capture and externalize an object's internal state so that the object can be restored to this state later (e.g., "Undo" functionality) without violating encapsulation.
**Pattern:** **Memento Pattern**
*   **Solution:** Create a memento object that stores a snapshot of the target object's state, allowing the target to restore itself without exposing its private fields.

### 17. Coordinating Complex Interactions
**Issue:** A set of objects interact in complex ways, creating a "spaghetti" of dependencies that makes the classes hard to reuse or modify.
**Pattern:** **Mediator Pattern**
*   **Solution:** Restrict direct communications between the objects and force them to collaborate only via a mediator object, reducing coupling.
### 18. Creating Families of Related Objects
**Issue:** A system needs to be independent of how its products are created, and it needs to work with multiple families of products (e.g., different UI themes or OS-specific widgets).
**Pattern:** **Abstract Factory Pattern**
*   **Solution:** Provide an interface for creating families of related or dependent objects without specifying their concrete classes.

### 19. Decoupling Abstraction from Implementation
**Issue:** Both an abstraction and its implementation need to be extended independently via inheritance, leading to a combinatorial explosion of classes.
**Pattern:** **Bridge Pattern**
*   **Solution:** Split a large class or a set of closely related classes into two separate hierarchies—abstraction and implementation—which can be developed independently.

### 20. Representing Part-Whole Hierarchies
**Issue:** You need to treat individual objects and compositions of objects uniformly (e.g., a file system with files and folders).
**Pattern:** **Composite Pattern**
*   **Solution:** Compose objects into tree structures to represent part-whole hierarchies. Composite lets clients treat individual objects and compositions of objects uniformly.
### 21. Creating Objects Without Specifying Exact Classes
**Issue:** A class can't anticipate the class of objects it must create, or you want a subclass to decide which object to instantiate.
**Pattern:** **Factory Method Pattern**
*   **Solution:** Define an interface for creating an object, but let subclasses alter the type of objects that will be created.

### 22. Cloning Existing Objects
**Issue:** Creating a new instance of a class is expensive or complex, and you already have a similar object that can be copied.
**Pattern:** **Prototype Pattern**
*   **Solution:** Specify the kinds of objects to create using a prototypical instance, and create new objects by copying this prototype.