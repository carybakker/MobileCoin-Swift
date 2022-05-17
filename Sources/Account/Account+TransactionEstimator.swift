//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable closure_body_length

import Foundation

extension Account {
    struct TransactionEstimator {
        private let serialQueue: DispatchQueue
        private let account: ReadWriteDispatchLock<Account>
        private let metaFetcher: BlockchainMetaFetcher
        private let txOutSelector: TxOutSelector

        init(
            account: ReadWriteDispatchLock<Account>,
            metaFetcher: BlockchainMetaFetcher,
            txOutSelectionStrategy: TxOutSelectionStrategy,
            targetQueue: DispatchQueue?
        ) {
            self.serialQueue = DispatchQueue(
                label: "com.mobilecoin.\(Account.self).\(Self.self))",
                target: targetQueue)
            self.account = account
            self.metaFetcher = metaFetcher
            self.txOutSelector = TxOutSelector(txOutSelectionStrategy: txOutSelectionStrategy)
        }

        func amountTransferable(
            tokenId: TokenId,
            feeLevel: FeeLevel,
            completion: @escaping (Result<UInt64, BalanceTransferEstimationFetcherError>) -> Void
        ) {
            metaFetcher.feeStrategy(for: feeLevel, tokenId: tokenId) {
                completion($0.mapError { .connectionError($0) }
                    .flatMap { feeStrategy in
                        let txOuts = self.account.readSync { $0.unspentTxOuts(tokenId: tokenId) }
                        logger.info(
                            "Calculating amountTransferable. feeLevel: \(feeLevel), " +
                                "tokenId: \(tokenId), " +
                                "unspentTxOutValues: \(redacting: txOuts.map { $0.value })",
                            logFunction: false)
                        return self.txOutSelector
                            .amountTransferable(
                                tokenId: tokenId,
                                feeStrategy: feeStrategy,
                                txOuts: txOuts
                            )
                            .mapError {
                                switch $0 {
                                case .feeExceedsBalance(let reason):
                                    return .feeExceedsBalance(reason)
                                case .balanceOverflow(let reason):
                                    return .balanceOverflow(reason)
                                }
                            }
                            .map {
                                logger.info(
                                    "amountTransferable: \(redacting: $0)",
                                    logFunction: false)
                                return $0
                            }
                    })
            }
        }

        func estimateTotalFee(
            toSendAmount amount: Amount,
            feeLevel: FeeLevel,
            completion: @escaping (Result<UInt64, TransactionEstimationFetcherError>) -> Void
        ) {
            guard amount.value > 0 else {
                let errorMessage = "estimateTotalFee failure: Cannot spend 0 \(amount.tokenId)"
                logger.error(errorMessage, logFunction: false)
                serialQueue.async {
                    completion(.failure(.invalidInput(errorMessage)))
                }
                return
            }

            metaFetcher.feeStrategy(for: feeLevel, tokenId: amount.tokenId) {
                completion($0.mapError { .connectionError($0) }
                    .flatMap { feeStrategy in
                        let txOuts = self.account.readSync {
                            $0.unspentTxOuts(tokenId: amount.tokenId)
                        }
                        logger.info(
                            "Estimating total fee: amount: \(redacting: amount.value), feeLevel: " +
                                "\(feeLevel), tokenId: \(amount.tokenId), unspentTxOutValues: " +
                                "\(redacting: txOuts.map { $0.value })",
                            logFunction: false)
                        return self.txOutSelector
                            .estimateTotalFee(
                                toSendAmount: amount,
                                feeStrategy: feeStrategy,
                                txOuts: txOuts)
                            .mapError { _ in
                                TransactionEstimationFetcherError.insufficientBalance()
                            }
                            .map {
                                logger.info(
                                    "estimateTotalFee: \(redacting: $0.totalFee), " +
                                        "requiresDefrag: \($0.requiresDefrag)",
                                    logFunction: false)
                                return $0.totalFee
                            }
                    })
            }
        }

        func requiresDefragmentation(
            toSendAmount amount: Amount,
            feeLevel: FeeLevel,
            completion: @escaping (Result<Bool, TransactionEstimationFetcherError>) -> Void
        ) {
            guard amount.value > 0 else {
                let errorMessage = "requiresDefragmentation failure: " +
                    "Cannot spend 0 \(amount.tokenId)"
                logger.error(errorMessage, logFunction: false)
                serialQueue.async {
                    completion(.failure(.invalidInput(errorMessage)))
                }
                return
            }

            metaFetcher.feeStrategy(for: feeLevel, tokenId: amount.tokenId) {
                completion($0.mapError { .connectionError($0) }
                    .flatMap { feeStrategy in
                        let txOuts = self.account.readSync {
                            $0.unspentTxOuts(tokenId: amount.tokenId)
                        }
                        logger.info(
                            "Calculation defragmentation required: amount: " +
                                "\(redacting: amount.value), " +
                                "feeLevel: \(feeLevel), tokenId: \(amount.tokenId), " +
                                "unspentTxOutValues: \(redacting: txOuts.map { $0.value })",
                            logFunction: false)
                        return self.txOutSelector
                            .estimateTotalFee(
                                toSendAmount: amount,
                                feeStrategy: feeStrategy,
                                txOuts: txOuts)
                            .mapError { _ in
                                TransactionEstimationFetcherError.insufficientBalance()
                            }
                            .map {
                                logger.info(
                                    "requiresDefragmentation: \($0.requiresDefrag), totalFee: " +
                                        "\(redacting: $0.totalFee)",
                                logFunction: false)
                                return $0.requiresDefrag
                            }
                    })
            }
        }
    }
}

