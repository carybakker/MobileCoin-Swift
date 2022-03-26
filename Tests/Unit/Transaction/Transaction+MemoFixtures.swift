//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin
import XCTest


extension Transaction.Fixtures {
    struct TxOutMemo {
        let senderAccountKey: AccountKey
        let recipientAccountKey: AccountKey
        
        let inputs: [PreparedTxInput]
        let txOuts: [TxOut]
        let membershipProofs: [TxOutMembershipProof]
        let fee = Self.fee
        let amount = PositiveUInt64(1)!
        let tombstoneBlockIndex = Self.tombstoneBlockIndex
        let fogResolver: FogResolver
        let globalIndex: UInt64
        let blockMetadata: BlockMetadata
        let blockVersion: BlockVersion
        
        var totalOutlay : UInt64 {
            return fee + amount.value
        }

        init() throws {
            self.inputs = try Self.inputs()
            self.txOuts = try Self.nativeTxOuts()
            self.membershipProofs = try Self.txOutMembershipProofs()
            self.senderAccountKey = try Self.senderAccountKey()
            self.recipientAccountKey = try Self.recipientAccountKey()
            self.fogResolver = try Self.fogResolver()
            self.globalIndex = Self.globalIndex
            self.blockMetadata = Self.blockMetadata
            self.blockVersion = Self.blockVersion
        }
    }
    
    struct DestinationMemo {
        let accountKey: AccountKey
        let fee: UInt64
        let totalOutlay: UInt64
        let numberOfRecipients: UInt8
        let validMemoDataHexBytes: String
        
        init() throws {
            self.accountKey = try AccountKey.Fixtures.AliceAndBob().alice
            self.validMemoDataHexBytes = Self.validMemoDataHexBytes
            self.fee = Self.fee
            self.totalOutlay = Self.totalOutlay
            self.numberOfRecipients = Self.numberOfRecipients
        }
        
        static var validMemoDataHexBytes: String =
            """
            ccb5a98f0c0c42f68491e5e0c936245201000000000000040000000000000064\
            0000000000000000000000000000000000000000000000000000000000000000
            """
        
        static var fee: UInt64 = 3
        
        static var totalOutlay: UInt64 = 100
        
        static var numberOfRecipients: UInt8 = 1
    }
    
    struct SenderMemo {
        let senderAccountKey: AccountKey
        let recieverAccountKey: AccountKey
        let txOutPublicKey: RistrettoPublic
        let expectedMemoData: Data64
        let expectedSenderAddressHash: Data16

        init() throws {
            self.senderAccountKey = try AccountKey.Fixtures.AliceAndBob().alice
            self.recieverAccountKey = try AccountKey.Fixtures.AliceAndBob().bob
            self.txOutPublicKey = try Self.getTxOutPublicKey()
            self.expectedMemoData = try Self.getExpectedMemoData()
            self.expectedSenderAddressHash = try Self.getExpectedSenderAddressHash()
        }
        
        static func getTxOutPublicKey() throws -> RistrettoPublic {
            try XCTUnwrap(
                    RistrettoPublic(try XCTUnwrap(
                                        Data(hexEncoded: txOutPublicKeyHex))))
        }
        
        static let txOutPublicKeyHex = "c235c13c4dedd808e95f428036716d52561fad7f51ce675f4d4c9c1fa1ea2165"

        static func getExpectedMemoData() throws -> Data64 {
            try XCTUnwrap(Data64(
                            XCTUnwrap(Data(hexEncoded: validMemoDataHexBytes))))
        }
        
        static var validMemoDataHexBytes: String =
            """
            ccb5a98f0c0c42f68491e5e0c936245200000000000000000000000000000000\
            00000000000000000000000000000000bf2eef7c5c35df8f909e40fbd118e426
            """
        
        static func getExpectedSenderAddressHash() throws -> Data16 {
            try XCTUnwrap(Data16(
                            XCTUnwrap(Data(hexEncoded: expectedAddressHashHex))))
        }
        
        static var expectedAddressHashHex: String =
            """
            ccb5a98f0c0c42f68491e5e0c9362452
            """
    }
    
    struct SenderWithPaymentRequestMemo {
        let senderAccountKey: AccountKey
        let recieverAccountKey: AccountKey
        let txOutPublicKey: RistrettoPublic
        let expectedMemoData: Data64
        let expectedSenderAddressHash: Data16
        let paymentRequestId: UInt64 = 17014

        init() throws {
            self.senderAccountKey = try AccountKey.Fixtures.AliceAndBob().alice
            self.recieverAccountKey = try AccountKey.Fixtures.AliceAndBob().bob
            self.txOutPublicKey = try Self.getTxOutPublicKey()
            self.expectedMemoData = try Self.getExpectedMemoData()
            self.expectedSenderAddressHash = try Self.getExpectedSenderAddressHash()
        }
        
        static func getTxOutPublicKey() throws -> RistrettoPublic {
            try XCTUnwrap(RistrettoPublic(
                            try XCTUnwrap(Data(hexEncoded: txOutPublicKeyHex))))
        }
        
        static let txOutPublicKeyHex = "c235c13c4dedd808e95f428036716d52561fad7f51ce675f4d4c9c1fa1ea2165"

        static func getExpectedMemoData() throws -> Data64 {
            try XCTUnwrap(Data64(
                            XCTUnwrap(Data(hexEncoded: validMemoDataHexBytes))))
        }
        
        static var validMemoDataHexBytes: String =
            """
            ccb5a98f0c0c42f68491e5e0c936245200000000000000000000000000000000\
            00000000000000000000000000000000bf2eef7c5c35df8f909e40fbd118e426
            """
        
        static func getExpectedSenderAddressHash() throws -> Data16 {
            try XCTUnwrap(Data16(
                            XCTUnwrap(Data(hexEncoded: expectedAddressHashHex))))
        }
        
        static var expectedAddressHashHex: String =
            """
            ccb5a98f0c0c42f68491e5e0c9362452
            """
    }

    static var validAddressHashHexBytes: String = "ccb5a98f0c0c42f68491e5e0c9362452"
}

extension Transaction.Fixtures.TxOutMemo {


    fileprivate static let blockVersion = BlockVersion.minRTHEnabled

    static let realIndex = 3;
    
    static func realKnownTxOut() throws -> KnownTxOut {
        let senderAccountKey = try senderAccountKey()
        let txOuts = try nativeTxOuts()
        let realTxOut = txOuts[realIndex]
        let ledgerTxOut = LedgerTxOut(PartialTxOut(realTxOut), globalIndex: globalIndex, block: blockMetadata)
        return try XCTUnwrap(KnownTxOut(ledgerTxOut, accountKey: senderAccountKey))
    }
    
    static let globalIndex: UInt64 = 100011
    static let blockMetadata: BlockMetadata = {
        BlockMetadata(
            index: 2,
            timestampStatus: .known(
                timestamp: Date(timeIntervalSince1970: 1602883052.0))
        )
    }()
    
