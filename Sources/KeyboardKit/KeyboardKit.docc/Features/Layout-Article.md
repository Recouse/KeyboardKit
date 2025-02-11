# Layout

This article describes the KeyboardKit layout engine.

@Metadata {

    @PageImage(
        purpose: card,
        source: "Page",
        alt: "Page icon"
    )
}

A flexible keyboard layout is an important part of a software keyboard, and must consider many factors like the current locale, device, screen orientation, user preferences, etc.

In KeyboardKit, an ``InputSet`` defines the input keys of a keyboard, after which a ``KeyboardLayoutService`` can create a dynamic ``KeyboardLayout`` at runtime that defines the full set of keys. 

👑 [KeyboardKit Pro][Pro] unlocks layout extensions that make modifying layouts easier, more input sets like ``InputSet/qwertz`` & ``InputSet/azerty``, localized input sets and layout services for all locales in your license, iPad Pro support, etc. Read more further down.



## Namespace

KeyboardKit has a ``KeyboardLayout`` type that is also a namespace for other layout-related types like ``KeyboardLayout/Configuration``, ``KeyboardLayout/Item``, etc.



## Input Sets & Layouts

While most iOS keyboards have 3 input rows of input keys surrounded by action keys, and a bottom row with space bar and action keys, this is not true for all locales. The layout can vary greatly, so the layout engine must be flexible.

In KeyboardKit an ``InputSet`` specifies the input keys of a keyboard, while a ``KeyboardLayout`` specifies the full set of keys. Layouts can vary greatly for different devices, screens, locales, etc.

KeyboardKit comes with pre-defined input sets, like ``InputSet/qwerty``, ``InputSet/numeric(currency:)`` & ``InputSet/symbolic(currencies:)``. KeyboardKit Pro unlocks more input sets, like ``InputSet/qwertz`` and ``InputSet/azerty``, as well as locale-specific input sets for all ``Foundation/Locale/keyboardKitSupported`` locales.



## Services

In KeyboardKit, a ``KeyboardLayoutService`` can generate dynamic layouts at runtime, It provides us with the flexibility we need, to accomodate to the varying needs for different locales, devices, etc.

KeyboardKit injects ``KeyboardLayout/StandardLayoutService`` into ``KeyboardInputViewController/services``. You can replace it at any time, as described further down, or add custom services to it with ``KeyboardLayoutService/tryRegisterLocalizedService(_:)``.


---


## 👑 KeyboardKit Pro

[KeyboardKit Pro][Pro] unlocks more input sets, like ``InputSet/qwertz`` & ``InputSet/azerty``, as well as alphabetic, numeric & symbolic sets for all ``Foundation/Locale/keyboardKitSupported`` locales that are included in your license, like `.french`, `.swedishNumeric`, etc.

KeyboardKit Pro also unlocks a localized ``KeyboardLayout/ProLayoutService`` for every locale and injects them as localized services into the ``Keyboard/Services/layoutService`` when a valid license is registered. You can access any localized service in your license like this:

```swift
let service = try KeyboardLayout.ProLayoutService.Swedish()
```

These input sets and layout services will all throw an error if you try to access them without a valid KeyboardKit Pro license. If you are on the Basic or Silver plan, you must specify which locales to use in your ``KeyboardApp``. See <doc:Getting-Started> for more info.


### More Layout Capabilites

KeyboardKit Pro extends ``KeyboardLayout`` and all layout ``KeyboardLayout/Item`` collections with more capabilities, that make it easier to add, remove, and replace items in the layout.

KeyboardKit Pro also unlocks more ``KeyboardLayout`` capabilities like ``KeyboardLayout/adjusted(for:layoutConfiguration:)``, ``KeyboardLayout/copy()`` and ``KeyboardLayout/createIdealItem(for:width:alignment:)``, ``KeyboardLayout/bottomRowLayout``, etc.

> Tip: See ``KeyboardLayout`` and the nested ``KeyboardLayout/Item`` type in the KeyboardKit Pro documentation for a full list of additional capabilities. The open-source documentation doesn't include these extensions, since they're not part of the open-source library. 


### iPad Pro Support

KeyboardKit Pro unlocks an ``KeyboardLayout/iPadProLayoutService`` that can generate iPad Pro-specific layouts for most supported locales.

![iPad Pro Layout](keyboardview-ipadpro)


---


## How to...

### ...create a custom layout service

You can create a custom ``KeyboardLayoutService`` to customize the layout for a certain locale, device type, or complete layout.

You can implement the ``KeyboardLayoutService`` protocol from scratch, or inherit and customize ``KeyboardLayout/StandardLayoutService`` or the ``KeyboardLayout/BaseLayoutService``, ``KeyboardLayout/iPadLayoutService``, ``KeyboardLayout/iPadProLayoutService``, or ``KeyboardLayout/iPhoneLayoutService`` base classes:

```swift
class CustomKeyboardLayoutService: KeyboardLayout.StandardLayoutService {
    
    // Never use array indices if it can cause a crash.
    override func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout {
        var layout = super.keyboardLayout(for: context)
        // Perform any modifications here
        return layout
    }
}
```

To use your custom service instead of the standard one, just inject it into ``KeyboardInputViewController/services`` by replacing its ``Keyboard/Services/layoutService`` property:

```swift
class KeyboardViewController: KeyboardInputViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        services.layoutService = CustomKeyboardLayoutService()
    }
}
```

This will make KeyboardKit use your custom implementation instead of the standard one.



### ...customize a localized layout service

Service that inherit ``KeyboardLayout/StandardLayoutService`` can use ``KeyboardLayoutService/tryRegisterLocalizedService(_:)`` or the ``Keyboard/Services`` convenient ``Keyboard/Services/tryRegisterLocalizedLayoutService(_:)`` function to register a custom service for a certain locale.

For instance, this is how you could make KeyboardKit Pro use a custom layout service for ``Foundation/Locale/german``:

```swift
class MyCustomGermanService: KeyboardLayout.ProLayoutService.German { ... } 

class KeyboardViewController: KeyboardInputViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPro(for: ...) { result in
            // KeyboardKit Pro is available first after this
            self.services.tryRegisterLocalizedLayoutService(
                try! MyCustomGermanService() 
            )
        }
    }
}
```

This makes it easy to replace the service for a certain locale, since you can inherit and customize the related ``KeyboardLayout/ProLayoutService``.

> Important: Note that you must wait for **setupPro** to finish successfully when you use KeyboardKit Pro and want to customize a Pro service class, otherwise you won't be able to resolve the pro-specific services, since your license will not yet be registered.



[Pro]: https://github.com/KeyboardKit/KeyboardKitPro
