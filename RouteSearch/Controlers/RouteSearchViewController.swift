//
//  RouteSearchViewController.swift
//  RouteSearch
//
//  Created by Александр Александров on 27.01.2022.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import SnapKit

class RouteSearchViewController: UIViewController {
    
    // Карта
    let mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    let addAdresButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "addAdress"), for: .normal)
        button.addTarget(self, action: #selector(addAdresButtonActions), for: .touchUpInside)
        return button
    }()
    
    let buildRouteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "route"), for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(buildRouteButtonActions), for: .touchUpInside)
        return button
    }()
    
    let clearMapButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "reset"), for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(clearMapButtonActions), for: .touchUpInside)
        return button
    }()
    
    var annotationsArray = [MKPointAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        mapView.delegate = self
        setView()
    }
    
    override func viewDidLayoutSubviews() {
        configurationsConctraints()
    }
    
    func setView() {
        view.addSubViews(views: [mapView, addAdresButton, buildRouteButton, clearMapButton])
    }
    
    // Установи точк на карте
    private func settingTheLabel(adres: String) {

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(adres) { [self] placemarks, error in
            if let error = error {
                print(error)
                errorAlert(title: "Ошибка", message: "Сервер не отвечет")
                return
            }

            // Проверка
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first

            // Строим анотацию
            let annotation = MKPointAnnotation()
            annotation.title = "\(adres)"

            // Координаты расположения
            guard let placemarkLocation = placemark?.location else { return }
            // Присвой координаты расположения
            annotation.coordinate = placemarkLocation.coordinate

            // Добавиь в массив выбранные координаты
            annotationsArray.append(annotation)

            // Появление кнопок (route, reset) при добалении 2х и болие точек на карту
            if annotationsArray.count > 2 {
                buildRouteButton.isHidden = false
                clearMapButton.isHidden = false
            }

            // Отобрази точки на карте
            mapView.showAnnotations(annotationsArray, animated: true)
        }
    }
    
    // Построй маршрут между точками
    private func plotRoute(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {

        // Начальна точка координат
        let startLocation = MKPlacemark(coordinate: startCoordinate)

        // Коекчная точка координат
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)

        // Запрос
        let request = MKDirections.Request()
        // Источник откуда начинать движение
        request.source = MKMapItem(placemark: startLocation)
        // Источник где заканчивает движение
        request.destination = MKMapItem(placemark: destinationLocation)
        // Движение пешком
        request.transportType = .walking
        // Покажи альтернативный маршрут
        request.requestsAlternateRoutes = true

        let diraction = MKDirections(request: request)

        diraction.calculate { response, error in
            if let error = error {
                print(error)
                return
            }

            guard let response = response else {
                self.errorAlert(title: "Ошибка", message: "Маршрут не доступен")
                return
            }

            // Минимальный маршрут
            var minRoute = response.routes[0]

            // Если несколько маршрутов проверь какой из них короче
            for item in response.routes {
                minRoute = (item.distance < minRoute.distance) ? item : minRoute
            }

            self.mapView.addOverlay(minRoute.polyline)
        }
    }
    
    @objc func addAdresButtonActions() {
        // При нажатии на кнопку вызыви алерт
        addAdressAlert(title: "Добавить", placeholder: "Введите адрес") { [self] text in
           // Вызови функцию для добавления адреса
            self.settingTheLabel(adres: text)
        }
    }
    
    @objc func buildRouteButtonActions() {
        // Пройди по массиву и построй маршрут
        for item in 0...annotationsArray.count - 2{
            plotRoute(startCoordinate: annotationsArray[item].coordinate, destinationCoordinate: annotationsArray[item + 1].coordinate)
        }
        
        // Отобрози маршрут на карте
        mapView.showAnnotations(annotationsArray, animated: true)
    }
    
    @objc func clearMapButtonActions() {
        
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotationsArray = [MKPointAnnotation]()
        buildRouteButton.isHidden = true
        clearMapButton.isHidden = true
    }
    
    func configurationsConctraints() {
        
        let addAdresButtonSize = CGSize(width: 100, height: 100)
        let buttonSize = CGSize(width: 120, height: 40)
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addAdresButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-20)
            make.size.equalTo(addAdresButtonSize)
        }
        
        
        buildRouteButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-60)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(buttonSize)
        }
        
        clearMapButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-60)
            make.trailing.equalToSuperview().offset(-20)
            make.size.equalTo(buttonSize)
        }
    }
}


extension RouteSearchViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        // Получи polyline
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        
        renderer.lineWidth = 3
        
        // Установи цвет маршрута
        renderer.strokeColor = .red
        
        return renderer
    }
}
