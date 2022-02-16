//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable closure_body_length

import Foundation
import LibMobileCoin

enum TxOutUtils {
    static func matchesAnySubaddress(
        maskedValue: UInt64,
        publicKey: RistrettoPublic,
        viewPrivateKey: RistrettoPrivate
    ) -> Bool {
        var mcAmount = McTxOutAmount(masked_value: maskedValue)
        return publicKey.asMcBuffer { publicKeyPtr in
            viewPrivateKey.asMcBuffer { viewPrivateKeyPtr in
                var matches = false
                // Safety: mc_tx_out_matches_any_subaddress is infallible when preconditions are
                // upheld.
                withMcInfallible {
                    mc_tx_out_matches_any_subaddress(
                        &mcAmount,
                        publicKeyPtr,
                        viewPrivateKeyPtr,
                        &matches)
                }
                return matches
            }
        }
    }

    static func matchesSubaddress(
        targetKey: RistrettoPublic,
        publicKey: RistrettoPublic,
        viewPrivateKey: RistrettoPrivate,
        subaddressSpendPrivateKey: RistrettoPrivate
    ) -> Bool {
        targetKey.asMcBuffer { targetKeyBufferPtr in
            publicKey.asMcBuffer { publicKeyBufferPtr in
                viewPrivateKey.asMcBuffer { viewKeyBufferPtr in
                    subaddressSpendPrivateKey.asMcBuffer { spendPrivateKeyBufferPtr in
                        var matches = false
                        // Safety: mc_tx_out_matches_subaddress is infallible when preconditions are
                        // upheld.
                        withMcInfallible {
                            mc_tx_out_matches_subaddress(
                                targetKeyBufferPtr,
                                publicKeyBufferPtr,
                                viewKeyBufferPtr,
                                spendPrivateKeyBufferPtr,
                                &matches)
                        }
                        return matches
                    }
                }
            }
        }
    }

    static func reconstructCommitment(
        maskedValue: UInt64,
        publicKey: RistrettoPublic,
        viewPrivateKey: RistrettoPrivate
    ) -> Data32? {
        var mcAmount = McTxOutAmount(masked_value: maskedValue)
        return publicKey.asMcBuffer { publicKeyBufferPtr in
            viewPrivateKey.asMcBuffer { viewPrivateKeyPtr in
                switch Data32.make(withMcMutableBuffer: { bufferPtr, errorPtr in
                    mc_tx_out_reconstruct_commitment(
                        &mcAmount,
                        publicKeyBufferPtr,
                        viewPrivateKeyPtr,
                        bufferPtr,
                        &errorPtr)
                }) {
                case .success(let bytes):
                    // Safety: It's safe to skip validation because
                    // mc_tx_out_reconstruct_commitment should always return a valid
                    // RistrettoPublic on success.
                    return bytes as Data32
                case .failure(let error):
                    switch error.errorCode {
                    case .invalidInput:
                        // Safety: This condition indicates a programming error and can only
                        // happen if arguments to mc_tx_out_reconstruct_commitment are
                        // supplied incorrectly.
                        logger.warning("error: \(redacting: error)")
                        return nil
                    default:
                        // Safety: mc_tx_out_reconstruct_commitment should not throw
                        // non-documented errors.
                        logger.warning("Unhandled LibMobileCoin error: \(redacting: error)")
                        return nil
                    }
                }
            }
        }
    }

    static func calculateCrc32(
        from commitment: Data32
    ) -> UInt32? {
        return commitment.asMcBuffer { commitmentPtr in
            var crc32: UInt32 = 0
            switch withMcError({ errorPtr in
                mc_tx_out_commitment_crc32(
                    commitmentPtr,
                    &crc32,
                    &errorPtr)
            }) {
            case .success:
                return crc32
            case .failure(let error):
                switch error.errorCode {
                case .invalidInput:
                    // Safety: This condition indicates a programming error and can only
                    // happen if arguments to mc_tx_out_commitment_crc32 are supplied incorrectly.
                    logger.assertionFailure("error: \(redacting: error)")
                    return nil
                default:
                    // Safety: mc_tx_out_commitment_crc32 should not throw nondocumented errors.
                    logger.assertionFailure("Unhandled LibMobileCoin error: \(redacting: error)")
                    return nil
                }
            }
        }
    }

    static func subaddressSpentPublicKey(
        targetKey: RistrettoPublic,
        publicKey: RistrettoPublic,
        viewPrivateKey: RistrettoPrivate
    ) -> RistrettoPublic {
        targetKey.asMcBuffer { targetKeyBufferPtr in
            publicKey.asMcBuffer { publicKeyBufferPtr in
                viewPrivateKey.asMcBuffer { viewPrivateKeyPtr in
                    switch Data32.make(withMcMutableBuffer: { bufferPtr, errorPtr in
                        mc_tx_out_get_subaddress_spend_public_key(
                            targetKeyBufferPtr,
                            publicKeyBufferPtr,
                            viewPrivateKeyPtr,
                            bufferPtr,
                            &errorPtr)
                    }) {
                    case .success(let bytes):
                        // Safety: It's safe to skip validation because
                        // mc_tx_out_get_subaddress_spend_public_key should always return a valid
                        // RistrettoPublic on success.
                        return RistrettoPublic(skippingValidation: bytes)
                    case .failure(let error):
                        switch error.errorCode {
                        case .invalidInput:
                            // Safety: This condition indicates a programming error and can only
                            // happen if arguments to mc_tx_out_get_subaddress_spend_public_key are
                            // supplied incorrectly.
                            logger.fatalError("error: \(redacting: error)")
                        default:
                            // Safety: mc_fog_resolver_add_report_response should not throw
                            // non-documented errors.
                            logger.fatalError("Unhandled LibMobileCoin error: \(redacting: error)")
                        }
                    }
                }
            }
        }
    }

