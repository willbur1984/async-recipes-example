//
//  Data+Extensions.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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
                if let baseAddress = $0.baseAddress, let start = buffer.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(self.count)
                    
                    CC_SHA1(baseAddress, messageLength, start)
                }
                return 0
            }
        }
        return retval.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}
