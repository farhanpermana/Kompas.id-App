//
//  HomeViewModel.swift
//  Kompas.id
//
//  Created by Farhan on 03/08/25.
//

import Foundation
import RxSwift
import RxRelay

protocol HomeViewModelType {
    var inputs: HomeViewModelInputs { get }
    var outputs: HomeViewModelOutputs { get }
}

protocol HomeViewModelInputs {
    func onViewDidLoad()
    func refresh()
}

protocol HomeViewModelOutputs {
    var homeSections: Observable<[HomeSectionData]?> { get }
    var error: Observable<APIError?> { get }
    
}

class HomeViewModel: BaseViewModel {
    
    private let homeSectionsRelay = BehaviorRelay<[HomeSectionData]?>(value: nil)
    private let errorRelay = BehaviorRelay<APIError?>(value: nil)
    
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
        super.init()
    }
    
    private func fetchHomeSections() {
        let homeSectionsURL = "http://localhost:3002/homesections"
        apiService.fetchData(from: homeSectionsURL) { [weak self] (result: Result<[HomeSectionData], APIError>) in
            guard let self else { return }
            switch result {
            case .success(let sections):
                self.homeSectionsRelay.accept(sections)
                self.errorRelay.accept(nil)
            case .failure(let error):
                print("Failed to fetch home sections: \(error.localizedDescription)")
                self.errorRelay.accept(error)
            }
        }
    }
}

// MARK: Private

extension HomeViewModel: HomeViewModelType {
    var inputs: HomeViewModelInputs { return self }
    var outputs: HomeViewModelOutputs { return self }
}

extension HomeViewModel: HomeViewModelInputs {
    
    func onViewDidLoad() {
        fetchHomeSections()
    }
    
    func refresh() {
        fetchHomeSections()
    }
}

extension HomeViewModel: HomeViewModelOutputs {
    
    var homeSections: Observable<[HomeSectionData]?> {
        return homeSectionsRelay.asObservable()
    }
    
    var error: Observable<APIError?> {
        return errorRelay.asObservable()
    }
}
