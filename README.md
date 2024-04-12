# EventDispatcherKit
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FNikSativa%2FEventDispatcherKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/NikSativa/EventDispatcherKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FNikSativa%2FEventDispatcherKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/NikSativa/EventDispatcherKit)

Library for dispatching events to multiple analytics services.

### EventDispatcher
Handle events from your app, encode them to JSON and than dispatch them to multiple processors.
    
```swift
func send<B: Encodable>(_ name: EventName, body: B)
func send<E: Event>(_ event: E)
func send<E: TechnicalEvent>(_ event: E)
func send<E: CustomizableEvent>(_ event: E)
```

### EventProcessor
Wrapper for analytics service, which will process and send the events to that service.
- `EventProcessorName` is just to identify the processor in the list of processors for each event.

```swift
var name: EventProcessorName { get }
typealias Properties = [String: Any]
func send(_ name: EventName, properties: Properties)
```

### Event
Simple protocol for events, which will be encoded and dispatched to processors.
```swift
struct CloseApp: Event {
    static let name: EventName = "app_close"
    let timestamp: Date
}
```

### CustomizableEvent
Protocol for events, which can be customized independently for each processor.
```swift
struct LogIn: CustomizableEvent, Encodable {
    func customized(for name: EventProcessorName) -> CustomizedEvent? {
        switch name {
        case .firebase:
            return .init(name: Firebase.AnalyticsEventLogin,
                         body: self)
        case .console:
            return .init(name: "login",
                         body: self)
        default:
            return nil
        }
    }
}
```

### TechnicalEvent
Special protocol for technical events, which will be dispatched to 'isTechnical' processors only. Used only for devs purposes.
```swift
struct CloseApp: TechnicalEvent {
    static let name: EventName = "app_close"
}
```

### ConsoleEventProcessor
Processor is just print the event to the console or your custom logger if you want.

```swift
import os

let logger = Logger(subsystem: "com.example", category: "EventDispatcherKit")
let processor = ConsoleEventProcessor(logger: { [logger] message in
    logger.log(level: .info, "\(message)")
})
```
