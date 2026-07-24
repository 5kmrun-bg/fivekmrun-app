import Foundation
import PassKit
import Security

class WalletPassGenerator {

    private static let passTypeIdentifier = "pass.bg.fivekmpark.5kmrun"
    private static let teamIdentifier = "48HKWHQ6FS"

    static func generatePass(userId: Int, userName: String, userStatus: String) throws -> URL {
        let barcodeValue = String(format: "%010d", userId)

        let passJSON: [String: Any] = [
            "formatVersion": 1,
            "passTypeIdentifier": passTypeIdentifier,
            "serialNumber": "5kmrun-\(userId)",
            "teamIdentifier": teamIdentifier,
            "organizationName": "5kmRun",
            "description": "5kmRun Member Card",
            "foregroundColor": "rgb(255, 255, 255)",
            "backgroundColor": "rgb(224, 31, 35)",
            "labelColor": "rgb(255, 255, 255)",
            "generic": [
                "primaryFields": [
                    ["key": "name", "label": "Бегач", "value": userName]
                ],
                "secondaryFields": [
                    ["key": "status", "label": "Статус", "value": userStatus]
                ],
                "auxiliaryFields": [
                    ["key": "id", "label": "ID", "value": String(userId)]
                ]
            ],
            "barcode": [
                "message": barcodeValue,
                "format": "PKBarcodeFormatCode128",
                "messageEncoding": "iso-8859-1"
            ]
        ]

        let passData = try JSONSerialization.data(withJSONObject: passJSON, options: .prettyPrinted)

        let iconData = loadBundleImage(named: "wallet_icon") ?? whitePNG1x1()
        let icon2xData = loadBundleImage(named: "wallet_icon@2x") ?? whitePNG1x1()
        let logoData = loadBundleImage(named: "wallet_logo") ?? whitePNG1x1()
        let logo2xData = loadBundleImage(named: "wallet_logo@2x") ?? whitePNG1x1()

        let files: [String: Data] = [
            "pass.json": passData,
            "icon.png": iconData,
            "icon@2x.png": icon2xData,
            "logo.png": logoData,
            "logo@2x.png": logo2xData
        ]

        let manifest = try buildManifest(files: files)
        let manifestData = try JSONSerialization.data(withJSONObject: manifest, options: .prettyPrinted)
        let signature = try signManifest(manifestData: manifestData)

        return try buildPassArchive(files: files, manifestData: manifestData, signature: signature)
    }

    // MARK: - Helpers

