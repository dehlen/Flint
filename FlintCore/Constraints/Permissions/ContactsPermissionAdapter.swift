//
//  ContactsPermissionAdapter.swift
//  FlintCore
//
//  Created by Marc Palmer on 30/05/2018.
//  Copyright © 2018 Montana Floss Co. Ltd. All rights reserved.
//

import Foundation
#if canImport(Contacts)
import Contacts
#endif

public enum ContactsEntity {
    case contacts
}

@objc protocol ProxyContactStore {
    @objc(authorizationStatusForEntityType:)
    static func authorizationStatus(for entityType: CNEntityType) -> CNAuthorizationStatus
    @objc(requestAccessForEntityType:completionHandler:)
    func requestAccess(for entityType: CNEntityType, completionHandler: @escaping (Bool, Error?) -> Swift.Void)
}

/// Checks and authorises access to the Contacts on supported platforms
///
/// Support: iOS 9+, macOS 10.11+, watchOS 2+, tvOS ⛔️
class ContactsPermissionAdapter: SystemPermissionAdapter {
    static var isSupported: Bool {
#if !os(tvOS)
        if #available(iOS 9, macOS 10.11, watchOS 2, *) {
            // Do this in case it is not auto-linked on all supported platforms
            let isLinked = libraryIsLinkedForClass("XXXContactStore")
            return isLinked
        } else {
            return false
        }
#else
        return false
#endif
    }

    static func createAdapters(for permission: SystemPermissionConstraint) -> [SystemPermissionAdapter] {
        return [ContactsPermissionAdapter(permission: permission)]
    }

    let permission: SystemPermissionConstraint
    let usageDescriptionKey: String = "NSContactsUsageDescription"

#if canImport(Contacts)
    typealias AuthorizationStatusFunc = (_ entityType: Int) -> Int
    typealias RequestAccessFunc = (_ entityType: Int, _ completion: (_ granted: Bool, _ error: Error?) -> Void) -> Void

    let entityType: CNEntityType
    lazy var contactStore: AnyObject = { try! instantiate(classNamed: "XXXContactStore") }()
    lazy var proxyContactStore: ProxyContactStore = { unsafeBitCast(self.contactStore, to: ProxyContactStore.self) }()
#endif

    var status: SystemPermissionStatus {
#if canImport(Contacts)
        if #available(iOS 9, macOS 10.11, watchOS 2, *) {
            return authStatusToPermissionStatus(type(of: proxyContactStore).authorizationStatus(for: entityType))
        } else {
            return .unsupported
        }
#else
        return .unsupported
#endif
    }
    
    required init(permission: SystemPermissionConstraint) {
        guard case let .contacts(entityType) = permission else {
            flintBug("Cannot create a ContactsPermissionAdapter with permission type \(permission)")
        }
        
#if canImport(Contacts)
        switch entityType {
            case .contacts: self.entityType = .contacts
        }
#endif
        self.permission = permission
    }
    
    func requestAuthorisation(completion: @escaping (_ adapter: SystemPermissionAdapter, _ status: SystemPermissionStatus) -> Void) {
#if !os(tvOS)
        guard status == .notDetermined else {
            return
        }
        
#if canImport(Contacts)
        proxyContactStore.requestAccess(for: entityType, completionHandler: { (_, _) in
            completion(self, self.status)
        })
#endif
#else
        completion(self, .unsupported)
#endif
    }

#if canImport(Contacts)
    @available(iOS 9, macOS 10.11, watchOS 2, *)
    func authStatusToPermissionStatus(_ authStatus: CNAuthorizationStatus) -> SystemPermissionStatus {
#if os(tvOS)
        return .unsupported
#else
        switch authStatus {
            case .authorized: return .authorized
            case .denied: return .denied
            case .notDetermined: return .notDetermined
            case .restricted: return .restricted
        }
#endif
    }
#endif
}
