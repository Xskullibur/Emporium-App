//
//  VoucherDataManager.swift
//  Emporium
//
//  Created by Peh Zi Heng on 18/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFunctions
import Combine

class VoucherDataManager {
    
    let user: User?
    
    //Create publisher
    private let availableVoucherPublisher: CurrentValueSubject<[[String: Any]], EmporiumError>
    
    private var claimedVoucherPublisher: CurrentValueSubject<[[String: Any]], EmporiumError>? = nil
    private var claimedVoucherRef: CollectionReference? = nil
    
    
    lazy var functions = Functions.functions()
    
    
    init(user: User? = nil){
        self.user = user
        
        self.availableVoucherPublisher = CurrentValueSubject<[[String: Any]], EmporiumError>([])
        
        let db = Firestore.firestore()
        
        //MARK: Available Voucher Reference
        
        // Create available voucher reference
        //Get voucher reference
        let availableVoucherRef = db.collection("emporium/globals/available_vouchers")
        
        //Get voucher and send to publisher
        availableVoucherRef.addSnapshotListener{
            (querySnapshot, error) in
            
            if let error = error {
                self.availableVoucherPublisher.send(completion: .failure(.firebaseError(error)))
            }
            
            var datas: [[String: Any]] = []
            
            if let querySnapshot = querySnapshot {
               for document in querySnapshot.documents {
                   var data = document.data()
                   data["id"] = document.documentID
                   datas.append(data)
               }
           }
           
            self.availableVoucherPublisher.send(datas)
        }
     
        //MARK: Claimed Voucher Reference
        
        if let user = user {
            self.claimedVoucherPublisher = CurrentValueSubject<[[String: Any]], EmporiumError>([])
            
            //Create user claimed voucher reference if signed in
            self.claimedVoucherRef = db.collection("users/\(user.uid)/claimed_vouchers")
            
            //Get voucher and send to publisher
            self.claimedVoucherRef?.addSnapshotListener{
                (querySnapshot, error) in
                
                if let error = error {
                    self.claimedVoucherPublisher?.send(completion: .failure(.firebaseError(error)))
                }
                
                var datas: [[String: Any]] = []
                
                if let querySnapshot = querySnapshot {
                   for document in querySnapshot.documents {
                       var data = document.data()
                       data["id"] = document.documentID
                       datas.append(data)
                   }
               }
               
                self.claimedVoucherPublisher?.send(datas)
            }
        }
        
        //Debugging
        #if DEBUG
        let functionsHost = ProcessInfo.processInfo.environment["functions_host"]
        if let functionsHost = functionsHost {
            functions.useFunctionsEmulator(origin: functionsHost)
        }
        #endif
    }
    
    /**
     Claim a voucher for user
     
     Requirement:
        User must be signed in in order to use this function.
     */
    func setClaimVoucher(voucher: Voucher, completion: ((VoucherStatus?) -> Void)?){
        functions.httpsCallable("claimVoucher").call(["voucherId": voucher.id]){
            result, error in
            
            if let error = error as NSError? {
                completion?(.error(error))
            }
            
            if let status = (result?.data as? [String: Any])?["status"] as? String {
                if status == "Success"{
                    completion?(.success)
                }else if status == "Not enough points"{
                    completion?(.notEnoughPoints)
                }
                else{
                    completion?(.error(StringError.stringError(status)))
                }
            }
            
        }
    }
    
    /**
     Get a list of vouchers that has been claimed by the user
     
     Requirement:
        User must be signed in in order to use this function.
     */
    func getClaimedVoucher() -> AnyPublisher<[Voucher], EmporiumError>? {
        //Convert [[String: Any]] -> [Voucher]
        return self.claimedVoucherPublisher?
            .tryMap{
                datas in
                return datas.map(self.toVoucher(data:))
            }
            .mapError{
            error in
            return error as! EmporiumError
        }
        .eraseToAnyPublisher()
    }
    
    /**
     Get a list of available vouchers
     */
    func getAvailableVouchers() -> AnyPublisher<[Voucher], EmporiumError> {
        //Convert [[String: Any]] -> [Voucher]
        return self.availableVoucherPublisher
            .tryMap{
                datas in
                return datas.map(self.toVoucher(data:))
            }
            .mapError{
            error in
            return error as! EmporiumError
        }
        .eraseToAnyPublisher()
    }
    
    private func toVoucher(data: [String: Any]) -> Voucher {
        let id = data["id"] as? String ?? ""
        let name = data["name"] as? String ?? ""
        let description = data["description"] as? String ?? ""
        let cost = data["cost"] as? Int ?? 0
        let formula = data["formula"] as? String ?? ""
        let used = data["used"] as? Bool ?? false
        return Voucher(id: id, name: name, description: description, cost: cost, formula: formula, used: used)
    }
    
}
