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
                    LabelTextField(label:"Distance (KM)", placeHolder: $deliveryOption.distanceInKm)
//                    Text()
//                        .padding(.horizontal, 15)
//                    TextField("", text:)
//                    .keyboardType(.decimalPad)
                    
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

struct LabelTextField : View {
    var label: String
    var placeHolder: Binding<String>
 
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
            TextField("", text: placeHolder)
                .padding(.all)
                .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
                .cornerRadius(5.0)
            }
            .padding(.horizontal, 15)
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