    fileprivate static func inputs() throws -> [PreparedTxInput] {
        let senderAccountKey = try senderAccountKey()
        let txOuts = try nativeTxOuts()
        let membershipProofs = try txOutMembershipProofs()
        
        let realTxOut = txOuts[realIndex]
        let partialTxOut = PartialTxOut(realTxOut)
        
        let ledgerTxOut = LedgerTxOut(partialTxOut, globalIndex: globalIndex, block: blockMetadata)
        let knownTxOut = try XCTUnwrap(KnownTxOut(
                                            ledgerTxOut,
                                            accountKey: senderAccountKey))

        let ring: [(TxOut, TxOutMembershipProof)] = Array(zip(txOuts, membershipProofs))

        return [try PreparedTxInput.make(knownTxOut: knownTxOut, ring: ring).get()]
    }
    
    static let fee: UInt64 = 1
    
    static let tombstoneBlockIndex: UInt64 = 2000
    
    fileprivate static let fogAlphaUri = "fog://fog.alpha.mobilecoin.com/";

    private static func fogReportUrl() throws -> FogUrl {
        try FogUrl.make(string: fogAlphaUri).get()
    }

    fileprivate static func fogResolver() throws -> FogResolver {
        let fogReportUrl = try self.fogReportUrl()
        return try FogResolver.Fixtures.TxOutMemo(reportUrl: fogReportUrl).fogResolver
    }

    static let serializedNativeTxOut1 =
        """
        0a2d0a220a2096d8617e40ed91a2d64e178eaa094e368d79ba99e0e4635e8eb4\
        b52ea0cacf2511c8a2790b6f52cbf212220a2026493f8f89fa0da368ebc17181\
        06166e33ae6ca55c020533e2999dfdf17aa24a1a220a2044b37d84b3b3a9af32\
        0eb328ef7b60acc65853b13475ff473b94a75776ccad3522560a54c1c9517f91\
        c2438631665223b7aa469e1d7842c22f8d86e9299c2b48311b178f6a3b0adbfe\
        9c2e2f7c0c0db75685034b0d2df4c31f3ebf6f28c939ce0a28e0a379326579f5\
        c52bfd62fe44e0071eb8da3f2d0100
        """

    static let serializedNativeTxOut2 =
        """
        0a2d0a220a20e22a66b7e47e9715347d09ab26397c11eda3d22f7fb828e7211f\
        42736c413944114cb68f677ded938912220a20628237110e12505192eddfefdc\
        060c7fc9141140496c7e278e7671dabb4bb6721a220a206ac207216beafa0330\
        9cf074fca62c6b502017a3b41767d77f12bf985b09d43222560a541089d11341\
        1fe5a0a5f56266d618612c918f1d5d3ffe197d4211e640ba920daa4d1bf4c253\
        a7941ef0292791a0f00c88c6690188d9bdf6bff51ce2ca016ae37fda77d5d303\
        4e3e97b9ae7ecb1add95be98850100
        """

    static let serializedNativeTxOut3 =
        """
        0a2d0a220a202ad7120b8bac67f269d090ed6f7b23c8ebe1882497dece3e6097\
        d1797b83521a11516697eaaaa5762012220a20a6f85c13014065a652e5ca0de1\
        2d5aa189e301dd0dc6ffda37b281695e0dc4361a220a207eea0be44b3fb54146\
        c7b7a5f89fc07b1862821cba6ee42b340eef8b9dcd262022560a549d79d119ea\
        d3528c760d6c1b453a5f85ed61ceb68d4527d902cfe2063c6745534b198a90b5\
        799fab00bdc9227bfded05301fc60cdac33a603d0893ffbf9b982b923dc758b3\
        379371b1f228573ee155b9f6320100
        """

    static let serializedNativeTxOut4 =
        """
        0a2d0a220a206e0a1edff5ed2a3b2d8c4c7a418e524f0cbdedccaf1374fefb3b\
        4d67223ba12b1197d7f2108284494c12220a2088250ef3f7d506fedcec4eec9b\
        dd8f10247667e69217568c4b135180a2f4b3711a220a2086eb856871f9d4277c\
        6284309d9592da1dd14f7b8c35d30d48cd96d9fb91e17022560a54f3b46a1653\
        35a29a3c3806ed92757d0e81ee653f429bd11193e77b1847d7e4a366b9ae8790\
        9a0aaf5de9fbcf0aff18f298ea9b0afc88117de2aadbb681de38a3370c4ed378\
        1621deb0c1394f7355e754302a0100
        """

    static let serializedNativeTxOut5 =
        """
        0a2d0a220a200825231e5c9d1b7fe6e1ec602d15d72b9bb03462fbf3e797cd68\
        3f755092f20f11dc06d083e587019b12220a20fc3fae5ecf0029ed73d2189caa\
        82199dd6a263fd2bca26cd2a0ac2e4746ddc791a220a20ae59f48ace3c4eb73f\
        60f1a962bb83a62ba882b2791aaa7619d57198093cde2c22560a54c865bbb6a8\
        9eb28634b083403cba4d4231e77206bab01b9afe289b7070418a589e577cd869\
        95fef4365f7f648a2b048e6da75bef4e1179ba1274c3390c767c234a03c89b20\
        963bea815523afa7500df580400100
        """

    static let serializedNativeTxOut6 =
        """
        0a2d0a220a2092aa8f077758c0f4346f5b128b71ef7dd21407a9ca5d43136a63\
        bd0398d8000f112172f1fda13f2f5512220a20eab42a0db07d4c9e4baebd86b7\
        1b7faecab76bf16dff6f2029fc5b117ef75e0d1a220a203ae1c03502dfe5f6d5\
        8834d1e93b060b98c3540421be5ac68e552a30826c444b22560a54ce4d758bd1\
        82471eba2a92fca5a15b9bc1d61516c734b557c915370fbdd21d083cac8a7ad6\
        30ab63d597fe5de0464f253e732bf1ddc5a58e26151aa762d4b9031a4138f09d\
        c7efd4e72bc7c5a262ec7e77390100
        """

    static let serializedNativeTxOut7 =
        """
        0a2d0a220a2042af8e64c71ae7fb29bfbdfe107cd88293625c6d0145571a202e\
        d607d2ed9b2611813b54e044cd11fe12220a20dc6e76e87e27125feb4708f60a\
        a79c825398b43dd571ecec61f409771d6162541a220a206231f0d580d4546004\
        b7cf82893575f375707a2a1df5e022402ad699d35a1a3322560a5417c683fb2a\
        f376bc62ea0b397335d1b8201f272a0073f0bada33f8184cd2dfcfbd3a50eddc\
        cc60ffd6e3bae1cada9b23fd05ebb96624dea21d771df830c8161f610035f554\
        d0cd7bc514efcc9f13baa038730100
        """

