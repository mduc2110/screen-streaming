//
//  Injector.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

import Foundation
import SwiftUI

public final class Injector: @unchecked Sendable {
    
    private var factories: [String: () -> Any] = [:]
    private var singletons: [String: Any] = [:]
    public static let shared = Injector()
    
    private init() {}
    
    public func factory<T>(_ type: T.Type, _ factory: @escaping () -> Any) {
        let key = String(describing: type)
        factories[key] = factory
    }
    
    public func single<T>(_ type: T.Type, _ factory: @escaping () -> T) {
        let key = String(describing: type)
        singletons[key] = factory()
    }
    
    func resolve<T>() -> T {
        let key = String(describing: T.self)
        // Check for singleton
        if let singleton = singletons[key] as? T {
            return singleton
        }
        
        if let factory = factories[key] {
            if let instance = factory() as? T {
                return instance
            } else {
                fatalError("Cannot cast factory result to \(T.self)")
            }
        }
        
        fatalError("No registration for type \(T.self)")
    }
    
    public func createModule(_ setup: (Injector) -> Void) {
        setup(self)
    }
}

@propertyWrapper
public struct ByInject<T> {
    public let wrappedValue: T
    
    public init() {
        self.wrappedValue = Injector.shared.resolve()
    }
}

public func get<T>() -> T {
    Injector.shared.resolve()
}

@propertyWrapper
public struct ByInjectObservable<T: ObservableObject> {
    private var _object: T
    
    public init() {
        self._object = Injector.shared.resolve()
    }
    
    @MainActor
    public var wrappedValue: T {
        _object
    }
    
    @MainActor
    public var projectedValue: ObservedObject<T>.Wrapper {
        ObservedObject(wrappedValue: _object).projectedValue
    }
}