    private static func loadBundleImage(named name: String) -> Data? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "png") else { return nil }
        return try? Data(contentsOf: url)
    }

    private static func whitePNG1x1() -> Data {
        Data([0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,0x00,0x00,0x00,0x0D,0x49,0x48,0x44,0x52,
              0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x08,0x02,0x00,0x00,0x00,0x90,0x77,0x53,
              0xDE,0x00,0x00,0x00,0x0C,0x49,0x44,0x41,0x54,0x08,0xD7,0x63,0xF8,0xFF,0xFF,0x3F,
              0x00,0x05,0xFE,0x02,0xFE,0xDC,0xCC,0x59,0xE7,0x00,0x00,0x00,0x00,0x49,0x45,0x4E,
              0x44,0xAE,0x42,0x60,0x82])
    }

    private static func buildManifest(files: [String: Data]) throws -> [String: String] {
        var manifest: [String: String] = [:]
        for (name, data) in files {
            manifest[name] = sha1Hex(data)
        }
        return manifest
    }

    private static func sha1Hex(_ data: Data) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes { CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest) }
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Signing

    private static func signManifest(manifestData: Data) throws -> Data {
        // Load raw PKCS#8 key directly — avoids keychain/entitlement requirements
        let keyBase64 = PassSecrets.privateKeyBase64.components(separatedBy: .whitespacesAndNewlines).joined()
        guard let keyDER = Data(base64Encoded: keyBase64) else {
            throw PassError.certificateImportFailed
        }

        // Strip PKCS#8 wrapper (30 82 xx xx 30 0d ... 04 82 xx xx) to get raw PKCS#1 RSA key
        let rsaDER = try stripPKCS8Header(keyDER)

        let keyAttrs: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
        ]
        var cfError: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateWithData(rsaDER as CFData, keyAttrs as CFDictionary, &cfError) else {
            throw PassError.certificateImportFailed
        }

        // Load cert from p12 (only need the cert DER, no keychain needed)
        guard let p12URL = Bundle.main.url(forResource: "pass_certificate", withExtension: "p12"),
              let p12Data = try? Data(contentsOf: p12URL) else {
            throw PassError.certificateNotFound
        }
        let options = [kSecImportExportPassphrase as String: PassSecrets.p12Passphrase] as CFDictionary
        var items: CFArray?
        guard SecPKCS12Import(p12Data as CFData, options, &items) == errSecSuccess,
              let arr = items as? [[String: Any]], let first = arr.first,
              let identity = first[kSecImportItemIdentity as String] else {
            throw PassError.certificateImportFailed
        }
        var certificate: SecCertificate?
        SecIdentityCopyCertificate(identity as! SecIdentity, &certificate)
        guard let cert = certificate else { throw PassError.certificateImportFailed }

        var signError: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(
            privateKey,
            .rsaSignatureMessagePKCS1v15SHA256,
            manifestData as CFData,
            &signError
        ) else {
            throw PassError.signingFailed
        }

        return try buildPKCS7Detached(content: manifestData, cert: cert, signatureBytes: signature as Data)
    }

    /// Strips the PKCS#8 AlgorithmIdentifier header to return raw PKCS#1 RSAPrivateKey DER.
    private static func stripPKCS8Header(_ pkcs8: Data) throws -> Data {
        let b = [UInt8](pkcs8)
        var i = 0
        func skip() throws {
            guard i < b.count else { throw PassError.certParseFailed }
            i += 1  // tag
            guard i < b.count else { throw PassError.certParseFailed }
            if b[i] < 0x80 { i += 1 + Int(b[i]) }
            else {
                let n = Int(b[i] & 0x7f); i += 1
                var l = 0; for _ in 0..<n { l = (l << 8) | Int(b[i]); i += 1 }
                i += l
            }
        }
        // SEQUENCE { INTEGER(0), SEQUENCE{OID,...}, OCTET STRING { RSAPrivateKey } }
        i += 1  // SEQUENCE tag
        if b[i] >= 0x80 { i += Int(b[i] & 0x7f) + 1 } else { i += 1 }  // outer length
        try skip()  // version INTEGER
        try skip()  // AlgorithmIdentifier SEQUENCE
        // Now at OCTET STRING wrapping the RSAPrivateKey
        i += 1  // OCTET STRING tag
        if b[i] >= 0x80 {
            let n = Int(b[i] & 0x7f); i += 1
            var l = 0; for _ in 0..<n { l = (l << 8) | Int(b[i]); i += 1 }
            _ = l
        } else { i += 1 }
        return Data(b[i...])
    }

    // MARK: - Minimal PKCS#7 DER builder

    /// Builds a detached PKCS#7 SignedData structure (no signed attributes).
    private static func buildPKCS7Detached(
        content: Data,
        cert: SecCertificate,
        signatureBytes: Data
    ) throws -> Data {
        let certDER = SecCertificateCopyData(cert) as Data

        // Parse issuer + serial from cert DER (needed for SignerInfo)
        let (issuerDER, serialDER) = try extractIssuerAndSerial(from: certDER)

        // OIDs
        let oidData          = derOID([1,2,840,113549,1,7,2])   // signedData
        let oidDataContent   = derOID([1,2,840,113549,1,7,1])   // data
        let oidSHA256        = derOID([2,16,840,1,101,3,4,2,1]) // sha-256
        let oidRSA           = derOID([1,2,840,113549,1,1,11])  // sha256WithRSAEncryption

        let sha256AlgID      = derSequence(oidSHA256 + derNull())
        let rsaAlgID         = derSequence(oidRSA + derNull())

        // DigestAlgorithms SET
        let digestAlgorithms = derSet(sha256AlgID)

        // EncapsulatedContentInfo (detached — no eContent)
        let encapContentInfo = derSequence(oidDataContent)

        // Certificates [0] IMPLICIT
        let certsTagged      = derTagged(0, certDER)

        // IssuerAndSerialNumber
        let issuerAndSerial  = derSequence(issuerDER + serialDER)

        // SignerInfo
        let signerInfo = derSequence(
            derInteger(Data([1]))       + // version
            issuerAndSerial             +
            sha256AlgID                 + // digestAlgorithm
            rsaAlgID                    + // signatureAlgorithm
            derOctetString(signatureBytes)
        )

        let signerInfos = derSet(signerInfo)

        // SignedData
        let signedData = derSequence(
            derInteger(Data([1]))       +
            digestAlgorithms            +
            encapContentInfo            +
            certsTagged                 +
            signerInfos
        )

        // ContentInfo
        let contentInfo = derSequence(
            oidData + derExplicit(0, signedData)
        )

        return contentInfo
    }

    /// Extracts raw DER bytes for the issuer SEQUENCE and serial INTEGER from a cert.
    private static func extractIssuerAndSerial(from certDER: Data) throws -> (Data, Data) {
        // TBSCertificate is inside Certificate SEQUENCE at index 0
        // Structure: SEQUENCE { SEQUENCE { [0] version, INTEGER serial, ... SEQUENCE issuer ... } }
        let bytes = [UInt8](certDER)
        var idx = 0

        func readTag() throws -> UInt8 {
            guard idx < bytes.count else { throw PassError.certParseFailed }
            let t = bytes[idx]; idx += 1; return t
        }
        func readLength() throws -> Int {
            guard idx < bytes.count else { throw PassError.certParseFailed }
            let first = bytes[idx]; idx += 1
            if first & 0x80 == 0 { return Int(first) }
            let numBytes = Int(first & 0x7f)
            var len = 0
            for _ in 0..<numBytes {
                guard idx < bytes.count else { throw PassError.certParseFailed }
                len = (len << 8) | Int(bytes[idx]); idx += 1
            }
            return len
        }
        func readTLV() throws -> (tag: UInt8, content: ArraySlice<UInt8>) {
            let tag = try readTag()
            let len = try readLength()
            guard idx + len <= bytes.count else { throw PassError.certParseFailed }
            let content = bytes[idx..<idx+len]; idx += len
            return (tag, content)
        }
        func skipTLV() throws { let _ = try readTLV() }
        func enterSequence() throws -> Int {
            let (_, _) = try readTLV()  // consume outer SEQUENCE wrapper
            return idx
        }

        // Outer Certificate SEQUENCE
        guard (try readTag()) == 0x30 else { throw PassError.certParseFailed }
        _ = try readLength()
        // TBSCertificate SEQUENCE
        guard (try readTag()) == 0x30 else { throw PassError.certParseFailed }
        _ = try readLength()

        // optional [0] version
        if bytes[idx] == 0xa0 { try skipTLV() }

        // serial INTEGER — capture raw TLV
        let serialStart = idx
        try skipTLV()
        let serialEnd = idx
        let serialTLV = Data(bytes[serialStart..<serialEnd])

        // signature AlgorithmIdentifier
        try skipTLV()

        // issuer SEQUENCE — capture raw TLV
        let issuerStart = idx
        try skipTLV()
        let issuerEnd = idx
        let issuerTLV = Data(bytes[issuerStart..<issuerEnd])

        return (issuerTLV, serialTLV)
    }

    // MARK: - DER primitives

    private static func derLength(_ len: Int) -> Data {
        if len < 0x80 { return Data([UInt8(len)]) }
        var tmp = len; var bytes: [UInt8] = []
        while tmp > 0 { bytes.insert(UInt8(tmp & 0xff), at: 0); tmp >>= 8 }
        return Data([0x80 | UInt8(bytes.count)] + bytes)
    }

    private static func derTLV(_ tag: UInt8, _ content: Data) -> Data {
        Data([tag]) + derLength(content.count) + content
    }

    private static func derSequence(_ content: Data) -> Data   { derTLV(0x30, content) }
    private static func derSet(_ content: Data) -> Data        { derTLV(0x31, content) }
    private static func derOctetString(_ d: Data) -> Data      { derTLV(0x04, d) }
    private static func derNull() -> Data                      { Data([0x05, 0x00]) }
    private static func derTagged(_ n: Int, _ d: Data) -> Data { derTLV(UInt8(0xa0 | n), d) }
    private static func derExplicit(_ n: Int, _ d: Data) -> Data { derTLV(UInt8(0xa0 | n), d) }

    private static func derInteger(_ d: Data) -> Data {
        // prepend 0x00 if high bit set to keep positive
        let content = (d.first ?? 0) >= 0x80 ? Data([0x00]) + d : d
        return derTLV(0x02, content)
    }

    private static func derOID(_ components: [Int]) -> Data {
        var body = Data()
        body.append(UInt8(40 * components[0] + components[1]))
        for c in components.dropFirst(2) {
            var val = c; var bytes: [UInt8] = [UInt8(val & 0x7f)]; val >>= 7
            while val > 0 { bytes.insert(UInt8(0x80 | (val & 0x7f)), at: 0); val >>= 7 }
            body.append(contentsOf: bytes)
        }
        return derTLV(0x06, body)
    }

    // MARK: - Archive

    private static func buildPassArchive(files: [String: Data], manifestData: Data, signature: Data) throws -> URL {
        var allFiles = files
        allFiles["manifest.json"] = manifestData
        allFiles["signature"] = signature

        let passURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("5kmrun_\(UUID().uuidString).pkpass")
        let zipData = buildZip(entries: allFiles)
        try zipData.write(to: passURL)
        return passURL
    }

    /// Builds a ZIP archive with all entries at the root (no subdirectory).
    private static func buildZip(entries: [String: Data]) -> Data {
        var zip = Data()
        var centralDirectory = Data()
        var offsets: [String: UInt32] = [:]

        for (name, content) in entries {
            let nameData = name.data(using: .utf8)!
            let crc = crc32(content)
            let offset = UInt32(zip.count)
            offsets[name] = offset

            // Local file header
            zip += zipUInt32(0x04034b50)  // signature
            zip += zipUInt16(20)           // version needed
            zip += zipUInt16(0)            // flags
            zip += zipUInt16(0)            // compression: stored
            zip += zipUInt16(0)            // mod time
            zip += zipUInt16(0)            // mod date
            zip += zipUInt32(crc)
            zip += zipUInt32(UInt32(content.count))
            zip += zipUInt32(UInt32(content.count))
            zip += zipUInt16(UInt16(nameData.count))
            zip += zipUInt16(0)            // extra field length
            zip += nameData
            zip += content

            // Central directory entry
            centralDirectory += zipUInt32(0x02014b50) // signature
            centralDirectory += zipUInt16(20)          // version made by
            centralDirectory += zipUInt16(20)          // version needed
            centralDirectory += zipUInt16(0)           // flags
            centralDirectory += zipUInt16(0)           // compression
            centralDirectory += zipUInt16(0)           // mod time
            centralDirectory += zipUInt16(0)           // mod date
            centralDirectory += zipUInt32(crc)
            centralDirectory += zipUInt32(UInt32(content.count))
            centralDirectory += zipUInt32(UInt32(content.count))
            centralDirectory += zipUInt16(UInt16(nameData.count))
            centralDirectory += zipUInt16(0)           // extra
            centralDirectory += zipUInt16(0)           // comment
            centralDirectory += zipUInt16(0)           // disk start
            centralDirectory += zipUInt16(0)           // int attributes
            centralDirectory += zipUInt32(0)           // ext attributes
            centralDirectory += zipUInt32(offset)
            centralDirectory += nameData
        }

        let cdOffset = UInt32(zip.count)
        zip += centralDirectory

        // End of central directory
        zip += zipUInt32(0x06054b50)
        zip += zipUInt16(0)            // disk number
        zip += zipUInt16(0)            // disk with cd
        zip += zipUInt16(UInt16(entries.count))
        zip += zipUInt16(UInt16(entries.count))
        zip += zipUInt32(UInt32(centralDirectory.count))
        zip += zipUInt32(cdOffset)
        zip += zipUInt16(0)            // comment length

        return zip
    }

    private static func zipUInt16(_ v: UInt16) -> Data {
        Data([UInt8(v & 0xff), UInt8((v >> 8) & 0xff)])
    }
    private static func zipUInt32(_ v: UInt32) -> Data {
        Data([UInt8(v & 0xff), UInt8((v >> 8) & 0xff),
              UInt8((v >> 16) & 0xff), UInt8((v >> 24) & 0xff)])
    }

    private static func crc32(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xffffffff
        let table: [UInt32] = (0..<256).map { i -> UInt32 in
            var c = UInt32(i)
            for _ in 0..<8 { c = (c & 1) != 0 ? 0xedb88320 ^ (c >> 1) : c >> 1 }
            return c
        }
        for byte in data { crc = table[Int((crc ^ UInt32(byte)) & 0xff)] ^ (crc >> 8) }
        return crc ^ 0xffffffff
    }

    enum PassError: Error {
        case certificateNotFound
        case certificateImportFailed
        case signingFailed
        case certParseFailed
    }
}
