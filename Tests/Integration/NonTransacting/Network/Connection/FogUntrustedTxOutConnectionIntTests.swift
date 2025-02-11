//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class FogUntrustedTxOutConnectionIntTests: XCTestCase {
    func testGetTxOutsReturnsNoResultsWithoutPubkeys() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try getTxOutsReturnsNoResultsWithoutPubkeys(transportProtocol: transportProtocol)
        }
    }

    func getTxOutsReturnsNoResultsWithoutPubkeys(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Fog GetTxOuts request")
        try createFogUntrustedTxOutConnection(
            transportProtocol: transportProtocol
        ).getTxOuts(request: FogLedger_TxOutRequest()) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }
            print("numBlocks: \(response.numBlocks)")
            print("globalTxoCount: \(response.globalTxoCount)")

            XCTAssertEqual(response.results.count, 0)
            XCTAssertGreaterThan(response.numBlocks, 0)
            XCTAssertGreaterThan(response.globalTxoCount, 0)

            expect.fulfill()
        }
        waitForExpectations(timeout: 40)
    }

    func testInvalidCredentialsReturnsAuthorizationFailure() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try invalidCredentialsReturnsAuthorizationFailure(transportProtocol: transportProtocol)
        }
    }

    func invalidCredentialsReturnsAuthorizationFailure(
        transportProtocol: TransportProtocol
    ) throws {
        try XCTSkipUnless(IntegrationTestFixtures.network.fogRequiresCredentials)

        let expect = expectation(description: "Fog GetTxOuts request")
        let connection = try createFogUntrustedTxOutConnectionWithInvalidCredentials(
            transportProtocol: transportProtocol)
        connection.getTxOuts(request: FogLedger_TxOutRequest()) {
            guard let error = $0.failureOrFulfill(expectation: expect) else { return }

            switch error {
            case .authorizationFailure:
                break
            default:
                XCTFail("error of type \(type(of: error)), \(error)")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 40)
    }
}

extension FogUntrustedTxOutConnectionIntTests {
    func createFogUntrustedTxOutConnection(
        transportProtocol: TransportProtocol
    ) throws -> FogUntrustedTxOutConnection {
        let networkConfig = try NetworkConfigFixtures.create(using: transportProtocol)
        return createFogUntrustedTxOutConnection(networkConfig: networkConfig)
    }

    func createFogUntrustedTxOutConnectionWithInvalidCredentials(
        transportProtocol: TransportProtocol
    ) throws
        -> FogUntrustedTxOutConnection
    {
        let networkConfig = try NetworkConfigFixtures.createWithInvalidCredentials(
            using: transportProtocol)
        return createFogUntrustedTxOutConnection(networkConfig: networkConfig)
    }

    func createFogUntrustedTxOutConnection(networkConfig: NetworkConfig)
        -> FogUntrustedTxOutConnection
    {
        let httpFactory = HttpProtocolConnectionFactory(
            httpRequester: networkConfig.httpRequester ?? DefaultHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return FogUntrustedTxOutConnection(
            httpFactory: httpFactory,
            grpcFactory: grpcFactory,
            config: networkConfig,
            targetQueue: DispatchQueue.main)
    }
}