    static let serializedNativeTxOut8 =
        """
        0a2d0a220a20d2f2a49f98b6f49b0e9074d60412a69fab34a8c4c389786ddf27\
        3bd6301a27401105e55413873af7cf12220a20b6b8b818d17ee0f1e32dbc3299\
        af994754861f0450f8f1997f914723601dab411a220a2038e3ab389e068893d0\
        6305733ce1111f375d2ccd7b17896ce97159b78846340f22560a544ee305d43a\
        7a90abededbd21ceb87f12e2663aa1d42479fd5716f4d4e4b683dc01c25a5d9a\
        7f06ba2cc1faf85b3ecd0972006bd00806f4ab1b5023edc7e1c8c7df3c29cb4e\
        e99d291aea6c311a7247bcf5e00100
        """

    static let serializedNativeTxOut9 =
        """
        0a2d0a220a20d82b06b47f5835482c67bc080175f54b53886be49ec6107311cf\
        f99bff4e8d7011b81cbea5b5fe85c712220a20600928b148ede245d53c5c2026\
        562802e66bc0125a102bb129250e5473c5e42d1a220a209245baa58fbb3baf03\
        609ca24e1c3732093570e8ab397532b71cb91bb822213022560a540fc9655b23\
        f2e8c061e7fbf500ebafb9a908cd37ee4adf9008f782c14e70cd6275eaa88623\
        c10ac8b8a07b14628f385c50eb78b91d75aee9621891b2618c4b86d7353c2d00\
        8f18424cf344f4c00a02dd258d0100
        """

    static let serializedNativeTxOut10 =
        """
        0a2d0a220a20aea8f06399d460ef4cafeb4e4eb0fe93bc12e0320c25533b406d\
        4a79939dab40113c7bb421799cc73112220a20a8d37db35397c3e5b953b3e06f\
        47b47b3ac32b4c684a363bbd8fff71c95295451a220a2036a46fb9fc928cac35\
        a7026b241db7c8e645a89f87020b7ddd495700546d6d5e22560a540000000000\
        0000000000000000000000000000000000000000000000000000000000000000\
        0000000000000000000000000000000000000000000000000000000000000000\
        000000000000000000000000000000
        """

    static let serializedNativeTxOut11 =
        """
        0a2d0a220a205ece4b69357ff4fbe5adfd601b7ea1dbcf530cb2af44dde5a817\
        3d12c0372a1a1150387efdd3039cb612220a2010b6452a0fdf538554603e319a\
        6d1697e097876a3644214580b4b5977d1187251a220a20fca0d582fe031c3e6b\
        0c7b3683de97a16db2ebb5dacd105864a42fab4969d16822560a54ed3c1ae11c\
        ebd9d6b4a8c85d8e979122fec6fdec595f247ffced4e10337d0c777864be7f77\
        80774c7d72f527913bd3288a7eff17f7853e0ea2cdad5f7568acd57a2d86a6f4\
        1c73ed3597d3e01e7cf5bbe8780100
        """

    static func nativeTxOuts() throws -> [TxOut] {
        try [
        serializedNativeTxOut1,
        serializedNativeTxOut2,
        serializedNativeTxOut3,
        serializedNativeTxOut4,
        serializedNativeTxOut5,
        serializedNativeTxOut6,
        serializedNativeTxOut7,
        serializedNativeTxOut8,
        serializedNativeTxOut9,
        serializedNativeTxOut10,
        serializedNativeTxOut11
       ].map {
            try XCTUnwrap(TxOut(serializedData: XCTUnwrap(Data(hexEncoded: $0))))
       }
    }

    
    static let serializedTxOutMembershipProof1 =
        """
        0891c80410dd92071a2e0a080891c8041091c80412220a20342090a03d097d20\
        8f84a4e9aa8c204e4e77657be474079e8b26287bc8d6b4771a2e0a080890c804\
        1090c80412220a20930d6557d1f75e7c538733127d191e546c8f7e8bff73aaab\
        c6c2b1e1dc553fdd1a2e0a080892c8041093c80412220a2012b10cb942eebaa5\
        a54e14561fdd90eed3e395579be591e3ee551f0fb5a4473b1a2e0a080894c804\
        1097c80412220a203d5318f431fe66c1650ae269789071ea1da5a22746a5939b\
        9f787f369be607d71a2e0a080898c804109fc80412220a206f8638e671b3c1e6\
        27fd01f76d2e1ed6da4c282398052ff29b9d1e8f77b2d2e11a2e0a080880c804\
        108fc80412220a2060439407688f940ba3685fb8b6208f3b7b6b4a06ebb1f331\
        c676f90405d4c6991a2e0a0808a0c80410bfc80412220a2023869cafe41f02b2\
        a0516593bf95a03065bf20061d43e86912276e5130bc92851a2e0a0808c0c804\
        10ffc80412220a20d454d0bab31d8ff5787b9c975564d98dee7a939c04910665\
        24fff80b2b7017c31a2e0a080880c90410ffc90412220a20b94f4ad9f3a32b64\
        5e1d5fe73861a5444b7ac429653d6bd05a3d6a5971e409de1a2e0a080880ca04\
        10ffcb0412220a2058727797e7e952185c1adc883d78c741a365d955d6dae0c8\
        3083f89dac89feb41a2e0a080880cc0410ffcf0412220a2051b8533354f723e1\
        bc507f5ffbbf07a5a6b7d16b35931c09c27288faf62dcb6c1a2e0a080880c004\
        10ffc70412220a2057c7bdb5e275eae55c464e2b65add03e4997cdeb85c9b201\
        6ef9e30a00e5e08b1a2e0a080880d00410ffdf0412220a206496553ab8b10d19\
        a1c9ca93934083dc7888db1f9c28460d293fe7ad141ca6b31a2e0a080880e004\
        10ffff0412220a202be341f625bdb58ccca2ba3fdb98f718f99bff55ca14e67f\
        10d8f849468984fe1a2e0a080880800410ffbf0412220a20e78b4b25e9c22ec0\
        bb478442ad4f73c939d9cf66c973bb52a8c90f0db75594e81a2e0a0808808005\
        10ffff0512220a20fb10a890567ac36a45711d93a228c71b87226eab98637d4b\
        f1f73bf1e5d59cf31a2e0a080880800610ffff0712220a2038ca2874b3d707f9\
        97b0dacb7197b4599f6e9d814f321c63ec517546acd8c6491a2a0a0410ffff03\
        12220a20f29e5b08a3161a7700a5492b35abb947598921aaf36c56e23b0babff\
        445db6dd
        """

