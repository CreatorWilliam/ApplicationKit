//
//  String+Extension.swift
//  ComponentKit
//
//  Created by William Lee on 4/9/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import CommonCrypto

public extension String  {
  
  var md5: String {
    
    let str = self.cString(using: String.Encoding.utf8)
    let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
    let digestLen = Int(CC_MD5_DIGEST_LENGTH)
    let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
    CC_MD5(str!, strLen, result)
    return stringFromBytes(bytes: result, length: digestLen)
  }
  
  var sha1: String! {
    
    let str = self.cString(using: String.Encoding.utf8)
    let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
    let digestLen = Int(CC_SHA1_DIGEST_LENGTH)
    let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
    CC_SHA1(str!, strLen, result)
    return stringFromBytes(bytes: result, length: digestLen)
  }
  
  var sha256: String! {
    
    let str = self.cString(using: String.Encoding.utf8)
    let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
    let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
    let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
    CC_SHA256(str!, strLen, result)
    return stringFromBytes(bytes: result, length: digestLen)
  }
  
  var sha512: String! {
    
    let str = self.cString(using: String.Encoding.utf8)
    let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
    let digestLen = Int(CC_SHA512_DIGEST_LENGTH)
    let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
    CC_SHA512(str!, strLen, result)
    return stringFromBytes(bytes: result, length: digestLen)
  }
  
  private func stringFromBytes(bytes: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
    
    var hash: String = ""
    for i in 0..<length {
      hash.append(String(format: "%02x", bytes[i]))
    }
    bytes.deallocate()
    return String(format: hash as String)
  }
  
  //  func hmac(algorithm: CryptoAlgorithm, key: String) -> String {
  //
  //    let str = self.cString(using: String.Encoding.utf8)
  //    let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
  //    let digestLen = algorithm.digestLength
  //    let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
  //    let keyStr = key.cString(using: String.Encoding.utf8)
  //    let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))
  //
  //    CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
  //
  //    let digest = stringFromResult(result: result, length: digestLen)
  //
  //    result.deallocate(capacity: digestLen)
  //
  //    return digest
  //  }
  
  private func stringFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
    
    var hash: String = ""
    for i in 0..<length {
      hash.append(String(format: "%02x", result[i]))
    }
    return String(hash)
  }
}
