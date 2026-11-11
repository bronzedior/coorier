//
//  RoomWire.swift
//  Coorier
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 26/10/26.
//

import Foundation
import Network

nonisolated enum RoomWire {
    static let service = "_coorier._tcp"
    static let sealKey = "seal"
    static let codeKey = "code"
    static let maxMembers = 8
    static let heartbeat = Duration.seconds(1)
    static let silenceLimit: TimeInterval = 2.5

    static var browseParameters: NWParameters {
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        return parameters
    }

    static func isPermissionDenied(_ error: NWError) -> Bool {
        if case .dns(let code) = error { return code == DNSServiceErrorType(kDNSServiceErr_PolicyDenied) }
        return false
    }
}

@available(iOS 26.0, *)
typealias RoomHostCoder = Coder<ServerMessage, ClientMessage, NetworkJSONCoder>

@available(iOS 26.0, *)
nonisolated extension NWParametersBuilder {
    static func reliable<S: Encodable, R: Decodable>(_: S.Type, _: R.Type) -> NWParametersBuilder<Coder<S, R, NetworkJSONCoder>> {
        .parameters { Coder(sending: S.self, receiving: R.self, using: .json) { TCP().noDelay(true) } }
            .peerToPeerIncluded(true)
    }
}
