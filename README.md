# Nectar
Nectar is a thin, type-safe, declarative router layer built on top of the Hummingbird server framework. It brings high-ergonomics, controller-style endpoint definitions to server-side Swift without sacrificing performance.

> [!IMPORTANT]
> Nectar is currently a Proof of Concept (PoC). If there is enough interest and community feedback, it will be expanded into a fully tested, public library.

```swift  
import Nectar

struct AppEntry: NectarApp {
    var endpoints: [Endpoint] {
        UserEndpointGroup()
    }
}  

@Endpoints
struct UserEndpointGroup: EndpointGroup {
    let partialName = "users"
    
    var subgroups: [Endpoint] {
        PathExtension(":id") {
            CommentEndpointGroup()
        }
    }
    
    @GET
    func getUser(id: UUID, otherThing: UUID?) throws -> String {
        return "id: \(id), otherThing: \(otherThing)"
    }
    
    @GET(pattern: ":id/activity")
    func getUserActivity(id: UUID) -> String {
        return "Activity: \(id.uuidString)"
    }
    
    @POST
    func createUser(body: UserCreationDTO) -> String {
        return "name: \(body.name)\nemail: \(body.email)\npassword: \(body.password)"
    }
}

@Endpoints
struct CommentEndpointGroup: EndpointGroup {
    let partialName: String = "comments"
    
    @GET(pattern: "")
    func getComments(id: UUID) -> String {
        "id: \(id.uuidString)"
    }
}

// register: 
router.registerNectarApp(AppEntry())
```

## Goal
- **Low visual nesting**: Avoid the deeply nested structural blocks typical of standard router trees.
- **Zero Runtime Overhead**: All routing maps down exactly to standard Hummingbird router.get(...),... calls during application startup. Request handling is fast and memory-efficient.
- **Non-Opinionated & Non-Intrusive**: Nectar is a light layer. It doesn't alter your database, middleware, or application setup—it simply registers routes to your existing Hummingbird router. (for now)

## How It Works (Features)
Nectar combines **Swift Macros** and **Result Builders** to extract parameters and register endpoints cleanly:

* **Return Types:** Functions can return any type conforming to Hummingbird's `ResponseGenerator`.
* **Concurrency:** Fully supports native `async` and `throws` execution.
* **Auto-Body Decoding:** Name a function argument `body` to automatically decode the incoming request payload using `Codable`.
* **Parameter Resolution:** 
  * **Non-optional parameters** are automatically resolved as **path parameters**.
  * **Optional parameters** are automatically resolved as **query parameters**.
  * Arguments typed as `Request` or `any RequestContext` will seamlessly receive the raw request or request context.
* **Path Customization:** Override or explicitly specify structural sub-paths using the `pattern` argument inside the route macros (e.g., `@GET(pattern: ":id/activity")`).


