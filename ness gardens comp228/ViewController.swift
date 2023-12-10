//
//  ViewController.swift
//  ness gardens comp228
//
//  Created by Lewis, Henry on 10/12/2023.
//

import UIKit
import MapKit
import CoreLocation

struct PlantResponse: Codable{
    var plants: [Plant]
}

struct Plant: Codable{
    var recnum: String?
    var acid: String?
    var accsta: String?
    var family: String?
    var genus: String?
    var species: String?
    var infraspecific_epithet: String?
    var vernacular_name: String?
    var cultivar_name: String?
    var donor: String?
    var latitude: String?
    var longitude: String?
    var country: String?
    var iso: String?
    var sgu: String?
    var loc: String?
    var alt: String?
    var cnam: String?
    var cid: String?
    var cdat: String?
    var bed: String?
    var memoriam: String?
    var redlist: String?
    var last_modified: String?
    
}

struct BedResponse: Codable{
    var beds: [Bed]
}

struct Bed: Codable{
    var bed_id: String
    var name: String
    var latitude: String
    var longitude: String
    var last_modified: String
    
    
}

struct ImageInfoResponse: Codable{
    var images: [ImageInfo]
}

struct ImageInfo: Codable{
    var recnum: String
    var imgid: String
    var img_file_name: String
    var imgtitle: String
    var photodt: String
    var photonme: String
    var copy: String?
    var last_modified: String
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate{
    @IBOutlet weak var bedMap: MKMapView!
    @IBOutlet weak var bedTable: UITableView!
    
    var bedsArray = [Bed]()
    var plantsArray = [Plant]()
    var thumbnailArray = [String: UIImage]()
    var bedPlants = [String: String]()
    
    var selectedPlant = Plant()
    
    var locationManger = CLLocationManager()
    var firstRun = true
    var startTrackingUser = false
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        if firstRun{
            firstRun = false
            let latDelta: CLLocationDegrees = 0.0025
            let lonDelta: CLLocationDegrees = 0.0025
            
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            
            let region = MKCoordinateRegion(center: location, span: span)
            
            self.bedMap.setRegion(region, animated: true)
            
            
            
            let _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [self] _ in startTrackingUser = true}
        }
        
        if startTrackingUser{
            bedMap.setCenter(location, animated: true)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let plantsInBed = plantsArray.filter{$0.bed == bedsArray[section].bed_id}
        
        var plants = ""
        
        for element in plantsInBed{
            plants += "\(element.recnum!) "
        }
        
        bedPlants[bedsArray[section].name] = plants
        
        return plantsInBed.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return bedsArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (bedsArray[section].latitude != "" && bedsArray[section].longitude != ""){
            let marker = MKPointAnnotation()
            marker.title = bedsArray[section].name
            marker.coordinate = CLLocationCoordinate2D(latitude: Double(bedsArray[section].latitude)!, longitude: Double(bedsArray[section].longitude)!)
            bedMap.addAnnotation(marker)
        }
        
        
        
        return bedsArray[section].name
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let plant = bedPlants[bedsArray[indexPath.section].name]!.components(separatedBy: .whitespaces)
        selectedPlant = plantsArray.first(where: {$0.recnum == plant[indexPath.row]})!
     
        performSegue(withIdentifier: "toDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail"{
            let nextVC = segue.destination as! detailsViewController
            nextVC.plantDetails = selectedPlant
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! PlantTableViewCell
        var content = UIListContentConfiguration.cell()
        
        let plant = bedPlants[bedsArray[indexPath.section].name]!.components(separatedBy: .whitespaces)
        var plantInfo = plantsArray.first(where: {$0.recnum == plant[indexPath.row]})
        
        if plantInfo?.family == "" {plantInfo?.family = "n/a"}
        if plantInfo?.genus == "" {plantInfo?.genus = "n/a"}
        if plantInfo?.species == "" {plantInfo?.species = "n/a"}
            
            
        aCell.familyLabel?.text = "Family: \(plantInfo?.family ?? "n/a")"
        aCell.genusLabel?.text = "Genus: \(plantInfo?.genus ?? "n/a")"
        aCell.speciesLabel?.text = "Species: \(plantInfo?.species ?? "n/a")"
        
        
        if thumbnailArray[(plantInfo?.recnum)!] != nil{
            aCell.thumbnailImage?.image = thumbnailArray[(plantInfo?.recnum)!]
        }
        else{
            aCell.thumbnailImage?.image = nil
        }
        aCell.accessoryType = .disclosureIndicator
        
        return aCell
    }
    
    
    func updateBeds() async{
        let bedURL = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness/data.php?class=beds")!
        let plantURL = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness/data.php?class=plants")!
        
        do{
            let jsonDecoder = JSONDecoder()
            
            var (data,_) = try await URLSession.shared.data(from: plantURL)
            do{
                plantsArray = []
            
                let result = try jsonDecoder.decode(PlantResponse.self, from: data)
            
                plantsArray = result.plants.filter{$0.accsta == "C"}
          
            }
            catch DecodingError.keyNotFound(let key, _){print("plant key: \(key) not found ")}
            catch DecodingError.valueNotFound(let value, _){print("plant value: \(value) not found")}
            
            
            (data,_) = try await URLSession.shared.data(from: bedURL)
            do{
                bedsArray = []
                
                let result = try jsonDecoder.decode(BedResponse.self, from: data)
                
                bedsArray = result.beds.filter {element in plantsArray.contains{$0.bed == element.bed_id}}
                
            }
            catch DecodingError.keyNotFound(let key, _){print("bed key: \(key) not found ")}
            catch DecodingError.valueNotFound(let value, _){print("bed value: \(value) not found")}
            
      
            
        }
        catch{print("invalid data")}
        
    }
    
    func downloadThumbnails() async{
        var imageInformation = [ImageInfo]()
        let imageInfoURL = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness/data.php?class=images")!
        let jsonDecoder = JSONDecoder()
        
        do{
            var (data,_) = try await URLSession.shared.data(from: imageInfoURL)
            do{
                let result = try jsonDecoder.decode(ImageInfoResponse.self, from: data)
                imageInformation = result.images
                
            }
            catch DecodingError.keyNotFound(let key, _){print("image info key: \(key) not found ")}
            catch DecodingError.valueNotFound(let value, _){print("image info value: \(value) not found")}
           
            
        }
        catch{print("invalid data");return}
        
        do{
            var last300 = 300
            for element in 0...(imageInformation.count-1){
                let imageURL = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness_thumbnails/\(imageInformation[element].recnum)-ID1.jpg")!
                do{
                    let (data,_) = try await URLSession.shared.data(from: imageURL)
                    thumbnailArray[imageInformation[element].recnum] = UIImage(data: data)
                    
                    if element > last300{
                        last300 += 300
                        bedTable.reloadData()
                    }
                }
                catch{
                    
                }
            }
        }

    }
    
    func distanceCalc(){
        
    }
    
    
    override func viewDidLoad(){

        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Task {
            await updateBeds()
            await downloadThumbnails()
            bedTable.reloadData()
        }
        
        locationManger.delegate = self as CLLocationManagerDelegate
        locationManger.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()
        bedMap.showsUserLocation = true
        
    }


}

class PlantTableViewCell: UITableViewCell{
    
    @IBOutlet weak var familyLabel: UILabel!
    @IBOutlet weak var genusLabel: UILabel!
    @IBOutlet weak var speciesLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    
}
