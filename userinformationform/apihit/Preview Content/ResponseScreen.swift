import Foundation
import SwiftUI

struct ResponseScreen: View {
    @State private var storedData: [[String: Any]] = []
    var responseData: [String: Any]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                ForEach(storedData.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        let orderedKeys = ["id", "name", "email", "age", "phone", "address"]
                        ForEach(orderedKeys, id: \.self) { key in
                            if let value = storedData[index][key] {
                                HStack {
                                    Text("\(key.capitalized):")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                        .frame(width: 100, alignment: .leading) // Fixed width for labels
                                    
                                    Text("\(value)")
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        
                        // Delete Button
                        Button(action: {
                            deleteEntry(at: index)
                        }) {
                            Text("Delete")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 5)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                }
                Spacer()
            }
        }
        .padding(.top, 20)
        .background(Color(.systemGray6))
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitle("Response Details", displayMode: .inline) // Proper title styling
        .onAppear {
            storedData.append(responseData)
        }
    }
    
    func deleteEntry(at index: Int) {
        storedData.remove(at: index)
    }
}

struct ResponseScreen_Previews: PreviewProvider {
    static var previews: some View {
        ResponseScreen(responseData: ["id": 1, "name": "Nigam", "email": "nigam@example.com", "age": "23", "phone": "1234567890", "address": "123 Street, City"])
    }
}
