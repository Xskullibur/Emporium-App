//
//  DeliveryOptionHostingController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 14/8/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import SwiftUI

struct RequestOrderOptionView: View {
    
    @ObservedObject var deliveryOption = DeliveryOption()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    private var loadAndSaveDeliveryOption: LoadAndSaveDeliveryOption? = nil
    
    init(_ loadAndSaveDeliveryOption: LoadAndSaveDeliveryOption?) {
        self.loadAndSaveDeliveryOption = loadAndSaveDeliveryOption
    }
    
    var body: some View {
        NavigationView {
            VStack{
                HStack(alignment: .firstTextBaseline, spacing: 5.0){
                    Text("Distance (KM)")
                        .padding(.horizontal, 15)
                    TextField("", text:$deliveryOption.distanceInKm)
                    .keyboardType(.decimalPad)
                    
                }.frame(width: nil, height: 25, alignment: .center)
                Spacer()
            }
        }.navigationBarTitle("Request Options")
        .navigationBarItems(trailing:
            Button(action: {
                self.loadAndSaveDeliveryOption?.save(self.deliveryOption)
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
            }
        )
    }
    
    mutating func setDeliveryOption(_ deliveryOption: DeliveryOption){
        self.deliveryOption = deliveryOption
    }
    
}
class DeliveryOptionHostingController: UIHostingController<RequestOrderOptionView> {
    
    private var firebaseLoadAndSaveDeliveryOption: FirebaseLoadAndSaveDeliveryOption
    
    required init?(coder: NSCoder) {
        self.firebaseLoadAndSaveDeliveryOption = FirebaseLoadAndSaveDeliveryOption()
        super.init(coder: coder, rootView: RequestOrderOptionView(self.firebaseLoadAndSaveDeliveryOption))
        self.firebaseLoadAndSaveDeliveryOption.load{
            deliveryOption in
            self.rootView.setDeliveryOption(deliveryOption)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

struct RequestOrderOption_Previews: PreviewProvider {
    static var previews: some View {
        RequestOrderOptionView(nil)
    }
}
