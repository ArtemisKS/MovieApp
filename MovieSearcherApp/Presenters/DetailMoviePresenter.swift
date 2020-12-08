//
//  DetailMoviePresenter.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import Foundation

protocol DetailViewProtocol: class {
    func setupButton(with title: String)
    func setupDataLabel(with title: String)
}

protocol DetailViewPresenterProtocol: class {
    init(data: MovieModel, view: DetailViewProtocol, router: RouterProtocol)
    //  var data: [MovieModel]? { get set }
    func tapOnData()
    func setupView()
}

class DetailPresenter: DetailViewPresenterProtocol {
    
    private var data: MovieModel
    weak var view: DetailViewProtocol?
    var router: RouterProtocol?
    //  var data: [MovieModel]?
    
    required init(data: MovieModel, view: DetailViewProtocol, router: RouterProtocol) {
        self.data = data
        self.view = view
        self.router = router
    }
    
    func tapOnData() {
        //    router?.showDetail(with: data)
    }
    
    func setupView() {
        //    let labelTitle = confLabelTitle()
        //    view?.setupButton(with: data != nil
        //      ? "Изменить фильтры" : "Выбрать фильтры")
        //    view?.setupDataLabel(with: labelTitle)
    }
    
}
