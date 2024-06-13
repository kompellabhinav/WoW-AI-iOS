//
//  PhoneNumberScreen.swift
//  WoW AI
//  Created by Abhinav Kompella on 5/28/24.
//

import SwiftUI

struct PhoneNumberScreen: View {
    @Environment(\.dismiss) var presentationMode
    
    @State var phoneNumber: String = ""
    @FocusState var isSelected: Bool
    var storage = StorePhoneNumber()
    @State var submitted: Bool = false
    @State var isEditScreen: Bool
    
    var body: some View {
        VStack {
            if isEditScreen {
                HStack {
                    Button(action: {
                        presentationMode.callAsFunction()
                    }, label: {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 30)
                            .foregroundStyle(Color("ThemePink"))
                            .padding()
                    })
                    Spacer()
                }
            }
            TextField(text: $phoneNumber) {
                Text("Enter your phone number")
            }
            .textFieldStyle(.roundedBorder)
            .keyboardType(.phonePad)
            .overlay(
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(isSelected ? Color("ThemePink") : Color.gray),
                alignment: .bottom
            )
            .focused($isSelected)
            .padding()
            Spacer()
            Button(action: {
                storage.phoneNumber = phoneNumber
                print("Stored")
                if isEditScreen {
                    presentationMode.callAsFunction()
                } else {
                    submitted = true
                }
            }, label: {
                Text("Submit")
                    .foregroundStyle(Color.white)
            })
            .frame(width: 350, height: 50)
            .background(Color("ThemePink"))
            .clipShape(RoundedRectangle(cornerRadius: 5.0))
            .padding()
            .fullScreenCover(isPresented: $submitted, content: {
                MainScreen()
            })
        }
    }
}

#Preview {
    PhoneNumberScreen(isEditScreen: false)
}
