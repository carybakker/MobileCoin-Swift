//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable todo

import Security

func securityRNG(context: UnsafeMutableRawPointer? = nil) -> UInt64 {
    if let context = context {
        print("********** securityRNG context = \(context)")
        return seedableRNG(context: context)
    } else {
        return defaultRNG()
    }
}

func seedableRNG(context: UnsafeMutableRawPointer) -> UInt64 {
    // get MobileCoinChaCha20Rng from context
    print("********** seedableRNG context = \(context)")
    let chaCha20 = context.bindMemory(to: MobileCoinChaCha20Rng.self, capacity: 1)
    print("********** seedableRNG chaCha20 = \(chaCha20)")
    print("********** seedableRNG chaCha20.pointee = \(chaCha20.pointee)")
    return chaCha20.pointee.nextUInt64()
}

func defaultRNG() -> UInt64 {
    var value: UInt64 = 0

    let numBytes = MemoryLayout.size(ofValue: value)
    let status = withUnsafeMutablePointer(to: &value) { valuePointer in
        SecRandomCopyBytes(kSecRandomDefault, numBytes, valuePointer)
    }

    guard status == errSecSuccess else {
        var message = ""
        if #available(iOS 11.3, *), let errorMessage = SecCopyErrorMessageString(status, nil) {
            message = ", message: \(errorMessage)"
        }
        // TODO: Handle this failure gracefully
        logger.fatalError("Failed to generate bytes. SecError: \(status)" + message)
    }

    return value
}
