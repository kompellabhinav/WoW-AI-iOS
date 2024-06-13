//
//  SettingsScreen.swift
//  WoW AI
//
//  Created by Abhinav Kompella on 5/28/24.
//

import SwiftUI

struct SettingsScreen: View {
    @Environment(\.dismiss) var presentationMode
    
    private var storage = StorePhoneNumber()
    @State var isPhoneNumberTapped: Bool = false
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.97)
            VStack {
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
                    Button(action: {}, label: {
                        Image(systemName: "trash.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 30)
                            .foregroundStyle(Color("ThemePink"))
                            .padding()
                    })
                }
                .background(Color.white)
                
                HStack {
                    Text("Phone Number:")
                    Spacer()
                    Button(action: {
                        self.isPhoneNumberTapped = true
                    }, label: {
                        if let phoneNumber = storage.phoneNumber {
                            Text(storage.phoneNumber!)
                                .foregroundStyle(Color("ThemePink"))
                        } else {
                            Text("Add")
                                .foregroundStyle(Color("ThemePink"))
                        }
                    })
                    .fullScreenCover(isPresented: $isPhoneNumberTapped, onDismiss: {
                    }, content: {
                        PhoneNumberScreen(isEditScreen: true)
                    })
                }
                .padding()
                
                Spacer()
            }
        }
    }
}

#Preview {
    SettingsScreen()
}
