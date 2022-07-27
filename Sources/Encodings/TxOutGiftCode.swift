//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

public struct TxOutGiftCode {
    let globalIndex: UInt64
    let oneTimeRistrettoPrivateKey: External_RistrettoPrivate?
    let sharedSecret: External_CompressedRistretto?

    init(
        globalIndex: UInt64,
        oneTimeRistrettoPrivateKey: External_RistrettoPrivate? = nil,
        sharedSecret: External_CompressedRistretto? = nil
    ) {
        self.globalIndex = globalIndex
        self.oneTimeRistrettoPrivateKey = oneTimeRistrettoPrivateKey
        self.sharedSecret = sharedSecret
    }
}

extension TxOutGiftCode: Equatable {}
extension TxOutGiftCode: Hashable {}

extension TxOutGiftCode {
    init?(_ txOutGiftCode: Printable_TxOutGiftCode) {

        let globalIndex = txOutGiftCode.globalIndex

        let privateKey = txOutGiftCode.hasOnetimePrivateKey
            ? txOutGiftCode.onetimePrivateKey : nil

        let sharedSecret = txOutGiftCode.hasSharedSecret
            ? txOutGiftCode.sharedSecret : nil

        self.init(
            globalIndex: globalIndex,
            oneTimeRistrettoPrivateKey: privateKey,
            sharedSecret: sharedSecret)
    }
}

extension Printable_TxOutGiftCode {
    init(_ txOutGiftCode: TxOutGiftCode) {
        self.init()
        self.globalIndex = txOutGiftCode.globalIndex

        if let oneTimePrivateKey = txOutGiftCode.oneTimeRistrettoPrivateKey {
            self.onetimePrivateKey = oneTimePrivateKey
        }

        if let sharedSecret = txOutGiftCode.sharedSecret {
            self.sharedSecret = sharedSecret
        }
    }
}
