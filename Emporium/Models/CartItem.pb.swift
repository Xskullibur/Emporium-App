// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: proto/CartItem.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

struct CartItem {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var productID: String = String()

  var quantity: Int32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct PaymentInfo {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var number: String = String()

  var month: Int32 = 0

  var year: Int32 = 0

  var cvc: String = String()

  var bank: String = String()

  var name: String = String()

  var voucherID: String = String()

  var order: Order {
    get {return _order ?? Order()}
    set {_order = newValue}
  }
  /// Returns true if `order` has been explicitly set.
  var hasOrder: Bool {return self._order != nil}
  /// Clears the value of `order`. Subsequent reads from it will return its default value.
  mutating func clearOrder() {self._order = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _order: Order? = nil
}

struct DeliveryAddress {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var latitude: Float = 0

  var longitude: Float = 0

  var postal: String = String()

  var address: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Order {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var orderID: String = String()

  var orderByUserID: String = String()

  var deliveryAddress: DeliveryAddress {
    get {return _deliveryAddress ?? DeliveryAddress()}
    set {_deliveryAddress = newValue}
  }
  /// Returns true if `deliveryAddress` has been explicitly set.
  var hasDeliveryAddress: Bool {return self._deliveryAddress != nil}
  /// Clears the value of `deliveryAddress`. Subsequent reads from it will return its default value.
  mutating func clearDeliveryAddress() {self._deliveryAddress = nil}

  var cartItems: [CartItem] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _deliveryAddress: DeliveryAddress? = nil
}

struct NotAvailableItems {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var accountID: String = String()

  var cartItems: [CartItem] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension CartItem: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "CartItem"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "productID"),
    2: .same(proto: "quantity"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.productID)
      case 2: try decoder.decodeSingularInt32Field(value: &self.quantity)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.productID.isEmpty {
      try visitor.visitSingularStringField(value: self.productID, fieldNumber: 1)
    }
    if self.quantity != 0 {
      try visitor.visitSingularInt32Field(value: self.quantity, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: CartItem, rhs: CartItem) -> Bool {
    if lhs.productID != rhs.productID {return false}
    if lhs.quantity != rhs.quantity {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension PaymentInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "PaymentInfo"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "number"),
    2: .same(proto: "month"),
    3: .same(proto: "year"),
    4: .same(proto: "cvc"),
    5: .same(proto: "bank"),
    6: .same(proto: "name"),
    7: .standard(proto: "voucher_id"),
    8: .same(proto: "order"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.number)
      case 2: try decoder.decodeSingularInt32Field(value: &self.month)
      case 3: try decoder.decodeSingularInt32Field(value: &self.year)
      case 4: try decoder.decodeSingularStringField(value: &self.cvc)
      case 5: try decoder.decodeSingularStringField(value: &self.bank)
      case 6: try decoder.decodeSingularStringField(value: &self.name)
      case 7: try decoder.decodeSingularStringField(value: &self.voucherID)
      case 8: try decoder.decodeSingularMessageField(value: &self._order)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.number.isEmpty {
      try visitor.visitSingularStringField(value: self.number, fieldNumber: 1)
    }
    if self.month != 0 {
      try visitor.visitSingularInt32Field(value: self.month, fieldNumber: 2)
    }
    if self.year != 0 {
      try visitor.visitSingularInt32Field(value: self.year, fieldNumber: 3)
    }
    if !self.cvc.isEmpty {
      try visitor.visitSingularStringField(value: self.cvc, fieldNumber: 4)
    }
    if !self.bank.isEmpty {
      try visitor.visitSingularStringField(value: self.bank, fieldNumber: 5)
    }
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 6)
    }
    if !self.voucherID.isEmpty {
      try visitor.visitSingularStringField(value: self.voucherID, fieldNumber: 7)
    }
    if let v = self._order {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 8)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: PaymentInfo, rhs: PaymentInfo) -> Bool {
    if lhs.number != rhs.number {return false}
    if lhs.month != rhs.month {return false}
    if lhs.year != rhs.year {return false}
    if lhs.cvc != rhs.cvc {return false}
    if lhs.bank != rhs.bank {return false}
    if lhs.name != rhs.name {return false}
    if lhs.voucherID != rhs.voucherID {return false}
    if lhs._order != rhs._order {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension DeliveryAddress: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "DeliveryAddress"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "latitude"),
    2: .same(proto: "longitude"),
    3: .same(proto: "postal"),
    4: .same(proto: "address"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularFloatField(value: &self.latitude)
      case 2: try decoder.decodeSingularFloatField(value: &self.longitude)
      case 3: try decoder.decodeSingularStringField(value: &self.postal)
      case 4: try decoder.decodeSingularStringField(value: &self.address)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.latitude != 0 {
      try visitor.visitSingularFloatField(value: self.latitude, fieldNumber: 1)
    }
    if self.longitude != 0 {
      try visitor.visitSingularFloatField(value: self.longitude, fieldNumber: 2)
    }
    if !self.postal.isEmpty {
      try visitor.visitSingularStringField(value: self.postal, fieldNumber: 3)
    }
    if !self.address.isEmpty {
      try visitor.visitSingularStringField(value: self.address, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: DeliveryAddress, rhs: DeliveryAddress) -> Bool {
    if lhs.latitude != rhs.latitude {return false}
    if lhs.longitude != rhs.longitude {return false}
    if lhs.postal != rhs.postal {return false}
    if lhs.address != rhs.address {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Order: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "Order"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "order_id"),
    2: .standard(proto: "order_by_user_id"),
    4: .standard(proto: "delivery_address"),
    5: .same(proto: "cartItems"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.orderID)
      case 2: try decoder.decodeSingularStringField(value: &self.orderByUserID)
      case 4: try decoder.decodeSingularMessageField(value: &self._deliveryAddress)
      case 5: try decoder.decodeRepeatedMessageField(value: &self.cartItems)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.orderID.isEmpty {
      try visitor.visitSingularStringField(value: self.orderID, fieldNumber: 1)
    }
    if !self.orderByUserID.isEmpty {
      try visitor.visitSingularStringField(value: self.orderByUserID, fieldNumber: 2)
    }
    if let v = self._deliveryAddress {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
    }
    if !self.cartItems.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.cartItems, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Order, rhs: Order) -> Bool {
    if lhs.orderID != rhs.orderID {return false}
    if lhs.orderByUserID != rhs.orderByUserID {return false}
    if lhs._deliveryAddress != rhs._deliveryAddress {return false}
    if lhs.cartItems != rhs.cartItems {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension NotAvailableItems: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "NotAvailableItems"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "account_id"),
    2: .same(proto: "cartItems"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.accountID)
      case 2: try decoder.decodeRepeatedMessageField(value: &self.cartItems)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.accountID.isEmpty {
      try visitor.visitSingularStringField(value: self.accountID, fieldNumber: 1)
    }
    if !self.cartItems.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.cartItems, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: NotAvailableItems, rhs: NotAvailableItems) -> Bool {
    if lhs.accountID != rhs.accountID {return false}
    if lhs.cartItems != rhs.cartItems {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
