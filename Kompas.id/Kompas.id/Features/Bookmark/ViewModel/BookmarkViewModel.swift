//
//  BookmarkViewModel.swift
//  Kompas.id
//
//  Created by Farhan on 10/08/25.
//

import Foundation
import RxSwift
import RxRelay

protocol BookmarkViewModelType {
    var inputs: BookmarkViewModelInputs { get }
    var outputs: BookmarkViewModelOutputs { get }
}

protocol BookmarkViewModelInputs {
    func onViewDidLoad()
}

protocol BookmarkViewModelOutputs {
    var update: Observable<Bool> { get }
}

class BookmarkViewModel: BaseViewModel {

    private let updateVariable = BehaviorRelay<Bool>(value: false)
    
    override init() {
        super.init()
    }
}


// MARK: Private

extension BookmarkViewModel {
    
}

extension BookmarkViewModel: BookmarkViewModelType {
    var inputs: BookmarkViewModelInputs { return self }
    var outputs: BookmarkViewModelOutputs { return self }
}

extension BookmarkViewModel: BookmarkViewModelInputs {
    
    func onViewDidLoad() {
        
    }
}

extension BookmarkViewModel: BookmarkViewModelOutputs {
    
    var update: Observable<Bool> {
        return updateVariable.asObservable().filter { $0 }
    }
}