    static let serializedTxOutMembershipProof2 =
        """
        08a2a00310dd92071a2e0a0808a2a00310a2a00312220a20a6e29bcfeab30fea\
        367180c353a47b05777aeb86ce8ae760527d27c1033ef9b41a2e0a0808a3a003\
        10a3a00312220a203a44329310d0f603f50f3a672fb05e606554e66ad8609200\
        b8ae92f7ebf57d551a2e0a0808a0a00310a1a00312220a20276c7018d0765231\
        7be860d67459a7275c0b78aac99b7d4883d7625d77ec2fa31a2e0a0808a4a003\
        10a7a00312220a20cac482137a023f5d95f078cc65d5fd31cf5f6e57fee1f2de\
        def92de76bce3ba51a2e0a0808a8a00310afa00312220a20422317ed8cdd887b\
        414718fe1740b6b8fbe942db38f2bf3cb84c48284d7240431a2e0a0808b0a003\
        10bfa00312220a2064ed8cac0d47d137c4bbff12e4703d958f5d13858d328108\
        d68e229a94d2a32b1a2e0a080880a003109fa00312220a2041d15e99e90ed28f\
        2ed1cb8aa931e2c7d2b9329a5a8d006708a2410f446d56961a2e0a0808c0a003\
        10ffa00312220a202bed37a071fccb2677726e441a14bd5d962d2dd49688febd\
        a73bdd95f24e05ea1a2e0a080880a10310ffa10312220a20e9476f997a439411\
        3ba0dd7e1d8704033b11ded04fbb42f3cb870fd345b6e86d1a2e0a080880a203\
        10ffa30312220a20bfd492553556c747c92129ea8672dad083025529f4f6b34d\
        bf373844dbcad88a1a2e0a080880a40310ffa70312220a207bc012647e80bb0a\
        1f59ef66bbbca0504e826907d28753be8f2d6c56aa1241441a2e0a080880a803\
        10ffaf0312220a20697042df2f1d90161ea7c6a179d89bd72182d43c65eae21e\
        939e863de03d2c871a2e0a080880b00310ffbf0312220a20b56c95fea6370cc8\
        b78c0783c18753a4264832fc01c01d1fbdf1dca3163986da1a2e0a0808808003\
        10ff9f0312220a205bb4563096546f8aa963fbeeaf79f85ddb0850a3b97c5484\
        39306213d0228af71a2e0a080880c00310ffff0312220a2094c72d9b36eb5afa\
        b77ad8075d499fb0bf9a1508df6f5f02d6b8f9c946b913fd1a2e0a0808808002\
        10ffff0212220a202b88523370fb8d1ddbe7a18562e0914bea026092074dc1fa\
        ca3ce8e28e0a5b6a1a2a0a0410ffff0112220a204ff926b8f4ccfffd18640758\
        7131f5354750594efcbf1bfc69e9dfc390f94e0d1a2e0a080880800410ffff07\
        12220a202dda655a09b0a61d89e4c320674b6bea439d1cc7324cb5fca91a9479\
        bf2e6756
        """

    static let serializedTxOutMembershipProof3 =
        """
        08946010dd92071a2c0a0608946010946012220a2037f24f838512471b1b6cf4\
        2c7f01bddb0bfce1677751eebcebba4072c15ea5881a2c0a0608956010956012\
        220a20479492ad406f27908dad955cc8ea03a1aa7bcda64561e5c141957ee9e4\
        b590ed1a2c0a0608966010976012220a202c47ccf0611b531a40b63058f3ab73\
        5ca320034400a6e9de9d1bfce270673c541a2c0a0608906010936012220a208d\
        371569cd3a829ab91e71be791f8036e3600426ded5b2ab60c4e0f1f5054cbc1a\
        2c0a06089860109f6012220a206cfd10a256178d5a6babe6abe1f028d8bb27a1\
        53a7eb9d743352446d4edc53181a2c0a06088060108f6012220a20bf92cd994c\
        f204f5ed76007097df5d2636f75109ae1847d3d462cfd1b20b07c41a2c0a0608\
        a06010bf6012220a203365192a568e60cf9b406c32a5d356e3b19d8e84b90c30\
        1754c59903b890101a1a2c0a0608c06010ff6012220a20eb9ed9eb64f29803b3\
        95cb563a4f58e37032388d6a85e9a9055f8d297d11db941a2c0a0608806110ff\
        6112220a20d5c1b01b1c48abf882718f8868f2cdd011318062d0138b2e61db45\
        8fb2817df21a2c0a0608806210ff6312220a204b609628e558f735e2e61208d5\
        bbe9ea873dcafc6bea9bffcf495c93367b777d1a2c0a0608806410ff6712220a\
        2019456c27c3c60e84201ff8a905bc750154dec2bff6b28dd03a83a80687a34a\
        941a2c0a0608806810ff6f12220a200754396a7c7481a89a095832ae14a3237f\
        245b9ed37c5aee2f413e0db2683dde1a2c0a0608807010ff7f12220a202041ef\
        2f700d23fa7bcdcf35895e009b56506161e33ff26f8c603dbecbf43ae21a2c0a\
        0608804010ff5f12220a20fc2a224473323446c43e83bd31e4973f44e8b71c30\
        125756ea19f240a01f66cc1a290a0310ff3f12220a2015c884410720e0b619cd\
        604e9204393f508280597140fce5840320a91205b1d71a2e0a080880800110ff\
        ff0112220a20f5c9a4424c4859b7a3695da5e7f8318b0826810d16b15e596bb6\
        1eae7fa4dc271a2e0a080880800210ffff0312220a20fb60de8b02816991ec85\
        920326ce47b3bb2ce6d4204c680cab1fcc5e36d74d411a2e0a080880800410ff\
        ff0712220a202dda655a09b0a61d89e4c320674b6bea439d1cc7324cb5fca91a\
        9479bf2e6756
        """

    static let serializedTxOutMembershipProof4 =
        """
        08b3910710dd92071a2e0a0808b3910710b3910712220a20ca1f295d4e1a807f\
        cea55edbc69c7a71cfeda23300e4b1c59e767b534e5dbd5a1a2e0a0808b29107\
        10b2910712220a20a15714b8bfa0f24d623ac29047b849a2019fa32a21fb667a\
        d55df3036ba2ead21a2e0a0808b0910710b1910712220a20c6d1167781a3cf71\
        8db198ce22f57f5860c6fe0e00f0a3e4152ed358c719f5ce1a2e0a0808b49107\
        10b7910712220a20dd7fb83f8f570f14a5ba5ffb12cc46553b16eef5263909d9\
        9942b780bbb86e1e1a2e0a0808b8910710bf910712220a205d31e770650feee6\
        b9ebb8f0a42dccbc0e6068df5df2d73feb3a01ea213777651a2e0a0808a09107\
        10af910712220a200f3a56e63882d1765bae59aec3e87913f4aaba423c3d874c\
        6b9554e657fc55761a2e0a0808809107109f910712220a2010929b194f880c2a\
        397f99b9e6bdc625b1d48de2b32abf608f09840e25627eaf1a2e0a0808c09107\
        10ff910712220a20d1d23db257da96d5c2d2d311d1ab072882a5bbd41fb6b479\
        2d7c7b5d4f95ae421a2e0a080880900710ff900712220a20dcf1ae2599b68a9b\
        74c881b5d33679f61aebd2dacf463224c202c20cd07ffef71a2e0a0808809207\
        10ff930712220a20e8a3a1a345239a8b8e685fa2d8054c975de0487a008bfd63\
        5f3ecb544818f4d31a2e0a080880940710ff970712220a20ffdaaf4305e365c4\
        c30ca1e5fbf4f5e62b081441ee94eb2d0980470b5e7059681a2e0a0808809807\
        10ff9f0712220a20ffdaaf4305e365c4c30ca1e5fbf4f5e62b081441ee94eb2d\
        0980470b5e7059681a2e0a080880800710ff8f0712220a20cef4b3f674d95ad1\
        c2cad0124c9ba2a45f91ca14174b6e6f29f4b743761a07d11a2e0a080880a007\
        10ffbf0712220a20ffdaaf4305e365c4c30ca1e5fbf4f5e62b081441ee94eb2d\
        0980470b5e7059681a2e0a080880c00710ffff0712220a20ffdaaf4305e365c4\
        c30ca1e5fbf4f5e62b081441ee94eb2d0980470b5e7059681a2e0a0808808006\
        10ffff0612220a202337187195b751a8fc398fddaf0256ba08bd18248cfd098a\
        092b641be4712f361a2e0a080880800410ffff0512220a20797b94d21cbdc8de\
        0c9d1cb1a973f1342bd95dc9e5a19b105e705b863d60437a1a2a0a0410ffff03\
        12220a20f29e5b08a3161a7700a5492b35abb947598921aaf36c56e23b0babff\
        445db6dd
        """

