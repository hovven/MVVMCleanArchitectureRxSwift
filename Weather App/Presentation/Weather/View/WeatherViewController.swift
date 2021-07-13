//
//  WeatherViewController.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/1/21.
//  Copyright © 2021 Hoven. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa

class WeatherViewController: UIViewController, StoryboardBased, ViewModelBased, Alertable {
    
    var viewModel: WeatherViewModel!
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var blurredImageView: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    private var headerView = HeaderView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViews()
        viewModel.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.backgroundImageView.frame = self.view.bounds
        self.blurredImageView.frame = self.view.bounds
        self.tableView.frame = self.view.bounds
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupViews() {
        
        headerView.backgroundColor = .clear
        self.tableView.tableHeaderView = headerView
        
        searchResultsTableView.register(UINib(nibName: "CityCell", bundle: nil), forCellReuseIdentifier: "city_cell")
        
        let keyboardDismiss = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.tableView.addGestureRecognizer(keyboardDismiss)
        self.view.bringSubviewToFront(searchResultsTableView)
    }
    
    private func bindViews() {
        viewModel.error.subscribe(onNext: {[weak self] error in
            guard let self = self else {return}
            self.showAlert(title: "Error", message: error)
        }).disposed(by: disposeBag)
        
        viewModel.tempreture
            .bind(to: headerView.temperatureLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.cityName
            .bind(to: headerView.cityLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.weatherDescription
            .bind(to: headerView.conditionsLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.lowHighTemp
            .bind(to: headerView.hiloLabel.rx.text)
            .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter{ !$0.isEmpty }
            .subscribe(onNext: {[unowned self] query in
                self.viewModel.didSearchCity(with: query)
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            if let text = self.searchBar.text {
                text.isEmpty ?
                    self.searchResultsTableView.isHidden = true : self.viewModel.didSearchCity(with: text)
            }
            self.view.endEditing(true)
        }).disposed(by: disposeBag)
        
        viewModel.cities.bind(to: searchResultsTableView.rx.items) { (tableView, row, element) in
            let indexPath = IndexPath(row: row, section: 0)
            let cell = tableView.dequeueReusableCell(withIdentifier: "city_cell", for: indexPath) as! CityCell
            cell.textLabel?.text = element.name
            cell.textLabel?.textColor = .black
            return cell
        }.disposed(by: disposeBag)
        
        viewModel.cities
            .map {$0.count == 0}
            .bind(to: searchResultsTableView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.historyItems.bind(to: tableView.rx.items) { [unowned self] (tableView, row, element) in
            let indexPath = IndexPath(row: row, section: 0)
            var cell : UITableViewCell!
            cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier")
            if cell == nil {
                cell = UITableViewCell(style: .value1, reuseIdentifier: "CellIdentifier")
            }
            
            if indexPath.row == 0 {
                return self.makeSectionCell(cell: cell)
            }else{
                return self.makeNormalCell(cell: cell, element: element)
            }
        }.disposed(by: disposeBag)
        
        searchResultsTableView.rx.modelSelected(WeatherModel.self).subscribe(onNext: {[weak self] model in
            guard let self = self else { return }
            self.searchResultsTableView.isHidden = true
            self.viewModel.feedTableView(coordinate: Coordinate(latitude: model.coord?.lat ?? 0, longitude: model.coord?.lon ?? 0))
        }).disposed(by: disposeBag)
        
        searchResultsTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        
        
        
    }
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    private func makeNormalCell(cell: UITableViewCell, element: Current) -> UITableViewCell {
        cell.textLabel?.font = UIFont.init(name: "HelveticaNeue-Light", size: 18)
        cell.detailTextLabel?.font = UIFont.init(name: "HelveticaNeue-Light", size: 18)
        
        let df = DateFormatter()
        df.dateFormat = "hh:mm"
        let now = df.string(from: Date(timeIntervalSince1970: element.dt ?? 0))
        
        cell.textLabel?.text = now
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.text = String(format: "%.0f°", viewModel.toCelsius(kelvin: element.temp ?? 0))
        cell.detailTextLabel?.textColor = .white
        cell.detailTextLabel?.backgroundColor = .clear
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        return cell
    }
    
    private func makeSectionCell(cell: UITableViewCell) -> UITableViewCell {
        cell.textLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 18)
        cell.textLabel?.text = "Hourly Forecast"
        cell.backgroundColor = .clear
        return cell
    }
}

extension WeatherViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect.zero)
    }
}

extension WeatherViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            dismissKeyboard()
        }
    }
}
