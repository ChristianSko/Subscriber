//
//  ContentView.swift
//  Subscriber
//
//  Created by Skorobogatow, Christian on 19/7/22.
//

import SwiftUI
import Combine


class SubscriberViewModel: ObservableObject {
    
    @Published var count = 0
    @Published var texfieldText = ""
    @Published var textIsValid: Bool = false
    @Published var showButton: Bool = false
    
    // For  Single Publisher
//    var timer: AnyCancellable?
    
    
    //For several Publishers
    var cancelleables = Set<AnyCancellable>()
    
    init() {
        setUpTimer()
        addTextfieldSubscriber()
        addButtonSubscriber()
    }
    
    func addTextfieldSubscriber() {
        $texfieldText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map { (text) -> Bool in
                if text.count > 3{
                    return true
                }
                return false
            }
        // Creates strong reference, no option currently to create weak reference
//            .assign(to: \.textIsValid, on: self) ->
        
            .sink(receiveValue: { [weak self] (isValid) in
                self?.textIsValid = isValid
            })
            .store(in: &cancelleables)
    }
    
    func setUpTimer() {
        Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.count += 1
                
                
                // To cancel all publishers
                /*
                if self.count >= 10 {
                    for item in self.cancelleables {
                        item.cancel()
                    }
                }
                 */
            }
            .store(in: &cancelleables)
    }
    
    func addButtonSubscriber() {
        $textIsValid
            .combineLatest($count)
            .sink { [weak self] (isValid , count) in
                guard let self = self else { return }
                if isValid && count >= 10 {
                    self.showButton = true
                } else {
                    self.showButton = false
                }
            }
            .store(in: &cancelleables)
    }
}

struct ContentView: View {
    
    @StateObject var vm = SubscriberViewModel()
    
    var body: some View {
        VStack(spacing: 25){
            Text("\(vm.count)")
                .font(.largeTitle)
                .padding()
    
            
            TextField("Write word here...", text: $vm.texfieldText)
                .padding(.leading)
                .frame(height: 55)
                .font(.headline)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .overlay(
                    ZStack{
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                            .opacity(
                                vm.texfieldText.count < 1 ? 0 :
                                vm.textIsValid ? 0.0 : 1.0)
                        
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .opacity(vm.textIsValid ? 1.0 : 0.0)
                    }
                        .font(.title)
                        .padding(.trailing)
                    , alignment: .trailing
                )
            
            
            Button(action: {}, label: {
                Text("Submit".uppercased())
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(10)
                    .opacity(vm.showButton ? 1.0 : 0.5)
                    .disabled(!vm.showButton)
            })
            
            
            Text("Password has \(vm.texfieldText.count) letters. \n Requires 10 seconds to pass and 4 Letters")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