extension Account.TransactionEstimator {
    // TODO update deprecation message, and or delete if not in use.
    @available(*, deprecated, message: "Use amountTransferable(feeLevel:completion:) instead")
    func amountTransferable(feeLevel: FeeLevel)
        -> Result<UInt64, BalanceTransferEstimationError>
    {
        let feeStrategy = feeLevel.defaultFeeStrategy
        let txOuts = account.readSync { $0.unspentTxOuts }
        logger.info(
            "Calculating amountTransferable. feeLevel: \(feeLevel), unspentTxOutValues: " +
                "\(redacting: txOuts.map { $0.value })",
            logFunction: false)
        return txOutSelector.amountTransferable(
            tokenId: .MOB,
            feeStrategy: feeStrategy,
            txOuts: txOuts)
            .mapError {
                switch $0 {
                case .feeExceedsBalance(let reason):
                    return .feeExceedsBalance(reason)
                case .balanceOverflow(let reason):
                    return .balanceOverflow(reason)
                }
            }
            .map {
                logger.info("amountTransferable: \(redacting: $0)", logFunction: false)
                return $0
            }
    }

    // TODO update deprecation message, and or delete if not in use.
    @available(*, deprecated, message:
        "Use estimateTotalFee(toSendAmount:feeLevel:completion:) instead")
    func estimateTotalFee(toSendAmount amount: UInt64, feeLevel: FeeLevel)
        -> Result<UInt64, TransactionEstimationError>
    {
        guard amount > 0 else {
            let errorMessage = "estimateTotalFee failure: Cannot spend 0 MOB"
            logger.error(errorMessage, logFunction: false)
            return .failure(.invalidInput(errorMessage))
        }

        let feeStrategy = feeLevel.defaultFeeStrategy
        let txOuts = account.readSync { $0.unspentTxOuts }
        logger.info(
            "Estimating total fee: amount: \(redacting: amount), feeLevel: \(feeLevel), " +
                "unspentTxOutValues: \(redacting: txOuts.map { $0.value })",
            logFunction: false)

        let amount = Amount(value: amount, tokenId: .MOB)
        return txOutSelector
            .estimateTotalFee(toSendAmount: amount, feeStrategy: feeStrategy, txOuts: txOuts)
            .mapError { _ -> TransactionEstimationError in .insufficientBalance() }
            .map {
                logger.info(
                    "estimateTotalFee: \(redacting: $0.totalFee), requiresDefrag: " +
                        "\($0.requiresDefrag)",
                    logFunction: false)
                return $0.totalFee
            }
    }

    // TODO update deprecation message, and or delete if not in use.
    @available(*, deprecated, message:
        "Use requiresDefragmentation(toSendAmount:feeLevel:completion:) instead")
    func requiresDefragmentation(toSendAmount amount: UInt64, feeLevel: FeeLevel)
        -> Result<Bool, TransactionEstimationError>
    {
        guard amount > 0 else {
            let errorMessage = "requiresDefragmentation failure: Cannot spend 0 MOB"
            logger.error(errorMessage, logFunction: false)
            return .failure(.invalidInput(errorMessage))
        }

        let feeStrategy = feeLevel.defaultFeeStrategy
        let txOuts = account.readSync { $0.unspentTxOuts }
        logger.info(
            "Calculation defragmentation required: amount: \(redacting: amount), feeLevel: " +
                "\(feeLevel), unspentTxOutValues: \(redacting: txOuts.map { $0.value })",
            logFunction: false)

        let amount = Amount(value: amount, tokenId: .MOB)
        return txOutSelector
            .estimateTotalFee(toSendAmount: amount, feeStrategy: feeStrategy, txOuts: txOuts)
            .mapError { _ -> TransactionEstimationError in .insufficientBalance() }
            .map {
                logger.info(
                    "requiresDefragmentation: \($0.requiresDefrag), totalFee: " +
                        "\(redacting: $0.totalFee)",
                logFunction: false)
                return $0.requiresDefrag
            }
    }
}
