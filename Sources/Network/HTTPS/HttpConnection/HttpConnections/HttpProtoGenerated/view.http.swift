//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: view.proto
//
//  swiftlint:disable all

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import SwiftProtobuf
import LibMobileCoin


/// Usage: instantiate `FogView_FogViewAPIRestClient`, then call methods of this protocol to make API calls.
public protocol FogView_FogViewAPIRestClientProtocol: HTTPClient {
  var serviceName: String { get }

  func auth(
    _ request: Attest_AuthMessage,
    callOptions: HTTPCallOptions?
  ) -> HTTPUnaryCall<Attest_AuthMessage, Attest_AuthMessage>

  func query(
    _ request: Attest_Message,
    callOptions: HTTPCallOptions?
  ) -> HTTPUnaryCall<Attest_Message, Attest_Message>
}

extension FogView_FogViewAPIRestClientProtocol {
  public var serviceName: String {
    return "fog_view.FogViewAPI"
  }

  //// This is called to perform IX key exchange with the enclave before calling GetOutputs.
  ///
  /// - Parameters:
  ///   - request: Request to send to Auth.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func auth(
    _ request: Attest_AuthMessage,
    callOptions: HTTPCallOptions? = nil
  ) -> HTTPUnaryCall<Attest_AuthMessage, Attest_AuthMessage> {
    return self.makeUnaryCall(
      path: "/fog_view.FogViewAPI/Auth",
      request: request,
      callOptions: callOptions ?? self.defaultHTTPCallOptions
    )
  }

  //// Input should be an encrypted QueryRequest, result is an encrypted QueryResponse
  ///
  /// - Parameters:
  ///   - request: Request to send to Query.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func query(
    _ request: Attest_Message,
    callOptions: HTTPCallOptions? = nil
  ) -> HTTPUnaryCall<Attest_Message, Attest_Message> {
    return self.makeUnaryCall(
      path: "/fog_view.FogViewAPI/Query",
      request: request,
      callOptions: callOptions ?? self.defaultHTTPCallOptions
    )
  }
}

public final class FogView_FogViewAPIRestClient: FogView_FogViewAPIRestClientProtocol {
  public var defaultHTTPCallOptions: HTTPCallOptions

  /// Creates a client for the fog_view.FogViewAPI service.
  ///
  /// - Parameters:
  ///   - defaultHTTPCallOptions: Options to use for each service call if the user doesn't provide them.
  public init(
    defaultHTTPCallOptions: HTTPCallOptions = HTTPCallOptions()
  ) {
    self.defaultHTTPCallOptions = defaultHTTPCallOptions
  }
}