    static let serializedTxOutMembershipProof5 =
        """
        08b65f10dd92071a2c0a0608b65f10b65f12220a2048338e100d2ca1ad585ab6\
        4243e84bbb39db29e4da6bf3c2a669127c689f93e51a2c0a0608b75f10b75f12\
        220a2037b38fd43d59003db7bfc1b3284e53766f194634917e633c2a72de4113\
        a42fd31a2c0a0608b45f10b55f12220a20b8eca2e5a8b737e9379189bd7650be\
        def7dab7757ee2bbb7a5b549e378fd51e41a2c0a0608b05f10b35f12220a20f2\
        8e7da8b19c8899a75bc8c25641ae9793dfb09552537d0a13920924524534081a\
        2c0a0608b85f10bf5f12220a205ea798febd32eb6fb2553e5d3e141fee557a2a\
        72d19e8cc956019a28cabf73211a2c0a0608a05f10af5f12220a2061eaa69cdf\
        d775f326ff44d4503f3d836181aefa30215c93418c2482261743511a2c0a0608\
        805f109f5f12220a204e19b143264a8e4155a3f7b95d2367dee50ad1427f3bd1\
        b928206ee2a4bdb2bb1a2c0a0608c05f10ff5f12220a2005c2fd8d82918205bb\
        dcda92e5d7eea9bcae3c4cbb2785361271591ed201928f1a2c0a0608805e10ff\
        5e12220a203e1ea486ea183bf2fe00ad65e38be86e48ef4fc9ba56233a906981\
        b5d897f19c1a2c0a0608805c10ff5d12220a20973212a05a13fdb0e23fdccc10\
        140a155f0ec386655957890af8d006df15acd31a2c0a0608805810ff5b12220a\
        20941f43b5a65b38d35a5bc679abffd91cf263ac760373e18e645f287971763d\
        5b1a2c0a0608805010ff5712220a20a3475c528ebed6927f7569aa3a625dad7b\
        9019c853eeb1a6cab854e3a27aab231a2c0a0608804010ff4f12220a204db931\
        0368010d0efb40df8c9d0301cc0b3557aaabc4b24956e2d1c9e48d75911a2c0a\
        0608806010ff7f12220a201c00a16693245619a4293a9902497c45e79055240c\
        bb184fbb9fc1b32dd94f2b1a290a0310ff3f12220a2015c884410720e0b619cd\
        604e9204393f508280597140fce5840320a91205b1d71a2e0a080880800110ff\
        ff0112220a20f5c9a4424c4859b7a3695da5e7f8318b0826810d16b15e596bb6\
        1eae7fa4dc271a2e0a080880800210ffff0312220a20fb60de8b02816991ec85\
        920326ce47b3bb2ce6d4204c680cab1fcc5e36d74d411a2e0a080880800410ff\
        ff0712220a202dda655a09b0a61d89e4c320674b6bea439d1cc7324cb5fca91a\
        9479bf2e6756
        """

    static let serializedTxOutMembershipProof6 =
        """
        08dcef0510dd92071a2e0a0808dcef0510dcef0512220a20f09cb23832b6b9b4\
        7cbbea761085f9d03ef2c87865b2294b2a484239976565c81a2e0a0808ddef05\
        10ddef0512220a203fa149505fe7d57773a0dffad82194e50038977e69acab0d\
        e14237f3813144181a2e0a0808deef0510dfef0512220a200a3dfa3c38eb4cd2\
        73ffa95a3e73a192fd2ffd6a640b7c3a570bc12bb57a2d491a2e0a0808d8ef05\
        10dbef0512220a20bd0c845ad62cc61d42bc19396b08723abfb2f55ca916b398\
        7d006b0b33e6b38e1a2e0a0808d0ef0510d7ef0512220a20f7bf0fbefaef83ed\
        bbc0f1fbf3e1dc2c9f841ede1c9e89ce75a59afbffe9238d1a2e0a0808c0ef05\
        10cfef0512220a20fc93da0625c1c0f8cd1f90dd4017ed8d3b5cbdb3f12aa16c\
        a1b6ed8a64ab6a271a2e0a0808e0ef0510ffef0512220a20eb7ff8b69a6a0cbe\
        59d793abbd880f46411ebffb0190081dbd42f2300798b7e31a2e0a080880ef05\
        10bfef0512220a2083acb252bc044304cf79370e03ced49dcc70c1fb1d2b80ec\
        bbaab41eedcdf4d41a2e0a080880ee0510ffee0512220a209693aae6cba5a92b\
        0144a2b3cc5b24bdaa5d8e2da64a9bfae2e56dc61db40a4d1a2e0a080880ec05\
        10ffed0512220a20d805d93341f16ebd4bbe93bfa75956fa72dd05ebe7917bfa\
        e17157e1c3853c301a2e0a080880e80510ffeb0512220a2048a51458936d6549\
        f7ec8dc4dd3584904e667b546bea8143163a95d78c79dcc11a2e0a080880e005\
        10ffe70512220a2025313bb5cdc53dd875c76acdd1ee94b6f2dff264b1b7fcbf\
        0e08197c5fa5511c1a2e0a080880f00510ffff0512220a204499b229ac7485ae\
        47fa9837dd46a98ebb6ca9a9935235fcc79c3ba259e695f01a2e0a080880c005\
        10ffdf0512220a20ce2de778c0cb51f01d5721250d57f69a2b6e4cc17566b078\
        b84741a5c0a053f51a2e0a080880800510ffbf0512220a20bdc27982150e27a5\
        e78d995784a239f187a65f3fc1f673d793ce2f3fa828d5ac1a2e0a0808808004\
        10ffff0412220a202385ccb3b4d6356701b1b6d8931d97ff23131fc11195b310\
        6e6a7f59065d28061a2e0a080880800610ffff0712220a2038ca2874b3d707f9\
        97b0dacb7197b4599f6e9d814f321c63ec517546acd8c6491a2a0a0410ffff03\
        12220a20f29e5b08a3161a7700a5492b35abb947598921aaf36c56e23b0babff\
        445db6dd
        """

