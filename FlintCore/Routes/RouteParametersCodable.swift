//
//  QueryParametersCodable.swift
//  FlintCore
//
//  Created by Marc Palmer on 29/01/2018.
//  Copyright © 2018 Montana Floss Co. Ltd. All rights reserved.
//

import Foundation

public typealias RouteParameters = [String:String]

/// The protocol for decoding an input value from URL route parameters.
/// Conform your input types to this to to enable execution of actions with your input type
/// when incoming URLs are parsed.
public protocol RouteParametersDecodable {
    /// Construct the type from the specified URL parameters.
    /// Implementations can use the `mapping` parameter to perform different parsing
    /// based on the kind of URL e.g. app custom URL scheme or deep linking.
    /// - param routeParameters: The dictionary of URL query parameters
    /// - param mapping: The URL mapping that the incoming URL matched
    init?(from routeParameters: RouteParameters?, mapping: URLMapping)
}

/// The protocol for encoding an input value from URL route parameters.
/// Conform your input types to this to to enable creation of links to actions with your input type.
public protocol RouteParametersEncodable {
    /// Return a dictionary of URL parameters that, when passed to `RouteParametersDecodable.init`, will
    /// reconstruct the same state of the conforming type.
    /// Implementations can use the `mapping` parameter to perform different encoding
    /// based on the kind of URL e.g. app custom URL scheme or deep linking.
    /// - param mapping: The URL mapping that is being used to create a link
    func encodeAsRouteParameters(for mapping: URLMapping) -> RouteParameters?
}

/// The protocol for encoding and decoding an input value to and from URL route parameters.
/// Conform your input types to this to to enable execution of actions with your input type
/// when incoming URLs are parsed, as well as creation of URL links to those actions.
public typealias RouteParametersCodable = RouteParametersDecodable & RouteParametersEncodable