    /// - Returns: `nil` when `viewPrivateKey` cannot unmask value, either because `viewPrivateKey`
    ///     does not own `TxOut` or because `TxOut` values are incongruent.
    static func value(
        maskedValue: UInt64,
        publicKey: RistrettoPublic,
        viewPrivateKey: RistrettoPrivate
    ) -> UInt64? {
        var mcAmount = McTxOutAmount(masked_value: maskedValue)
        return publicKey.asMcBuffer { publicKeyPtr in
            viewPrivateKey.asMcBuffer { viewKeyBufferPtr in
                var valueOut: UInt64 = 0
                switch withMcError({ errorPtr in
                    mc_tx_out_get_value(
                        &mcAmount,
                        publicKeyPtr,
                        viewKeyBufferPtr,
                        &valueOut,
                        &errorPtr)
                }) {
                case .success:
                    return valueOut
                case .failure(let error):
                    switch error.errorCode {
                    case .transactionCrypto:
                        // Indicates either `commitment`/`maskedValue`/`publicKey` values are
                        // incongruent or `viewPrivateKey` does not own `TxOut`. However, it's
                        // not possible to determine which, only that the provided `commitment`
                        // doesn't match the computed commitment.
                        return nil
                    case .invalidInput:
                        // Safety: This condition indicates a programming error and can only
                        // happen if arguments to mc_tx_out_get_value are supplied incorrectly.
                        logger.fatalError("error: \(redacting: error)")
                    default:
                        // Safety: mc_tx_out_get_value should not throw non-documented errors.
                        logger.fatalError("Unhandled LibMobileCoin error: \(redacting: error)")
                    }
                }
            }
        }
    }

    /// - Returns: `nil` when a valid `KeyImage` cannot be constructed, either because
    ///     `viewPrivateKey`/`subaddressSpendPrivateKey` do not own `TxOut` or because `TxOut`
    ///     values are incongruent.
    static func keyImage(
        targetKey: RistrettoPublic,
        publicKey: RistrettoPublic,
        viewPrivateKey: RistrettoPrivate,
        subaddressSpendPrivateKey: RistrettoPrivate
    ) -> KeyImage? {
        targetKey.asMcBuffer { targetKeyPtr in
            publicKey.asMcBuffer { publicKeyPtr in
                viewPrivateKey.asMcBuffer { viewKeyBufferPtr in
                    subaddressSpendPrivateKey.asMcBuffer { spendKeyBufferPtr in
                        switch Data32.make(withMcMutableBuffer: { bufferPtr, errorPtr in
                            mc_tx_out_get_key_image(
                                targetKeyPtr,
                                publicKeyPtr,
                                viewKeyBufferPtr,
                                spendKeyBufferPtr,
                                bufferPtr,
                                &errorPtr)
                        }) {
                        case .success(let keyImageData):
                            return KeyImage(keyImageData)
                        case .failure(let error):
                            switch  error.errorCode {
                            case .transactionCrypto:
                                // Indicates either `targetKey`/`publicKey` values are incongruent
                                //  or`viewPrivateKey`/`subaddressSpendPrivateKey` does not own
                                // `TxOut`. However, it's not possible to determine which, only that
                                // the provided `targetKey` doesn't match the computed target key
                                // (aka onetime public key).
                                return nil
                            case .invalidInput:
                                // Safety: This condition indicates a programming error and can only
                                // happen if arguments to mc_tx_out_get_key_image are supplied
                                // incorrectly.
                                logger.fatalError("error: \(redacting: error)")
                            default:
                                // Safety: mc_tx_out_get_key_image should not throw non-documented
                                // errors.
                                logger.fatalError(
                                    "Unhandled LibMobileCoin error: \(redacting: error)")
                            }
                        }
                    }
                }
            }
        }
    }

    static func validateConfirmationNumber(
        publicKey: RistrettoPublic,
        confirmationNumber: TxOutConfirmationNumber,
        viewPrivateKey: RistrettoPrivate
    ) -> Bool {
        publicKey.asMcBuffer { publicKeyPtr in
            confirmationNumber.asMcBuffer { confirmationNumberPtr in
                viewPrivateKey.asMcBuffer { viewKeyBufferPtr in
                    var result = false
                    // Safety: mc_tx_out_validate_confirmation_number is infallible when
                    // preconditions are upheld.
                    withMcInfallible {
                        mc_tx_out_validate_confirmation_number(
                            publicKeyPtr,
                            confirmationNumberPtr,
                            viewKeyBufferPtr,
                            &result)
                    }
                    return result
                }
            }
        }
    }
}