    static let serializedTxOutMembershipProof7 =
        """
        08fc940210dd92071a2e0a0808fc940210fc940212220a20cdb83799349c7b08\
        6ddd82f3389cf7288f3dc2e8fab4c48445c41651906661bd1a2e0a0808fd9402\
        10fd940212220a206aca12fbe8ee0be3c21df6e8d197a7a3f922a7f90bf2d445\
        6e58030d85feda941a2e0a0808fe940210ff940212220a2090b7c87af0b0d370\
        1bf262190ca9343712b8cc92506e54b13001b9e46e45b9f31a2e0a0808f89402\
        10fb940212220a201fb0e98997046ce95ff8d659cc551269f0805e56f3f02638\
        c377479df02091841a2e0a0808f0940210f7940212220a202554e95b10dc5a30\
        d2f037c378a669f00d68c7284bc9dbff4c9b375a539ca4d41a2e0a0808e09402\
        10ef940212220a207da596187054e08c2ce018cf7b708f9d3c0bcae466584703\
        8eeab119a8325bb51a2e0a0808c0940210df940212220a200e3875bd45b50a52\
        ccf68a72f7d833128c09853d3ee14b3ddad93b9eca2e2a631a2e0a0808809402\
        10bf940212220a20019fe19bcfebb380de5247b2e9d1ad28f485433f53356fb8\
        baff36f907232c9e1a2e0a080880950210ff950212220a2048649b8b25e4a8de\
        b004e7c3edb26e0237597b398ed7c791c3e76affb991e89c1a2e0a0808809602\
        10ff970212220a20b5e901a7d12988c8ce7b557124d223cd8109bfa2f70533d9\
        52019c65eba4f62b1a2e0a080880900210ff930212220a2010489abbf419eea6\
        a5ca15c25bf9c30cfaa2317ca7e584a987baa7444df48caa1a2e0a0808809802\
        10ff9f0212220a2097cf3f7c3f1d61c210d278824c585dbcf992b73c8b0b5e27\
        1f39b58c75c9bd571a2e0a080880800210ff8f0212220a20d28063b31543f375\
        c23bc17be23ed19291e180d196a6c86a7389aa6f94faa7dc1a2e0a080880a002\
        10ffbf0212220a2044a2c2b59232cac82ee6de810b6a6775d8743a5e76309755\
        20b45abd6b127cdd1a2e0a080880c00210ffff0212220a208aa118e729a4c8b6\
        3db46cdbee74b6cbc019cadec3101bb726f95fc5fa2db4c81a2e0a0808808003\
        10ffff0312220a2073fdace37f7d64fca60ac0827df3c72f0c44f9d4afbd1d6d\
        f52e4300546362c51a2a0a0410ffff0112220a204ff926b8f4ccfffd18640758\
        7131f5354750594efcbf1bfc69e9dfc390f94e0d1a2e0a080880800410ffff07\
        12220a202dda655a09b0a61d89e4c320674b6bea439d1cc7324cb5fca91a9479\
        bf2e6756
        """

    static let serializedTxOutMembershipProof8 =
        """
        08ed960210dd92071a2e0a0808ed960210ed960212220a203513b1f1b52d78be\
        9961ec379e6a373aa282190b93c5f5ea0959fb54424cb76f1a2e0a0808ec9602\
        10ec960212220a200f6ecd03398e3964dcceb4211da2eaae1f154211a26f7eb6\
        5dcea0a09fa9b84d1a2e0a0808ee960210ef960212220a201e68e84127856a51\
        d09984487ce9a3906b53c2177c67f8357f65e2923855f1d01a2e0a0808e89602\
        10eb960212220a20fdae18d48da01489e5923eff1352c3cbbe94aa0bd60294f8\
        6514e3b19bf584da1a2e0a0808e0960210e7960212220a204a39243c85737764\
        078f930706b0406b0a935f6a88bf6241dbb5a822fe83edb71a2e0a0808f09602\
        10ff960212220a202092859f230537fe11479a5d54ff9b84d683fc1fb109e9dc\
        1e3bc2b843e8c8fd1a2e0a0808c0960210df960212220a20a508e859ebb94a70\
        6bf6f5b5ae929a9bd6c143df0500364f6d2022c65376e4401a2e0a0808809602\
        10bf960212220a2014e96138f4edb0a7e93c3187d355050476a98afdd6d94149\
        faacbeb7ed869da41a2e0a080880970210ff970212220a20518c1df46f5c6465\
        79e4e9157db9be5f78dbe15c5c3f70cd45224ad9b0272dae1a2e0a0808809402\
        10ff950212220a20864738a96acf652306763efa28f2aff94b8c13e55bddb84b\
        fc4e4672b0f0b2251a2e0a080880900210ff930212220a2010489abbf419eea6\
        a5ca15c25bf9c30cfaa2317ca7e584a987baa7444df48caa1a2e0a0808809802\
        10ff9f0212220a2097cf3f7c3f1d61c210d278824c585dbcf992b73c8b0b5e27\
        1f39b58c75c9bd571a2e0a080880800210ff8f0212220a20d28063b31543f375\
        c23bc17be23ed19291e180d196a6c86a7389aa6f94faa7dc1a2e0a080880a002\
        10ffbf0212220a2044a2c2b59232cac82ee6de810b6a6775d8743a5e76309755\
        20b45abd6b127cdd1a2e0a080880c00210ffff0212220a208aa118e729a4c8b6\
        3db46cdbee74b6cbc019cadec3101bb726f95fc5fa2db4c81a2e0a0808808003\
        10ffff0312220a2073fdace37f7d64fca60ac0827df3c72f0c44f9d4afbd1d6d\
        f52e4300546362c51a2a0a0410ffff0112220a204ff926b8f4ccfffd18640758\
        7131f5354750594efcbf1bfc69e9dfc390f94e0d1a2e0a080880800410ffff07\
        12220a202dda655a09b0a61d89e4c320674b6bea439d1cc7324cb5fca91a9479\
        bf2e6756
        """

