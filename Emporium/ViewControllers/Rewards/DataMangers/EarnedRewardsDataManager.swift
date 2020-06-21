//
//  EarnedRewardsManager.swift
//  Emporium
//
//  Created by Riyfhx on 20/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFunctions
import Combine

class EarnedRewardsDataManager {
    
    private var earnedRewardsPublisher: CurrentValueSubject<[[String: Any]], EmporiumError>!
    
    private var earnedPointsRef: CollectionReference?
    private var user: User?
    
    lazy var functions = Functions.functions()
    
    init (){
        Auth.auth().addStateDidChangeListener{
            (auth, user) in
            self.user = user
            
            self.reset()
            self.listen()
        }
        self.earnedRewardsPublisher = CurrentValueSubject<[[String: Any]], EmporiumError>([])
        
        //Debugging
        #if DEBUG
        functions.useFunctionsEmulator(origin: "http://192.168.211.1:5000")
        #endif
        
    }
    
    private func listen(){
        guard let user = user else{
            return
        }
        
        let database = Firestore.firestore()
        
        //Get reference to point field
        self.earnedPointsRef = database.collection("users/\(user.uid)/earned_rewards")
        
        self.earnedPointsRef?.addSnapshotListener{
            (querySnapshot, error) in
            
            if let error = error {
               self.earnedRewardsPublisher?.send(completion: .failure(.firebaseError(error)))
           }
                           
           var datas: [[String: Any]] = []
           
           if let querySnapshot = querySnapshot {
              for document in querySnapshot.documents {
                  var data = document.data()
                  data["id"] = document.documentID
                  datas.append(data)
              }
          }
            
            self.earnedRewardsPublisher.send(datas)
            
        }
    }
    
    private func reset(){
        self.earnedPointsRef = nil
    }
    
    private func toEarnedReward(data: [String: Any]) -> EarnedReward{
        let id = data["id"] as? String ?? ""
        let earnedAmount = data["earned_amount"] as? Int ?? 0
        let earnedDate = data["earned_date"] as? Date ?? Date()
        let displayed = data["displayed"] as? Bool ?? false
        return EarnedReward(id: id, earnedAmount: earnedAmount, earnedDate: earnedDate, displayed: displayed)
    }
    
    /*
     Get list of earned points by user
     */
    func getEarnedRewards() -> AnyPublisher<[EarnedReward], EmporiumError>{
        return self.earnedRewardsPublisher
            .tryMap{
                datas in
                return datas.map(self.toEarnedReward(data:))
        }.mapError{
            error in
            return error as! EmporiumError
        }.eraseToAnyPublisher()
    }
 
    /*
     Set earned rewards as seen, so it wont be shown to the user again
     Requirements:
      EarnedReward must belong to the user signed in
     */
    func seenEarnedRewards(_ earnedReward: EarnedReward, completion: ((EarnedRewardStatus) -> Void)?){
        functions.httpsCallable("seenRewardReward").call(["earnedRewardId": earnedReward.id]){
            result, error in
            
            if let error = error as NSError? {
                completion?(.error(error))
            }
            
            if let status = (result?.data as? [String: Any])?["status"] as? String {
                if status == "Success"{
                    completion?(.success)
                }else if status == "Failed"{
                    completion?(.failure)
                }
                else{
                    completion?(.error(StringError.stringError(status)))
                }
            }
            
            
        }
    }
    
}
