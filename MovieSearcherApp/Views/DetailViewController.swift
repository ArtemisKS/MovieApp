//
//  DetailViewController.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 07.12.2020.
//

import UIKit

class DetailViewController: UIViewController {
  
  @IBOutlet weak var chooseButton: UIButton!
  @IBOutlet weak var dataLabel: UILabel!
  
  var presenter: DetailViewPresenterProtocol!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    presenter?.setupView()
  }
  
  @IBAction func buttonTapped(_ sender: UIButton) {
    presenter.tapOnData()
  }
  
}

extension DetailViewController: DetailViewProtocol {
  
  func setupButton(with title: String) {
    chooseButton.setTitle(title, for: .normal)
  }
  
  func setupDataLabel(with title: String) {
    dataLabel.text = title
  }
}