    static let serializedTxOutMembershipProof9 =
        """
        08ceaa0210dd92071a2e0a0808ceaa0210ceaa0212220a209152ef0ab2e2fd35\
        d070e5c1ac3943029ebd32e8fb4d6e112e083b7018382ad81a2e0a0808cfaa02\
        10cfaa0212220a20fa1f8d499ccb75559873ad67d1c00659ffff74b2b2158c82\
        8a3be0084210a05e1a2e0a0808ccaa0210cdaa0212220a20789ce65fe150a864\
        83103c9b425ec0a794a1d944b3404380069142cfe3a007ce1a2e0a0808c8aa02\
        10cbaa0212220a2080f70456ed4de5ef26b0ec6c2504b18898b6bea8a70a2085\
        77960c6e8def08201a2e0a0808c0aa0210c7aa0212220a203fea823651c7f4a3\
        e59467abcdf618460fb0773e74e33eb280816129402cbd441a2e0a0808d0aa02\
        10dfaa0212220a20274ec988ab9055b78974540224ea9e181370c0775d3a4a8b\
        daa48ec10ab4d0591a2e0a0808e0aa0210ffaa0212220a2065984c011833f2bd\
        254dd12435abcd9a5216fb7a659fcd5a1a39353e7d7a8b391a2e0a080880aa02\
        10bfaa0212220a20b194ad8f41b18102e83f8f3062041bfe9a5188968ceeacff\
        8a1d5f3e4cdf643f1a2e0a080880ab0210ffab0212220a209e9791b1d217ce94\
        2e46c946de0406fa21ac7ed827fbe3e7a6d62b2c33c9850f1a2e0a080880a802\
        10ffa90212220a20e845352f785995bc99f59ad4c85ec032ce50c8fe640623e3\
        591d7d64598f89a01a2e0a080880ac0210ffaf0212220a20f6d4a5ea4324c11f\
        3be45e156405d43c065c8998779a9ca93975252c9b2c976d1a2e0a080880a002\
        10ffa70212220a2035b79cf78db284dc563b8f69508279f41187b2208d2225b1\
        2c61970ee83432d11a2e0a080880b00210ffbf0212220a2092a9cad4226655f4\
        6141112558dc870fcebbc06428ed15c051738592411480bc1a2e0a0808808002\
        10ff9f0212220a2029bf76ab8d3e04f4ffe5b8ba7bf6fd84d4ed06e0ee4a0934\
        fac8f959f731dc321a2e0a080880c00210ffff0212220a208aa118e729a4c8b6\
        3db46cdbee74b6cbc019cadec3101bb726f95fc5fa2db4c81a2e0a0808808003\
        10ffff0312220a2073fdace37f7d64fca60ac0827df3c72f0c44f9d4afbd1d6d\
        f52e4300546362c51a2a0a0410ffff0112220a204ff926b8f4ccfffd18640758\
        7131f5354750594efcbf1bfc69e9dfc390f94e0d1a2e0a080880800410ffff07\
        12220a202dda655a09b0a61d89e4c320674b6bea439d1cc7324cb5fca91a9479\
        bf2e6756
        """

    static let serializedTxOutMembershipProof10 =
        """
        089f910710dd92071a2e0a08089f9107109f910712220a2062134c4652687380\
        e98dfeb948f5357100c1c21e4e7537991f3ca89d4695b8421a2e0a08089e9107\
        109e910712220a20f56526a0899bdeb7f94eb4ad3c7cd69d5d0469d5202f199f\
        3d3f87b0864724381a2e0a08089c9107109d910712220a20073fcc11b99c7a24\
        e1181799a9c78d589c2af44b102efc2f0019110e9d3da43d1a2e0a0808989107\
        109b910712220a2054559b14706be7097d245230ed941e568e50af22bda17e8a\
        adaada6bd6bebaf91a2e0a08089091071097910712220a20bb683dcc339278bf\
        2ae395cc09e8200249f07388a74dee4c6a0011e4ccb1c1d31a2e0a0808809107\
        108f910712220a20fd91765d51a36334cef29259a567dc047998d5ee4cb42045\
        ba291bf1833bdb6c1a2e0a0808a0910710bf910712220a200699a58446df1f4b\
        f82c42c9f4d20659ee9b41bbc39a98bd6a6a54799488a3bd1a2e0a0808c09107\
        10ff910712220a20d1d23db257da96d5c2d2d311d1ab072882a5bbd41fb6b479\
        2d7c7b5d4f95ae421a2e0a080880900710ff900712220a20dcf1ae2599b68a9b\
        74c881b5d33679f61aebd2dacf463224c202c20cd07ffef71a2e0a0808809207\
        10ff930712220a20e8a3a1a345239a8b8e685fa2d8054c975de0487a008bfd63\
        5f3ecb544818f4d31a2e0a080880940710ff970712220a20ffdaaf4305e365c4\
        c30ca1e5fbf4f5e62b081441ee94eb2d0980470b5e7059681a2e0a0808809807\
        10ff9f0712220a20ffdaaf4305e365c4c30ca1e5fbf4f5e62b081441ee94eb2d\
        0980470b5e7059681a2e0a080880800710ff8f0712220a20cef4b3f674d95ad1\
        c2cad0124c9ba2a45f91ca14174b6e6f29f4b743761a07d11a2e0a080880a007\
        10ffbf0712220a20ffdaaf4305e365c4c30ca1e5fbf4f5e62b081441ee94eb2d\
        0980470b5e7059681a2e0a080880c00710ffff0712220a20ffdaaf4305e365c4\
        c30ca1e5fbf4f5e62b081441ee94eb2d0980470b5e7059681a2e0a0808808006\
        10ffff0612220a202337187195b751a8fc398fddaf0256ba08bd18248cfd098a\
        092b641be4712f361a2e0a080880800410ffff0512220a20797b94d21cbdc8de\
        0c9d1cb1a973f1342bd95dc9e5a19b105e705b863d60437a1a2a0a0410ffff03\
        12220a20f29e5b08a3161a7700a5492b35abb947598921aaf36c56e23b0babff\
        445db6dd
        """

    static let serializedTxOutMembershipProof11 =
        """
        08f0cd0310dd92071a2e0a0808f0cd0310f0cd0312220a208ae4a64361aea79f\
        5ef64fa43575f489b16bb198e63cdf7dd4be10837f3933631a2e0a0808f1cd03\
        10f1cd0312220a20c5efab16e94531a6a37fc3dc9cc808537218087731929597\
        e93e1c6a753b21dd1a2e0a0808f2cd0310f3cd0312220a200bf02c38be3008f8\
        c8cc01c31e1feba2890a32e33e6f832800cc199a5885f0201a2e0a0808f4cd03\
        10f7cd0312220a200a998532ebaf370aa83737983ea42d5817bbacb3dbf971ea\
        a3c92bd4d93e14971a2e0a0808f8cd0310ffcd0312220a2076505a06be094f54\
        4c6a68752e00b7db79bc04ec6c803be8eb49a6a3657ab9671a2e0a0808e0cd03\
        10efcd0312220a207654bff3dc2a119df898ae90749946d72eb9c2fc9a3824a0\
        3509a10de69dbba41a2e0a0808c0cd0310dfcd0312220a2060f94e66ff2fb4e1\
        8d7b9be16a1f6f2d191c8715d4130c43f3001eb05ef966661a2e0a080880cd03\
        10bfcd0312220a20fbe301dd787a9196a5f7d50c480dc2bf3775426ae81ea7bc\
        0e86c24c91602b111a2e0a080880cc0310ffcc0312220a20d42fbc7d0f71d61c\
        ad2dd088199c2b9b4cc20851cb8bab77870d56235c37e12f1a2e0a080880ce03\
        10ffcf0312220a207d47a1ac6ce04927e96de85392c1876c23ccd6141826d63f\
        d8fec596a2ce6dd41a2e0a080880c80310ffcb0312220a2036464b49a3aa6c63\
        b924dc2cb5337398e27ca21c46ed16935d38dceaddef96871a2e0a080880c003\
        10ffc70312220a20edd7e2d3eb8db1690ec7e8d76c55db0a35a72cf6b48c6186\
        4e01ec2d4619b8641a2e0a080880d00310ffdf0312220a20658db5d6688b0254\
        14ff246af052df1aefe0477c0ca0089fd0f508db7e49b9c71a2e0a080880e003\
        10ffff0312220a20f8d60438a513951868fbfd6142b03b852ba91ffd2b9ecb60\
        41966cfb724bd2bf1a2e0a080880800310ffbf0312220a208f0bc275db1424f3\
        353b03e7a465cb62a8784b083fc75c792b9093cbad9234801a2e0a0808808002\
        10ffff0212220a202b88523370fb8d1ddbe7a18562e0914bea026092074dc1fa\
        ca3ce8e28e0a5b6a1a2a0a0410ffff0112220a204ff926b8f4ccfffd18640758\
        7131f5354750594efcbf1bfc69e9dfc390f94e0d1a2e0a080880800410ffff07\
        12220a202dda655a09b0a61d89e4c320674b6bea439d1cc7324cb5fca91a9479\
        bf2e6756
        """

