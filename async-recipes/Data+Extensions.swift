//
//  Data+Extensions.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//

import CommonCrypto
import Foundation

extension Data {
    // MARK: - Public Functions
    func toSHA1String() -> String? {
        guard self.count > 0 else {
            return nil
        }
        var retval = Data(count: Int(CC_SHA1_DIGEST_LENGTH))
        
        _ = retval.withUnsafeMutableBytes { buffer in
            self.withUnsafeBytes {
                if let messageBytesBaseAddress = $0.baseAddress, let digestBytesBlindMemory = buffer.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(self.count)
                    
                    CC_SHA1(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return retval.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}
