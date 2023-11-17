//
//  SdkSessionContext.swift
//  SDK
//
//  Created by Stan Potemkin on 26.02.2023.
//

import Foundation

protocol ISdkSessionContext: AnyObject {
    var eventSignal: JVBroadcastTool<SdkSessionContextEvent> { get }
    var networkingState: ReachabilityMode { get set }
    var connectionAllowance: SdkSessionConnectionAllowance { get set }
    var connectionState: SdkSessionConnectionState { get set }
    var accountConfig: SdkClientAccountConfig? { get set }
    var endpointConfig: SdkSessionEndpointConfig? { get set }
    var identifyingToken: String? { get set }
    var localChatId: Int? { get }
    var authorizingPath: String? { get set }
    func reset()
}

extension PreferencesToken {
    static let accountConfig = PreferencesToken(key: "accountConfig", hint: SdkClientAccountConfig.self)
    static let endpointConfig = PreferencesToken(key: "endpointConfig", hint: SdkSessionEndpointConfig.self)
}

enum SdkSessionContextEvent {
    case networkingStateChanged(ReachabilityMode)
    case connectionStateChanged(SdkSessionConnectionState)
    case accountConfigChanged(SdkClientAccountConfig?)
    case identifyingTokenChanged(String?)
    case authorizingPathChanged(String?)
}

enum SdkSessionConnectionAllowance {
    case allowed
    case disallowed
}

enum SdkSessionConnectionState {
    case disconnected
    case searching
    case identifying
    case connecting
    case connected
}

struct SdkSessionEndpointConfig: Codable {
    let chatserverHost: String
    let chatserverPort: Int
    let apiHost: String
    let filesHost: String
}

final class SdkSessionContext: ISdkSessionContext {
    let eventSignal = JVBroadcastTool<SdkSessionContextEvent>()
    
    private let accountConfigAccessor: IPreferencesAccessor
    private let endpointConfigAccessor: IPreferencesAccessor
    
    init(accountConfigAccessor: IPreferencesAccessor, endpointConfigAccessor: IPreferencesAccessor) {
        self.accountConfigAccessor = accountConfigAccessor
        self.endpointConfigAccessor = endpointConfigAccessor
        
        accountConfig = accountConfigAccessor.accountConfig
        endpointConfig = endpointConfigAccessor.endpointConfig
    }
    
    var networkingState = ReachabilityMode.none {
        didSet {
            eventSignal.broadcast(.networkingStateChanged(networkingState))
//            print("[DEBUG] SdkSessionContext.connectionState = \(connectionState)")
        }
    }

    var connectionAllowance = SdkSessionConnectionAllowance.disallowed {
        didSet {
            eventSignal.broadcast(.connectionStateChanged(connectionState))
//            print("[DEBUG] SdkSessionContext.connectionState = \(connectionState)")
        }
    }

    var connectionState = SdkSessionConnectionState.disconnected {
        didSet {
            eventSignal.broadcast(.connectionStateChanged(connectionState))
//            print("[DEBUG] SdkSessionContext.connectionState = \(connectionState)")
        }
    }

    var accountConfig: SdkClientAccountConfig? {
        didSet {
            accountConfigAccessor.accountConfig = accountConfig
            eventSignal.broadcast(.accountConfigChanged(accountConfig))
        }
    }
    
    var endpointConfig: SdkSessionEndpointConfig? {
        didSet {
            endpointConfigAccessor.endpointConfig = endpointConfig
        }
    }
    
    var identifyingToken: String? {
        didSet {
            eventSignal.broadcast(.identifyingTokenChanged(identifyingToken))
        }
    }
    
    var localChatId: Int? {
        guard let identifyingToken = identifyingToken else {
            journal {"Failed obtaining a chat because clientToken doesn't exists"}
            return nil
        }
        
        let chatId = max(1, CRC32.encrypt(identifyingToken))
        return chatId
    }
    
    var authorizingPath: String? {
        didSet {
            eventSignal.broadcast(.authorizingPathChanged(authorizingPath))
        }
    }
    
    func reset() {
//        print("[DEBUG] SessionContext -> Reset identifyingToken")
        accountConfig = nil
        identifyingToken = nil
        authorizingPath = nil
    }
}

extension IPreferencesAccessor {
    var accountConfig: SdkClientAccountConfig? {
        get {
            data.flatMap { try? JSONDecoder().decode(SdkClientAccountConfig.self, from: $0) }
        }
        set {
            data = try? JSONEncoder().encode(newValue)
        }
    }
    
    var endpointConfig: SdkSessionEndpointConfig? {
        get {
            data.flatMap { try? JSONDecoder().decode(SdkSessionEndpointConfig.self, from: $0) }
        }
        set {
            data = try? JSONEncoder().encode(newValue)
        }
    }
}