    static func txOutMembershipProofs() throws -> [TxOutMembershipProof] {
        try [
        serializedTxOutMembershipProof1,
        serializedTxOutMembershipProof2,
        serializedTxOutMembershipProof3,
        serializedTxOutMembershipProof4,
        serializedTxOutMembershipProof5,
        serializedTxOutMembershipProof6,
        serializedTxOutMembershipProof7,
        serializedTxOutMembershipProof8,
        serializedTxOutMembershipProof9,
        serializedTxOutMembershipProof10,
        serializedTxOutMembershipProof11
       ].map {
            try XCTUnwrapSuccess(
                TxOutMembershipProof.make(serializedData: XCTUnwrap(Data(hexEncoded: $0))))
        }
    }


    fileprivate static func recipientAccountKey() throws -> AccountKey {
        try XCTUnwrap(AccountKey(serializedData: Data(hexEncoded: recipientAccountKeyHex)!))
    }

    fileprivate static func senderAccountKey() throws -> AccountKey {
        try XCTUnwrap(AccountKey(serializedData: Data(hexEncoded: senderAccountKeyHex)!))
    }

    static let senderAccountKeyHex =
            """
            0a220a20ec8cb9814ac5c1a4aacbc613e756744679050927cc9e5f8772c6d649\
            d4a5ac0612220a20e7ef0b2772663314ecd7ee92008613764ab5669666d95bd2\
            621d99d60506cb0d1a1e666f673a2f2f666f672e616c7068612e6d6f62696c65\
            636f696e2e636f6d2aa60430820222300d06092a864886f70d01010105000382\
            020f003082020a0282020100c853a8724bc211cf5370ed4dbec8947c5573bed0\
            ec47ae14211454977b41336061f0a040f77dbf529f3a46d8095676ec971b940a\
            b4c9642578760779840a3f9b3b893b2f65006c544e9c16586d33649769b7c1c9\
            4552d7efa081a56ad612dec932812676ebec091f2aed69123604f4888a125e04\
            ff85f5a727c286664378581cf34c7ee13eb01cc4faf3308ed3c07a9415f98e5f\
            bfe073e6c357967244e46ba6ebbe391d8154e6e4a1c80524b1a6733eca46e37b\
            fdd62d75816988a79aac6bdb62a06b1237a8ff5e5c848d01bbff684248cf06d9\
            2f301623c893eb0fba0f3faee2d197ea57ac428f89d6c000f76d58d5aacc3d70\
            204781aca45bc02b1456b454231d2f2ed4ca6614e5242c7d7af0fe61e9af6ecf\
            a76674ffbc29b858091cbfb4011538f0e894ce45d21d7fac04ba2ff57e9ff6db\
            21e2afd9468ad785c262ec59d4a1a801c5ec2f95fc107dc9cb5f7869d70aa844\
            50b8c350c2fa48bddef20752a1e43676b246c7f59f8f1f4aee43c1a15f36f7a3\
            6a9ec708320ea42089991551f2656ec62ea38233946b85616ff182cf17cd227e\
            596329b546ea04d13b053be4cf3338de777b50bc6eca7a6185cf7a5022bc9be3\
            749b1bb43e10ecc88a0c580f2b7373138ee49c7bafd8be6a64048887230480b0\
            c85a045255494e04a9a81646369ce7a10e08da6fae27333ec0c16c8a74d93779\
            a9e055395078d0b07286f9930203010001
            """
    
    static let recipientAccountKeyHex =
            """
            0a220a20553a1c51c1e91d3105b17c909c163f8bc6faf93718deb06e5b9fdb9a\
            24c2560912220a20db8b25545216d606fc3ff6da43d3281e862ba254193aff8c\
            408f3564aefca5061a1e666f673a2f2f666f672e616c7068612e6d6f62696c65\
            636f696e2e636f6d2aa60430820222300d06092a864886f70d01010105000382\
            020f003082020a0282020100c853a8724bc211cf5370ed4dbec8947c5573bed0\
            ec47ae14211454977b41336061f0a040f77dbf529f3a46d8095676ec971b940a\
            b4c9642578760779840a3f9b3b893b2f65006c544e9c16586d33649769b7c1c9\
            4552d7efa081a56ad612dec932812676ebec091f2aed69123604f4888a125e04\
            ff85f5a727c286664378581cf34c7ee13eb01cc4faf3308ed3c07a9415f98e5f\
            bfe073e6c357967244e46ba6ebbe391d8154e6e4a1c80524b1a6733eca46e37b\
            fdd62d75816988a79aac6bdb62a06b1237a8ff5e5c848d01bbff684248cf06d9\
            2f301623c893eb0fba0f3faee2d197ea57ac428f89d6c000f76d58d5aacc3d70\
            204781aca45bc02b1456b454231d2f2ed4ca6614e5242c7d7af0fe61e9af6ecf\
            a76674ffbc29b858091cbfb4011538f0e894ce45d21d7fac04ba2ff57e9ff6db\
            21e2afd9468ad785c262ec59d4a1a801c5ec2f95fc107dc9cb5f7869d70aa844\
            50b8c350c2fa48bddef20752a1e43676b246c7f59f8f1f4aee43c1a15f36f7a3\
            6a9ec708320ea42089991551f2656ec62ea38233946b85616ff182cf17cd227e\
            596329b546ea04d13b053be4cf3338de777b50bc6eca7a6185cf7a5022bc9be3\
            749b1bb43e10ecc88a0c580f2b7373138ee49c7bafd8be6a64048887230480b0\
            c85a045255494e04a9a81646369ce7a10e08da6fae27333ec0c16c8a74d93779\
            a9e055395078d0b07286f9930203010001
            """

}
