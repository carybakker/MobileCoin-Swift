//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

func withMcRngObjCallback<T>(
    rngFunc: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
    rng: MobileCoinRng,
    _ body: (UnsafeMutablePointer<McRngCallback>?) throws -> T
) rethrows -> T {
    if let rngFunc = rngFunc {
        let rawRng = Unmanaged.passUnretained(rng).toOpaque()
        var rngCallback = McRngCallback(rng: rngFunc, context: rawRng)
        return try body(&rngCallback)
    } else {
        return try body(nil)
    }
}

func withMcRngCallback<T>(
    rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
    rngContext: Any?,
    _ body: (UnsafeMutablePointer<McRngCallback>?) throws -> T
) rethrows -> T {
    if let rng = rng {
        if let rngContext = rngContext {
            var rngContext = rngContext
            return try withUnsafeMutablePointer(to: &rngContext) { rngContextPtr in
                var rngCallback = McRngCallback(rng: rng, context: rngContextPtr)
                return try body(&rngCallback)
            }
        } else {
            var rngCallback = McRngCallback(rng: rng, context: nil)
            return try body(&rngCallback)
        }
    } else {
        return try body(nil)
    }
}
